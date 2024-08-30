-- Services --

-- Dependencies --
local ClientModule = script.Parent
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local CameraManagerModule = require(ClientModule.CameraManagerModule)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)

-- Variables --
local assets = game.ReplicatedStorage.Shared.Assets
local animateScript = assets.Animate

local RampWalkModule = {}

function RampWalkModule.startWalk(playerData, getPoseAnim)
	local promise = Promise.new(function(resolve, reject)
		if not playerData then
			reject()
			return
		end

		if not playerData.player then
			reject()
			return
		end

		local character: Model = playerData.player.Character
		if not character then
			reject()
			return
		end

		character.Archivable = true

		resolve(character:Clone())
	end)

	promise:andThen(function(model)
		local humanoid: Humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 5
		end

		local animate = model:FindFirstChild("Animate")
		if animate then
			animate:Destroy()
		end

		local newAnimate = animateScript:Clone()
		newAnimate.Parent = model
		newAnimate.Disabled = false

		local rampFolder = workspace.World.Models.Ramp
		if not rampFolder then
			return
		end

		local startPos = rampFolder.Start
		local posingPos = rampFolder.Posing
		local endPos = rampFolder.End

		model:PivotTo(startPos.CFrame)

		model.Parent = rampFolder.Models

		humanoid:MoveTo(posingPos.CFrame.Position)

		return Promise.fromEvent(humanoid.MoveToFinished)
			:andThen(function()
				if getPoseAnim then
					local anim = getPoseAnim()
					if anim then
						PlayerController.playAnimation(model, anim, {
							["Looped"] = false,
						})
					end
				end

				return Promise.delay(5)
			end)
			:andThen(function()
				humanoid:MoveTo(endPos.CFrame.Position)
			end)
	end)

	return promise
end

function RampWalkModule.toggleCamera(enable)
	if enable then
		local rampFolder = workspace.World.Models.Ramp
		if not rampFolder then
			return
		end

		local cameraPos = rampFolder.CameraPos

		CameraManagerModule.toggleCamera(enable, cameraPos.CFrame)
	else
		CameraManagerModule.toggleCamera(enable)
	end
end

return RampWalkModule
