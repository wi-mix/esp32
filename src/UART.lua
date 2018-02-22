-- UART.lua
--
-- u = UART.init(<baud>, <bits>, <parity>, <stopBits>)
-- u:onError(function(err) ... end)
-- u:onData(function(data) ... end)
-- u:write(<data>)

UART = {}
function UART.init(baud, bits, parity, stopBits)
	local _uart = {}
	setmetatable(_uart, {__index = UART})

	uart.on("data", 0, function(data)
		if self.onDataFunc then
			self.onDataFunc(data)
		end
	end, 0)
	uart.on("error", function(err)
		if self.onErrorFunc then
			self.onErrorFunc(err)
		end
	end)
	uart.setup(0, baud, bits, parity, stopBits, 0)

	return _uart
end

function UART:write(data)
	uart.write(0, data)
end

function UART:onError(func)
	self.onErrorFunc = func
end

function UART:onData(func)
	self.onDataFunc = func
end
