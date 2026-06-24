local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Janitor"))
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local PlayerUtils = {}

--[[
	Get a player's backpack.
	@yields
]]
function PlayerUtils.GetBackpack(player: Player): Backpack?
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		repeat
			task.wait()
		until backpack or not player.Parent

		if not player.Parent then
			return nil
		end

		backpack = player:FindFirstChildOfClass("Backpack")
	end

	return backpack
end

-- Equivalent to `Players.PlayerAdded:Connect()` but connections are handled by Janitor.
function PlayerUtils.ObservePlayers(callback: (player: Player, playerJanitor: Types.Janitor) -> ()): Types.Janitor
	local mainJanitor = Janitor.new()

	local function onNewPlayer(player: Player): ()
		task.spawn(callback, player, mainJanitor:AddObject(Janitor, nil, player))
	end

	for _, player in Players:GetPlayers() do
		task.spawn(onNewPlayer, player)
	end

	mainJanitor:Add(Players.PlayerAdded:Connect(onNewPlayer))
	mainJanitor:Add(Players.PlayerRemoving:Connect(function(player: Player): ()
		mainJanitor:Remove(player)
	end))

	return mainJanitor
end

return PlayerUtils
