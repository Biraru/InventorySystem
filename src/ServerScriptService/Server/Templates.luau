local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ServerScriptService.Server.Types)

local PLAYER_DATA = {
	Weapon = "Default",
	Level = 1,
	Experience = 0,
	Inventory = {},
} :: {
	Weapon: string,
	Level: number,
	Experience: number,
	Inventory: { [string]: Types.ItemData },
}

export type PlayerData = typeof(PLAYER_DATA)

return {
	PLAYER_DATA = PLAYER_DATA,
}
