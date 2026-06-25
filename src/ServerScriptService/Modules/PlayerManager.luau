local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Utils = require(ReplicatedStorage.Shared.Utils)
local InventorySystem = require(ServerScriptService.Modules.InventorySystem)

local PlayerManager = {}

function PlayerManager.Init()
	Utils.Player.ObservePlayers(function(player: Player): ()
		Utils.Character.ObserveCharacter(player, function(): ()
			InventorySystem.LoadInventory(player)
		end)
	end)
end

return PlayerManager
