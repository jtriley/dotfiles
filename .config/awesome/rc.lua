-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("wi")
require("cal")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
theme_path = awful.util.getdir("config") .. "/themes/dust/theme.lua"
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}
-- }}}

separator = widget({ type = "textbox" })
separator.text  = " :: "

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "|1-dev", "| 2-www", "| 3-email", "| 4-music", "| 5-chat  |"}, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
awesomemenu = {
    { "terminal",    terminal},
    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
    { "reload", awesome.restart, awful.util.getdir("config") .. "/icons/reload.png" },
    { "logout", awesome.quit, awful.util.getdir("config") .. "/icons/logout.png" },
}

networkmenu = {
    { "firefox",     "firefox" },
    { "firefox-bin", "firefox-bin" },
    { "chromium",    "chromium" },
    { "thunderbird", "thunderbird" },
    { "kmail",       "kmail" },
    { "pidgin",      "pidgin" },
    { "rtorrent",    terminal .. " -e rtorrent" }
}

officemenu = {
    { "writer",      "env GTK2_RC_FILES=/usr/share/themes/Clearlooks/gtk-2.0/gtkrc soffice -writer" },
    { "calc",        "env GTK2_RC_FILES=/usr/share/themes/Clearlooks/gtk-2.0/gtkrc soffice -calc" },
    { "impress",     "env GTK2_RC_FILES=/usr/share/themes/Clearlooks/gtk-2.0/gtkrc soffice -impress" },
}

editorsmenu = {
    { "vim",         terminal .. " -e vim" },
}

graphicsmenu = {
    { "gimp",        "gimp" },
    { "inkscape",    "inkscape" },
    { "gwenview",    "gwenview" }
}

mediamenu = {
    { "amarok",      "amarok" },
    { "vlc",         "vlc" },
    { "ncmpcpp",     terminal .. " -e ncmpcpp" },
    { "audacity",    "audacity" }
}

utilitiesmenu = {
    { "virtualbox",  "VirtualBox" },
}

monitormenu = {
    { "scroff",      "xrandr --output LVDS --off" },
    { "scron",       "xrandr --output LVDS --auto" },
    { "scrmax",      "xrandr --output VGA-0 --preferred" }
}

systemmenu = {
    { "nvidia settings", "nvidia-settings"},
    { "monitor",     monitormenu },
    { "htop",        terminal .. " -e htop" },
    { "kill",        "xkill" }
}

mainmenu = awful.menu({
    items = {
        { "network",   networkmenu },
        { "office",    officemenu },
        { "editors",   editorsmenu },
        { "graphics",  graphicsmenu },
        { "media",     mediamenu },
        { "utilities", utilitiesmenu },
        { "sytem",     systemmenu },
        --{ "awesome",   awesomemenu , }
        { "awesome", awesomemenu, awful.util.getdir("config") .. "/icons/awesomemenu-dust.png" },
    }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })
mytextclock = awful.widget.textclock({}, "<span color='#d6d6d6'>%a, %m/%d</span> @ %l:%M %p ")
cal.addCalendarToWidget(mytextclock, "<span color='green'>@</span>")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s], separator,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock, separator,
	weatherwidget, separator,
        --s == 1 and mysystray or nil, separator,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- Create the graphbox
    mygraphbox[s] = awful.wibox({ position = "bottom", height = 14, screen = s })
    mygraphbox[s].widgets = {
        mylayoutbox[s], separator, 
	cpuinfo, separator, thermalwidget, thermallabel, separator,
	cpugraph.widget, cpupct, separator, 
	cpugraph1.widget, cpupct1, separator,
	cpugraph2.widget, cpupct2, separator,
	cpugraph3.widget, cpupct3, separator,
	memused, membar.widget, mempct, separator,
	swapused, swapbar.widget, swappct, separator,
	myrootfsusedwidget, rootfsbar.widget, rootfspct, separator,
        --myhomefsusedwidget, homefsbar, homefspct, tab,
        --mydatafsusedwidget, datafsbar, datafspct, tab,
	txwidget, upgraph.widget, upwidget, separator,
	rxwidget, downgraph.widget, downwidget, separator,
        layout = awful.widget.layout.horizontal.leftright,
        {
            separator, s == 1 and mysystray or nil, separator,
            --myvolbarwidget, vollabel,
            --mailwidget, maillabel,
            --pacwidget, paclabel,
	    mpdwidget,separator, mpdlabel,
            layout = awful.widget.layout.horizontal.rightleft
        }
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    -- jtriley
    awful.key({ modkey, "Mod1"    }, "l", function () awful.util.spawn("xtrlock") end),
    awful.key({ modkey,           }, "f", function () awful.util.spawn("firefox") end),
    awful.key({ "Print",          }, "Print", function () awful.util.spawn("ksnapshot") end),
    awful.key({ "XF86Sleep",      }, "XF86Sleep", function () awful.util.spawn(terminal .. " -e sudo -k shutdown -h now") end),
    awful.key({ "XF86AudioMedia", }, "XF86AudioMedia", function () awful.util.spawn(terminal .. " -e ncmpcpp") end),
    awful.key({ modkey,           }, "g", function () awful.util.spawn("chromium --auto-ssl-client-auth") end),
    awful.key({ modkey,           }, "t", function () awful.util.spawn("zsh -c /home/jtriley/bin/terminator") end),
    awful.key({ modkey,           }, "p", function () awful.util.spawn("urxvt -e ipython") end),
    awful.key({  		  }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -c 0 set Headphone 2dB-") end),
    awful.key({  		  }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -c 0 set Headphone 2dB+") end),
    awful.key({  		  }, "XF86AudioMute", function () awful.util.spawn("amixer -c 0 set Headphone toggle") end),
    awful.key({  		  }, "XF86AudioNext", function () awful.util.spawn("ncmpcpp next") end),
    awful.key({  		  }, "XF86AudioPrev", function () awful.util.spawn("ncmpcpp prev") end),
    awful.key({  		  }, "XF86AudioPlay", function () awful.util.spawn("ncmpcpp toggle") end),
    awful.key({  		  }, "XF86AudioStop", function () awful.util.spawn("ncmpcpp stop") end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "z",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Timers
-- /tmp/weather
-- command adapted from Dave Taylor's "Wicked Cool Shell Scripts"
-- @ http://www.intuitive.com/wicked/showscript.cgi?063-weather.sh
zip_code = 02141
weatherhook = timer { timeout = 1800 }
weatherhook:add_signal("timeout", function()
    os.execute("wget -q -O - 'http://wwwa.accuweather.com/adcbin/public/local_index_print.asp?zipcode=" .. zip_code .."'".." | sed -n '/Start - Forecast Cell/,/End - Forecast Cell/p' | sed 's/<[^>]*>//g; s/^ [ ]*//g; s/&copy;/(c) /; s/&amp;/and/' | uniq | head -38 > /tmp/weather")
end)
weatherhook:start()
-- }}}
