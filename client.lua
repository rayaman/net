package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("net.udp")
local client = net:newUDPClient("localhost",12345)

client:send("Test!")

client.OnDataRecieved(function(c,data)
    print("Response: ",data)
    --c:send("Testing again!")
end)

multi:mainloop()