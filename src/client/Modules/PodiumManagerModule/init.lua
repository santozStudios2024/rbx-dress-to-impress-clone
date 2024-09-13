-- Services --

-- Dependencies --
local ClientModules = script.Parent
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local LocalGameStateManager = require(ClientModules.LocalGameStateManager)
local CameraManagerModule = require(ClientModules.CameraManagerModule)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)

-- Variables --
local assets = game.ReplicatedStorage.Shared.Assets
local animateScript = assets.Animate
local podiumAnimations = assets.PodiumAnimations
local podiumJanitor = Janitor.new()

local PodiumManagerModule = {}

function PodiumManagerModule.togglePodium(enable)
	if enable then
		local promise = Promise.new(function(resolve, reject)
			local gameState = LocalGameStateManager.getState()
			local submissions = gameState.metaData.submissions

			if not submissions then
				reject()
				return
			end

			local models = {}
			for i = 1, math.min(3, #submissions) do
				local playerData = submissions[i]
				local character: Model = playerData.player.Character
				if not character then
					continue
				end

				character.Archivable = true

				table.insert(models, PlayerController.cloneCharacter(character))
			end

			resolve(models)
		end)

		promise:andThen(function(models)
			local podiumFolder = workspace.World.Models.Podium
			if not podiumFolder then
				return
			end

			for i, model in ipairs(models) do
				podiumJanitor:Add(model, "Destroy")

				local stand = podiumFolder.Stands:FindFirstChild(i)
				if not stand then
					continue
				end

				local animate = model:FindFirstChild("Animate")
				if animate then
					animate:Destroy()
				end

				model.PrimaryPart.Anchored = true

				local newAnimate = animateScript:Clone()
				newAnimate.Parent = model
				newAnimate.Disabled = false

				model:PivotTo(stand.CFrame)

				model.Parent = podiumFolder.Models

				-- Play Random Animation --
				local animationsFolder = podiumAnimations:FindFirstChild(i)
				if not animationsFolder then
					continue
				end

				local animations = animationsFolder:GetChildren()
				if #animations <= 0 then
					continue
				end

				local animation = animations[math.random(1, #animations)]
				PlayerController.playAnimation(model, animation)
			end
		end)

		return promise
	else
		podiumJanitor:Cleanup()
	end
end

function PodiumManagerModule.toggleCamera(enable)
	if enable then
		local podiumFolder = workspace.World.Models.Podium
		if not podiumFolder then
			return
		end

		local cameraPos = podiumFolder.CameraPos

		CameraManagerModule.toggleCamera(enable, cameraPos.CFrame)
	else
		CameraManagerModule.toggleCamera(enable)
	end
end

return PodiumManagerModule
