local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ServerScriptService.Server.Types)

local PLAYER_DATA = {
	Inventory = {} :: { [string]: Types.ItemData },
}

export type PlayerData = typeof(PLAYER_DATA)

return {
	PLAYER_DATA = PLAYER_DATA,
}
