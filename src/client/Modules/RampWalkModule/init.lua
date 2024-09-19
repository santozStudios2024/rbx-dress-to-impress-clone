-- Services --

-- Dependencies --
local ClientModule = script.Parent
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local CameraManagerModule = require(ClientModule.CameraManagerModule)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
local assets = game.ReplicatedStorage.Shared.Assets
local animateScript = assets.Animate
local rampWalkJanitor = Janitor.new()

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

		TableUtils:apply(character:GetDescendants(), function(part)
			if not part:IsA("BasePart") then
				return
			end

			part.Anchored = false
		end)

		task.wait()

		local clone = PlayerController.cloneCharacter(character)

		resolve(clone)
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

		RampWalkModule.tweenCamera(model, true)

		model.Parent = rampFolder.Models

		humanoid:MoveTo(posingPos.CFrame.Position)

		local poseAnimChangedConnection
		return Promise.fromEvent(humanoid.MoveToFinished)
			:andThen(function()
				if getPoseAnim then
					local animValue = getPoseAnim(playerData.player)

					if animValue then
						poseAnimChangedConnection = animValue.Changed:Connect(function()
							if not animValue.Value then
								return
							end

							PlayerController.playAnimation(model, animValue.Value, {}, true)
						end)
						if animValue.Value then
							PlayerController.playAnimation(model, animValue.Value, {}, true)
						end
					end
				end

				local poseWaitTime = posingPos:GetAttribute("PoseWaitTime")
				if not poseWaitTime then
					poseWaitTime = 5
				end

				return Promise.delay(poseWaitTime)
			end)
			:andThen(function()
				if poseAnimChangedConnection then
					poseAnimChangedConnection:Disconnect()
				end
				humanoid:MoveTo(endPos.CFrame.Position)
			end)
			:finally(function() end)
	end)

	return promise
end

function RampWalkModule.tweenCamera(model, enable)
	if enable then
		local rampFolder = workspace.World.Models.Ramp
		if not rampFolder then
			return
		end

		local cameraInitialPos = rampFolder.CameraPositions.InitialPos
		CameraManagerModule.toggleCamera(enable, cameraInitialPos.CFrame)

		CameraManagerModule.updateFOV(30)

		local promise = Promise.delay(1):andThen(function()
			local tween =
				CameraManagerModule.tweenCamera(TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					DiagonalFieldOfView = 90,
				})

			return Promise.fromEvent(tween.Completed)
		end)

		local motorJanitor = Janitor.new()
		promise
			:andThen(function()
				if not model then
					return Promise.resolve()
				end

				local hrp: BasePart = model.PrimaryPart
				if not hrp then
					return Promise.resolve()
				end

				local motor = Flipper.SingleMotor.new(-3)
				motorJanitor:Add(motor, "stop")
				motor:onStep(function(value)
					local offsetPos = hrp.CFrame:PointToWorldSpace(Vector3.new(7, value, -1))
					local finalCFrame =
						CFrame.new(offsetPos, Vector3.new(hrp.CFrame.Position.X, offsetPos.Y, hrp.CFrame.Position.Z))

					CameraManagerModule.tweenCamera(TweenInfo.new(0.01), {
						CFrame = finalCFrame,
					})
				end)

				CameraManagerModule.tweenCamera(TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					DiagonalFieldOfView = 120,
				})
				motor:setGoal(Flipper.Spring.new(2.5, {
					frequency = 1,
					dampingRatio = 4,
				}))

				return Promise.delay(4)
			end)
			:andThen(function()
				local cameraEndPos = rampFolder.CameraPositions.EndPos

				CameraManagerModule.toggleCamera(enable, cameraEndPos.CFrame)
			end)
			:finally(function()
				motorJanitor:Cleanup()
			end)

		rampWalkJanitor:AddPromise(promise)
	else
		CameraManagerModule.toggleCamera(enable)
		rampWalkJanitor:Cleanup()
	end
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
