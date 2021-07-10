package = "lnet"
version = "5.0-0"
source = {
   url = "git://github.com/rayaman/net.git",
   tag = "net-v5",
}
description = {
   summary = "Lua networking library that wraps around lua-socket to make networking easy.",
   detailed = [[
      This library uses the multi library. The new multitasking library and this one are now co-Dependant if using the networkManager integration for network parallelism. This has an event driven approach for networking which allows one to easily work async with the data.
   ]],
   homepage = "https://github.com/rayaman/net",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luasocket"
   "multi",
}
build = {
   type = "builtin",
   modules = {
      ["net.init"] = "net/init.lua",
      ["net.tcp.init] = "net/tcp/init.lua",
      ["net.udp.init] = "net/udp/init.lua",
      ["net.core.clientbase"] = "net/core/clientbase.lua"
      ["net.core.serverbase"] = "net/core/serverbase.lua"
      ["net.http"] = "net/http.lua"
      ["net.https"] = "net/https.lua"
   }
}