--
-- Widgets file
--

require("vicious")
require("beautiful")

bg_widget = "#333333"
fg_widget = "#908884"

tab = widget({ type = "textbox" })
tab.text = "       "

-- {{{ MEMORY
-- used
memused = widget({ type = "textbox" })
vicious.cache(vicious.widgets.mem)
vicious.register(memused, vicious.widgets.mem, "<span color='#d6d6d6'>RAM </span>$2MB", 5)

-- bar
membar = awful.widget.progressbar()
membar:set_width(40)
membar:set_height(12)
membar:set_border_color(bg_widget)
membar:set_background_color(bg_widget)
membar:set_gradient_colors({ fg_widget, bg_widget })
vicious.register(membar, vicious.widgets.mem, "$1", 5)

-- %
mempct = widget({ type = "textbox" })
vicious.register(mempct, vicious.widgets.mem, "$1%", 5)
-- }}}

--{{{ SWAP
-- used
swapused = widget({ type = "textbox" })
vicious.register(swapused, vicious.widgets.mem, "<span color='#d6d6d6'>SWAP </span>$6MB", 10) 

-- bar
swapbar = awful.widget.progressbar()
swapbar:set_width(40)
swapbar:set_height(12)
swapbar:set_border_color(bg_widget)
swapbar:set_background_color(bg_widget)
swapbar:set_gradient_colors({ fg_widget, bg_widget })
vicious.register(swapbar, vicious.widgets.mem, "$5", 10) 

-- %
swappct = widget({ type = "textbox" })
vicious.register(swappct, vicious.widgets.mem, "$5%", 10) 
-- }}}

-- {{{ PROCESSOR
-- cpu0 info
cpuinfo = widget({ type = "textbox" })
vicious.register(cpuinfo, vicious.widgets.cpuinf, "<span color='#d6d6d6'>CPU </span>${cpu0 ghz}GHz")

-- cpu0 graph
cpugraph = awful.widget.graph()
vicious.cache(vicious.widgets.cpu)
cpugraph:set_width(40)
cpugraph:set_height(12)
cpugraph:set_background_color(bg_widget)
cpugraph:set_border_color(bg_widget)
cpugraph:set_gradient_colors({ fg_widget, bg_widget })
cpugraph:set_gradient_angle(180)
vicious.register(cpugraph, vicious.widgets.cpu, "$2")

-- cpu0 %
cpupct = widget({ type = "textbox" })
vicious.register(cpupct, vicious.widgets.cpu, "$2%", 2)

-- cpu1 graph
cpugraph1 = awful.widget.graph()
cpugraph1:set_width(40)
cpugraph1:set_height(12)
cpugraph1:set_background_color(bg_widget)
cpugraph1:set_border_color(bg_widget)
cpugraph1:set_gradient_colors({ fg_widget, bg_widget })
cpugraph1:set_gradient_angle(180)
vicious.register(cpugraph1, vicious.widgets.cpu, "$3")

-- cpu1 %
cpupct1 = widget({ type = "textbox" })
vicious.register(cpupct1, vicious.widgets.cpu, "$3%", 2)

-- cpu2 graph
cpugraph2 = awful.widget.graph()
cpugraph2:set_width(40)
cpugraph2:set_height(12)
cpugraph2:set_background_color(bg_widget)
cpugraph2:set_border_color(bg_widget)
cpugraph2:set_gradient_colors({ fg_widget, bg_widget })
cpugraph2:set_gradient_angle(180)
vicious.register(cpugraph2, vicious.widgets.cpu, "$4")

-- cpu2 %
cpupct2 = widget({ type = "textbox" })
vicious.register(cpupct2, vicious.widgets.cpu, "$4%", 2)

-- cpu3 graph
cpugraph3 = awful.widget.graph()
cpugraph3:set_width(40)
cpugraph3:set_height(12)
cpugraph3:set_background_color(bg_widget)
cpugraph3:set_border_color(bg_widget)
cpugraph3:set_gradient_colors({ fg_widget, bg_widget })
cpugraph3:set_gradient_angle(180)
vicious.register(cpugraph3, vicious.widgets.cpu, "$5")

-- cpu2 %
cpupct3 = widget({ type = "textbox" })
vicious.register(cpupct3, vicious.widgets.cpu, "$5%", 2)

-- }}}

-- {{{ WEATHER
weatherwidget = widget({ type = "textbox" })
weatherwidget.width=150
vicious.register(weatherwidget, vicious.widgets.weather, "<span color='#d6d6d6'>${sky}</span> @ ${tempf}°F on", 1200, "KBOS")

function get_forecast(mode)
    local s, cutoff
    if mode == "quick" then
        s = " | sed 's/Tomorrow Night/.../'"
        cutoff = "/Tomorrow Night/"
    elseif mode == "full" then
        s = ""
        cutoff = 38
    end

    local fp = io.popen("sed -n '1," .. cutoff .. "p' /tmp/weather" .. s)
    local forecast = fp:read("*a")
    fp:close()

    return forecast
end

-- buttons
weatherwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
        naughty.notify { text = get_forecast("quick"), timeout = 5, hover_timeout = 0.5 }
    end),
    awful.button({ }, 2, function ()
        awful.util.spawn(browser .. " http://www.accuweather.com/us/ma/cambridge/02141/city-weather-forecast.asp?partner=accuweather&u=1&traveler=0", false)
        awful.tag.viewonly(tags[1][2])
    end),
    awful.button({ }, 3, function ()
        naughty.notify { text = get_forecast("full"), timeout = 10, hover_timeout = 0.5 }
    end)))
-- }}}

-- {{{ MPD
mpdlabel = widget({ type = "imagebox" })
mpdlabel.image = image(awful.util.getdir("config") .. "/icons/dust/mpd2.png")
mpdspacer = widget({ type = "textbox" })
mpdspacer.text = "<span color='#222222'> </span>"
mpdspacer.bg = "#908884"

-- current song
mpdwidget = widget({ type = "textbox" })
--mpdwidget.bg = "#908884"

vicious.register(mpdwidget, vicious.widgets.mpd,
  function (widget, args)
    if   args["{state}"] == "Stop" then return '<span color="white">MPD:</span> None'
    else return '<span color="white">MPD:</span> '..
           args["{Artist}"]..' - '.. args["{Title}"]
    end
  end)

mpc_cmd = "ncmpcpp"
-- buttons
mpdwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn(mpc_cmd .. " next", false) end),
    awful.button({ }, 2, function () awful.util.spawn(mpc_cmd .. " toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn(mpc_cmd .. " prev", false) end)))
mpdlabel:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn(mpc_cmd .. " next", false) end),
    awful.button({ }, 2, function () awful.util.spawn(mpc_cmd .. " toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn(mpc_cmd .. " prev", false) end)))
-- }}}


--{{{ NETWORK
-- tx
txwidget = widget({ type = "textbox" })
vicious.cache(vicious.widgets.net)
vicious.register(txwidget, vicious.widgets.net, "<span color='#d6d6d6'>UP </span>${eth0 tx_mb}MB", 15)

-- up graph
upgraph = awful.widget.graph()
upgraph:set_width(40)
upgraph:set_height(12)
upgraph:set_background_color(bg_widget)
upgraph:set_border_color(bg_widget)
upgraph:set_gradient_colors({ fg_widget, bg_widget })
upgraph:set_gradient_angle(180)
vicious.register(upgraph, vicious.widgets.net, "${eth0 up_kb}")

-- up speed
upwidget = widget({ type = "textbox" })
vicious.register(upwidget, vicious.widgets.net, "${eth0 up_kb}k/s", 2)

-- rx
rxwidget = widget({ type = "textbox" })
vicious.register(rxwidget, vicious.widgets.net, "<span color='#d6d6d6'>DOWN </span>${eth0 rx_mb}MB", 15)

-- down graph
downgraph = awful.widget.graph()
downgraph:set_width(40)
downgraph:set_height(12)
downgraph:set_background_color(bg_widget)
downgraph:set_border_color(bg_widget)
downgraph:set_gradient_colors({ fg_widget, bg_widget })
downgraph:set_gradient_angle(180)
vicious.register(downgraph, vicious.widgets.net, "${eth0 down_kb}")

-- down speed
downwidget = widget({ type = "textbox" })
vicious.register(downwidget, vicious.widgets.net, "${eth0 down_kb}k/s", 2)
-- }}}

-- {{{ ROOT FILESYSTEM
-- used
myrootfsusedwidget = widget({ type = "textbox" })
vicious.cache(vicious.widgets.fs)
vicious.register(myrootfsusedwidget, vicious.widgets.fs, "<span color='#d6d6d6'>ROOTFS </span>${/ used_gb}GB", 90)

-- bar
rootfsbar = awful.widget.progressbar()
rootfsbar:set_width(40)
rootfsbar:set_height(12)
rootfsbar:set_border_color(bg_widget)
rootfsbar:set_background_color(bg_widget)
rootfsbar:set_gradient_colors({ fg_widget, bg_widget })
vicious.register(rootfsbar, vicious.widgets.fs, "${/ used_p}", 90)

-- %
rootfspct = widget({ type = "textbox" })
vicious.register(rootfspct, vicious.widgets.fs, "${/ used_p}%", 90)
-- }}}

-- {{{ THERMAL
temp_img = awful.util.getdir("config") .. "/icons/dust/temp.png"
thermallabel= widget({ type = "imagebox" })
thermallabel.image = image(temp_img)

-- cpu temp
thermalwidget = widget({ type = "textbox" })
vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 30, {"coretemp.0", "core"})
-- }}}
