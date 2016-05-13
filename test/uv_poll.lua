--[[
shell:
	nanocat --pair --connect tcp://127.0.0.1:15001 --data 'ping' --format ascii

luv:
	lua-binding for libuv
	libuv : https://github.com/joyent/libuv
	luv : https://github.com/luvit/luv

--]]

uv = require "luv"
lnn = require "lnn"

local sock = lnn.socket(lnn.AF_SP, lnn.NN_PAIR)
assert(sock:bind('tcp://127.0.0.1:15001'))

local fd = sock:getsockopt(lnn.NN_SOL_SOCKET, lnn.NN_RCVFD)
local poll = uv.new_poll(fd)

local sigint = uv.new_signal()
uv.signal_start(sigint, "sigint", function(signal)
	print("got " .. signal .. ", shutting down")
	poll:stop()
	sock:shutdown()
	os.exit(0)
end)

print("start poll", fd)
poll:start("r", function(err, events)
	print("on poll", err, events)
	local data, err, errnum = sock:recv()
	sock:send("pong")
	print("RECEIVED:", data)
end)

uv.run()
