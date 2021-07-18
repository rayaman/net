package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("lnet.tcp")
local multi, thread = require("multi"):init()

local http = require("lnet.http")

multi:newThread("Download Test",function()
    local data = http.request("http://zjcdn.mangafox.me/store/manga/14765/01-001.0/compressed/t001.jpg")
    local file = io.open("test.jpg","wb")
    file:write(data)
    file:flush()
    file:close()
    os.exit()
end)

multi:newThread("Timer",function()
 
end)   
-- local client = net.newCastedClient("Test")--net:newTCPClient("localhost",12345)

-- client:send("Test!")

-- client.OnDataRecieved(function(c,data)
--     print("Response: ",data)
-- end)
multi:mainloop()