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
CONST.ssid = "ManInTheVan"
CONST.pass = "vanmancanwan"
CONST.port = 80

CONST.http200 = "200 OK"
CONST.http201 = "201 Created"
CONST.http409 = "409 Conflict"

CONST.http404Response = "HTTP/1.1 404 Not found\r\nContent-Type: application/json\r\nContent-Length: 13\r\n\r\n{\"error\":404}"

CONST.httpStatus = 2
CONST.httpLength = 6
CONST.httpIndex = 8
CONST.httpResponse = StringFormat.new()
CONST.httpResponse[1] = "HTTP/1.1 "
CONST.httpResponse[2] = ""
CONST.httpResponse[3] = "\r\n"
CONST.httpResponse[4] = "Content-Type: application/json\r\n"
CONST.httpResponse[5] = "Content-Length: "
CONST.httpResponse[6] = 0
CONST.httpResponse[7] = "\r\n\r\n"
CONST.httpResponse[8] = ""

CONST.wiREAD_LEVEL   = 0
CONST.wiDISPENSE_REQ = 1
CONST.wiDISPENSE     = 2
