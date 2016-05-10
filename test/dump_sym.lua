local l = require "lnn"

function printf(fmt, ...)
	return print(string.format(fmt, ...))
end

function dump_var()
	local keys = {}
	for k, v in pairs(l) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for _, k in pairs(keys) do
		local v = l[k]
		if type(v) == "function" then
			printf("lnn.%s = %s", k, tostring(v))
		end
	end
	for _, k in pairs(keys) do
		local v = l[k]
		if type(v) ~= "function" then
			printf("lnn.%s = %s", k, tostring(v))
		end
	end
end

function dump_symbol()
	local i = 0
	while true do
		i = i + 1
		local sym = l.symbol_info(i)
		if not sym then
			break
		end
		print(sym.ns, sym.name, sym.value, sym.type, sym.unit)
	end
end

dump_var()
dump_symbol()



