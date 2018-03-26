-- UDPHandler.lua
-- David Skrundz

function startUDPBroadcast(ip)
  local targetIP, _ = ip:gsub("(%d+)$", "255")
  local message = "g5:" .. ip
  udpCaster:start(targetIP, CONST.udpPORT, message, CONST.udpINTERVAL)
end

function stopUDPBroadcast()
  udpCaster:stop()
end
