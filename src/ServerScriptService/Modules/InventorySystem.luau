local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModulesFolder = ServerScriptService.Modules
local ServerFolder = ServerScriptService.Server

local Utils = require(ReplicatedStorage.Shared.Utils)
local DataSystem = require(ModulesFolder.DataSystem)
local ItemSystem = require(ModulesFolder.ItemSystem)
local Constants = require(ServerFolder.Constants)
local Types = require(ServerFolder.Types)

local InventorySystem = {}

-- Init
function InventorySystem.Init(): ()
	-- TODO: remove this when done testing or a way to get items is implemented
	ReplicatedStorage:WaitForChild("InventoryEditTEMP").OnServerEvent
		:Connect(function(player: Player, actionType: "add" | "remove", editTable: { string }): ()
			if not player or not player:IsA("Player") then
				return
			elseif not actionType then
				return
			elseif not editTable or type(editTable) ~= "table" then
				return
			end

			local loweredActionType = actionType:lower()
			if loweredActionType ~= "add" and loweredActionType ~= "remove" then
				return
			end

			for _, name in editTable do
				if not name or type(name) ~= "string" then
					continue
				end

				if loweredActionType == "add" then
					InventorySystem.AddItem(player, name)
				else
					InventorySystem.RemoveItem(player, name)
				end
			end
		end)
end

-- Add an item to a player's inventory.
function InventorySystem.AddItem(player: Player, itemName: string): boolean
	local itemInstance = ItemSystem.GetItem(itemName)
	if not itemInstance then
		return false
	end

	local playerBackpack = Utils.Player.GetBackpack(player)
	if not playerBackpack then
		return false
	end

	local itemId = Utils.Misc.GenerateId()
	local itemData: Types.ItemData = {
		Name = itemName,
	}

	DataSystem.EditPlayerData(player, function(playerData): ()
		playerData.Inventory[itemId] = itemData
	end)

	local tool = InventorySystem._createTool(itemId, itemInstance)
	tool.Parent = playerBackpack

	return true
end

-- Remove an item from a player's inventory.
function InventorySystem.RemoveItem(player: Player, itemId: string): boolean
	local playerBackpack = Utils.Player.GetBackpack(player)
	if not playerBackpack then
		return false
	end

	local tool = InventorySystem._findToolByGuid(playerBackpack, itemId)
		or player.Character and InventorySystem._findToolByGuid(player.Character, itemId)

	if tool then
		tool:Destroy()
	end

	DataSystem.EditPlayerData(player, function(playerData): ()
		playerData.Inventory[itemId] = nil
	end)

	return true
end

-- Loads a player's inventory. (clears backpack and adds the tools)
function InventorySystem.LoadInventory(player: Player): ()
	local profileData = DataSystem.GetPlayerData(player)
	if not profileData then
		player:Kick(Constants.ERROR_CODES.PROFILE.DATA_LOAD_FAIL)
		return
	end

	local playerBackpack = Utils.Player.GetBackpack(player)
	if not playerBackpack then
		return
	end
	playerBackpack:ClearAllChildren()

	for itemId, itemData in profileData.Inventory do
		local itemInstance = ItemSystem.GetItem(itemData.Name)
		if not itemInstance then
			continue
		end

		local tool = InventorySystem._createTool(itemId, itemInstance)
		tool.Parent = playerBackpack
	end
end

-- Create a new tool from an item instance.
function InventorySystem._createTool(itemId: string, itemInstance: Types.ItemInstance): Tool
	local tool = itemInstance.Tool:Clone()
	tool:SetAttribute("GUID", itemId)
	if itemInstance.CustomInfo then
		for key, value in itemInstance.CustomInfo do
			tool:SetAttribute(key, value)
		end
	end

	return tool
end

function InventorySystem._findToolByGuid(container: Instance, guid: string): Tool?
	for _, child in container:GetChildren() do
		if child:IsA("Tool") and child:GetAttribute("GUID") == guid then
			return child
		end
	end

	return nil
end

return InventorySystem
