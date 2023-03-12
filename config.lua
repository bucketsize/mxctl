local Sh = require("minilib.shell")
local Home = os.getenv("HOME")
local logger = require("minilib.logger").create()

local Cfg
if Sh.path_exists(Home.."/.config/mxctl/config") then
	--logger.info("config < existing")
	Cfg = loadfile(Home.."/.config/mxctl/config")()
else
	--logger.info("config < default")
	Cfg = require("mxctl.config0")
end

Cfg.termopts = {
	st 		= '-f monospace:size=10',
	stterm  = '-f monospace:size=10 -g 108x24'
}

Cfg.pop_termopts = {
   alacritty = '--class Popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e',
   xterm     = '-name Popeye -geom 64x16 -e',
   urxvt     = '-name Popeye -geometry 64x16 -e',
   urxvtc    = '-name Popeye -geometry 64x16 -e',
   st        = '-c Popeye -g 64x16 -e',
   stterm    = '-c Popeye -g 64x16 -e',
   qterminal = '--profile Popeye -e',
   foot      = '--app-id Popeye --title Popeye --window-size-chars 64x16'
}

function Cfg.get_renderer()
    local wl_dev = os.getenv("WAYLAND_DISPLAY")
    if wl_dev then
        print("get_renderer:", wl_dev)
		return "wayland"
	else
        print("get_renderer:", "xorg")
        return "xorg"
    end
end
function Cfg.get_pop_term()
	return Cfg.pop_term[Cfg.get_renderer()]
end
function Cfg.build_pop_term(cmd)
	local pop_term = Cfg.get_pop_term()
	if Cfg.termopts[pop_term] == nil then
		Cfg.termopts[pop_term] = ''
	end
	return string.format("%s %s %s %s", pop_term
		, Cfg.termopts[pop_term]
		, Cfg.pop_termopts[pop_term]
		, cmd)
end
function Cfg.build_term(t)
	if Cfg.termopts[t] == nil then
		Cfg.termopts[t] = ''
	end
	return string.format("%s %s", t
		, Cfg.termopts[t]
		, cmd)
end
function Cfg.build_menu_sel(lst)
	return string.format("%s | %s ", lst, Cfg.menu_sel)
end
function Cfg.build_ctrl_bin(cmd)
	return string.format("%s %s ",Cfg.ctrl_bin, cmd)
end

return Cfg
