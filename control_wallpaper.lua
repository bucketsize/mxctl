require "luarocks.loader"

local http_request = require("http.request")
local Util         = require("minilib.util")
local Cfg          = require("mxctl.config")
local Sh           = require("minilib.shell")
local Pr           = require("minilib.process")
local logger = require("minilib.logger").create()

local wlprs = os.getenv("HOME").."/.wlprs/"
math.randomseed(os.time())

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

function find(path)
    local h = assert(io.popen("find "..path.." -type f"))
    local t={}
    for i in h:lines() do
        -- logger.info("found", i)
        table.insert(t, i)
    end
    return t
end

function randstr(length)
	local s = ""
	for _ = 1, length do
		s = s .. string.char(math.random(97, 122))
	end
	return res
end
	
local urlr = {
    bing = { 
        url = function() 
            local s = "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=%s&n=1"
            return string.format(s, randstr(13))
        end,
        parse = function(s)
            logger.info(s)
            local s1, s2 = s:find("<url>"), s:find("</url>")
            local res = s:sub(s1+5, s2-1)
            local s3, s4 = res:find("id="), res:find("jpg")
            local name = res:sub(s3+3, s4+2)
            return "http://www.bing.com" .. res, name
        end
    },

    nasa = {
        url = function()
            return "https://api.nasa.gov/planetary/apod?api_key=cRFIBE5eZnucIQxhm3jJGJopmXDBTQsTkAQal6Qu&count=1"
        end,
        parse = function(s)
			logger.info("TODO %s", s)
        end
    }
}

function geturlonsuccess(url)
	local headers, stream, err = http_request
		.new_from_uri(url)
		:go()
    if err then
        logger.info("Error get [%s]: %s, %s", url, err)
        return nil, err
    end
	if headers:get ":status" ~= "200" then
        logger.info("Error get [%s]: %s, %s", url, err)
		return nil, "error: httpstatus = "..err
	end
    return stream, nil
end

local F = {}
function F:getwallpaper(provider)
    if not provider then provider = "bing" end
    if not urlr[provider] then 
        error("invalid provider: "..provider)
    end
    logger.info("Using wallpaper provider %s", provider) 
    local pro = urlr[provider]
    local stream1, err1 = geturlonsuccess(pro.url())
    if err1 then
        logger.info("Error on request %s", err1)
        return
    end
    local body, err2 = stream1:get_body_as_string()
    if err2 then
        logger.info("Error reading response %s", err2)
        return
    end
	local url, name = pro.parse(body)
    logger.info("wallpaper url  %s", url)
    logger.info("wallpaper name %s", name)

	local stream, err = geturlonsuccess(url)
    local file = io.open(wlprs..name, "w")
    local _, ferr, fcode = stream:save_body_to_file(file, 2)
    file:close()
    if ferr then
        logger.info("Error saving file %s, %s", ferr, fcode)
    end
    return wlprs..name
end

function F:selectwallpaper(dir)
    local wps = find(dir)
	if #wps == 0 then
		return F:applywallpaper()
	end
    return wps[math.random(1, #wps)]
end

function F:applywallpaper()
    local wp
    if Cfg.wallpapermode == "new" then
        wp = F:getwallpaper()
    elseif Cfg.wallpapermode == "fixed" then
        wp = os.getenv("HOME").."/"..Cfg.wallpaperfixd
    elseif Cfg.wallpapermode == "folder" then
        wp = F:selectwallpaper(os.getenv("HOME").."/"..Cfg.wallpapersdir)
    else
        wp = F:selectwallpaper(wlprs)
    end
    logger.info("applying wallpaper %s", wp)
    Sh.exec_cmd("feh --bg-scale '"..wp.."'")
end

function exec_select(eopts, fn)
   local labels = {}
   for k, _ in pairs(eopts) do
	 table.insert(labels, k) 
   end

   Pr.pipe()
	   .add(Sh.exec(menu_sel(string.format('echo "%s"',
	   		table.concat(labels, '\n')))))
	   .add(function(k)
		   if k then
			   logger.info("exec_select %s %s ", k, eopts[k])
			   fn(k, eopts[k])
		   end
		   return k
	   end)
	   .run()
end

function F:tmenu_set_wallpaper()
    local wps = {} 
	for k,v in pairs(find(wlprs)) do
		wps[string.format("%d: %s", k, Sh.basename(v))] = v
	end
	exec_select(wps, function(k, wp)
		Sh.exec_cmd("feh --bg-scale '"..wp.."'")
	end)
end

function F:dmenu_set_wallpaper()
	Sh.sh(pop_term(ctrl_bin("tmenu_set_wallpaper")))
end

return F
