local Util = require("minilib.util")
local Home = os.getenv("HOME")

local Cfg
if Util:file_exists(Home.."/.config/mxctl/config") then
   Cfg = loadfile(Home.."/.config/mxctl/config")()
else
   Cfg = require("mxctl.config0")
end

Cfg.pop_termopts = {
   alacritty = '--class Popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e '..Cfg.ctrl_bin,
   xterm = '-name Popeye -geom 64x16 -e '..Cfg.ctrl_bin,
   urxvt = '-name Popeye -geometry 64x16 -e '..Cfg.ctrl_bin,
}

function Cfg:build_pop_term()
    if not Cfg.pop_termopts[Cfg.pop_term] then
        print("not supporting "..Cfg.pop_term)
        print(".. using `urxvt` please install")
        Cfg.pop_term = "urxvt"
    end
    return string.format("%s %s", Cfg.pop_term, Cfg.pop_termopts[Cfg.pop_term])
end

return Cfg
