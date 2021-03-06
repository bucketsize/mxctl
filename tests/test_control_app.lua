#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test_list()
   assert(Ctl.Funs.find)
end

function test_findapps()
    local apps = Ctl.Funs.find()
    table.sort(apps, function(a, b)
        return a < b
    end)
	assert(Util:size(apps) > 0)
end

function test_parsedesktopfile()
   local app = Ctl.Funs.parsedesktopfile(nil, "tests/res/URxvtc.desktop")
   assert(app)
end

function test_dmenu_run()
   local app = Ctl.Funs.tmenu_run()
end

test_list()
test_findapps()
test_parsedesktopfile()
test_dmenu_run()
