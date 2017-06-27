require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi") -- you need this to handle multiple connections and such
require("net") -- That requires the main library
client=net:newTCPClient("localhost",12345) -- connect to the server
client.OnClientReady(function(self)
  self:send("Hello!")
end) -- For a tcp client the client is already ready, with udp a small handshake is done and the client is not instantly ready
client.OnDataRecieved(function(self,data) -- thats it clients only have to worry about itself and the server
  if data=="Hello Client!" then
    print("Server Responded Back!")
  end
end)
multi:mainloop()
