package.path="?/init.lua;"..package.path
require("bin")
require("multi")
require("net.aft")
client=net:newCastedClient("Lua_Server") -- searches the lan for this server name
-- Both udp and tcp clients can be broadcasted
client.OnClientReady(function(self)
	self:send("Hello!")
end) -- For a tcp client the client is already ready, with udp a small handshake is done and the client is not instantly ready
client.OnDataRecieved(function(self,data) -- thats it clients only have to worry about itself and the server
	if data=="Hello Client!" then
		print("Server Responded Back!")
	end
end)
multi:mainloop()
