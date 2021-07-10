package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("lnet.tcp")
local multi, thread = require("multi"):init()
local client = net:newCastedClient("Test")--net:newTCPClient("localhost",12345)

client:send("Test!")

client.OnDataRecieved(function(c,data)
    print("Response: ",data)
end)
multi:mainloop()