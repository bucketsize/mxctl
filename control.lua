#!/usr/bin/env lua

require "luarocks.loader"

local Util = require('minilib.util')

function mergeWith(f, t)
   for k, v in pairs(t) do
	  f[k] = v
   end
   return f
end

local Fn = {}
mergeWith(Fn, require('mxctl.control_power'))
mergeWith(Fn, require('mxctl.control_x11'))
mergeWith(Fn, require('mxctl.control_app'))
mergeWith(Fn, require('mxctl.control_cmd'))
mergeWith(Fn, require('mxctl.control_pulseaudio'))
mergeWith(Fn, require('mxctl.control_wallpaper'))

------------------------------------------------------
function Fn:help()
   for k,_ in pairs(Fn) do
      print('\t', k)
   end
end

local fn = Fn[arg[1]]
if fn == nil then
   print('huh!')
else
   fn(arg[2])
end
