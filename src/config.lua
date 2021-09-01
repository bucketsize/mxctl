local Util = require("minilib.util")
local Home = os.getenv("HOME")

local Cfg
if Util:file_exists(Home.."/.config/mxctl/config") then
   Cfg = loadfile(Home.."/.config/mxctl/config")()
else
   Cfg = require("mxctl.config0")
end

Cfg.pop_termopts = {
   alacritty = '-t Popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e ~/.luarocks/bin/mxctl.control',
   lxterminal = '-t Popeye --geometry=64x16 -e ~/.luarocks/bin/mxctl.control',
   xterm = '-title Popeye -geom 64x16 -e ~/.luarocks/bin/mxctl.control',
   urxvt = '-title Popeye -geometry 64x16 -e ~/.luarocks/bin/mxctl.control'
}

function Cfg:build_pop_term()
   if not Cfg.pop_termopts[Cfg.pop_term] then
      print("bad pop_term in config")
      print(".. using `urxvt` please install")
      Cfg.pop_term = "urxvt"
   end
   return string.format("%s %s", Cfg.pop_term, Cfg.pop_termopts[Cfg.pop_term])
end

return Cfg

