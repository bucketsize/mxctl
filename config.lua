local Util = require("minilib.util")
local Sh = require("minilib.shell")
local Home = os.getenv("HOME")

local Cfg
if Sh.path_exists(Home.."/.config/mxctl/config") then
    print("config < existing")
   Cfg = loadfile(Home.."/.config/mxctl/config")()
else
    print("config < default")
   Cfg = require("mxctl.config0")
end

Cfg.pop_termopts = {
   alacritty = '--class Popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e '..Cfg.ctrl_bin,
   xterm = '-name Popeye -geom 64x16 -e '..Cfg.ctrl_bin,
   urxvt = '-name Popeye -geometry 64x16 -e '..Cfg.ctrl_bin,
   foot = '--app-id Popeye --title Popeye --window-size-chars 64x16 '..Cfg.ctrl_bin,
}

function Cfg:get_renderer()
    local xs_dev = os.getenv("DISPLAY")
    local wl_dev = os.getenv("WAYLAND_DISPLAY")
    if wl_dev == "" then
        return "wayland", wl_dev, xs_dev
    else
        return "xorg", xs_dev
    end
end

function Cfg:build_pop_term()
    if not Cfg.pop_termopts[Cfg.pop_term] then
        print("not supporting "..Cfg.pop_term)
        print(".. using `urxvt` please install")
        Cfg.pop_term = "urxvt"
    end
    return string.format("%s %s", Cfg.pop_term, Cfg.pop_termopts[Cfg.pop_term])
end

return Cfg

