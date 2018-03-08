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
  print("-- Wifi disconnected: " .. reason)
  if server then server:close(); server = nil end
end

function onWifiGetIP(ip, netmask, gw)
  print("-- IP: " .. ip)
  if server then server:close() end
  server = Server.new()
  server:listen(CONST.port, onServerConnectionReceived)
  LED.blink(500)
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
  sendResponse(client, CONST.http200, "")
  setIngredients(json.parse(body))
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

function setIngredients(object)
  local newIngredients = object.ingredients
  ingredients[1].id = newIngredients[1].id
  ingredients[1].name = newIngredients[1].name
  ingredients[2].id = newIngredients[2].id
  ingredients[2].name = newIngredients[2].name
  ingredients[3].id = newIngredients[3].id
  ingredients[3].name = newIngredients[3].name
end

function startDispense(object)
  -- TODO: Check in use
  if ingredients[1].amount >= object.ingredients[1] and
     ingredients[2].amount >= object.ingredients[2] and
     ingredients[3].amount >= object.ingredients[3] then
    -- TODO: dispense
    return true
  else
    return false
  end
end

function onUARTDataReceived(data)
  -- Simple echo server
  print("UART data: " .. data)
  u:write(data)
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
ingredients[1] = {id = nil, name = nil, amount = 0}
ingredients[2] = {id = nil, name = nil, amount = 0}
ingredients[3] = {id = nil, name = nil, amount = 0}

LED.init()
LED.off()

server = nil
sendBuffer = SendBuffer.new()

requestBuffer = RequestBuffer.new()
requestBuffer:onRequest(onRequest)

w = Wifi.init()
w:onDisconnect(onWifiDisconnect)
w:onGetIp(onWifiGetIP)
w:connect(CONST.ssid, CONST.pass)

u = UART.init(115200, 8, uart.PARITY_ODD, uart.STOPBITS_1)
u:onData(onUARTDataReceived)
