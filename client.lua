package.path="?/init.lua;"..package.path
local multi = require("multi")
local net = require("net")
client = net:newTCPClient("localhost",12345)
client:enableBinaryMode()
local file = bin.new()
client.OnDataRecieved(function(self,data)
	if data == "END" then
		file:tofile("test2.mp3")
		print("File transfered!")
	else
		file:tackE(data)
	end
end)
client.OnClientReady:holdUT() -- waits until the client is ready... You can also connect to this event as well and have code do stuff too
client:send("Hello Server!")
multi:mainloop()
