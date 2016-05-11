-- shell : nanocat --pair --connect tcp://127.0.0.1:15001 --data 'ping' --format ascii

local lnn = require "lnn"
local s = lnn.socket(lnn.AF_SP, lnn.NN_PAIR)
local eid = s:bind('tcp://127.0.0.1:15001')

local list = { 
        {s, "rw"}
}


print("rcvfd", s:getsockopt(lnn.NN_SOL_SOCKET, lnn.NN_RCVFD))
print("sndfd", s:getsockopt(lnn.NN_SOL_SOCKET, lnn.NN_SNDFD))
-- print("poll", lnn.poll(list, 5000))
-- print("err", lnn.errno(), lnn.strerror())


while true do
	local pl, err = lnn.poll(list, 50)
	if pl and #pl > 0 then
		for _, row in pairs(pl) do
			local data, errno, err = row.sock:recv()
			print(data, errno, err)
			row.sock:send("pong")
		end
	end 
end
