-- CallbackHell.lua
-- David Skrundz

function writeFactory(address, bytes)
  return function(i)
    i:start()
    i:address(address, i2c.TRANSMITTER)
    i:write(bytes)
    i:stop()
  end
end

function readFactory(address, size)
  return function(i)
    i:start()
    i:address(address, i2c.RECEIVER)
    i:read(size)
    i:stop()
  end
end

function requestLevels(callback)
  i2cBuffer:append(
    writeFactory(CONST.i2cAddress, CONST.i2cRequestLevels),
    nil, function(_, _, _) end)
  i2cBuffer:append(
    readFactory(CONST.i2cAddress, 2*3),
    nil,
    function(_, data, _)
      local l1, l2, l3, _ = struct.unpack(">I2I2I2", data)
      callback({l1, l2, l3})
    end)
end

dispenseBusy = false
function startDispense(object, callback)
  if dispenseBusy then return callback(false) end
  if not object or not object.ingredients then
    return callback(false)
  end
  for index, value in ipairs(object.ingredients) do
    if value.amount > ingredients[index].amount then
      return callback(false)
    end
  end
  dispenseBusy = true
  i2cBuffer:append(
    writeFactory(CONST.i2cAddress, CONST.i2cDispense),
    nil, function(_, _, _) end)
  i2cBuffer:append(
    readFactory(CONST.i2cAddress, 1),
    nil,
    function(_, data, _) 
      -- TODO: Process data for 1 or 0
      i2cBuffer:append(
        writeFactory(CONST.i2cAddress, CONST.i2cDispense),
        nil,
        function(_, data, _)
          -- TODO: Process data and send it to callback
          callback({})
        end)
    end)
end
