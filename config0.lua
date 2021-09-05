   return {
	  app_dirs = {
			"/usr/local/bin",
			"/usr/share/applications"
		},
	  menu_sel = "fzy",
	  ctrl_bin = "mxctl.control",
	  pop_term = 'urxvt',

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
