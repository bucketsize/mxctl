#!/usr/bin/env lua

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl = require("mxctl.control")

function test_list()
   assert(Ctl.Funs.find)
end

function test_findapps()
   Ctl.Funs.find()
end

function test_parsedesktopfile()
   parsedesktopfile = Ctl.Funs['parsedesktopfile']
   parsedesktopfile(nil, "/usr/share/applications/chromium-browser.desktop")
end

test_list()
test_findapps()
test_parsedesktopfile()
