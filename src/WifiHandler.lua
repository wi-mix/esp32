-- WifiHandler.lua
-- David Skrundz

function onWifiDisconnect(ssid, bssid, reason)
  LED.blink(100)
  stopUDPBroadcast()
  if server then server:close(); server = nil end
end

function onWifiGetIP(ip, netmask, gw)
  if server then server:close() end
  server = Server.new()
  server:listen(CONST.port, onServerConnectionReceived)
  LED.blink(500)
  startUDPBroadcast(ip)
end
