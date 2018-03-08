-- I2C.lua
-- David Skrundz
--
-- i = I2C.init(dataSignal, clockSignal, address, tenBit, rxBufLen, txBufLen)
-- i:onData(function(data) ... end)
-- i:onError(function(error) ... end)
-- i:write(data)

I2C = {}
function I2C.init(dataSignal, clockSignal, address, tenBit, rxBufLen, txBufLen)
  local _i2c = {}
  setmetatable(_i2c, {__index = I2C})
  
  i2c.slave.on(i2c.HW0, "receive", function(err, data)
    if err and _i2c.onErrorFunc then
      _i2c.onErrorFunc(err)
    end
    if data and _i2c.onDataFunc then
      _i2c.onDataFunc(data)
    end
  end)
  
  local i2cConfig = {
    sda = dataSignal,
    scl = clockSignal,
    addr = address,
    rxbuf_len = rxBufLen,
    txbuf_len = txBufLen
  }
  i2cConfig["10bit"] = tenBit
  i2c.slave.setup(i2c.HW0, i2cConfig)
  
  return _i2c
end

function I2C:write(data)
  i2c.slave.send(i2c.HW0, data)
end

function I2C:onData(func)
  self.onDataFunc = func
end

function I2C:onError(func)
  self.onErrorFunc = func
end
