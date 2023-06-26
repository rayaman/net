package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("lnet.tcp")
local multi, thread = require("multi"):init()

local http = require("lnet.http")
--local https = require("lnet.https")
local https = require("ssl.https")

-- multi:newThread("Download Test",function()
--     http.request:holdMe(false) -- Gain Access to the return manager
--     local data = http.request {
--         url = "http://files.luaforge.net/releases/luaforwindows/luaforwindows/5.1.4-35/LuaForWindows_v5.1.4-35.exe",
--         sink = ltn12.sink.file(io.open("test.exe","wb"))
--     }
--     local t={}
--     data.OnStatus(function(part,whole)
--         local per = math.ceil((part/whole)*100)
--         if not t[per] then
--             print("T1",per)
--             t[per] = true
--         end
--     end)
--     local c = os.clock()
--     thread.hold(data.connect())
--     print("Done!",os.clock()-c)
-- end)

multi:newThread("Download Test 2",function()--https://erowall.com/download_img.php?dimg=16911&raz=2560x1600
    local data,err = https.request("https://erowall.com/download_img.php?dimg=16911&raz=2560x1600")
    local file = io.open("test.jpg","wb")
    file:write(data)
    file:flush()
    file:close()
    print("Done!")
    os.exit()
end).OnError(function(self,err)
    print(">>",err)
end)

-- local client = net.newCastedClient("Test")--net:newTCPClient("localhost",12345)

-- client:send("Test!")

-- client.OnDataRecieved(function(c,data)
--     print("Response: ",data)
-- end)
multi:mainloop()