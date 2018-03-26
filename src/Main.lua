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

function setIngredients(newIngredients)
  for index,value in ipairs(newIngredients) do
    ingredients[index].key = value.key
    ingredients[index].name = value.name
  end
  FS.write(CONST.save, json.stringify(ingredients))
end

function startDispense(object)
  -- TODO: Check in use
  if not object.ingredients then return false end
  for index, value in ipairs(object.ingredients) do
    if value.amount > ingredients[index].amount then
      return false
    end
  end
  -- TODO: dispense
  return true
end

function getIngredients()
  return { ingredients = ingredients }
end

function getLevels()
  local levels = {}
  for i,v in ipairs(ingredients) do
    levels[i] = v.amount
  end
  return levels
end

ingredients = {}

ingredientsString = FS.read(CONST.save)
if ingredientsString then
  ingredients = json.parse(ingredientsString)
end

LED.init()
LED.off()

udpCaster = UDPBroadcaster.new()

server = nil
sendBuffer = SendBuffer.new()

i = I2C.init(21, 22, i2c.SLOW/2)
i2cBuffer = I2CBuffer.new(i)

requestBuffer = RequestBuffer.new()
requestBuffer:onRequest(onRequest)

w = Wifi.init()
w:onDisconnect(onWifiDisconnect)
w:onGetIp(onWifiGetIP)
w:connect(CONST.ssid, CONST.pass)
