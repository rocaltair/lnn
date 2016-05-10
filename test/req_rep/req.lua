lnn = require "lnn"

local addr = "tcp://127.0.0.1:15001"

local s = lnn.socket(lnn.AF_SP, lnn.NN_REQ)
local eid = assert(s:connect(addr))
print("eid", eid)

function block()
	local len, errnum, err = s:send("ping")
	print("send", len, errnum, err)

	local data, errnum, err = s:recv(200)
	print("recv", data)
end

block()

