lnn = require "lnn"

local addr = "tcp://127.0.0.1:15001"

local s = lnn.socket(lnn.AF_SP, lnn.NN_REP)
local eid = assert(s:bind(addr))

while true do
	local data = s:recv()
	if data then
		s:send("pong")
		print("rev", data)
	end
end
