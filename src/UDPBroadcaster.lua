-- UDPBroadcaster.lua
-- David Skrundz
--
-- udp = UDPBroadcaster.new()
-- udp:start(ip, port, message, interval)
-- bool = udp:isBroadcasting()
-- udp:stop()

UDPBroadcaster = {}
function UDPBroadcaster.new()
  local _udpbroadcaster = {}
  setmetatable(_udpbroadcaster, {__index = UDPBroadcaster})
  return _udpbroadcaster
end

function UDPBroadcaster:isBroadcasting()
  return self.socket ~= nil
end

function UDPBroadcaster:start(ip, port, message, interval)
  if self:isBroadcasting() then self:stop() end
  self.canSend = true
  self.socket = net.createUDPSocket()
  self.socket:on("sent", function(_)
    self.canSend = true
  end)
  self.timer = tmr.create()
  self.timer:alarm(interval, tmr.ALARM_AUTO, function()
    if not self.canSend then return end
    self.socket:send(port, ip, message)
  end)
end

function UDPBroadcaster:stop()
  if not self:isBroadcasting() then return end
  self.timer:unregister()
  self.timer = nil
  self.canSend = nil
  self.socket = nil
end
