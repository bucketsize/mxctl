local Util = require("minilib.util")
local Home = os.getenv("HOME")

local Cfg
if Util:file_exists(Home.."/.config/mxctl/config") then
   Cfg = loadfile(Home.."/.config/mxctl/config")()
else
   Cfg = require("mxctl.config0")
end

return Cfg

