local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local ItemsFolder = ServerStorage:WaitForChild("Assets"):WaitForChild("Items")
local ItemsModulesFolder = ItemsFolder:WaitForChild("Modules")
local ItemsToolsFolder = ItemsFolder:WaitForChild("Tools")

local Utils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils"))
local Types = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Types"))

local ItemSystem = {
	_items = {} :: { [string]: Types.ItemInstance },
}

-- Init
function ItemSystem.Init(): ()
	for _, item: ModuleScript in ItemsModulesFolder:GetChildren() do
		if not item:IsA("ModuleScript") or CollectionService:HasTag(item, "Disabled") then
			continue
		end
		
		local tool = ItemsToolsFolder:FindFirstChild(item.Name)
		if not tool or not tool:IsA("Tool") then
			warn("Invalid tool for item: " .. item.Name)
			continue
		end
		
		local module = require(item) :: Types.ItemModule
		if not ItemSystem._validateItemModule(module) then
			warn("Invalid item module: " .. item.Name)
			continue
		end
		
		local itemInstance = {
			Tool = tool,
		} :: Types.ItemInstance
		for key, value in pairs(module :: { [string]: any }) do
			itemInstance[key] = value
		end
		
		ItemSystem._items[item.Name] = itemInstance
	end
end

--[[
	Get an item by name.
	DO NOT MUTATE THE RETURNED TABLE AS IT WILL NOT UPDATE THE ITEM INSTANCE.
]]
function ItemSystem.GetItem(itemName: string): Types.ItemInstance?
	local itemInstance = ItemSystem._items[itemName]
	if not itemInstance then
		return nil
	end
	
	return Utils.Table.CopyTable(itemInstance)
end

-- Validate an item module.
function ItemSystem._validateItemModule<T>(module: T & Types.ItemModule): boolean
	if module.Stackable == nil then
		return false
	end
	
	return true
end

return ItemSystem
