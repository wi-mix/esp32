-- StringFormat.lua
-- David Skrundz
--
-- sf = StringFormat.new()
-- sf[1] = "start "
-- sf[2] = 10
-- sf[3] = " end"
-- sf:render() -- "start 10 end"

StringFormat = {}
function StringFormat.new()
  local _stringformat = {}
  setmetatable(_stringformat, {__index = StringFormat})
  return _stringformat
end

function StringFormat:render()
  return table.concat(self)
end
