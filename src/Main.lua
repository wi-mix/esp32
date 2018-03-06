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
  local responseList = {
    method = method,
    path = path,
    version = version,
    headers = headers,
    body = body
  }
  local response = json.stringify(responseList)
  CONST.httpResponse[CONST.httpIndex] = response
  CONST.httpResponse[CONST.httpLength] = response:len()
  sendBuffer:send(client, CONST.httpResponse:render())
end

function onUARTDataReceived(data)
  -- Simple echo server
  print("UART data: " .. data)
  u:write(data)
end

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
