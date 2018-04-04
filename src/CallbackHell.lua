-- CallbackHell.lua
-- David Skrundz

function writeFactory(address, bytes)
  return function(i)
    if type(bytes) == "string" then
      print("Writing " .. bytes:gsub('.', function (c)
        return string.format('%02X ', string.byte(c))
      end))
    else
      print("Writing " .. bytes)
    end
    i:start()
    i:address(address, i2c.TRANSMITTER)
    i:write(bytes)
    i:stop()
  end
end

function readFactory(address, size)
  return function(i)
    print("Reading " .. size .. " bytes")
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

function startDispense(object, callback)
  if not object or not object.ingredients then
    print("MISSING OBJECT")
    return callback(false)
  end
  for index, value in ipairs(object.ingredients) do
    if value.amount > ingredients[index].amount then
      print("BAD: ")
      for index, value in ipairs(object.ingredients) do
        print(index)
        print(value.amount)
      end
      return callback(false)
    end
  end
  i2cBuffer:append(
    writeFactory(CONST.i2cAddress, CONST.i2cDispense),
    nil, function(_, _, _) end)
  i2cBuffer:append(
    readFactory(CONST.i2cAddress, 1),
    nil,
    function(_, data, _)
      local ready, _ = struct.unpack(">I1", data)
      print("READY " .. tostring(ready))
      if ready ~= 1 then return callback(false) end
      local toSend = {
        {amount = 0, order = 0},
        {amount = 0, order = 0},
        {amount = 0, order = 0},
      }
      local ordered = 0
      for index, value in ipairs(object.ingredients) do
        toSend[index].amount = value.amount
        toSend[index].order = value.order
        if value.order > 0 then ordered = 1 end
      end
      print("Ordered: " .. ordered)
      i2cBuffer:append(
        writeFactory(CONST.i2cAddress,
          struct.pack("<I2I2I2I2I2I2I2",
            toSend[1].amount, toSend[1].order,
            toSend[2].amount, toSend[2].order,
            toSend[3].amount, toSend[3].order,
            ordered)),
        nil,
        function(_, _, ack)
          callback(ack)
        end)
    end)
end
