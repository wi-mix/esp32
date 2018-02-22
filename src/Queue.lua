Queue = {}
function Queue.new()
	local queue = {first = 0, last = -1}
	setmetatable(queue, {__index = Queue})
	return queue
end

function Queue:append(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function Queue:pop()
	local first = self.first
	if self:isEmpty() then error("empty queue") end
	local value = self[first]
	self[first] = nil
	self.first = first + 1
	if self:isEmpty() then
		self.first = 0
		self.last = -1
	end
	return value
end

function Queue:isEmpty()
	return self.first > self.last
end
