local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ModulesFolder = ServerScriptService:WaitForChild("Modules")
local ServerFolder = ServerScriptService:WaitForChild("Server")

local Utils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils"))
local DataSystem = require(ModulesFolder:WaitForChild("DataSystem"))
local ItemSystem = require(ModulesFolder:WaitForChild("ItemSystem"))
local Constants = require(ServerFolder:WaitForChild("Constants"))
local Types = require(ServerFolder:WaitForChild("Types"))

local InventorySystem = {}

-- Init
function InventorySystem.Init(): ()
	Utils.Player.ObservePlayers(function(player: Player): ()
		Utils.Character.ObserveCharacter(player, function(character: Model): ()
			InventorySystem._loadInventory(player)
		end)
	end)
	
	-- TODO: remove this when done testing or a way to get items is implemented
	ReplicatedStorage:WaitForChild("InventoryEditTEMP").OnServerEvent:Connect(function(player: Player, table): ()
		if not player or not player:IsA("Player") then
			return
		elseif not table or type(table) ~= "table" then
			return
		end

		for _, name in ipairs(table) do
			if not name or type(name) ~= "string" then
				continue
			end
			
			InventorySystem.AddItem(player, name)
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

-- Create a new tool from an item instance.
function InventorySystem._createTool(itemId: string, itemInstance: Types.ItemInstance): Tool
	local tool = itemInstance.Tool:Clone()
	tool:SetAttribute("Id", itemId)
	if itemInstance.CustomInfo then
		for key, value in itemInstance.CustomInfo do
			tool:SetAttribute(key, value)
		end
	end
	
	return tool
end

-- Loads a player's inventory. (removes old tools and adds new ones)
function InventorySystem._loadInventory(player: Player): ()
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

return InventorySystem
