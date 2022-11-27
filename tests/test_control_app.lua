#!/usr/bin/env lua

package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Util = require("minilib.util")
local Ctl  = require("control_app")

function test_list()
   assert(Ctl.find)
end

function test_findapps()
    local apps = Ctl.find()
    table.sort(apps, function(a, b)
        return a < b
    end)
	assert(Util:size(apps) > 0)
end

function test_parsedesktopfile()
   local app = Ctl.parsedesktopfile(nil, "tests/res/URxvtc.desktop")
   assert(app)
end

function test_tmenu_run()
   local app = Ctl.tmenu_run()
end

os.exit( luaunit.LuaUnit.run() )
