local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local InstanceUtils = require(script.Parent:WaitForChild("Instance"))

local MiscellaneousUtils = {}

function MiscellaneousUtils.GenerateId(wrapInCurlyBraces: boolean?): string
	return HttpService:GenerateGUID(wrapInCurlyBraces or false)
end

--[[
	Loads any assets in the function's parameter.
	This is useful for character animations and sounds, since they're loaded before they're used and they don't have to be loaded on the way.
]]
function MiscellaneousUtils.PreloadAssets(assets: string | Instance | { string } | { Instance }): ()
	task.defer(function()
		local loadedAssets = {}

		local function fetch(assetsToFetch: any)
			if typeof(assetsToFetch) == "table" then
				for _, asset in assetsToFetch do
					pcall(fetch, asset)
				end

				return
			end

			if typeof(assetsToFetch) ~= "string" and typeof(assetsToFetch) ~= "Instance" then
				return
			end

			if typeof(assetsToFetch) == "string" then
				if not assetsToFetch:find("://") and not tonumber(assetsToFetch) then
					return
				end

				if assetsToFetch:find("rbxassetid://") and RunService:IsClient() then
					local sound = Instance.new("Sound")
					sound.Name = assetsToFetch
					sound.SoundId = assetsToFetch
					sound.Volume = 0
					sound.Parent = SoundService
					sound:Play()

					InstanceUtils.AddToDebris(sound, 1)
				end
			end

			table.insert(loadedAssets, assetsToFetch)
		end

		pcall(fetch, assets)

		local success, error = pcall(function()
			return ContentProvider:PreloadAsync(loadedAssets)
		end)

		if not success then
			print(error)
			print(HttpService:JSONEncode(loadedAssets))
		end
	end)
end

-- Splits a path into multiple strings.
function MiscellaneousUtils.SplitStringPath(path: string): { string }
	return path:split(".")
end

return MiscellaneousUtils
