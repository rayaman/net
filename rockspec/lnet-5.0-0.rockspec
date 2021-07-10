package = "llnet"
version = "5.0-0"
source = {
   url = "git://github.com/rayaman/lnet.git",
   tag = "lnet-v5",
}
description = {
   summary = "Lua lnetworking library that wraps around lua-socket to make lnetworking easy.",
   detailed = [[
      This library uses the multi library. The new multitasking library and this one are now co-Dependant if using the lnetworkManager integration for lnetwork parallelism. This has an event driven approach for lnetworking which allows one to easily work async with the data.
   ]],
   homepage = "https://github.com/rayaman/lnet",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luasocket",
   "multi",
}
build = {
   type = "builtin",
   modules = {
      ["lnet.init"] = "lnet/init.lua",
      ["lnet.tcp.init"] = "lnet/tcp/init.lua",
      ["lnet.udp.init"] = "lnet/udp/init.lua",
      ["lnet.core.clientbase"] = "lnet/core/clientbase.lua",
      ["lnet.core.serverbase"] = "lnet/core/serverbase.lua",
      ["lnet.http"] = "lnet/http.lua",
      ["lnet.https"] = "lnet/https.lua"
   }
}