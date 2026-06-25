local TableUtils = {}
local Rand = Random.new()

-- Makes a copy of an entire table.
function TableUtils.CopyTable<T>(cloneTable: T): T
	if type(cloneTable) ~= "table" then
		return cloneTable
	end

	local newTable = {}

	for key, value in cloneTable :: any do
		if typeof(value) == "table" then
			newTable[key] = TableUtils.CopyTable(value)

			local metaTable = getmetatable(value)
			if metaTable then
				setmetatable(newTable[key], metaTable)
			end
		else
			newTable[key] = value
		end
	end

	local metaTable = getmetatable(cloneTable)
	if metaTable then
		setmetatable(newTable, metaTable)
	end

	return newTable :: T & {}
end

--[[
	Converts a dictionary into an array.
	If convertType is "Key", the returned array contains the dictionary's keys.
	If convertType is "Value", the returned array contains the dictionary's values.
	The order of elements in the returned array is not guaranteed.
]]
function TableUtils.ConvertDictToArray<Key, Value>(
	dictionary: { [Key]: Value },
	convertType: "Keys" | "Values"
): { Key } | { Value }
	local newTable = {}

	for key, value in dictionary do
		if convertType == "Keys" then
			table.insert(newTable, key)
		elseif convertType == "Values" then
			table.insert(newTable, value)
		end
	end

	return newTable
end

--[[
	Counts the items inside a dictionary.
	Resource wasting for arrays. (use #)
]]
function TableUtils.GetDictionaryCount(dict: { [any]: any }): number
	local count = 0

	for _ in dict do
		count += 1
	end

	return count
end

--[[
	Gets a random key from the provided dictionary.
]]
function TableUtils.GetRandomKeyFromDictionary<Key, Value>(target: { [Key]: Value }): Key?
	-- turn into a table
	local convertedTable = TableUtils.ConvertDictToArray(target, "Keys")

	-- if it's empty return nothing
	if #convertedTable <= 0 then
		return nil
	end

	-- if it only has one item just return the item
	if #convertedTable == 1 then
		return convertedTable[1]
	end

	-- return a random index from the table
	return convertedTable[Rand:NextInteger(1, #convertedTable)]
end

--[[
	Checks if a table is either a dictionary or an array.
	Mixed tables (containing numbers and others as keys) will be treated as dictionaries as well.
	This util is useless if the table is empty for obvious reasons.
]]
function TableUtils.IsTableADictionary(target: { [any]: any }): boolean
	for key, _ in target do
		if typeof(key) ~= "number" then
			return true
		end
	end

	return false
end

return TableUtils
