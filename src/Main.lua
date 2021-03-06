-- Main.lua
-- David Skrundz
--
-- dofile("Main.lc")

-- load all modules
struct = require("struct")
dofile("FS.lc")
FS.forEachFile(".lc", function(name)
  if name == "init.lc" then return end
  if name == "FS.lc"   then return end
  if name == "Main.lc" then return end
  dofile(name)
end)

function setIngredients(newIngredients)
  for index,value in ipairs(newIngredients) do
    if not ingredients[index] then
      ingredients[index] = {}
    end
    ingredients[index].key = value.key
    ingredients[index].name = value.name
    ingredients[index].amount = 0
  end
  FS.write(CONST.save, json.stringify(ingredients))
end

function getIngredients(callback)
  getLevels(function(levels)
    callback({ ingredients = ingredients })
  end)
end

function getLevels(callback)
  print("getLevels")
  requestLevels(function(levels)
    for i,v in ipairs(levels) do
      if not ingredients[i] then
        ingredients[i] = {}
      end
      ingredients[i].amount = v
    end
    print("callback(levels)")
    callback(levels)
  end)
end

ingredients = {{amount = 0},{amount = 0},{amount = 0}}

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
