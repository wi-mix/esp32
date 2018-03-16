-- RequestBuffer.test.lua
-- David Skrundz

package.path = "./../src/?.lua;" .. package.path
require "RequestBuffer"

Test:start("RequestBuffer")


data = {}
data.client = nil
data.method = nil
data.path = nil
data.version = nil
data.header = nil
data.body = nil
data.called = false

rb = RequestBuffer.new()
rb:onRequest(function(client, method, path, version, headers, body)
  data.client = client
  data.method = method
  data.path = path
  data.version = version
  data.header = headers
  data.body = body
  data.called = true
end)

rb:append(1, "A B C\r\nD: E\r\n\r\n")
Test:assertTrue(data.called, "called")
Test:assertEqual(data.client, 1, "client", 1)
Test:assertEqual(data.method, "A", "method", "A")
Test:assertEqual(data.path, "B", "path", "B")
Test:assertEqual(data.version, "C", "version", "C")
Test:assertEqual(data.header["d"], "E", "header[\"D\"]", "E")
Test:assertNil(data.body, "body")
data.called = false

rb:append(1, "A B C\r\nD: E\r\n")
rb:drop(1)
rb:append(1, "A B C\r\ncontent-length: 3\r\n\r\nABCZ Z Z\r\n")
Test:assertTrue(data.called, "called")
Test:assertEqual(data.client, 1, "client", 1)
Test:assertEqual(data.method, "A", "method", "A")
Test:assertEqual(data.path, "B", "path", "B")
Test:assertEqual(data.version, "C", "version", "C")
Test:assertEqual(data.body, "ABC", "body", "ABC")
data.called = false

print(rb.buffers[1].string)

rb:append(1, "X: no\r\n\r\n")
Test:assertTrue(data.called, "called")
Test:assertEqual(data.client, 1, "client", 1)
Test:assertEqual(data.method, "Z", "method", "Z")
Test:assertEqual(data.path, "Z", "path", "Z")
Test:assertEqual(data.version, "Z", "version", "Z")
Test:assertEqual(data.header["x"], "no", "header[\"X\"]", "no")
Test:assertNil(data.body, "body")
data.called = false

rb:append(1, "A B C\r\nA: A\r\n")
rb:append(2, "\r\n")
Test:assertFalse(data.called, "called")
rb:append(3, "G H J\r\nB: B\r\n\r\n")
Test:assertTrue(data.called, "called")
Test:assertEqual(data.client, 3, "client", 3)
Test:assertEqual(data.method, "G", "method", "G")
Test:assertEqual(data.path, "H", "path", "H")
Test:assertEqual(data.version, "J", "version", "J")
Test:assertEqual(data.header["b"], "B", "header[\"B\"]", "B")
Test:assertNil(data.body, "body")
data.called = false


Test:stop()
