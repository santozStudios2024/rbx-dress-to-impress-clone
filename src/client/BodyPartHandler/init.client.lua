-- Services --
local CollectionService = game:GetService("CollectionService")

-- Dependencies --
local Constatns = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)

-- Variables --
local bodyPartAddedSignal = CollectionService:GetInstanceAddedSignal(Constatns.TAGS.BODY_PART)
local bodyPartRemovedSignal = CollectionService:GetInstanceRemovedSignal(Constatns.TAGS.BODY_PART)
local bodyParts = {}
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

local function onBodyPartAdded(bodyPart)
	local cd = Instance.new("ClickDetector")
	cd.Parent = bodyPart

	local highlight = Instance.new("Highlight")
	highlight.Parent = bodyPart
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	local janitor = Janitor.new()

	local clickedConnection = cd.MouseClick:Connect(function()
		RemoteEvents.AccessoryManager_RE:FireServer(Constatns.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_PART, {
			bodyPart = bodyPart,
		})
	end)

	local mouseEnterConnection = cd.MouseHoverEnter:Connect(function()
		highlight.OutlineTransparency = 0
	end)

	local mouseLeaveConnection = cd.MouseHoverLeave:Connect(function()
		highlight.OutlineTransparency = 1
	end)

	janitor:Add(clickedConnection, "Disconnect")
	janitor:Add(mouseEnterConnection, "Disconnect")
	janitor:Add(mouseLeaveConnection, "Disconnect")

	bodyParts[bodyPart] = janitor
end

local function onBodyPartRemoved(bodyPart)
	if not bodyParts[bodyPart] then
		return
	end

	bodyParts[bodyPart]:Cleanup()
end

for _, bodyPart in ipairs(CollectionService:GetTagged(Constatns.TAGS.BODY_PART)) do
	onBodyPartAdded(bodyPart)
end

bodyPartAddedSignal:Connect(onBodyPartAdded)
bodyPartRemovedSignal:Connect(onBodyPartRemoved)
