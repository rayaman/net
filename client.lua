package.path="?/init.lua;"..package.path
require("multi")
require("net")
client = net:newUDPClient("localhost",12345)
client.OnDataRecieved(function(self,data)
	print(data)
end)
client.OnClientReady:holdUT() -- waots until the client is ready... You can also connect to this event as well and have code do stuff too
client:send("Hello Server!")
multi:mainloop()
