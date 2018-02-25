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

sendQueue = Queue.new()

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
      c:send("HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: 75\n\n<html><head></head><body><center><h1>Lua Server</h1></center></body></html>")
    end)
    c:onSent(function(client)
      print("-- Done sending")
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
