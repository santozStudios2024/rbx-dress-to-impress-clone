-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
-- local Assets = game.ReplicatedStorage.Shared.Assets
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

	humanoid:ApplyDescription(description)

	TableUtils:apply(character:GetDescendants(), function(part)
		if part:IsA("Accessory") then
			part:Destroy()
			return
		end

		if not part:IsA("BasePart") then
			return
		end

		if not table.find(PARTS_TO_SCALE, part.Name) then
			return
		end

		local originalSizeValue = part:FindFirstChild("OriginalSize")
		if not originalSizeValue then
			return
		end

		local scalingFactor = (part.Size / originalSizeValue.Value).X

		PlayerController.scalePart(character, part.Name, scalingFactor)
	end)

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

	part.Size = originalSizeValue.Value * scaleFactor

	for _, joint in ipairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			if joint.Part0 == part then
				local offset = (joint.C0.Position * scaleFactor) - joint.C0.Position
				joint.C0 = CFrame.new(joint.C0.Position + offset)
					* CFrame.fromEulerAnglesXYZ(joint.C0:ToEulerAnglesXYZ())
			elseif joint.Part1 == part then
				local offset = (joint.C1.Position * scaleFactor) - joint.C1.Position
				joint.C1 = CFrame.new(joint.C1.Position + offset)
					* CFrame.fromEulerAnglesXYZ(joint.C1:ToEulerAnglesXYZ())
			end
		end
	end

	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("Attachment") then
			child.Position = child.Position * scaleFactor
		elseif child:IsA("SpecialMesh") or child:IsA("MeshPart") then
			child.Scale = child.Scale * scaleFactor
		end
	end

	PlayerController.scaleAccessories(character, partName, scaleFactor)
end

function PlayerController.scaleAccessories(character, partName, scaleFactor)
	local part = character:FindFirstChild(partName)

	if not part then
		return
	end

	local originalSize = part:FindFirstChild("OriginalSize") and part:FindFirstChild("OriginalSize").Value or part.Size

	for _, accessory in ipairs(character:GetChildren()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		if not accessory:FindFirstChild("Handle") then
			continue
		end

		local handle = accessory.Handle
		local originalSizeValue = handle:FindFirstChild("OriginalSize")
		if not originalSizeValue then
			originalSizeValue = Instance.new("Vector3Value")
			originalSizeValue.Name = "OriginalSize"
			originalSizeValue.Parent = handle
			originalSizeValue.Value = handle.Size
		end

		for _, child in ipairs(handle:GetChildren()) do
			if not child:IsA("Attachment") or not part:FindFirstChild(child.Name) then
				continue
			end

			handle.Size = originalSizeValue.Value * scaleFactor

			for _, handleChild in ipairs(handle:GetChildren()) do
				if handleChild:IsA("Attachment") then
					local originalPos = handle:FindFirstChild("OriginalPosition")
					if not originalPos then
						originalPos = Instance.new("Vector3Value")
						originalPos.Name = "OriginalSize"
						originalPos.Parent = handle
						originalPos.Value = handleChild.Position
					end
					handleChild.Position = originalPos.Value * scaleFactor
				elseif handleChild:IsA("SpecialMesh") then
					handleChild.Scale = handleChild.Scale * scaleFactor
				end
			end

			local partAttachment = part:FindFirstChild(child.Name)
			if partAttachment and partAttachment:IsA("Attachment") then
				local sizeDifference = (part.Size - originalSize) / 2
				local newPosition = handle.Position + sizeDifference

				handle.CFrame = CFrame.new(newPosition) * handle.CFrame.Rotation
			end
		end
	end
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

function PlayerController.cloneCharacter(character)
	character.Archivable = true

	local scalingTable = {}

	TableUtils:apply(character:GetDescendants(), function(child)
		if not child:IsA("BasePart") then
			return
		end

		if not table.find(PARTS_TO_SCALE, child.Name) then
			return
		end

		local originalSizeValue = child:FindFirstChild("OriginalSize")
		if not originalSizeValue then
			return
		end

		local scalingFactor = (child.Size / originalSizeValue.Value).X

		scalingTable[child.Name] = scalingFactor
	end)

	local clone = character:Clone()
	clone:PivotTo(CFrame.new(1000, 10000, 1000))
	clone.Parent = workspace

	task.wait()

	TableUtils:apply(clone:GetDescendants(), function(child)
		if not child:IsA("BasePart") then
			return
		end

		if not table.find(PARTS_TO_SCALE, child.Name) then
			return
		end

		if not scalingTable[child.Name] then
			return
		end

		PlayerController.scalePart(clone, child.Name, scalingTable[child.Name])
	end)

	return clone
end

return PlayerController
