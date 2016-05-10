local lnn = require "lnn"
local addr = "tcp://127.0.0.1:15001"

local s = lnn.socket(lnn.AF_SP, lnn.NN_PUB)
local eid = assert(s:bind(addr))

function test()
	while true do
		local time = os.date("%F %T")
		s:send(time)
		print("send", time)
		lnn.sleep(5000)
	end
end

test()
