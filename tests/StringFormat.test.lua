-- StringFormat.test.lua
-- David Skrundz

package.path = "./../src/?.lua;" .. package.path
require "StringFormat"

Test:start("StringFormat")


sf = StringFormat.new()
sf[1] = "start "
sf[2] = 10
sf[3] = " end"
Test:assertEqual(sf:render(), "start 10 end", "sf:render()", "\"start 10 end\"")


Test:stop()
