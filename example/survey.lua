--[[
lua example/survey.lua server ipc:///tmp/survey.ipc & server=$!
lua example/survey.lua client ipc:///tmp/survey.ipc client0 & client0=$!
lua example/survey.lua client ipc:///tmp/survey.ipc client1 & client1=$!
lua example/survey.lua client ipc:///tmp/survey.ipc client2 & client2=$!
sleep 3
kill $server $client0 $client1 $client2
--]]

lnn = require "lnn"

local SERVER = "server"
local CLIENT = "client"
local DATE = "date"

function werrorf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stderr:write(str)
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	return io.stdout:write(str)
end

function server(url)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_SURVEYOR))
	assert(sock:bind(url))
	lnn.sleep(1000)
	print("SERVER: SENDING DATE SURVEY REQUEST")
	assert(sock:send(DATE))
	while true do
		local buf, err, errnum = sock:recv()
		--[[
		if errnum == lnn.ETIMEOUT then
			break
		end
		--]]
		if buf then
			printf('SERVER: RECEIVED "%s" SURVEY RESPONSE\n', buf)
		end
	end
	return sock:shutdown(0)
end

function client(url, name)
	local sock = assert(lnn.socket(lnn.AF_SP, lnn.NN_RESPONDENT))
	assert(sock:connect(url))
	while true do
		local buf = sock:recv()
		if buf then
			printf('CLIENT(%s): RECEIVED :"%s" SURVEY REQUEST\n', name, buf)
			printf('CLIENT(%s): SENDING DATE SURVEY RESPONSE\n', name)
			local text = string.format("%s from %s", os.date("%F %T"), name)
			assert(sock:send(text))
		end
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

