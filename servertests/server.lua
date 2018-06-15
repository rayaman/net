require("socket")
ssl=require("ssl")

-- TLS/SSL server parameters (omitted)
local params = {
  mode = "server",
  protocol = "tlsv1_2",
  key = "certs/serverAkey.pem",
  certificate = "certs/serverA.pem",
  cafile = "certs/rootA.pem",
  verify = "peer",
  options = "all"
}

local server = socket.tcp()
server:bind("127.0.0.1", 8888)
server:listen()
local conn = server:accept()

-- TLS/SSL initialization
conn = ssl.wrap(conn, params)
print(conn:dohandshake())
--
conn:send("one line\n")
conn:close()
