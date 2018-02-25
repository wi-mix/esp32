-- LED.lua
-- David Skrundz
--
-- l = LED.init()
-- l.on()
-- l.off()
-- l.blink(ms)

LED = {pin = 2, value = 0}
function LED.init()
  gpio.config({gpio={LED.pin}, dir=gpio.OUT})
end

function LED.set()
  gpio.write(LED.pin, LED.value)
end

function LED.on()
  LED.value = 1
  LED.unblink()
  LED.set()
end

function LED.off()
  LED.value = 0
  LED.unblink()
  LED.set()
end

function LED.blink(ms)
  if ms < 50 then return end
  LED.unblink()
  LED.timer = tmr.create()
  LED.timer:alarm(ms, tmr.ALARM_AUTO, function()
    LED.value = 1 - LED.value
    LED.set()
  end)
end

function LED.unblink()
  if LED.timer then
    LED.timer:unregister()
    LED.timer = nil
  end
end
