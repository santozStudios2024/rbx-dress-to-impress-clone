-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils
local VectorUtils = Utils.VectorUtils

-- Variables --
local Assets = game.ReplicatedStorage.Shared.Assets
local defaultCharacter = Assets.DefaultCharacter
-- local basicHd = Assets.BasicHD

-- Constants --
local PARTS_TO_SCALE = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
}
local PARTS_TO_SCALE_VALUES = {
	Head = "HeadScale",
	UpperTorso = "TorsoScale",
	LowerTorso = "TorsoScale",
	RightUpperArm = "RightArmScale",
	RightLowerArm = "RightArmScale",
	RightHand = "RightArmScale",
	LeftUpperArm = "LeftArmScale",
	LeftLowerArm = "LeftArmScale",
	LeftHand = "LeftArmScale",
	RightUpperLeg = "RightLegScale",
	RightLowerLeg = "RightLegScale",
	RightFoot = "RightLegScale",
	LeftUpperLeg = "LeftLegScale",
	LeftLowerLeg = "LeftLegScale",
	LeftFoot = "LeftLegScale",
}

local SCALE_VALUES_TOPART = {
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

local PlayerController = {}

function PlayerController.toggleControls(enable)
	if RunService:IsServer() then
		return
	end

	local localPlayer = Players.LocalPlayer
	local playerModule =
		require(localPlayer:WaitForChild("PlayerScripts", math.huge):WaitForChild("PlayerModule", math.huge))
	local controls = playerModule:GetControls()

	if enable then
		controls:Enable()
	else
		controls:Disable()
	end
end

function PlayerController.applyDescription(player, hd)
	if not hd then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local hdClone = hd:Clone()
	hdClone.Parent = workspace

	local humanoid: Humanoid = character:FindFirstChildOfClass("Humanoid")

	humanoid:ApplyDescription(hdClone)

	hdClone:Destroy()
end

function PlayerController.resetDescription(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local originalHipHeight = humanoid:FindFirstChild("OriginalHipHeight")
	if originalHipHeight then
		humanoid.HipHeight = originalHipHeight.Value
	end

	local description: HumanoidDescription = humanoid:GetAppliedDescription()

	for _, prop in pairs(Constants.BODY_COLORS) do
		description[prop] = Color3.fromHex("#7F7F7F")
	end

	description.HeightScale = 1
	description.WidthScale = 1
	description.DepthScale = 1
	description.HeadScale = 1

	description.Face = 0
	description.FaceAccessory = ""
	description.BackAccessory = ""
	description.FrontAccessory = ""
	description.HairAccessory = ""
	description.HatAccessory = ""
	description.NeckAccessory = ""
	description.ShouldersAccessory = ""
	description.WaistAccessory = ""

	humanoid:ApplyDescription(description)

	local scaleValuesFolder = player:FindFirstChild("ScaleValues")
	if scaleValuesFolder then
		for _, child in ipairs(scaleValuesFolder:GetChildren()) do
			if not child:IsA("NumberValue") then
				continue
			end

			child.Value = 1
		end
	end

	PlayerController.scalePlayer(player, character)

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

		face.Transparency = 0
	end):catch(warn)

	for _, part in ipairs(defaultCharacter:GetChildren()) do
		PlayerController.swapBodyPart(player, character, part)
	end
end

function PlayerController.playAnimation(character, animation, animProps, stopAll)
	local hum: Humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end

	local animator: Animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	local animTrack: AnimationTrack = animator:LoadAnimation(animation)
	if not animTrack then
		return
	end

	if stopAll then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end

	if animProps then
		for prop, value in pairs(animProps) do
			animTrack[prop] = value
		end
	end

	animTrack:Play()
end

function PlayerController.scalePart(character, partName, scaleFactor)
	local part = character:FindFirstChild(partName)
	if not part then
		return
	end
	if not part:IsA("BasePart") then
		return
	end

	local originalSizeValue = part:FindFirstChild("OriginalSize")
	if not originalSizeValue then
		originalSizeValue = Instance.new("Vector3Value")
		originalSizeValue.Name = "OriginalSize"
		originalSizeValue.Parent = part
		originalSizeValue.Value = part.Size
	end

	part.Size = VectorUtils.multiply(originalSizeValue.Value, scaleFactor)

	for _, joint in ipairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			local originalC0 = joint:FindFirstChild("OriginalC0")
			if not originalC0 then
				originalC0 = Instance.new("CFrameValue")
				originalC0.Parent = joint
				originalC0.Name = "OriginalC0"
				originalC0.Parent = joint
				originalC0.Value = joint.C0
			end
			local originalC1 = joint:FindFirstChild("OriginalC1")
			if not originalC1 then
				originalC1 = Instance.new("CFrameValue")
				originalC1.Parent = joint
				originalC1.Name = "OriginalC1"
				originalC1.Parent = joint
				originalC1.Value = joint.C1
			end

			if joint.Part0 == part then
				local offset = VectorUtils.multiply(originalC0.Value.Position, scaleFactor) - originalC0.Value.Position
				joint.C0 = CFrame.new(originalC0.Value.Position + offset)
					* CFrame.fromEulerAnglesXYZ(originalC0.Value:ToEulerAnglesXYZ())
			elseif joint.Part1 == part then
				local offset = VectorUtils.multiply(originalC1.Value.Position, scaleFactor) - originalC1.Value.Position
				joint.C1 = CFrame.new(originalC1.Value.Position + offset)
					* CFrame.fromEulerAnglesXYZ(originalC1.Value:ToEulerAnglesXYZ())
			end
		end
	end

	for _, child in ipairs(part:GetDescendants()) do
		if child:IsA("Attachment") then
			local originalPos = child:FindFirstChild("OriginalPosition")
			if not originalPos then
				originalPos = Instance.new("Vector3Value")
				originalPos.Name = "OriginalPosition"
				originalPos.Parent = child
				originalPos.Value = child.Position
			end
			child.Position = VectorUtils.multiply(originalPos.Value, scaleFactor)
		elseif child:IsA("SpecialMesh") then
			child.Scale = VectorUtils.multiply(child.Scale, scaleFactor)
		elseif child:IsA("BasePart") then
			originalSizeValue = child:FindFirstChild("OriginalSize")
			if not originalSizeValue then
				originalSizeValue = Instance.new("Vector3Value")
				originalSizeValue.Name = "OriginalSize"
				originalSizeValue.Parent = child
				originalSizeValue.Value = child.Size
			end

			child.Size = VectorUtils.multiply(originalSizeValue.Value, scaleFactor)
		elseif child:IsA("Motor6D") then
			local originalC0 = child:FindFirstChild("OriginalC0")
			if not originalC0 then
				originalC0 = Instance.new("CFrameValue")
				originalC0.Parent = child
				originalC0.Name = "OriginalC0"
				originalC0.Parent = child
				originalC0.Value = child.C0
			end
			local originalC1 = child:FindFirstChild("OriginalC1")
			if not originalC1 then
				originalC1 = Instance.new("CFrameValue")
				originalC1.Parent = child
				originalC1.Name = "OriginalC1"
				originalC1.Parent = child
				originalC1.Value = child.C1
			end

			if child.Part0 == part then
				child.C0 = CFrame.new(VectorUtils.multiply(originalC0.Value.Position, scaleFactor))
					* originalC0.Value.Rotation
			else
				child.C1 = CFrame.new(VectorUtils.multiply(originalC1.Value.Position, scaleFactor))
					* originalC1.Value.Rotation
			end
		end
	end

	PlayerController.scaleAccessories(character, partName, scaleFactor)
end

function PlayerController.initializeAccessory(player, character, accessory)
	local handle = accessory:FindFirstChild("Handle")
	if not handle then
		return
	end

	local attachment = handle:FindFirstChildOfClass("Attachment")
	if not attachment then
		return
	end

	local children = character:GetChildren()
	local index = TableUtils:findBy(children, function(child)
		if not child:IsA("BasePart") then
			return false
		end

		if not child:FindFirstChild(attachment.Name) then
			return false
		end

		return true
	end)

	if not index then
		return
	end

	local part = children[index]
	local scaleFactor = PlayerController.getScalingFactor(player, part)

	PlayerController.scaleAccessory(character, part, accessory, scaleFactor)
end

function PlayerController.scaleAccessories(character, partName, scaleFactor)
	local part = character:FindFirstChild(partName)

	if not part then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	for _, accessory in ipairs(character:GetChildren()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChild("Handle")
		if not handle then
			continue
		end

		local attachment = handle:FindFirstChildOfClass("Attachment")
		if not attachment then
			continue
		end

		if not part:FindFirstChild(attachment.Name) then
			continue
		end

		PlayerController.scaleAccessory(character, part, accessory, scaleFactor)
	end
end

function PlayerController.scaleAccessory(character, part, accessory, scaleFactor)
	if not accessory:FindFirstChild("Handle") then
		return
	end

	local handle = accessory.Handle
	if handle:FindFirstChildOfClass("WrapLayer") then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	accessory.Parent = nil
	for _, child in ipairs(handle:GetChildren()) do
		if not child:IsA("Attachment") or not part:FindFirstChild(child.Name) then
			continue
		end

		local originalSizeValue = handle:FindFirstChild("OriginalScale")
		if not originalSizeValue then
			originalSizeValue = Instance.new("Vector3Value")
			originalSizeValue.Name = "OriginalScale"
			originalSizeValue.Parent = handle
			originalSizeValue.Value = handle.Size
		end
		handle.Size = VectorUtils.multiply(originalSizeValue.Value, scaleFactor)

		local originalSize = handle:FindFirstChild("OriginalSize")
		if originalSize then
			originalSize.Value = handle.Size
		end

		for _, handleChild in ipairs(handle:GetChildren()) do
			if handleChild:IsA("Attachment") then
				local originalPos = handleChild:FindFirstChild("OriginalPosition")
				if not originalPos then
					originalPos = Instance.new("Vector3Value")
					originalPos.Name = "OriginalPosition"
					originalPos.Parent = handleChild
					originalPos.Value = handleChild.Position
				end

				handleChild.Position = VectorUtils.multiply(originalPos.Value, scaleFactor)
			elseif handleChild:IsA("SpecialMesh") then
				originalSizeValue = handleChild:FindFirstChild("OriginalSize")
				if not originalSizeValue then
					originalSizeValue = Instance.new("Vector3Value")
					originalSizeValue.Name = "OriginalSize"
					originalSizeValue.Parent = handleChild
					originalSizeValue.Value = handleChild.Scale
				end
				handleChild.Scale = VectorUtils.multiply(originalSizeValue.Value, scaleFactor)
			end
		end

		for _, motor in ipairs(handle:GetChildren()) do
			if motor:IsA("Motor6D") and motor.Part1 and motor.Part1:IsA("MeshPart") then
				-- Scale the MeshPart
				originalSizeValue = motor.Part1:FindFirstChild("OriginalSize")
				if not originalSizeValue then
					originalSizeValue = Instance.new("Vector3Value")
					originalSizeValue.Name = "OriginalSize"
					originalSizeValue.Parent = motor.Part1
					originalSizeValue.Value = motor.Part1.Size
				end
				motor.Part1.Size = VectorUtils.multiply(originalSizeValue.Value, scaleFactor)

				-- Adjust the Motor6D's C0 and C1 to reposition the MeshPart
				local originalC0 = motor:FindFirstChild("OriginalC0")
				if not originalC0 then
					originalC0 = Instance.new("CFrameValue")
					originalC0.Name = "OriginalC0"
					originalC0.Parent = motor
					originalC0.Value = motor.C0
				end
				local originalC1 = motor:FindFirstChild("OriginalC1")
				if not originalC1 then
					originalC1 = Instance.new("CFrameValue")
					originalC1.Name = "OriginalC1"
					originalC1.Parent = motor
					originalC1.Value = motor.C1
				end

				local offset = VectorUtils.multiply(originalC0.Value.Position, scaleFactor) - originalC0.Value.Position
				motor.C0 = CFrame.new(originalC0.Value.Position + offset)
					* CFrame.fromEulerAnglesXYZ(originalC0.Value:ToEulerAnglesXYZ())

				offset = VectorUtils.multiply(originalC1.Value.Position, scaleFactor) - originalC1.Value.Position
				motor.C1 = CFrame.new(originalC1.Value.Position + offset)
					* CFrame.fromEulerAnglesXYZ(originalC1.Value:ToEulerAnglesXYZ())

				continue
			end

			if motor:IsA("Weld") then
				local originalC1 = motor:FindFirstChild("OriginalC1")
				if not originalC1 then
					originalC1 = Instance.new("CFrameValue")
					originalC1.Name = "OriginalC1"
					originalC1.Parent = motor
					originalC1.Value = motor.C1
				end

				local offset = VectorUtils.multiply(originalC1.Value.Position, scaleFactor) - originalC1.Value.Position
				motor.C1 = CFrame.new(originalC1.Value.Position + offset)
					* CFrame.fromEulerAnglesXYZ(originalC1.Value:ToEulerAnglesXYZ())

				continue
			end
		end
	end

	humanoid:AddAccessory(accessory)
end

function PlayerController.scaleHipHeight(character, scaleFactor)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local originalHipHeight = humanoid:FindFirstChild("OriginalHipHeight")
	if not originalHipHeight then
		originalHipHeight = Instance.new("NumberValue")
		originalHipHeight.Name = "OriginalHipHeight"
		originalHipHeight.Parent = humanoid
		originalHipHeight.Value = humanoid.HipHeight
	end

	humanoid.HipHeight = originalHipHeight.Value * scaleFactor
end

function PlayerController.cloneCharacter(player, character)
	character.Archivable = true

	-- local scalingTable = {}

	-- TableUtils:apply(character:GetDescendants(), function(child)
	-- 	if not child:IsA("BasePart") then
	-- 		return
	-- 	end

	-- 	if not table.find(PARTS_TO_SCALE, child.Name) then
	-- 		return
	-- 	end

	-- 	local scalingFactor = PlayerController.getScalingFactor(player, child)

	-- 	scalingTable[child.Name] = scalingFactor
	-- end)

	local clone = character:Clone()
	clone:PivotTo(CFrame.new(1000, 10000, 1000))
	clone.Parent = workspace

	task.wait()

	-- TableUtils:apply(clone:GetDescendants(), function(child)
	-- 	if not child:IsA("BasePart") then
	-- 		return
	-- 	end

	-- 	if not table.find(PARTS_TO_SCALE, child.Name) then
	-- 		return
	-- 	end

	-- 	if not scalingTable[child.Name] then
	-- 		return
	-- 	end

	-- 	PlayerController.scalePart(clone, child.Name, scalingTable[child.Name])
	-- end)

	-- local playerScaling = PlayerController.getPlayerScaling(player)

	-- PlayerController.scaleHipHeight(
	-- 	clone,
	-- 	math.max(playerScaling.RightLegScale, playerScaling.LeftLegScale, playerScaling.BodyHeightScale)
	-- )

	PlayerController.scalePlayer(player, clone)

	return clone
end

function PlayerController.getScalingFactor(player, part)
	if not part:IsA("BasePart") then
		return Vector3.one
	end

	if not table.find(PARTS_TO_SCALE, part.Name) then
		return Vector3.one
	end

	-- local originalSizeValue = part:FindFirstChild("OriginalSize")
	-- if not originalSizeValue then
	-- 	return
	-- end

	-- local scalingFactor = (part.Size / originalSizeValue.Value).X
	-- return scalingFactor

	local playerScaling = PlayerController.getPlayerScaling(player)

	local scalingValueName = PARTS_TO_SCALE_VALUES[part.Name]

	if not scalingValueName then
		return Vector3.one
	end

	if not playerScaling[scalingValueName] then
		return Vector3.one
	end

	if part.Name == "Head" then
		return Vector3.new(
			playerScaling[scalingValueName],
			playerScaling[scalingValueName],
			playerScaling[scalingValueName]
		)
	else
		return Vector3.new(
			math.max(playerScaling[scalingValueName], playerScaling.BodyWidthScale),
			math.max(playerScaling[scalingValueName], playerScaling.BodyHeightScale),
			math.max(playerScaling[scalingValueName], playerScaling.BodyDepthScale)
		)
	end
end

function PlayerController.getPlayerScaling(player)
	local scalingValues = {
		HeadScale = 1,
		TorsoScale = 1,
		RightArmScale = 1,
		LeftArmScale = 1,
		LeftLegScale = 1,
		RightLegScale = 1,
		BodyHeightScale = 1,
		BodyWidthScale = 1,
		BodyDepthScale = 1,
	}
	local scaleValuesFolder = player:FindFirstChild("ScaleValues")

	if not scaleValuesFolder then
		return scalingValues
	end

	for _, scalingValue in ipairs(scaleValuesFolder:GetChildren()) do
		scalingValues[scalingValue.Name] = scalingValue.Value
	end

	return scalingValues
end

function PlayerController.swapBodyPart(player, character, newPart)
	if not character or not newPart then
		return
	end

	local partName = newPart.Name
	local oldPart = character:FindFirstChild(partName)

	if not oldPart or not oldPart:IsA("BasePart") then
		warn("The part " .. partName .. " does not exist in the player's character or isn't a valid BasePart.")
		return
	end

	local scalingFactor = PlayerController.getScalingFactor(player, oldPart)

	local newPartClone = newPart:Clone()
	newPartClone.Parent = character
	newPartClone.CanCollide = false
	newPartClone.Anchored = false

	for _, child in ipairs(oldPart:GetChildren()) do
		if child:GetAttribute("Destroyable") then
			continue
		end

		if child.Name == "OriginalSize" then
			child.Value = newPartClone.Size
		end

		if child:IsA("Attachment") and newPartClone:FindFirstChild(child.Name) then
			continue
		end

		local newAttachment = child:Clone()
		newAttachment.Parent = newPartClone
	end

	oldPart.Parent = nil
	oldPart.Transparency = 1
	oldPart.CanCollide = false

	for _, motor in ipairs(character:GetDescendants()) do
		if not motor:IsA("Motor6D") then
			continue
		end

		if motor.Part0 == oldPart then
			motor.Part0 = newPartClone
		elseif motor.Part1 == oldPart then
			motor.Part1 = newPartClone

			local lastOffset = oldPart:FindFirstChild("Offset")
			local offset = newPartClone:FindFirstChild("Offset")

			local originalC1 = motor:FindFirstChild("OriginalC1") and motor:FindFirstChild("OriginalC1").Value
				or motor.C1

			if lastOffset then
				motor.C1 = originalC1 * lastOffset.Value:Inverse()
			end

			if offset then
				motor.C1 = motor.C1 * offset.Value
			end
		end

		if motor:FindFirstChild("OriginalC1") then
			motor:FindFirstChild("OriginalC1").Value = motor.C1
		end
	end

	oldPart:Destroy()

	PlayerController.scalePart(character, newPartClone.Name, scalingFactor)
end

function PlayerController.saveBodyScale(player, bodyScale)
	local scaleValuesFolder = player:FindFirstChild("ScaleValues")
	if not scaleValuesFolder then
		return
	end

	for partToScale, scale in pairs(bodyScale) do
		local scalingValue = scaleValuesFolder:FindFirstChild(partToScale)

		if not scalingValue then
			continue
		end

		scalingValue.Value = scale
	end
end

function PlayerController.scalePlayer(player, character, bodyScale)
	local scaleValuesFolder = player:FindFirstChild("ScaleValues")
	if not scaleValuesFolder then
		return
	end

	if not bodyScale then
		bodyScale = PlayerController.getPlayerScaling(player)
	end

	for partToScale, scale in pairs(bodyScale) do
		if not SCALE_VALUES_TOPART[partToScale] then
			continue
		end

		for _, partName in ipairs(SCALE_VALUES_TOPART[partToScale]) do
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
end

return PlayerController
