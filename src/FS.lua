-- FS.lua
-- David Skrundz
--
-- FS.forEachFile("lua", function(name) print(name) end)
-- FS.deleteAll()
-- FS.cleanup()

FS = {}
function FS.forEachFile(extension, callback)
  local files = file.list()
  for name, _ in pairs(files) do
    if stringHasSuffix(name, extension) then
      callback(name)
    end
  end
end

function FS.deleteAll()
  local files = file.list()
  for name, _ in pairs(files) do
    file.remove(name)
  end
end

function FS.cleanup()
  FS.forEachFile(".lua", function(name)
    file.remove(name)
  end)
end

function stringHasSuffix(self, suffix)
  return suffix == '' or self:sub(-suffix:len()) == suffix
end
