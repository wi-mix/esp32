-- HTTPHandler.lua
-- David Skrundz

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
