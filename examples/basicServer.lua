require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi") -- you need this to handle multiple connections and such
require("net") -- That requires the main library
server=net:newTCPServer(12345) -- create a server that listens on port 12345
server.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP,UPDATER_OR_NIL) -- a bit confusing, but dont worry you will hardly ever need more then the first 5 arguments, unless you are writing modules!
  if data=="Hello!" then
    print("Got response from client sending back data!")
    self:send(IP_OR_HANDLE,"Hello Client!",PORT_OR_IP) -- doing it like this makes this code work for both udp and tcp
  end
end)
multi:mainloop()
