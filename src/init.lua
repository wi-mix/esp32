-- init.lua
-- David Skrundz

local wait = tmr.create()
wait:alarm(2000, tmr.ALARM_SINGLE, function()
  dofile("Main.lc")
end)
print("Waiting 2 seconds before starting...")
