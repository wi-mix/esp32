-- Main.lua
-- David Skrundz
--
-- dofile("Main.lc")

-- load all modules
dofile("FS.lc")
FS.forEachFile(".lc", function(name)
  if not (name == "FS.lc" or name == "Main.lc") then
    dofile(name)
  end
end)

wireless = Wifi.init()
server = nil
wireless:onDisconnect(function(ssid, bssid, reason)
  print("-- Wifi disconnected")
  if s then
    s:close()
    s = nil
  end
end)
wireless:onGetIp(function(ip, netmask, gw)
  print("-- Wifi got ip " .. ip .. ", mask: " .. netmask .. ", gateway: " .. gw)
  if server then
    server:close()
  end
  server = Server.new()
  server:listen(CONST.port, function(client)
    client:onReceive(function(client, data)
      print("-- Receive data: " .. data)
      client:send("HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: 75\n\n<html><head></head><body><center><h1>Lua Server</h1></center></body></html>")
    end)
    client:onSent(function(client)
      print("-- Done sending")
    end)
    local port, ip = client:address()
    print("-- Client connected to " .. ip .. ":" .. port)
    local port, ip = client:peerAddress()
    print("-- Client connected from " .. ip .. ":" .. port)
  end)
end)
wireless:connect(CONST.ssid, CONST.pass)
