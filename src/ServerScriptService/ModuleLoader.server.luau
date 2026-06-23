local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService:WaitForChild("Modules")

local API = {
	Modules = {},
}

local function setupModule(name: string, module)
	API.Modules[name] = module
	
	if module.Init then
		module.Init()
	end
end

for _, module in Modules:GetChildren() do
	if not module:IsA("ModuleScript") then
		continue
	end
	
	setupModule(module.Name, require(module) :: any)
end