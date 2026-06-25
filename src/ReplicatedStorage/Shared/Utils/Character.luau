local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PackagesFolder = ReplicatedStorage:WaitForChild("Packages")

local Janitor = require(PackagesFolder:WaitForChild("Janitor"))
local Promise = require(PackagesFolder:WaitForChild("TypedPromise"))
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local InstanceUtils = require(script.Parent:WaitForChild("Instance"))

local CharacterUtils = {}

-- Equivalent to `Player.CharacterAdded:Connect()` but managed by Janitor.
function CharacterUtils.ObserveCharacter(
	player: Player,
	callback: (character: Model, characterJanitor: Types.Janitor) -> ()
): Types.Janitor
	local mainJanitor = Janitor.new()
	mainJanitor:LinkToInstance(player)

	local function onCharacterAdded(character: Model): ()
		mainJanitor:AddPromise(Promise.new(function(resolve: () -> ()): ()
			CharacterUtils.WaitForCharacterLoaded(character)

			return resolve()
		end):andThen(function(): ()
			task.defer(callback, character, mainJanitor:AddObject(Janitor, nil, "LastCharacter"))
		end))
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
	mainJanitor:Add(player.CharacterAdded:Connect(onCharacterAdded))

	return mainJanitor
end

--[[
	Equivalent to waiting for a player's character's humanoid to appear.
	It will execute code whenever a `Humanoid` appears in a player's character.
]]
function CharacterUtils.ObserveHumanoid(
	player: Player,
	callback: (humanoid: Humanoid, humanoidJanitor: Types.Janitor) -> ()
): Types.Janitor
	return CharacterUtils.ObserveCharacter(player, function(character: Model, characterJanitor: Types.Janitor): ()
		characterJanitor:Add(
			InstanceUtils.ObserveChildrenWhichIsA(
				character,
				"Humanoid",
				function(humanoid: Humanoid, childJanitor: Types.Janitor): ()
					local aliveJanitor = childJanitor:AddObject(Janitor)

					aliveJanitor:Add(CharacterUtils.ObserveOnDeath(humanoid, function(): ()
						aliveJanitor:Cleanup()
					end))

					callback(humanoid, aliveJanitor)
				end
			)
		)
	end)
end

-- Equal to `Humanoid.Died:Connect()` but managed by Janitor.
function CharacterUtils.ObserveOnDeath(humanoid: Humanoid, callback: () -> ()): Types.Janitor
	local mainJanitor = Janitor.new()
	mainJanitor:LinkToInstance(humanoid)

	local alreadyDied = false
	local function onDied(): ()
		if alreadyDied then
			return
		end
		alreadyDied = true

		callback()
	end

	mainJanitor:Add(InstanceUtils.ObserveProperty(humanoid, "Health", function(health: number): ()
		if health > 0 then
			return
		end
		onDied()
	end))
	mainJanitor:Add(InstanceUtils.ObserveParent(humanoid, function(parent: Instance): ()
		if parent ~= nil then
			return false
		end
		
		onDied()
		return true
	end))

	mainJanitor:Add(humanoid.Died:Connect(onDied))

	return mainJanitor
end

--[[
	Waits for a character to properly load.
	@yields
]]
function CharacterUtils.WaitForCharacterLoaded(character: Model): ()
	if not character.PrimaryPart then
		character:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	if not character:IsDescendantOf(Workspace) then
		character.AncestryChanged:Wait()
	end

	local humanoid = InstanceUtils.WaitForChildWhichIsA(character, "Humanoid")
	InstanceUtils.WaitForChildWhichIsA(humanoid, "Animator")
end

return CharacterUtils
