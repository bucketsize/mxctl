#!/usr/bin/env lua

package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Util = require("minilib.util")
local Ctl  = require("control_pulseaudio")

function test_dmenu_select_pa_sinks()
	Ctl.tmenu_select_pa_sinks()
end

os.exit( luaunit.LuaUnit.run() )
