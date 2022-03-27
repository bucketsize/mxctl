#!/usr/bin/env lua

require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')

function mergeWith(f, t)
   for k, v in pairs(t) do
	  f[k] = v
   end
   return f
end

local Funs = {}
mergeWith(Funs, require('mxctl.control_cmds'))
mergeWith(Funs, require('mxctl.control_x11'))
mergeWith(Funs, require('mxctl.control_app'))
mergeWith(Funs, require('mxctl.control_pulseaudio'))
mergeWith(Funs, require('mxctl.control_wallpaper'))

------------------------------------------------------
local Fn = {}
function Fn:fun(key)
   local cmd = Funs[key]
   if cmd then
      cmd = Funs[key]()
      if cmd then
	 if type(cmd) == 'table' then
	    for i,icmd in ipairs(cmd) do
	       Util:exec(icmd)
	    end
	 else
	    Util:exec(cmd)
	 end
      end
   else
      print('cmd: ', key, 'not mapped')
   end
end
function Fn:help()
   print("fun")
   for k,v in pairs(Funs) do
      print('\t',k)
   end
end

local fn = Fn[arg[1]]
if fn == nil then
   print('huh!')
else
   fn(fn, arg[2])
end

return {Funs = Funs }
