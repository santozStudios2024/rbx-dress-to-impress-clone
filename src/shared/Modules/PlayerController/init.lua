-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
-- local Assets = game.ReplicatedStorage.Shared.Assets
-- local basicHd = Assets.BasicHD

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

	TableUtils:apply(character:GetDescendants(), function(child)
		if not child:IsA("Accessory") then
			return
		end

		child:Destroy()
	end)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
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

	humanoid:ApplyDescription(description)
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

	print("Stop all animations: " .. tostring(stopAll))
	if stopAll then
		print("Playing animation: " .. tostring(#animator:GetPlayingAnimationTracks()))
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			print("Stop Playing Track")
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

return PlayerController
