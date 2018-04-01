-- I2CBuffer.lua
-- David Skrundz
--
-- i2b = I2CBuffer.new()
-- i2b:append(function(i2c) ... end, object, function(object, data, ack) ... end)

I2CBuffer = {}
function I2CBuffer.new(i2cObj)
  local _i2cbuffer = {canSend = true}
  setmetatable(_i2cbuffer, {__index = I2CBuffer})
  
  _i2cbuffer.i2c = i2cObj
  _i2cbuffer.queue = Queue.new()
  _i2cbuffer.timer = tmr.create()
  _i2cbuffer.timer:alarm(CONST.i2cINTERVAL, tmr.ALARM_AUTO, function()
    if not _i2cbuffer.canSend then return end
    _i2cbuffer:trySend()
  end)
  
  return _i2cbuffer
end

function I2CBuffer:append(doFunc, object, callback)
  local entry = {}
  entry.func = doFunc
  entry.data = object
  entry.call = callback
  self.queue:append(entry)
  self:trySend()
end

function I2CBuffer:trySend()
  if not self.canSend then return end
  if self.queue:isEmpty() then return end
  self.canSend = false
  local entry = self.queue:pop()
  entry.func(self.i2c)
  self.i2c:transfer(function(data, ack)
    self.canSend = true
    entry.call(entry.data, data, ack)
  end)
end
