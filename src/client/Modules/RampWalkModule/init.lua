-- Services --

-- Dependencies --
local Promise = require(game.ReplicatedStorage.Packages.Promise)

-- Variables --
local assets = game.ReplicatedStorage.Shared.Assets
local animateScript = assets.Animate

local RampWalkModule = {}

function RampWalkModule.startWalk(playerData)
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
		local humanoid = model:FindFirstChildOfClass("Humanoid")
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
		local endPos = rampFolder.End

		model:PivotTo(startPos.CFrame)

		model.Parent = rampFolder.Models

		humanoid:MoveTo(endPos.CFrame.Position)
	end)

	return promise
end

function RampWalkModule.toggleCamera(enable)
	local currentCamera = workspace.CurrentCamera
	if enable then
		local rampFolder = workspace.World.Models.Ramp
		if not rampFolder then
			return
		end

		local cameraPos = rampFolder.CameraPos

		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = cameraPos.CFrame
	else
		currentCamera.CameraType = Enum.CameraType.Custom
	end
end

return RampWalkModule
