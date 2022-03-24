
local cURL = require("cURL")
local params = {...}

f = io.open("/tmp/speedtest_down.txt", "w")
f:write('0,0,0,0,0\n')
f:close()

local start_time = os.clock()
local end_time = os.clock()

local c = cURL.easy()
  :setopt_url(params[1])
  :setopt_useragent('Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)')
  :setopt_timeout(8)
  :setopt_connecttimeout(2)
  :setopt_accepttimeout_ms(2)
  :setopt_noprogress(false)
  :setopt_progressfunction(function(dltotal, dlnow, ultotal, ulnow)
    end_time = os.clock()
    local elapsed_time = end_time - start_time
    f = io.open("/tmp/speedtest_down.txt", "w")
    local down_speed = dlnow / 1000000 / elapsed_time
    f:write(elapsed_time, ',', dltotal, ',', dlnow, ',', down_speed, ',0', '\n')
    f:close()
    return 1
  end)

local ok, err = pcall(function() c:perform() end)
f = io.open("/tmp/speedtest_down.txt", "w")
f:write('-1,-1,-1,-1,1\n')
f:close()
