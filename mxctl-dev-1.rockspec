package = "mxctl"
version = "dev-1"
source = {
   url = "."
}
description = {
   homepage = "",
   license = "EULA"
}
dependencies = {
   "lua >= 5.3",
   "minilib"
}
build = {
	type = "none",
	install = {
		lua = {
			["mxctl.config0"] = "config0.lua",
			["mxctl.config"] = "config.lua",
			["mxctl.control_cmds"] = "control_cmds.lua",
			["mxctl.control_process"] = "control_process.lua",
			["mxctl.control_pulseaudio"] = "control_pulseaudio.lua",
			["mxctl.control_x11"] = "control_x11.lua",
			["mxctl.control_app"] = "control_app.lua",
		},
		bin = {
			["mxctl.control"] = "control.lua",
			["mxctl.controld"] = "controld.lua"
		}
	}
}
