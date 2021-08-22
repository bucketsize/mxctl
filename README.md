# mxctl

## dependencies
- lua >= 5.1
- luarocks

## install
Clone this repo, and from toplevel:

`luarocks make --local #installs to ~/.luarocks`

Then bind to shortcut in any WM or VT
`~/.luarocks/bin/control fun dmenu_run #for WM`
`~/.luarocks/bin/control fun tmenu_run #for VT`

To list all supported functionality
`> ~/.luarocks/bin/control help`

## uninstall
`luarocks remove mxctl --local #removes from ~/.luarocks`
