--[[
lua example/bus.lua node0 ipc:///tmp/node0.ipc ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc & node0=$!
lua example/bus.lua node1 ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node1=$!
lua example/bus.lua node2 ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node2=$!
lua example/bus.lua node3 ipc:///tmp/node3.ipc ipc:///tmp/node0.ipc & node3=$!
sleep 5
kill $node0 $node1 $node2 $node3
--]]

lnn = require "lnn"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stdout:write(str)
end

function node(argc, argv)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_BUS))
	assert(sock:bind(argv[2]))
	lnn.sleep(1000)
	if argc >= 3 then
		for x = 3, argc do
			assert(sock:connect(argv[x]))
		end
	end
	lnn.sleep(1000)
	local timeout = 100
	assert(sock:setsockopt(lnn.NN_SOL_SOCKET, lnn.NN_RCVTIMEO, 100))

	printf("%s:SENDING '%s' ONTO BUS\n", argv[1], argv[1])
	sock:send(argv[1])

	while true do
		local buf = sock:recv()
		if buf then
			printf("%s:RECEIVED '%s' FROM BUS\n", argv[1], buf)
		end
	end
	return sock:shutdown(0)
end

function main(argc, argv)
	if argc >= 3 then
		return node(argc, argv)
	end
	werrorf("Usage: lua %s %s|%s <URL> <ARG> ...\n", argv[0], SERVER, CLIENT)
	return false
end

local ret = main(#arg, arg)
os.exit(ret and 0 or 1)

