require "luarocks.loader"

local http_request = require("http.request")
local Util         = require("minilib.util")
local json         = require("minilib.json")
local Cfg          = require("mxctl.config")

local wlprs = os.getenv("HOME").."/.wlprs/"
math.randomseed(os.time())

function find(path)
    local h = assert(io.popen("find "..path.." -type f"))
    local t={}
    for i in h:lines() do
        print("found", i)
        table.insert(t, i)
    end
    return t
end

function randstr(length)
	local s = ""
	for i = 1, length do
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
            print(s)
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
        end
    }
}

function geturlonsuccess(url)
	local headers, stream, err = http_request
		.new_from_uri(url)
		:go()
    if err then
        print(string.format("Error get [%s]: %s, %s", url, err, status))
        return nil, err
    end
	if headers:get ":status" ~= "200" then
        print(string.format("Error get [%s]: %s, %s", url, err, status))
		return nil, "error: httpstatus = "..status
	end
    return stream, nil
end

local F = {}
function F:getwallpaper(provider)
    if not provider then provider = "bing" end
    if not urlr[provider] then 
        error("invalid provider: "..provider)
    end
    print("Using wallpaper provider:"..provider) 
    local pro = urlr[provider]
    local stream1, err1 = geturlonsuccess(pro.url())
    if err1 then
        print("Error on request:", err1)
        return
    end
    local body, err2 = stream1:get_body_as_string()
    if err2 then
        print("Error reading response:", err2)
        return
    end
	local url, name = pro.parse(body)
    print("wallpaper url:", url)
    print("wallpaper name:", name)

	local stream, err = geturlonsuccess(url)
    local file = io.open(wlprs..name, "w")
    local f, ferr, fcode = stream:save_body_to_file(file, 2)
    file:close()
    if ferr then
        print("Error saving file: ", ferr, fcode)
    end
    return wlprs..name
end

function F:selectwallpaper(dir)
    local wps = find(dir)
    return wps[math.random(1, #wps)]
end

function F:applywallpaper()
    local wp = ""
    if Cfg.wallpapermode == "new" then
        wp = F:getwallpaper()
    elseif Cfg.wallpapermode == "fixed" then
        wp = os.getenv("HOME").."/"..Cfg.wallpaperfixd
    elseif Cfg.wallpapermode == "folder" then
        wp = F:selectwallpaper(os.getenv("HOME").."/"..Cfg.wallpapersdir)
    else
        wp = F:selectwallpaper(wlprs)
    end
    print("applying wallpaper "..wp)
    assert(Util:exec("feh --bg-scale '"..wp.."'"))
end

return F
