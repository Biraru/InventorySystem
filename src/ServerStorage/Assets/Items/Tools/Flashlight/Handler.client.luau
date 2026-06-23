local Tool = script.Parent
local HandlePart = Tool:WaitForChild("Handle")
local Spotlight = HandlePart:WaitForChild("Spotlight")
local Sounds = {
	Equip = HandlePart:WaitForChild("Equip"),
	Activate = HandlePart:WaitForChild("Activate")
}

local function applyAttributes()
	Spotlight.Brightness = Tool:GetAttribute("Brightness")
end

applyAttributes()
Tool:GetAttributeChangedSignal("Brightness"):Connect(applyAttributes)

Tool.Activated:Connect(function()
	if Spotlight.Enabled then
		Spotlight.Enabled = false
	else
		Spotlight.Enabled = true
	end
	
	Sounds.Activate:Play()
end)

Tool.Equipped:Connect(function()
	Spotlight.Enabled = false
	Sounds.Equip:Play()
end)
Tool.Unequipped:Connect(function()
	Sounds.Equip:Play()
end)