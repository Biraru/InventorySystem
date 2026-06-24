local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules

local API = {
	Modules = {},
}

local function setupModule(name: string, module)
	API.Modules[name] = module

	if module.Init then
		module.Init()
	end
end

local order = {
	"DataSystem",
	"ItemSystem",
	"InventorySystem",
}

for _, moduleName in order do
	local module = Modules:FindFirstChild(moduleName)
	if not module or not module:IsA("ModuleScript") then
		continue
	end

	setupModule(module.Name, require(module) :: any)
end
