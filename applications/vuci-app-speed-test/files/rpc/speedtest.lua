local M = {}

local cURL = require("cURL")

function M.getLocation(params)
	headers = {
		"Accept: text/*",
		"Accept-Language: en",
		"Accept-Charset: iso-8859-1,*,utf-8",
		"Cache-Control: no-cache"
	}
		
	c = cURL.easy{
		url            = "http://ipwhois.app/json/",
		ssl_verifypeer = false,
		ssl_verifyhost = false,
		httpheader     = headers,
		writefunction  = function(str)
			succeed = succeed or (string.find(str, "srcId:%s+SignInAlertSupressor--"))
			params.result = str
		end
	}
	c:perform()
	params.response = c:getinfo_response_code()
	return params
end

function M.getServerList(params)
	headers = {
		"Accept: application/xml",
		"Accept-Language: en",
		"Accept-Charset: iso-8859-1,*,utf-8",
		"Cache-Control: no-cache"
	}
		
	c = cURL.easy{
		url            = "https://gist.githubusercontent.com/autos/6f11ffa74a414fa58d4587a77d1f7ea7/raw/63bcfe0889798653d679be6fc17efc3f60dc4714/speedtest.php",
		ssl_verifypeer = false,
		ssl_verifyhost = false,
		httpheader     = headers,
		writefunction  = function(str)
			succeed = succeed or (string.find(str, "srcId:%s+SignInAlertSupressor--"))
			params.result = str
		end
	}
	c:perform()
	params.response = c:getinfo_response_code()
	return params
end

function M.readFile(params)
  local arr = {}

	local count = 1

	local lines = {}
	for line in io.lines("/tmp/serverlist2.txt") do
			if count >= params.from and count <= params.to then
				lines[#lines+1] = line
			end
			count = count+1
	end
	return lines
end

function M.readAllFile(params)
  local arr = {}

	local path = "/tmp/serverlist.txt"

	local f = io.open(path, "r")
	if f~=nil then
		io.close(f)
		local handle  = assert( io.open(path,"r") )
		local value = handle:read("*line")
		while value do
			table.insert( arr, value )
			value = handle:read("*line")
		end
		handle:close()
		return arr
	else
		return arr
	end
end

return M
