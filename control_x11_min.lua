local Sh   = require('minilib.shell')

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

local Funs = {}
for f,cmd in pairs(_CMD) do
	Funs[f] = function() 
		Sh.exec_cmd(cmd)
	end
	Funs[f.."_cmd"] = function() 
		return cmd
	end
end

return Funs
