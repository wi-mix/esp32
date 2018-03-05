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

function wifiDisconnected(ssid, bssid, reason)
  LED.blink(100)
  print("-- Wifi disconnected: " .. reason)
  if s then s:close(); s = nil end
end

function wifiGotIP(ip, netmask, gw)
  print("-- Wifi got ip " .. ip .. ", mask: " .. netmask .. ", gateway: " .. gw)
  if s then s:close() end
  s = Server.new()
  s:listen(CONST.port, serverOnConnect)
  LED.blink(500)
end

function serverOnConnect(c)
  c:onReceive(clientOnReceive)
  c:onSent(clientOnSent)
  c:onDisconnection(clientOnDisconnection)
  local port, ip = c:address()
  print("-- Client connected to " .. ip .. ":" .. port)
  local port, ip = c:peerAddress()
  print("-- Client connected from " .. ip .. ":" .. port)
end

function clientOnReceive(c, data)
  print("-- Receive data: " .. data)
  html[htmlIndex] = "HTML SERVER"
  response = html:render()
  CONST.httpResponse[CONST.httpIndex] = response
  CONST.httpResponse[CONST.httpLength] = response:len()
  sendBuffer:send(c, CONST.httpResponse:render())
end

function clientOnSent(client)
  print("-- Done sending")
  sendBuffer:sent()
end

function clientOnDisconnection(client, err)
  print("-- Disconnected: " .. err)
  sendBuffer:disconnect(client)
end

function uartOnData(data)
  print("UART data: " .. data)
  u:write(data)
end

htmlIndex = 7
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
html[10] = "</body>"
html[11] = "</html>"

LED.init()
LED.off()

s = nil
sendBuffer = SendBuffer.new()

w = Wifi.init()
w:onDisconnect(wifiDisconnected)
w:onGetIp(wifiGotIP)
w:connect(CONST.ssid, CONST.pass)

u = UART.init(115200, 8, uart.PARITY_ODD, uart.STOPBITS_1)
u:onData(uartOnData)
