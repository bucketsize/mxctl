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
   alacritty = '--class Popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e ',
   xterm     = '-name Popeye -geom 64x16 -e ',
   urxvt     = '-name Popeye -geometry 64x16 -e ',
   foot      = '--app-id Popeye --title Popeye --window-size-chars 64x16 '
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

if not Cfg.pop_termopts[Cfg.pop_term] then
	print("not supporting "..Cfg.pop_term)
	print(".. using `urxvt` please install")
	Cfg.pop_term = "urxvt"
end
function Cfg.build_pop_term(cmd)
	return string.format("%s %s %s", Cfg.pop_term, Cfg.pop_termopts[Cfg.pop_term], cmd)
end
function Cfg.build_menu_sel(lst)
	return string.format("%s | %s ", lst, Cfg.menu_sel)
end
function Cfg.build_ctrl_bin(cmd)
	return string.format("%s fun %s ",Cfg.ctrl_bin, cmd)
end

return Cfg

