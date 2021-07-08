package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("net.tcp")
local client = net:newTCPClient("localhost",12345)

multi:newAlarm(1):OnRing(function()
    client:send("Test!")
end)

client.OnDataRecieved(function(c,data)
    print("Response: ",data)
    --c:send("Testing again!")
end)

multi:mainloop()