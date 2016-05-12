--[[
lua example/pipeline.lua node0 ipc:///tmp/pipeline.ipc & node0=$! && sleep 1
lua example/pipeline.lua node1 ipc:///tmp/pipeline.ipc "Hello, World."
lua example/pipeline.lua node1 ipc:///tmp/pipeline.ipc "Goodbye."
kill $node0
--]]

lnn = require "lnn"

local NODE0 = "node0"
local NODE1 = "node1"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function node0(url)
	local s = assert(lnn.socket(lnn.AF_SP, lnn.NN_PULL))
	assert(s:bind(url))
	while true do
		local buf = assert(s:recv())
		print("NODE0:RECEIVED", buf)
	end
	return true
end

function node1(url, msg)
	local s = assert(lnn.socket(lnn.AF_SP, lnn.NN_PUSH))
	assert(s:connect(url))
	print("NODE1:SENDING", msg)
	s:send(msg)
	return s:shutdown(0)
end

function main(argc, argv)
	if argv[1] == NODE0 and argc > 1 then
		return node0(argv[2])
	elseif argv[1] == NODE1 and argc > 2 then
		return node1(argv[2], argv[3])
	end
	werrorf("Usage: lua %s %s|%s <URL> <ARG> ...'\n", argv[0], NODE0, NODE1)
	return false
end

local ret = main(#arg, arg)
os.exit(ret and 0 or 1)

