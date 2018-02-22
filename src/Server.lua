-- Server.lua
--
-- s = Server.new()
-- s:listen(port, function(client) ... end)
-- port, ip = s:address()
-- s:close()
--
-- c = client -- from s:listen
-- c:onConnection(function(client) ... end)
-- c:onReconnection(function(client, err) ... end)
-- c:onDisconnection(function(client, err) ... end)
-- c:onReceive(function(client, data) ... end)
-- c:onSent(function(client) ... end)
-- port, ip = c:address()
-- port, ip = c:peerAddress()
-- c:send(data)

Client = {}
function Client.new(connection)
	local _client = {conn = connection}
	setmetatable(_client, {__index = Client})

	self.conn:on("connection", function (socket)
		if self.onConnectionFunc then
			self.onConnectionFunc(self)
		end
	end)
	self.conn:on("reconnection", function (socket, err)
		if self.onReconnectionFunc then
			self.onReconnectionFunc(self, err)
		end
	end)
	self.conn:on("disconnection", function (socket, err)
		if self.onDisconnectionFunc then
			self.onDisconnectionFunc(self, err)
		end
	end)
	self.conn:on("receive", function (socket, data)
		if self.onReceiveFunc then
			self.onReceiveFunc(self, data)
		end
	end)
	self.conn:on("sent", function (socket)
		if self.onSentFunc then
			self.onSentFunc(self)
		end
	end)

	return _client
end

function Client:address()
	return self.conn:getaddr()
end

function Client:peerAddress()
	return self.conn:getpeer()
end

function Client:send(data)
	self.conn:send(data)
end

function Client:close()
	self.conn:close()
	self.conn = nil
end

function Client:onConnection(func)
	self.onConnectionFunc = func
end

function Client:onReconnection(func)
	self.onReconnectionFunc = func
end

function Client:onDisconnection(func)
	self.onDisconnectionFunc = func
end

function Client:onReceive(func)
	self.onReceiveFunc = func
end

function Client:onSent(func)
	self.onSentFunc = func
end

Server = {}
function Server.new()
	local _server = {}
	setmetatable(_server, {__index = Server})

	_server.net = net.createServer(net.TCP, 30)

	return _server
end

function Server:listen(port, callback)
	self.net:listen(port, function(connection)
		callback(Client.new(connection))
	end)
end

function Server:address()
	return self.net:getaddr()
end

function Server:close()
	self.net:close()
	self.net = nil
end
