# net

# Discord
For real-time assistance with my libraries! A place where you can ask questions and get help with any of my libraries</br>
https://discord.gg/U8UspuA</br>

The net library was created to make servers and clients interact easily. This isn't for webservers! (It could be, but you would need to codde that part)

This library depends on luasocket and you should use luajit! It will work on a standard lua interperter, but wont be as fast.
# Goal
A simple and powerful way to make servers and clients

# Usage
server.lua
```lua
require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi.all") -- you need this to handle multiple connections and such
require("net") -- That requires the main library
server=net:newTCPServer(12345) -- create a server that listens on port 12345
server.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP,UPDATER_OR_NIL) -- a bit confusing, but dont worry you will hardly ever need more then the first 5 arguments, unless you are writing modules!
  if data=="Hello!" then
    print("Got response from client sending back data!")
    self:send(IP_OR_HANDLE,"Hello Client!",PORT_OR_IP) -- doing it like this makes this code work for both udp and tcp
  end
end)
multi:mainloop()
```
client.lua
```lua
require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi.all") -- you need this to handle multiple connections and such
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
```
The bin and multi library can be found on my github page. They are all 100% pure lua so it should be easy to add to your project.
# Todo
- Write the wiki
- put examples on main page
- 
