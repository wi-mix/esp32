-- init.lua
-- David Skrundz

print("Waiting 2 seconds before starting...")
print("run `halt()` to stop")

local wait = tmr.create()
wait:alarm(2000, tmr.ALARM_SINGLE, function()
  dofile("Main.lc")
end)

function halt()
  wait:unregister()
  wait = nil
end
