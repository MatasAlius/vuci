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

function M.fileExists(path)
	local f = io.open(path,"r")
	if f ~= nil then 
		io.close(f)
		return 1
	else
		return 0
	end
end

function M.getServerList(params)

	local exists = M.fileExists('/tmp/serverlist.txt')

	if exists == 0 then
		headers = {
			"Accept: application/xml",
			"Accept-Language: en",
			"Accept-Charset: iso-8859-1,*,utf-8",
			"Cache-Control: no-cache"
		}

		f = io.open("/tmp/serverlist_orig.txt", "w")
		-- login_url = "http://ipwhois.app/json/8.8.8.8"
		-- be nurodyto ip rodys dabartinio ip info
		local results

		c = cURL.easy{
			url = "https://gist.githubusercontent.com/autos/6f11ffa74a414fa58d4587a77d1f7ea7/raw/63bcfe0889798653d679be6fc17efc3f60dc4714/speedtest.php",
			ssl_verifypeer = false,
			ssl_verifyhost = false,
			httpheader     = headers,
			writefunction  = function(str)
				results = str
				f:write(str)
			end
		}
		c:perform()
		f:close()
		params.response = c:getinfo_response_code()
		os.execute('sed "1,2d" /tmp/serverlist_orig.txt | head -n-2 > /tmp/serverlist.txt')
	else
		params.response = 202
	end
	return params
end

function M.readFile(params)
  local arr = {}

	local count = 1

	local lines = {}
	for line in io.lines("/tmp/serverlist.txt") do
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

function M.pingIp(params)
	local handler = io.popen("ping -c 3 '"..params.ip.."' | tail -1 | awk '{print $4}' | cut -d '/' -f 2")
	local response = handler:read("*a")
	return response
end

function M.speedTestCurl(params)
	os.execute('head -c 1024 /dev/urandom > temp.txt')
	local post = cURL.form()
		:add_file  ("name", "temp.txt", "text/plain")

	local c = cURL.easy()
		:setopt_url(params.url)
		:setopt_httppost(post)
		:setopt_timeout(2)
		:setopt_connecttimeout(1)
	
	local ok, err = pcall(function() c:perform() end)
	params.ok = ok
	params.err = err
	params.response = c:getinfo_response_code()
	if ok then
		if params.response == 200 then
			params.connect = c:getinfo_connect_time()
			params.total = c:getinfo_total_time()
		end
	end
	c:close()
	return params
end

return M
