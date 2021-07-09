package.path = "./?/init.lua;./?.lua;"..package.path
-- local net = require("net.tcp")
-- local client = net:newTCPClient("localhost",12345)

-- client:send("Test!")

-- client.OnDataRecieved(function(c,data)
--     print("Response: ",data)
--     --c:send("Testing again!")
-- end)

local multi, thread = require("multi"):init()
local https = require("net.https")

-- multi:newThread("test1",function()
--     local file = io.open("test1.jpg","wb")
--     data, code, headers, status = http.request("http://zjcdn.manga3fox.me/store/manga/33769/091.0/compressed/s20210705_163050_598.jpg")
--     print("Data:",data)
--     if headers then
--         for i,v in pairs(headers) do
--             print(i,v)
--         end
--     end
--     print(data,code,headers,status)
--     file:write(data)
--     file:flush()
--     file:close()
--     os.exit()
-- end).OnError(function(a,b,c)
--     print("Error: ",a,b,c)
--     --os.exit()
-- end)

data, code, headers, status = https.request("https://example.com/")
print(data, code, headers, status)
if headers then
    for i,v in pairs(headers) do
        print(i,v)
    end
end

-- multi.OnExit(function()
--     print("Lua state being shutdown! :'(")
-- end)
-- multi:mainloop()