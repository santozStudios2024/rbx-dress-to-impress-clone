-- Services --
-- local InsertService = game:GetService("InsertService")
-- local CollectionService = game:GetService("CollectionService")
-- local HttpService = game:GetService("HttpService")
-- local MarketPlaceService = game:GetService("MarketplaceService")

-- Variables --
-- local accessories = { 18360418757 }
-- local placedAccessories = {}
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

-- Grid Info --
-- local gridSizeY = 3
-- local gridSpacing = 2

-- Dependencies --
-- local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- local accessoriesFolder = Instance.new("Folder")
-- accessoriesFolder.Name = "Accessories"
-- accessoriesFolder.Parent = workspace.World

local function ToggleAccessory(player, data)
	local character = player.character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local accessory = data.accessory

	local existingAccessory = character:FindFirstChild(accessory.Name)

	if existingAccessory then
		existingAccessory:Destroy()
	else
		local accessoryClone = accessory:Clone()
		accessoryClone.Parent = nil

		TableUtils:apply(accessoryClone:GetDescendants(), function(child)
			if not child:IsA("BasePart") then
				return
			end

			child.Anchored = false
		end)

		humanoid:AddAccessory(accessoryClone)
	end
end

local function SaveBodyCustomizations(player, data)
	local character = player.Character
	if not character then
		return
	end

	local humanoid: Humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local bodyColor = data.bodyColor
	local bodyScale = data.bodyScale
	local selectedFace = data.selectedFace

	local description = humanoid:GetAppliedDescription()

	for _, prop in pairs(Constants.BODY_COLORS) do
		description[prop] = bodyColor
	end

	description.HeightScale = bodyScale.BodyHeightScale
	description.WidthScale = bodyScale.BodyWidthScale
	description.DepthScale = bodyScale.BodyDepthScale
	description.HeadScale = bodyScale.HeadScale

	description.Face = selectedFace or 0

	humanoid:ApplyDescription(description)
end

local function OnAccessoryManagerEvent(player, eventName, eventData)
	if eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY then
		ToggleAccessory(player, eventData)
	elseif eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_COLOR then
		SaveBodyCustomizations(player, eventData)
	end
end

RemoteEvents.AccessoryManager_RE.OnServerEvent:Connect(OnAccessoryManagerEvent)
