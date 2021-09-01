require "luarocks.loader"

local Config = require("mxctl.config")
local Cmds = {
	vol_up      = 'pactl set-sink-volume @DEFAULT_SINK@ +10%',
	vol_down    = 'pactl set-sink-volume @DEFAULT_SINK@ -10%',
	vol_mute    = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	vol_unmute  = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',

	scr_lock    = 'xlock -dpmsoff 60 -mode random -modelist swarm,pacman,molecule,hyper',

	scr_cap     = 'import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	scr_cap_sel = 'import ~/Pictures/$(date +%Y%m%dT%H%M%S).png',

	-- this stuff for openbox / floating win managers
	win_left    = 'xdotool getactivewindow windowmove 03% 02% windowsize 48% 92%',
	win_right   = 'xdotool getactivewindow windowmove 52% 02% windowsize 48% 92%',
	win_max     = 'wmctrl -r :ACTIVE: -b    add,maximized_vert,maximized_horz',
	win_unmax   = 'wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz',
	win_big     = 'xdotool getactivewindow windowmove 04% 04% windowsize 92% 92%',
	win_small   = 'xdotool getactivewindow windowmove 20% 20% windowsize 70% 50%',

	kb_led_on   = 'xset led on',
	kb_led_off  = 'xset led off',

	autolockd_xautolock   = [[
		xautolock
			-time 3 -locker "~/scripts/sys_mon/control.lua fun scr_lock_if"
			-killtime 10 -killer "notify-send -u critical -t 10000 -- 'Killing system ...'"
			-notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking system ETA 30s ...'";
	]],
}

return Cmds
