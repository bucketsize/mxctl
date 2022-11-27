#!/usr/bin/env lua

package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Util = require("minilib.util")
local Ctl  = require("control_cmd")

function test_control_tmenu_misc()
	Ctl.tmenu_misc()
end

os.exit( luaunit.LuaUnit.run() )
