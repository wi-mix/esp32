-- Test.lua
-- David Skrundz

Test = {tests = {}}
function Test:start(name)
  self.current = name
  self.tests[self.current] = {count = 0, failed = 0, failures = {}}
  print("----- " .. self.current .. " Tests -----")
end

function Test:assertEqual(left, right, str1, str2)
  if not self.current then error("Testing not started") end
  print("Testing " .. str1 .. " == " .. str2)
  if left ~= right then
    self.tests[self.current].failed = self.tests[self.current].failed + 1
    self.tests[self.current].failures[self.tests[self.current].failed] = tostring(left) .. " is not equal to " .. tostring(right)
  end
  self.tests[self.current].count = self.tests[self.current].count + 1
end

function Test:assertTrue(val, str)
  if not self.current then error("Testing not started") end
  print("Testing " .. str .. " is true")
  if val ~= true then
    self.tests[self.current].failed = self.tests[self.current].failed + 1
    self.tests[self.current].failures[self.tests[self.current].failed] = tostring(val) .. " is not true"
  end
  self.tests[self.current].count = self.tests[self.current].count + 1
end

function Test:assertFalse(val, str)
  if not self.current then error("Testing not started") end
  print("Testing " .. str .. " is true")
  if val ~= false then
    self.tests[self.current].failed = self.tests[self.current].failed + 1
    self.tests[self.current].failures[self.tests[self.current].failed] = tostring(val) .. " is not false"
  end
  self.tests[self.current].count = self.tests[self.current].count + 1
end

function Test:stop()
  self.current = nil
end

function Test:isStopped()
  return not not self.current
end


function runTest(file)
  dofile(file)
  if Test:isStopped() then error("Testing not stopped") end
end

function stringHasSuffix(self, suffix)
  return suffix == '' or self:sub(-suffix:len()) == suffix
end

path = debug.getinfo(1, "S").source:match("^@?(.*[\/])[^\/]-$")
if not path then path = "" end
path = "./" .. path

for file in io.popen("ls -1 " .. path):lines() do
  if stringHasSuffix(file, ".test.lua") then
    runTest(path .. file)
  end
end

print("")
for name, data in pairs(Test.tests) do
  print("--- " .. name)
  print("Tests: " .. data.count)
  print("Failed: " .. data.failed)
  for _, str in pairs(data.failures) do
    print("-> " .. str)
  end
end
