local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PackagesFolder = ReplicatedStorage:WaitForChild("Packages")
local JanitorModule = require(PackagesFolder:WaitForChild("Janitor"))

-- Module Types
export type Janitor = JanitorModule.Janitor

return {}
