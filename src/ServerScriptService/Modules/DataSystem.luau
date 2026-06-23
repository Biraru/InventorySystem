local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ServerFolder = ServerScriptService:WaitForChild("Server")

local FastSignal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("FastSignal"))
local Types = require(SharedFolder:WaitForChild("Types"))
local Utils = require(SharedFolder:WaitForChild("Utils"))
local Constants = require(ServerFolder:WaitForChild("Constants"))
local Templates = require(ServerFolder:WaitForChild("Templates"))
local ProfileStore = require(ServerScriptService:WaitForChild("Packages"):WaitForChild("ProfileStore"))

type Profile = ProfileStore.Profile<Templates.PlayerData>
local PlayerStore = ProfileStore.New(Constants.DATASTORE_KEY, Templates.PLAYER_DATA) -- had to type cast since the second param isn't typed properly
local DataSystem = {
	-- Signals
	Signals = {
		DataUpdated = FastSignal.new() :: FastSignal.ScriptSignal<Player>,
	},
	
	-- Table holding all the player profiles
	_profiles = {} :: { [number]: Profile }
}

-- Init
function DataSystem.Init(): ()
	Utils.Player.ObservePlayers(function(player: Player, playerJanitor: Types.Janitor): ()
		DataSystem._loadProfile(player)

		playerJanitor:Add(function(): ()
			DataSystem._unloadProfile(player)
		end, true)
	end)
end

--[[
	Get a player's data.
	DO NOT MUTATE THE RETURNED TABLE AS IT WILL NOT UPDATE THE PROFILE.
	USE "DataSystem.EditPlayerData" INSTEAD.
]]
function DataSystem.GetPlayerData(player: Player): Templates.PlayerData?
	local profile = DataSystem._getProfile(player)
	if not profile then
		return nil
	end
	
	local profileDataClone = Utils.Table.CopyTable(profile.Data)
	return profileDataClone :: Templates.PlayerData
end

-- Edit a player's data.
function DataSystem.EditPlayerData(player: Player, editFunction: (playerData: Templates.PlayerData) -> ()): ()
	local profile = DataSystem._getProfile(player)
	if not profile then
		return
	end
	
	editFunction(profile.Data)
	
	-- future proofing for when its needed to get data changes
	DataSystem.Signals.DataUpdated:Fire(player)
end

-- Load a player's profile (data).
function DataSystem._loadProfile(player: Player): ()
	local playerId = player.UserId

	if DataSystem._profiles[playerId] then
		return
	end

	local profile = PlayerStore:StartSessionAsync(`{playerId}`, {
		Cancel = function(): boolean
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		return player:Kick(Constants.ERROR_CODES.PROFILE.LOAD_FAIL)
	end

	profile:AddUserId(playerId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function(): ()
		DataSystem._profiles[playerId] = nil
		player:Kick(Constants.ERROR_CODES.PROFILE.SESSION_ENDED)
	end)

	if not (player.Parent == Players) then
		profile:EndSession()
	end

	DataSystem._profiles[playerId] = profile
end

-- Unload a player's profile (data) if it exists.
function DataSystem._unloadProfile(player: Player): boolean
	local profile = DataSystem._profiles[player.UserId]

	if profile ~= nil then
		profile:EndSession()

		return true
	end

	return false
end

-- Gets a player's profile (data) if it exists, if not it will wait until it does (or until it times out)
function DataSystem._getProfile(player: Player): Profile?
	local profile = DataSystem._profiles[player.UserId]
	if not profile then
		local startTime = os.time()
		repeat
			task.wait()
		until DataSystem._profiles[player.UserId] and os.time() - startTime < Constants.DATA_TIMEOUT

		profile = DataSystem._profiles[player.UserId]
	end

	return profile
end

return DataSystem
