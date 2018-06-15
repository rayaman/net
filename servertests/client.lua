require("socket")
ssl=require("ssl")

-- TLS/SSL client parameters (omitted)
local params = {
  mode = "client",
  protocol = "tlsv1_2",
  key = "certs/clientAkey.pem",
  certificate = "certs/clientA.pem",
  cafile = "certs/rootA.pem",
  verify = "peer",
  options = "all"
}

local conn = socket.tcp()
conn:connect("127.0.0.1", 8888)

-- TLS/SSL initialization
conn = ssl.wrap(conn, params)
print(conn:dohandshake())
--
print(conn:receive("*l"))
conn:close()
