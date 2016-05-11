lnn = require "lnn"

local addr = "tcp://127.0.0.1:15001"

local s = lnn.socket(lnn.AF_SP, lnn.NN_REQ)
local eid = assert(s:connect(addr))
print("eid", eid)

local len, err, errnum = s:send("ping")
print("send", len, err, errnum)

local data, err, errnum = s:recv()
print("recv", data, errnum)

