-- SendBuffer.lua
-- David Skrundz
--
-- sb = SendBuffer.new()
-- sb:send(client, string)
-- sb:sent()

SendBuffer = {}
function SendBuffer.new()
  local _sendbuffer = {canSend = true}
  setmetatable(_sendbuffer, {__index = SendBuffer})
  
  _sendbuffer.queue = Queue.new()
  
  return _sendbuffer
end

function SendBuffer:send(client, string)
  local entry = {}
  entry.client = client
  entry.string = string
  self.queue:append(entry)
  self:trySend()
end

function SendBuffer:sent()
  self.canSend = true
  self:trySend()
end

function SendBuffer:trySend()
  if not self.canSend then return end
  if self.queue:isEmpty() then return end
  local entry = self.queue:pop()
  if entry.client.closed then return self:trySend() end
  entry.client:send(entry.string)
  self.canSend = false
end
