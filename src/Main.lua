-- Main.lua
-- David Skrundz
--
-- dofile("Main.lc")

-- load all modules
dofile("FS.lc")
FS.forEachFile(".lc", function(name)
  if name == "init.lc" then return end
  if name == "FS.lc"   then return end
  if name == "Main.lc" then return end
  dofile(name)
end)

function onWifiDisconnect(ssid, bssid, reason)
  LED.blink(100)
  print("-- Wifi disconnected: " .. reason)
  if server then server:close(); server = nil end
end

function onWifiGetIP(ip, netmask, gw)
  print("-- IP: " .. ip)
  if server then server:close() end
  server = Server.new()
  server:listen(CONST.port, onServerConnectionReceived)
  LED.blink(500)
end

function onServerConnectionReceived(client)
  client:onReceive(onClientReceive)
  client:onSent(onClientSent)
  client:onDisconnection(onClientDisconnect)
end

function onClientReceive(client, data)
  requestBuffer:append(client, data)
end

function onClientSent(client)
  sendBuffer:sent()
end

function onClientDisconnect(client, err)
  requestBuffer:drop(client)
  sendBuffer:disconnect(client)
end

function onRequest(client, method, path, version, headers, body)
  html[htmlTitleIndex] = "HTML SERVER - " .. path
  html[htmlBodyIndex] = ""
  if body then html[htmlBodyIndex] = body end
  response = html:render()
  CONST.httpResponse[CONST.httpIndex] = response
  CONST.httpResponse[CONST.httpLength] = response:len()
  sendBuffer:send(client, CONST.httpResponse:render())
end

function onUARTDataReceived(data)
  -- Simple echo server
  print("UART data: " .. data)
  u:write(data)
end

htmlTitleIndex = 7
htmlBodyIndex = 12
html = StringFormat.new()
html[ 1] = "<html>"
html[ 2] = "<head>"
html[ 3] = "</head>"
html[ 4] = "<body>"
html[ 5] = "<center>"
html[ 6] = "<h1>"
html[ 7] = ""
html[ 8] = "</h1>"
html[ 9] = "</center>"
html[10] = "<br/>"
html[11] = "<p>"
html[12] = ""
html[13] = "</p>"
html[14] = "</body>"
html[15] = "</html>"

LED.init()
LED.off()

server = nil
sendBuffer = SendBuffer.new()

requestBuffer = RequestBuffer.new()
requestBuffer:onRequest(onRequest)

w = Wifi.init()
w:onDisconnect(onWifiDisconnect)
w:onGetIp(onWifiGetIP)
w:connect(CONST.ssid, CONST.pass)

u = UART.init(115200, 8, uart.PARITY_ODD, uart.STOPBITS_1)
u:onData(onUARTDataReceived)
