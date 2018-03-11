-- FS.lua
-- David Skrundz
--
-- FS.forEachFile("lua", function(name) print(name) end)
-- FS.deleteAll()
-- FS.cleanup()
-- data = FS.read(file)
-- FS.write(file, data)

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
    if name == "init.lua" then return end
    file.remove(name)
  end)
  file.remove("init.lc")
end

function FS.read(fileName)
  if file.open(fileName, "r") then
    local str = file.read()
    file.close()
    return str
  end
  return nil
end

function FS.write(fileName, data)
  if file.open(fileName, "w+") then
    file.write(data)
    file.close()
  end
end

function stringHasSuffix(self, suffix)
  return suffix == '' or self:sub(-suffix:len()) == suffix
end
