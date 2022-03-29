require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Cmds = require('mxctl.control_cmds')
local Cfg = require('mxctl.config')

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

DISPLAYS = Cfg.displays

DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %dx%d \
			--rotate normal \
			--pos %dx%d %s
]]
DISPLAY_OFF = [[
		xrandr \
			--output %s \
			--off
]]

function xrandr_info()
	local h = assert(io.popen("xrandr -q"))
	local ots = {}

	local ot
	for line in h:lines() do
		local otc = line:match("^([%w-]+) connected ")
		if otc then
			ot = otc
			if ots[ot] == nil then
				ots[ot] = {modes={}}
			end
		else
			if ot then
				local mx, my = string.match(line, "%s+(%d+)x(%d+)")
				if my then
					table.insert(ots[ot].modes, {x=mx, y=my})
					-- print(ot, mx, my)
				end
			end
		end
	end
	h:close()
	return ots
end

function get2dElem(t, i, j)
	if t[i] == nil then
		return nil
	else
		return t[i][j]
	end
end

function getElem(t, indexes)
	if indexes[1] == nil then
		return nil
	else
		if indexes[2] == nil then
			return t
		else
			return getElem(t[indexes[1]], {})
		end
	end
end

function outgrid_config(outgrid, d, o)
   if o then
	  local mode = o.modes[1]
	  for _,m in ipairs(o.modes) do
		 --print("?y", m.x, m.y, d.mode, type(m.y), type(d.mode))
		 if (tonumber(m.y) == d.mode.y) and (tonumber(m.x) == d.mode.x) then
			--print("configure", d.name, d.pos[1], d.pos[2])
			mode = m
			break
		 end
	  end
	  o.name = d.name
	  o.mode = mode
	  o.pos = d.pos
	  o.extra_opts = d.extra_opts
	  outgrid[d.pos[1]] = {}
	  outgrid[d.pos[1]][d.pos[2]] = o
   end
end

function outgrid_controls_config(outgrid, outgrid_ctl, d, o0)
   local x, y = d.pos[1], d.pos[2]
   local o = get2dElem(outgrid, x, y)
   if o then
	  local off_xo, off_yo = get2dElem(outgrid, x-1, y), get2dElem(outgrid, x, y-1)
	  local off_x, off_y
	  if off_xo == nil then
		 off_x = 0
	  else
		 off_x = off_xo.mode.x * d.pos[1]
	  end
	  if off_yo == nil then
		 off_y = 0
	  else
		 off_y = off_xo.mode.y * d.pos[2]
	  end

	  local dOn = string.format(DISPLAY_ON
								, o.name
								, o.mode.x, o.mode.y
								, off_x, off_y
								, o.extra_opts)
	  local dOff = string.format(DISPLAY_OFF, o.name)

	  outgrid_ctl[d.name .. " on"]  = dOn
	  outgrid_ctl[d.name .. " off"] = dOff
   end
end


function xrandr_configs()
   local outputs = xrandr_info()
   local outgrid = {}
   for _,d in ipairs(DISPLAYS) do
	  -- print("configure", i, d.name)
	  local o = outputs[d.name]
	  outgrid_config(outgrid, d, o)
   end

   local outgrid_ctl = {}
   for _,d in ipairs(DISPLAYS) do
	  outgrid_controls_config(outgrid, outgrid_ctl, d, o)
   end
   return outgrid, outgrid_ctl
end

local Funs = {}
function Funs:setup_video()
	local _, outgrid_ctl = xrandr_configs()
	for _,d in ipairs(DISPLAYS) do
		Util:exec(outgrid_ctl[d.name .. " on"])
	end
end

function Funs:tmenu_setup_video()
	local _, vgridctl = xrandr_configs()
	local opts = ""
	for k, cmd in pairs(vgridctl) do
		opts = opts .. string.format("%s", k) .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', opts))))
	.add(function(id)
		Util:exec(vgridctl[id])
	end)
	.run()
end

function Funs:dmenu_setup_video()
	Util:exec(pop_term(ctrl_bin("tmenu_setup_video")))
end

function Funs:tmenu_select_window()
	local ws = {}
	local wl = ''
	Pr.pipe()
	.add(Sh.exec('wmctrl -l'))
	.add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
	.add(function(arr)
		ws[arr[4]]= {id = arr[1], ws = arr[2], name = arr[4]}
		return arr[4]
	end)
	.add(function(name)
		wl = wl .. name .. '\n'
	end)
	.run()

	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', wl))))
	.add(function(name)
		Util:exec('wmctrl -ia ' .. ws[name].id)
	end)
	.run()
end
function Funs:dmenu_select_window()
	Util:exec(pop_term(ctrl_bin("tmenu_select_window")))
end
function Funs:scr_lock_if()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sink-inputs'))
		.add(Sh.grep('state: RUNNING.*'))
		.add(Sh.echo())
		.run()
	print("audio live:", iv)
  if iv == nil then
		return Cmds['scr_lock']
	end
end
function wm_info()
   local h = assert(io.popen("wmctrl -m"))
   local wm
   for line in h:lines() do
	  wm = line:match("Name:%s(%w+)")
	  if wm then break end
   end
   return {wm=wm}
end

function Funs:tmenu_exit()
   local wminf = wm_info()
   local wxitf = ""
   if wminf.wm == 'bspwm' then
	  wxitf = "bspc quit"
   end
   if wminf.wm == 'i3wm' then
	  wxitf = "i3-msg exit"
   end

   local exit_with = {
	  lock = Cmds["scr_lock"],
	  logout = wxitf,
	  suspend = "systemctl suspend",
	  hibernate = "systemctl hibernate",
	  reboot = "systemctl reboot",
	  shutdown = "systemctl poweroff -i"
   }

   local opts = ""
   for k, _ in pairs(exit_with) do
	  opts = opts .. k .. "\n"
   end

   Pr.pipe()
	  .add(Sh.exec(menu_sel(string.format('echo "%s"', opts))))
	  .add(function(name)
			Util:exec(exit_with[name])
		  end)
	  .run()
end
function Funs:dmenu_exit()
   Util:exec(pop_term(ctrl_bin("tmenu_exit")))
end

return Funs
