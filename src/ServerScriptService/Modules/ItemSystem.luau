local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local ItemsFolder = ServerStorage.Assets.Items
local ItemsModulesFolder = ItemsFolder.Modules
local ItemsToolsFolder = ItemsFolder.Tools

local Utils = require(ReplicatedStorage.Shared.Utils)
local Types = require(ServerScriptService.Server.Types)

local ItemSystem = {
	_items = {} :: { [string]: Types.ItemInstance },
}

-- Init
function ItemSystem.Init(): ()
	for _, item: ModuleScript in ItemsModulesFolder:GetChildren() do
		if not item:IsA("ModuleScript") or CollectionService:HasTag(item, "Disabled") then
			continue
		end

		local module = require(item) :: Types.ItemModule
		if not ItemSystem._validateItemModule(module) then
			warn("Invalid item module: " .. item.Name)
			continue
		end

		local tool = ItemsToolsFolder:FindFirstChild(module.ToolName or item.Name)
		if not tool or not tool:IsA("Tool") then
			warn("Invalid tool for item: " .. item.Name)
			continue
		end

		if (module.DisplayName or tool.Name) ~= item.Name then
			tool = tool:Clone()
			tool.Name = module.DisplayName or item.Name
			tool.Parent = ItemsToolsFolder
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
