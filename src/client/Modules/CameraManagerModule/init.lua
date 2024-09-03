-- Services --
local TweenService = game:GetService("TweenService")

local CameraManagerModule = {}

function CameraManagerModule.toggleCamera(enable, targetCFrame)
	local currentCamera = workspace.CurrentCamera
	if enable then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = targetCFrame
	else
		currentCamera.CameraType = Enum.CameraType.Custom
	end
end

function CameraManagerModule.tweenCamera(tweenInfo, props)
	local currentCamera = workspace.CurrentCamera

	local tween = TweenService:Create(currentCamera, tweenInfo, props)
	tween:Play()

	return tween
end

function CameraManagerModule.updateFOV(newFov)
	local currentCamera = workspace.CurrentCamera

	currentCamera.DiagonalFieldOfView = newFov
end

return CameraManagerModule
