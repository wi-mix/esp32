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

function onWifiDisconnect(ssid, bssid, reason)
  LED.blink(100)
  stopUDPBroadcast()
  if server then server:close(); server = nil end
end

function onWifiGetIP(ip, netmask, gw)
  print("-- IP: " .. ip)
  if server then server:close() end
  server = Server.new()
  server:listen(CONST.port, onServerConnectionReceived)
  LED.blink(500)
  startUDPBroadcast(ip)
end

function startUDPBroadcast(ip)
  local targetIP, _ = ip:gsub("(%d+)$", "255")
  local message = "g5:" .. ip
  udpCaster:start(targetIP, CONST.udpPORT, message, CONST.udpINTERVAL)
end

function stopUDPBroadcast()
  udpCaster:stop()
end

function onServerConnectionReceived(client)
  client:onReceive(onClientReceive)
  client:onSent(onClientSent)
  client:onDisconnection(onClientDisconnect)
end

function onClientReceive(client, data)
  requestBuffer:append(client, data)
end

function onClientSent(client)
  sendBuffer:sent()
end

function onClientDisconnect(client, err)
  requestBuffer:drop(client)
  sendBuffer:disconnect(client)
end

function onRequest(client, method, path, version, headers, body)
  if method == "GET" and path == "/ingredients" then
    return onGETingredients(client, version, headers)
  end
  if method == "POST" and path == "/ingredients" then
    return onPOSTingredients(client, version, headers, body)
  end
  if method == "POST" and path == "/dispense" then
    return onPOSTdispense(client, version, headers, body)
  end
  sendBuffer:send(client, CONST.http404Response)
end

function onGETingredients(client, version, headers)
  local response = json.stringify(getIngredients())
  sendResponse(client, CONST.http200, response)
end

function onPOSTingredients(client, version, headers, body)
  local object = json.parse(body)
  if not object.ingredients then
    sendResponse(client, CONST.http400, "")
    return
  end
  setIngredients(object.ingredients)
  sendResponse(client, CONST.http200, "")
end

function onPOSTdispense(client, version, headers, body)
  local response = json.stringify(getLevels())
  if startDispense(json.parse(body)) then
    sendResponse(client, CONST.http201, response)
  else
    sendResponse(client, CONST.http409, response)
  end
end

function sendResponse(client, status, response)
  CONST.httpResponse[CONST.httpStatus] = status
  CONST.httpResponse[CONST.httpIndex] = response
  CONST.httpResponse[CONST.httpLength] = response:len()
  sendBuffer:send(client, CONST.httpResponse:render())
end

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
  return { ingredients = {
    ingredients[1].amount,
    ingredients[2].amount,
    ingredients[3].amount
  }}
end

ingredients = {}
ingredients[1] = {key = nil, name = nil, amount = 100}
ingredients[2] = {key = nil, name = nil, amount = 200}
ingredients[3] = {key = nil, name = nil, amount = 300}

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
