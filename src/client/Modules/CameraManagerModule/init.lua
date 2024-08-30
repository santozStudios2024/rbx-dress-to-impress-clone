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

return CameraManagerModule
