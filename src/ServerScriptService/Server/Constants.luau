local RunService = game:GetService("RunService")

local Constants = {
	DATASTORE_KEY = RunService:IsStudio() and "Test" or "Production",
	DATA_TIMEOUT = 3,

	ERROR_CODES = {
		INVENTORY = {
			
		},
		PROFILE = {
			LOAD_FAIL = "Profile load fail, Please rejoin. CODE: DS_PRFL-LDA-FAIL",
			DATA_LOAD_FAIL = "Data load fail, please rejoin. CODE: INVS_DATA-LDA-FAIL",
			SESSION_ENDED = "Profile session ended, please rejoin. CODE: DS_PRFL-SESSION-END",
		},
	},
}

return Constants
