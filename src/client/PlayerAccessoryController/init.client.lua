-- Services --
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Dependencies --
local Constatns = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local AccessoryColorSelectionGui = require(script.AccessoryColorSelectionGui)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
local accessoryAddedSignal = CollectionService:GetInstanceAddedSignal(Constatns.TAGS.ACCESSORY)
local accessoryRemovedSignal = CollectionService:GetInstanceRemovedSignal(Constatns.TAGS.ACCESSORY)
local accessories = {}
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local guiHandle

local function InitColorSelectionGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = playerGui
	screenGui.Name = "AccessoryColorSelectionGui"
	screenGui.IgnoreGuiInset = true

	local background = Instance.new("Frame")
	background.Parent = screenGui
	background.Name = "BG"
	background.BackgroundTransparency = 1
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.Position = UDim2.fromScale(0.5, 0.5)
	background.Size = UDim2.fromScale(1, 1)

	guiHandle = Roact.mount(
		Roact.createElement(AccessoryColorSelectionGui, {
			Visible = false,
			Input = {},
		}),
		background,
		"AccessoryColorSelectionGui"
	)
end

local function OnAccessoryAdded(accessory)
	local cd = Instance.new("ClickDetector")
	cd.Parent = accessory

	local highlights = {}

	TableUtils:apply(accessory:GetDescendants(), function(child)
		if not child:IsA("BasePart") then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.Parent = child
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded

		table.insert(highlights, highlight)
	end)

	local janitor = Janitor.new()

	local clickedConnection = cd.MouseClick:Connect(function()
		local model = Instance.new("Model")
		local accessoryClone = accessory:Clone()
		CollectionService:RemoveTag(accessoryClone, Constatns.TAGS.ACCESSORY)
		accessoryClone.Parent = model

		if accessoryClone:FindFirstChildOfClass("ClickDetector") then
			accessoryClone:FindFirstChildOfClass("ClickDetector"):Destroy()
		end

		Roact.update(
			guiHandle,
			Roact.createElement(AccessoryColorSelectionGui, {
				Visible = true,
				Input = {
					model = model,
					accessory = accessory,
				},
			})
		)
	end)

	local mouseEnterConnection = cd.MouseHoverEnter:Connect(function()
		TableUtils:apply(highlights, function(highlight)
			highlight.OutlineTransparency = 0
		end)
	end)

	local mouseLeaveConnection = cd.MouseHoverLeave:Connect(function()
		TableUtils:apply(highlights, function(highlight)
			highlight.OutlineTransparency = 1
		end)
	end)

	janitor:Add(clickedConnection, "Disconnect")
	janitor:Add(mouseEnterConnection, "Disconnect")
	janitor:Add(mouseLeaveConnection, "Disconnect")

	accessories[accessory] = janitor
end

local function OnAccessoryRemoved(accessory)
	if not accessories[accessory] then
		return
	end

	accessories[accessory]:Cleanup()
end

for _, accessory in ipairs(CollectionService:GetTagged(Constatns.TAGS.ACCESSORY)) do
	OnAccessoryAdded(accessory)
end

accessoryAddedSignal:Connect(OnAccessoryAdded)
accessoryRemovedSignal:Connect(OnAccessoryRemoved)

InitColorSelectionGui()
