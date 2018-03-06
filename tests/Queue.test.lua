-- Queue.test.lua
-- David Skrundz

package.path = "./../src/?.lua;" .. package.path
require "Queue"

Test:start("Queue")


q = Queue.new()
Test:assertTrue(q:isEmpty(), "q:isEmpty()")
q:append(1)
Test:assertFalse(q:isEmpty(), "q:isEmpty()")
Test:assertEqual(q:pop(), 1, "q:pop()", 1)
Test:assertTrue(q:isEmpty(), "q:isEmpty()")
q:append(2)
Test:assertFalse(q:isEmpty(), "q:isEmpty()")
q:append(3)
Test:assertFalse(q:isEmpty(), "q:isEmpty()")
Test:assertEqual(q:pop(), 2, "q:pop()", 2)
q:append(4)
Test:assertFalse(q:isEmpty(), "q:isEmpty()")
Test:assertEqual(q:pop(), 3, "q:pop()", 3)
Test:assertEqual(q:pop(), 4, "q:pop()", 4)
Test:assertTrue(q:isEmpty(), "q:isEmpty()")


Test:stop()
