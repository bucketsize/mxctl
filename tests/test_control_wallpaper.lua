#!/usr/bin/env lua

package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Util = require("minilib.util")
local Ctl  = require("control_wallpaper")

function test_control_tmenu_set_wallpaper()
	Ctl.tmenu_set_wallpaper()
end

os.exit( luaunit.LuaUnit.run() )
