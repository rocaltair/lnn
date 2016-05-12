--[[
lua example/pubsub.lua server ipc:///tmp/pubsub.ipc & server=$! && sleep 1
lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client0 & client0=$!
lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client1 & client1=$!
lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client2 & client2=$!
sleep 5
kill $server $client0 $client1 $client2
--]]

lnn = require "lnn"

local SERVER = "server"
local CLIENT = "client"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stdout:write(str)
end

function server(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_PUB))
	assert(sock:bind(url))
	while true do
		local date = os.date("%F %T")
		printf("SERVER:PUBLISHING DATE:%s\n", date)
		assert(sock:send(date))
		lnn.sleep(1000)
	end
	return sock:shutdown(0)
end

function client(url, name)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_SUB))
	assert(sock:setsockopt(lnn.NN_SUB, lnn.NN_SUB_SUBSCRIBE, ""))
	assert(sock:connect(url))
	while true do
		local buf = sock:recv()
		printf('CLIENT(%s): RECEIVED :"%s"\n', name, buf)
	end
	sock:shutdown(0)
	return true
end

function main(argc, argv)
	if argc >= 2 and SERVER == argv[1] then
		return server(argv[2])
	elseif argc >= 3 and CLIENT == argv[1] then
		return client(argv[2], argv[3])
	end
	werrorf("Usage: lua %s %s|%s <URL> <ARG> ...\n", argv[0], SERVER, CLIENT)
	return false
end

local ret = main(#arg, arg)
os.exit(ret and 0 or 1)
