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

LED.init()
LED.off()

contentIndex = 6
contentLengthIndex = 4
httpResponse = StringFormat.new()
httpResponse[1] = "HTTP/1.1 200 OK\n"
httpResponse[2] = "Content-Type: text/html\n"
httpResponse[3] = "Content-Length: "
httpResponse[4] = 0
httpResponse[5] = "\n\n"
httpResponse[6] = ""

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

sendBuffer = SendBuffer.new()

w = Wifi.init()
s = nil
w:onDisconnect(function(ssid, bssid, reason)
  LED.blink(100)
  print("-- Wifi disconnected: " .. reason)
  if s then
    s:close()
    s = nil
  end
end)
w:onGetIp(function(ip, netmask, gw)
  LED.on()
  print("-- Wifi got ip " .. ip .. ", mask: " .. netmask .. ", gateway: " .. gw)
  if s then
    s:close()
  end
  s = Server.new()
  s:listen(CONST.port, function(c)
    c:onReceive(function(c, data)
      print("-- Receive data: " .. data)
      html[htmlIndex] = "HTML SERVER"
      response = html:render()
      httpResponse[contentIndex] = response
      httpResponse[contentLengthIndex] = response:len()
      sendBuffer:send(c, httpResponse:render())
    end)
    c:onSent(function(client)
      print("-- Done sending")
      sendBuffer:sent()
    end)
    local port, ip = c:address()
    print("-- Client connected to " .. ip .. ":" .. port)
    local port, ip = c:peerAddress()
    print("-- Client connected from " .. ip .. ":" .. port)
  end)
  LED.blink(500)
end)
w:connect(CONST.ssid, CONST.pass)

u = UART.init(115200, 8, uart.PARITY_ODD, uart.STOPBITS_1)
u:onData(function(data)
  print("UART data: " .. data)
  --u:write(data)
  --sendQueue:append(value)
  --value = sendQueue:pop()
end)
