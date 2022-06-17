package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("lnet.tcp")
local multi, thread = require("multi"):init()

-- local http = require("lnet.http")
-- local http_ = require("socket.http")

-- download = thread:newFunction(function(url,fn)
--     print(1)
--     local t = multi:newTimer()
--     print(2)
--     t:Start()
--     print(3,url)
--     local data,b = http.request(url)
--     print(data,b)
--     local file = io.open(fn,"wb")
--     print(5)
--     file:write(data)
--     print(6)
--     file:flush()
--     print(7)
--     file:close()
--     print(fn.." Finished downloading: ".. t:Get())
-- end)

-- multi:newThread("Timer",function()
--     while true do
--         thread.sleep(8)
--         print("...")
--     end
-- end)
--download("http://212.183.159.230/5MB.zip","test1.bin")
--download("http://212.183.159.230/50MB.zip","test2.bin").OnError(print)

-- local client = net.newCastedClient("Test")--net:newTCPClient("localhost",12345)

-- client:send("Test!")

-- client.OnDataRecieved(function(c,data)
--     print("Response: ",data)
-- end)

--multi:mainloop()