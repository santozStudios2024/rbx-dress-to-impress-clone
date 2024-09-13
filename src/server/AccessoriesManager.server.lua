-- Variables --
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Constants --
local PARTS_TO_SCALE = {
	HeadScale = {
		"Head",
	},
	TorsoScale = {
		"UpperTorso",
		"LowerTorso",
	},
	RightArmScale = {
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
	},
	LeftArmScale = {
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
	},
	LeftLegScale = {
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
	},
	RightLegScale = {
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
	},
}

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

	-- description.HeightScale = bodyScale.BodyHeightScale
	-- description.WidthScale = bodyScale.BodyWidthScale
	-- description.DepthScale = bodyScale.BodyDepthScale
	-- description.HeadScale = bodyScale.HeadScale

	description.Face = selectedFace or 0

	humanoid:ApplyDescription(description)

	for partToScale, scale in pairs(bodyScale) do
		if not PARTS_TO_SCALE[partToScale] then
			continue
		end

		for _, partName in ipairs(PARTS_TO_SCALE[partToScale]) do
			PlayerController.scalePart(character, partName, scale)
		end
	end
end

local function OnAccessoryManagerEvent(player, eventName, eventData)
	if eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY then
		ToggleAccessory(player, eventData)
	elseif eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_COLOR then
		SaveBodyCustomizations(player, eventData)
	end
end

RemoteEvents.AccessoryManager_RE.OnServerEvent:Connect(OnAccessoryManagerEvent)
