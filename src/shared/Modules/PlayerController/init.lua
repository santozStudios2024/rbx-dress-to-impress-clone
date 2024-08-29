-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Dependencies --
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
end

function PlayerController.playAnimation(character, animation)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end

	local animator: Animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	local animTrack = animator:LoadAnimation(animation)
	if not animTrack then
		return
	end

	print("Animation Platyed")
	animTrack:Play()
end

return PlayerController
