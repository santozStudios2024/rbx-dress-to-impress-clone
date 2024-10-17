-- Services --
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local bodyPartAddedSignal = CollectionService:GetInstanceAddedSignal(Constants.TAGS.BODY_PART)
local assets = game.ReplicatedStorage.Shared.Assets
local defaultCharacter = assets.DefaultCharacter

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

local function OnBodyPartAdded(bodyPart)
	for _, part in ipairs(bodyPart:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local partId = part:FindFirstChild("PartId")
		if partId then
			continue
		end

		partId = Instance.new("StringValue")
		partId.Parent = part
		partId.Name = "PartId"
		partId.Value = HttpService:GenerateGUID(false)

		for _, child in ipairs(part:GetDescendants()) do
			child:SetAttribute("Destroyable", true)
		end
	end
end

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

		CollectionService:RemoveTag(accessoryClone, Constants.TAGS.ACCESSORY)

		TableUtils:apply(accessoryClone:GetDescendants(), function(child)
			if not child:IsA("BasePart") then
				return
			end

			child.Anchored = false
		end)

		humanoid:AddAccessory(accessoryClone)

		task.wait()

		PlayerController.initializeAccessory(player, character, accessoryClone)
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

	if selectedFace then
		TableUtils:apply(character:GetChildren(), function(child)
			if not child:IsA("Accessory") then
				return
			end

			local handle = child:FindFirstChild("Handle")
			if not handle then
				return
			end

			if handle:FindFirstChild("FaceCenterAttachment") then
				description.FaceAccessory = ""
				humanoid:ApplyDescription(description)

				task.wait()

				child:Destroy()
			end
		end)

		if selectedFace.assetType == Constants.FACE_TYPE.FACE then
			description.Face = selectedFace.assetId or 0
			description.FaceAccessory = ""
		else
			description.FaceAccessory = selectedFace.assetId or 0
			description.Face = 0
		end
	else
		description.FaceAccessory = ""
		description.Face = 0
	end

	humanoid:ApplyDescription(description)

	for partToScale, scale in pairs(bodyScale) do
		local scaleValuesFolder = player:FindFirstChild("ScaleValues")
		if scaleValuesFolder then
			local scalingValue = scaleValuesFolder:FindFirstChild(partToScale)

			if scalingValue then
				scalingValue.Value = scale
			end
		end

		if not PARTS_TO_SCALE[partToScale] then
			continue
		end

		for _, partName in ipairs(PARTS_TO_SCALE[partToScale]) do
			if partName == "Head" then
				PlayerController.scalePart(character, partName, Vector3.one * scale)
				continue
			end

			PlayerController.scalePart(
				character,
				partName,
				Vector3.new(
					math.max(scale, bodyScale.BodyWidthScale),
					math.max(scale, bodyScale.BodyHeightScale),
					math.max(scale, bodyScale.BodyDepthScale)
				)
			)
		end
	end

	PlayerController.scaleHipHeight(
		character,
		math.max(bodyScale.RightLegScale, bodyScale.LeftLegScale, bodyScale.BodyHeightScale)
	)

	Promise.new(function(_, reject)
		local head = character:FindFirstChild("Head")

		if not head then
			reject("Head not found")
			return
		end

		local face = head:FindFirstChild("face")
		if not face then
			reject("Face not found")
		end

		if not selectedFace then
			face.Transparency = 0
			return
		end

		if selectedFace.assetType == Constants.FACE_TYPE.FACE then
			face.Transparency = 0
		else
			face.Transparency = 1
		end
	end):catch(warn)
end

local function SwapBodyPart(player, data)
	local character = player.Character

	if not character then
		return
	end

	for _, part in ipairs(data.bodyPart:GetChildren()) do
		local characterPart = character:FindFirstChild(part.Name)
		if not characterPart then
			continue
		end

		local defaultPart = defaultCharacter:FindFirstChild(part.Name)
		if not defaultPart then
			continue
		end

		local swapPartId = part:FindFirstChild("PartId")
		local characterPartId = characterPart:FindFirstChild("PartId")

		local swapPart
		if swapPartId and characterPartId and swapPartId.Value == characterPartId.Value then
			swapPart = defaultPart
		else
			swapPart = part
		end

		PlayerController.swapBodyPart(player, character, swapPart)
	end
end

local function OnAccessoryManagerEvent(player, eventName, eventData)
	if eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY then
		ToggleAccessory(player, eventData)
	elseif eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_COLOR then
		SaveBodyCustomizations(player, eventData)
	elseif eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_PART then
		SwapBodyPart(player, eventData)
	end
end

RemoteEvents.AccessoryManager_RE.OnServerEvent:Connect(OnAccessoryManagerEvent)

for _, bodyPart in ipairs(CollectionService:GetTagged(Constants.TAGS.BODY_PART)) do
	OnBodyPartAdded(bodyPart)
end

bodyPartAddedSignal:Connect(OnBodyPartAdded)
