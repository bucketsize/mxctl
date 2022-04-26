#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test()
	for i,j in pairs(Ctl.Funs) do
		print(i, j)
	end
end

test()
