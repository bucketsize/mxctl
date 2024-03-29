   return {
	  app_dirs = {
			-- "/usr/bin", -- too much
			"/usr/local/bin",
			"/usr/share/applications",
			"/snap/bin",
            "~/.local/share/applications"
		},
	  menu_sel = "fzf",
	  ctrl_bin = "~/.luarocks/bin/mxctl.control",
	  pop_term = {xorg="alacritty", wayland="alacritty"},
	  lux_step = 2,
      
      -- relative to $HOME
      wallpapermode = "folder", -- new|fixed|cycle|folder
      wallpaperscache = ".wlprs", 
      wallpaperfixd = "Pictures/wallpapertip_halo-master-chief-wallpaper_2221578.jpg",
      wallpapersdir = "Pictures",

	  displays = {
		 {
			name = 'Virtual-0',
			mode = {x=1280,y=720},
			pos = {0,0},
			extra_opts = '--primary --set underscan off'
		 },
		 {
			name = 'DisplayPort-0',
			mode = {x=1280,y=720},
			pos = {0,0},
			extra_opts = '--primary --set underscan off'
		 },
		 {
			name = 'eDP-1',
			mode = {x=1280, y=720},
			pos = {0,0},
			extra_opts = '--primary --set underscan off'
		 },
		 {
			name = 'HDMI-A-0',
			mode = {x=1280, y=720},
			pos = {0,0},
			extra_opts = '--primary --set underscan off'
		 },
		 {
			name = 'HDMI-A-1',
			mode = {x=1280, y=720},
			pos = {1,0},
			extra_opts = '--set underscan on --set "underscan hborder" 48 --set "underscan vborder" 24'
		 }
	  }
   }
