-- ServerHandler.lua
-- David Skrundz

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
