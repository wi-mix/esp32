-- RequestBuffer.lua
-- David Skrundz
--
-- rb = RequestBuffer.new()
-- rb:onRequest(function(client, method, path, version, headers, body) ... end)
-- rb:append(client, string)
-- rb:drop(client)

RequestBuffer = {}
function RequestBuffer.new()
  local _requestbuffer = {buffers = {}}
  setmetatable(_requestbuffer, {__index = RequestBuffer})
  return _requestbuffer
end

function RequestBuffer:onRequest(func)
  self.onRequestFunc = func
end

function RequestBuffer:append(client, string)
  if not self.buffers[client] then
    self.buffers[client] = {string = string}
  else
    self.buffers[client].string = self.buffers[client].string .. string
  end
  self:process(client)
end

function RequestBuffer:drop(client)
  self.buffers[client] = nil
end

function RequestBuffer:process(client)
  if not self.buffers[client].headers then
    return self:processHeaders(client)
  end
  if self.buffers[client].headers["content-length"] then
    return self:processBody(client)
  end
end

local httpRequestPattern = "([%S ]+\r\n)([%S \r\n]+)\r\n\r\n([%s%S]*)"
function RequestBuffer:processHeaders(client)
  local request = self.buffers[client].string
  local method, header, body = request:match(httpRequestPattern)
  if not method or not header or not body then return end
  
  local methodParts = method:gmatch("%S+")
  self.buffers[client].method = methodParts()
  self.buffers[client].path   = methodParts()
  self.buffers[client].ver    = methodParts()
  
  self.buffers[client].headers = {}
  header = header .. "\r\n"
  for key, value in header:gmatch("([%S]+): ([%S ]+)\r\n") do
    if key then
      self.buffers[client].headers[key:lower()] = value
    end
  end
  
  self.buffers[client].string = body
  
  if self.buffers[client].headers["content-length"] then
    self:processBody(client)
  else
    if self.onRequestFunc then
      self.onRequestFunc(
        client,
        self.buffers[client].method,
        self.buffers[client].path,
        self.buffers[client].ver,
        self.buffers[client].headers,
        nil)
    end
    self:prepareForNextRequest(client)
  end
end

function RequestBuffer:processBody(client)
  local length = tonumber(self.buffers[client].headers["content-length"])
  if self.buffers[client].string:len() >= length then
    local body = self.buffers[client].string:sub(0, length)
    self.buffers[client].string = self.buffers[client].string:sub(length+1)
    if self.onRequestFunc then
      self.onRequestFunc(
        client,
        self.buffers[client].method,
        self.buffers[client].path,
        self.buffers[client].ver,
        self.buffers[client].headers,
        body)
    end
    self:prepareForNextRequest(client)
  end
end

function RequestBuffer:prepareForNextRequest(client)
  self.buffers[client].method = nil
  self.buffers[client].path = nil
  self.buffers[client].ver = nil
  self.buffers[client].headers = nil
end
