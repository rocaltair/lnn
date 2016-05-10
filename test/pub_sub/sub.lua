local lnn = require "lnn"
local addr = "tcp://127.0.0.1:15001"

local s = lnn.socket(lnn.AF_SP, lnn.NN_SUB)
s:setsockopt(lnn.NN_SUB, lnn.NN_SUB_SUBSCRIBE, "")
local eid = assert(s:connect(addr))

while true do
	local data = s:recv()
	print("recv", data)
end
