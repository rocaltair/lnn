--[[
lua example/reqrep.lua node0 ipc:///tmp/reqrep.ipc & node0=$! && sleep 1
lua example/reqrep.lua node1 ipc:///tmp/reqrep.ipc
kill $node0
--]]

lnn = require "lnn"

local NODE0 = "node0"
local NODE1 = "node1"
local DATE = "DATE"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stdout:write(str)
end

function node0(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_REP))
	assert(sock:bind(url))
	while true do
		local buf = assert(sock:recv())
		if buf == DATE then
			print("NODE0: RECEIVED DATE REQUEST")
			local date = os.date("%F %T")
			printf("NODE0 : SENDING DATE %s\n", date)
			assert(sock:send(date))
		end
	end
	return sock:shutdown(0)
end

function node1(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_REQ))
	assert(sock:connect(url))
	printf("NODE1:SENDING DATE REQUEST %s\n", DATE)
	assert(sock:send(DATE))
	local buf = assert(sock:recv())
	printf("NODE1:RECEIVED DATE:'%s'\n", buf)

	return sock:shutdown(0)
end

function main(argc, argv)
	if argv[1] == NODE0 and argc > 1 then
		return node0(argv[2])
	elseif argv[1] == NODE1 and argc > 1 then
		return node1(argv[2])
	end
	werrorf("Usage: lua %s %s|%s <URL> <ARG> ...'\n", argv[0], NODE0, NODE1)
	return false
end

local ret = main(#arg, arg)
os.exit(ret and 0 or 1)

