   return {
	  app_dirs = "/usr/local/bin /usr/share/applications",
	  menu_sel = "fzy",
	  ctrl_bin = "~/.luarocks/bin/mxctl.control",
	  pop_term = 'alacritty --class Popeye -t popeye -o window.dimensions.columns=64 -o window.dimensions.lines=16 -e ~/.luarocks/bin/mxctl.control',
	  --pop_term = 'lxterminal -t popeye --geometry=64x16 -e ~/.luarocks/bin/mxctl.control',
		--pop_term = ' xterm -class Popeye -geom 64x16 -e ~/.luarocks/bin/mxctl.control'

	  displays = {
		 {
			name = 'DisplayPort-0',
			mode = {x=1280,y=720},
			pos = {0,0},
			extra_opts = '--primary'
		 },
		 {
			name = 'HDMI-A-0',
			mode = {x=1280, y=720},
			pos = {1,0},
			extra_opts = '--set underscan on --set "underscan hborder" 48 --set "underscan vborder" 24'
		 }
	  }
   }
