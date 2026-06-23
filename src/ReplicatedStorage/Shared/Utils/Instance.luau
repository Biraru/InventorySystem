local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Janitor"))
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local InstanceUtils = {}

-- Imitates `game:GetService("Debris"):AddItem()` using `task.delay()` for better performance and to break the 1000-item safe limit.
function InstanceUtils.AddToDebris(item: Instance, lifetime: number?): ()
	task.delay(lifetime or 10, function(): ()
		if item == nil then
			return
		end
		item:Destroy()
	end)
end

-- Executes a callback when a specific attribute of an `Instance` changes.
function InstanceUtils.ObserveAttribute(
	instance: Instance,
	attributeName: string,
	callback: (value: any, propertyJanitor: Types.Janitor) -> (),
	predicate: ((value: any) -> boolean)?
): Types.Janitor
	local mainJanitor = Janitor.new()
	mainJanitor:LinkToInstance(instance)

	local function onAttributeChanged(): ()
		local value = instance:GetAttribute(attributeName)
		if predicate and not predicate(value) then
			return
		end

		callback(value, mainJanitor:AddObject(Janitor, nil, "LastValue"))
	end

	task.spawn(onAttributeChanged)
	mainJanitor:Add(instance:GetAttributeChangedSignal(attributeName):Connect(onAttributeChanged))

	return mainJanitor
end

-- Equivalent of `Instance.ChildAdded:Connect()` but managed by Janitor.
function InstanceUtils.ObserveChildren(
	parent: Instance,
	callback: (child: Instance, childJanitor: Types.Janitor) -> (),
	predicate: (child: Instance) -> boolean?
): Types.Janitor
	local mainJanitor = Janitor.new()
	mainJanitor:LinkToInstance(parent)

	local function onChildAdded(child: Instance): ()
		if predicate and not predicate(child) then
			return
		end

		callback(child, mainJanitor:AddObject(Janitor, nil, child))
	end

	for _, child in parent:GetChildren() do
		task.spawn(onChildAdded, child)
	end
	mainJanitor:Add(parent.ChildAdded:Connect(onChildAdded))
	mainJanitor:Add(parent.ChildRemoved:Connect(function(child: Instance): ()
		mainJanitor:Remove(child)
	end))

	return mainJanitor
end

-- Equivalent of `Instance.ChildAdded:Connect()` but only for children of a specific class and managed by Janitor.
function InstanceUtils.ObserveChildrenWhichIsA<T>(
	parent: Instance,
	className: string,
	callback: (child: T, childJanitor: Types.Janitor) -> ()
): Types.Janitor
	return InstanceUtils.ObserveChildren(parent, function(child: Instance, janitor: Types.Janitor): ()
		callback(child :: any, janitor)
	end, function(child: Instance): boolean
		return child:IsA(className)
	end)
end

-- Executes a callback when the `Parent` property of an `Instance` changes.
function InstanceUtils.ObserveParent(
	instance: Instance,
	callback: (parent: Instance, parentJanitor: Types.Janitor) -> (),
	predicate: ((parent: Instance) -> boolean?)?
): Types.Janitor
	return InstanceUtils.ObserveProperty(instance, "Parent", callback, predicate)
end

-- Executes a callback when a specific property of an `Instance` changes.
function InstanceUtils.ObserveProperty(
	instance: Instance,
	propertyName: string,
	callback: (value: any, propertyJanitor: Types.Janitor) -> (),
	predicate: ((value: any) -> boolean)?
): Types.Janitor
	local mainJanitor = Janitor.new()
	mainJanitor:LinkToInstance(instance)

	local function onPropertyChanged(): ()
		local value = (instance :: any)[propertyName]

		if predicate and not predicate(value) then
			return
		end

		callback(value, mainJanitor:AddObject(Janitor, nil, "LastValue"))
	end

	task.spawn(onPropertyChanged)
	mainJanitor:Add(instance:GetPropertyChangedSignal(propertyName):Connect(onPropertyChanged))

	return mainJanitor
end

--[[
	Behaves like `WaitForChild()` but uses `...ChildWhichIsA()` which lets you look for a specific type of `Instance`.
	@yields
]]
function InstanceUtils.WaitForChildWhichIsA(parent: Instance, className: string, timeout: number?): Instance
	local existing = parent:FindFirstChildWhichIsA(className)
	if existing then
		return existing
	end

	local thread = coroutine.running()
	local connection: RBXScriptConnection

	connection = parent.ChildAdded:Connect(function(child: Instance): ()
		if not child:IsA(className) then
			return
		end

		connection:Disconnect()
		task.spawn(thread, child)
	end)

	if timeout then
		task.delay(timeout, function()
			if not connection then
				return
			end

			connection:Disconnect()
			task.spawn(thread)
		end)
	end

	return coroutine.yield()
end

return InstanceUtils
