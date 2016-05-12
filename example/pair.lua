--[[
lua example/pair.lua node0 ipc:///tmp/pair.ipc & node0=$!
lua example/pair.lua node1 ipc:///tmp/pair.ipc & node1=$!
sleep 3
kill $node0 $node1
--]]

lnn = require "lnn"

local NODE0 = "node0"
local NODE1 = "node1"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stdout:write(str)
end

function send_name(sock, name)
	printf('%s : SENDING "%s"\n', name, name)
	return sock:send(name)
end

function recv_name(sock, name)
	local buf = sock:recv()
	if buf then
		printf('%s: RECEIVED "%s"\n', name, buf)
	end
	return buf and string.len(buf) or 0
end

function send_recv(sock, name)
	local timeout = 100
	assert(sock:setsockopt(lnn.NN_SOL_SOCKET, lnn.NN_RCVTIMEO, timeout))
	while true do
		recv_name(sock, name)
		lnn.sleep(1000)
		send_name(sock, name)
	end
end

function node0(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_PAIR))
	assert(sock:bind(url))
	send_recv(sock, NODE0)
	return sock:shutdown(0)
end

function node1(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_PAIR))
	assert(sock:connect(url))
	send_recv(sock, NODE1)
	return sock:shutdown(0)
end

function main(argc, argv)
	if NODE0 == argv[1] and argc > 1 then
		return node0(argv[2])
	elseif NODE1 == argv[1] and argc > 1  then
		return node1(argv[2])
	end
	werrorf("Usage: lua %s %s|%s <URL> <ARG> ...\n", argv[0], NODE0, NODE2)
	return false
end

local ret = main(#arg, arg)
os.exit(ret and 0 or 1)
