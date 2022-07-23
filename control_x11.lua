require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Util = require('minilib.util')
local Ut   = Util
local Cfg  = require('mxctl.config')

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

local DISPLAYS = Cfg.displays

local DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %dx%d \
			--rotate normal \
			--pos %dx%d \
			%s
]]
local DISPLAY_OFF = [[
		xrandr \
			--output %s \
			--off
]]

local _CMD = {
	kb_led_on   = 'xset led on',
	kb_led_off  = 'xset led off',

	-- this stuff for openbox / floating win managers
	win_left    = 'xdotool getactivewindow windowmove 03% 02% windowsize 48% 92%',
	win_right   = 'xdotool getactivewindow windowmove 52% 02% windowsize 48% 92%',
	win_max     = 'wmctrl -r :ACTIVE: -b    add,maximized_vert,maximized_horz',
	win_unmax   = 'wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz',
	win_big     = 'xdotool getactivewindow windowmove 04% 04% windowsize 92% 92%',
	win_small   = 'xdotool getactivewindow windowmove 20% 20% windowsize 70% 50%',

	scr_cap     = 'import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	scr_cap_sel = 'import ~/Pictures/$(date +%Y%m%dT%H%M%S).png',

	-- scr_lock    = 'xlock -dpmsoff 60 -mode random -modelist swarm,pacman,molecule,hyper',
	scr_lock    = 'slock',
	autolockd_xautolock   = [[
		xautolock
			-time 3 -locker "mxctl.control scr_lock_if"
			-killtime 10 -killer "notify-send -u critical -t 10000 -- 'Killing system ...'"
			-notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking system ETA 30s ...'";
	]],
}


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
		Sh.sh(outgrid_ctl[d.name .. " on"])
	end
end

function Funs:tmenu_setup_video()
	local _, vgridctl = xrandr_configs()
	local opts = table.concat(Util:keys(vgridctl), '\n')

	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', opts))))
	.add(function(id)
		Sh.sh(vgridctl[id])
	end)
	.run()
end

function Funs:dmenu_setup_video()
	Sh.sh(pop_term(ctrl_bin("tmenu_setup_video")))
end

function Funs:tmenu_select_window()
	local ws = {}
	local wl = {}
	Pr.pipe()
	.add(Sh.exec('wmctrl -l'))
	.add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
	.add(function(arr)
		if arr then
			ws[arr[4]]= {id = arr[1], ws = arr[2], name = arr[4]}
			return arr[4]
		end
	end)
	.add(function(name)
		if name then
			table.insert(wl, name)
		end
	end)
	.run()

	local wl_opts = table.concat(wl, '\n')
	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', wl_opts))))
	.add(function(name)
		if name then
			Sh.sh('wmctrl -ia ' .. ws[name].id)
		end
	end)
	.run()
end
function Funs:dmenu_select_window()
	Sh.sh(pop_term(ctrl_bin("tmenu_select_window")))
end
function Funs:scr_lock_if()
	local iv = nil
	Pr.pipe()
		.add(Sh.exec('pactl list sinks'))
		.add(Sh.grep('RUNNING'))
		.add(Sh.echo())
		.add(function(x)
			if x then
				iv = x
			end
		end)
		.run()
	if iv == nil then
		Sh.sh(_CMD['scr_lock'])
	end
end
local _LOGOUT_CMD = {
	bspwm   = "bspc quit",
	i3wm    = "i3-msg exit",
	openbox = "openbox --exit",
	xmonad  = "",
}

function Funs:tmenu_exit()
   local wminf = Util:wminfo()
   local exit_with = {
	  lock      = _CMD["scr_lock"],
	  logout    = _LOGOUT_CMD[wminf.wm:lower()], 
	  suspend   = "systemctl suspend",
	  hibernate = "systemctl hibernate",
	  reboot    = "systemctl reboot",
	  shutdown  = "systemctl poweroff -i",
   }

   local opts = {}
   for k, _ in pairs(exit_with) do
	 table.insert(opts, k)
   end

   Pr.pipe()
	   .add(Sh.exec(menu_sel(string.format('echo "%s"',
	   		table.concat(opts, '\n')))))
	   .add(function(name)
		   if name then
			   if exit_with[name] ~= "" then
				   Sh.sh(exit_with[name])
			   else
				   print("no ", name, "for", wminf.wm)
			   end
		   end
		   return name
	   end)
	   .run()
end
function Funs:dmenu_exit()
   Sh.sh(pop_term(ctrl_bin("tmenu_exit")))
end

function brightness(delta)
	print("brightness", delta)
	Pr.pipe()
		.add(Sh.exec("ls /sys/class/backlight"))
		.add(function(bf)
			if bf then
				local max = tonumber(Ut:head_file("/sys/class/backlight/"..bf.."/max_brightness"))
				local cur = tonumber(Ut:head_file("/sys/class/backlight/"..bf.."/brightness"))
				local tar = math.floor(cur + delta*max/100)
				if tar > max then
					tar = max
				end
				if tar < 0 then
					tar = cur
				end
				print("brightness", delta, bf, cur, tar, max)
				local h = assert(io.open("/sys/class/backlight/"..bf.."/brightness", "w"))
				h:write(tar)
				h:close()
			end
		end)
		.run()
end

function Funs:brightness_up()
	brightness(10)
end

function Funs:brightness_down()
	brightness(-10)
end

for f,cmd in pairs(_CMD) do
	Funs[f] = function() 
		Sh.sh(cmd)
	end
end

return Funs
