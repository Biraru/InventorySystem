local Utils = {
	--- Utils related to players.
	Player = require(script:WaitForChild("Player")),
	--- Utils related to characters.
	Character = require(script:WaitForChild("Character")),
	--- Utils related to general instances.
	Instance = require(script:WaitForChild("Instance")),
	--- Other utils that might be useful.
	Misc = require(script:WaitForChild("Miscellaneous")),
	--- Utils related to tables.
	Table = require(script:WaitForChild("Table")),
}

export type PlayerUtils = typeof(Utils.Player)
export type CharacterUtils = typeof(Utils.Character)
export type InstanceUtils = typeof(Utils.Instance)
export type MiscUtils = typeof(Utils.Misc)
export type TableUtils = typeof(Utils.Table)

return Utils
