-- Constants.lua
-- David Skrundz
--
-- CONST.ssid
-- CONST.pass
-- CONST.port
--
-- CONST.httpLength
-- CONST.httpIndex
-- CONST.httpResponse

dofile("StringFormat.lc")

CONST = {}
CONST.ssid = ""
CONST.pass = ""
CONST.port = 80

CONST.httpLength = 4
CONST.httpIndex = 6
CONST.httpResponse = StringFormat.new()
CONST.httpResponse[1] = "HTTP/1.1 200 OK\n"
CONST.httpResponse[2] = "Content-Type: text/html\n"
CONST.httpResponse[3] = "Content-Length: "
CONST.httpResponse[4] = 0
CONST.httpResponse[5] = "\n\n"
CONST.httpResponse[6] = ""
