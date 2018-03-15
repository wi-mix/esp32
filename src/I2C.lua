-- I2C.lua
-- David Skrundz
--
-- i = I2C.init(dataSignal, clockSignal, speed)
-- i:start()
-- i:address(address, i2c.TRANSMITTER)
-- i:write(data)
-- i:stop()
-- i:start()
-- i:address(address, i2c.RECEIVER)
-- i:read(length)
-- i:stop()
-- i:transfer(function(data, ack) ... end)

I2C = {}
function I2C.init(dataSignal, clockSignal, speed)
  local _i2c = {}
  setmetatable(_i2c, {__index = I2C})
  
  i2c.setup(i2c.HW0, dataSignal, clockSignal, speed)
  
  return _i2c
end

function I2C:start()
  i2c.start(i2c.HW0)
end

function I2C:address(addr, send_recv)
  i2c.address(i2c.HW0, addr, send_recv, true)
end

function I2C:read(length)
  i2c.read(i2c.HW0, length)
end

function I2C:write(data)
  i2c.write(i2c.HW0, data, true)
end

function I2C:stop()
  i2c.stop(i2c.HW0)
end

function I2C:transfer(func)
  i2c.transfer(i2c.HW0, func, 0)
end
