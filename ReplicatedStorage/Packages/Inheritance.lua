local module = {}

function module.merge(Table1: table, Table2: table)
	local new_table = Table2

	for key, value in pairs(Table1) do
		if typeof(key) == "number" then
			table.insert(new_table, value)
		else
			new_table[key] = value
		end
	end

	return new_table
end

return module