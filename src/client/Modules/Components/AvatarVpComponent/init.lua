-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local ClientModules = script.Parent.Parent
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local VpModelModule = require(game.ReplicatedStorage.Packages.viewportmodel)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler
local TableUtils = Utils.TableUtils

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event
local localPlayer = Players.LocalPlayer
local modelData = {
	userId = localPlayer.UserId,
}
local assets = game.ReplicatedStorage.Shared.Assets
local animate = assets.Animate

-- Constants --
local PARTS_TO_SCALE = {
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
local AutomaticRotationSpeed = 30
local ManualRotationSpeed = 180

local AvatarVpComponent = Roact.Component:extend("AvatarVpComponent")

function AvatarVpComponent:updateColor(selectedColor)
	local humanoid = self.dummyModel:FindFirstChildOfClass("Humanoid")

	return Promise.new(function(resolve)
		if not humanoid then
			return
		end
		local description: HumanoidDescription = humanoid:GetAppliedDescription()

		for _, prop in pairs(Constants.BODY_COLORS) do
			description[prop] = selectedColor
		end

		humanoid:ApplyDescription(description)

		resolve()
	end)
end

function AvatarVpComponent:updateScaling(scaling)
	for partToScale, scale in pairs(scaling) do
		if not PARTS_TO_SCALE[partToScale] then
			continue
		end

		for _, partName in ipairs(PARTS_TO_SCALE[partToScale]) do
			PlayerController.scalePart(self.dummyModel, partName, scale)
		end
	end

	if scaling.RightLegScale >= scaling.LeftLegScale then
		PlayerController.scaleHipHeight(self.dummyModel, scaling.RightLegScale)
	else
		PlayerController.scaleHipHeight(self.dummyModel, scaling.LeftLegScale)
	end

	return Promise.new(function()
		self.vpfModel = VpModelModule.new(self.vpRef:getValue(), self.camera)

		self.vpfModel:SetModel(self.dummyModel)

		local theta = math.rad(180)
		local orientation = CFrame.fromEulerAnglesYXZ(math.rad(0), theta, 0)
		local distance = self.vpfModel:GetFitDistance(self.dummyModel:GetPivot().Position)

		local finalCF = self.dummyModel:GetPivot() * CFrame.new(0, 0, -distance) * orientation
		if self.props.offset then
			finalCF = finalCF * self.props.offset
		end
		self.camera.CFrame = finalCF
	end):catch(warn)
end

function AvatarVpComponent:updateFace(selectedFace)
	local humanoid = self.dummyModel:FindFirstChildOfClass("Humanoid")

	Promise.new(function(_, reject)
		local head = self.dummyModel:FindFirstChild("Head")

		if not head then
			reject("Head not found")
			return
		end

		local face = head:FindFirstChild("face")
		if not face then
			reject("Face not found")
		end

		if not selectedFace then
			face.Transparency = 0
			return
		end

		if selectedFace.assetType == Constants.FACE_TYPE.FACE then
			face.Transparency = 0
		else
			face.Transparency = 1
		end
	end):catch(warn)

	return Promise.new(function(resolve)
		if not humanoid then
			resolve()
			return
		end
		local description: HumanoidDescription = humanoid:GetAppliedDescription()
		if selectedFace then
			TableUtils:apply(self.dummyModel:GetChildren(), function(child)
				if not child:IsA("Accessory") then
					return
				end

				local handle = child:FindFirstChild("Handle")
				if not handle then
					return
				end

				if handle:FindFirstChild("FaceCenterAttachment") then
					description.FaceAccessory = ""
					humanoid:ApplyDescription(description)

					task.wait()

					child:Destroy()
				end
			end)

			if selectedFace.assetType == Constants.FACE_TYPE.FACE then
				description.Face = selectedFace.assetId or 0
				description.FaceAccessory = ""
			else
				description.FaceAccessory = selectedFace.assetId or 0
				description.Face = 0
			end
		else
			description.FaceAccessory = ""
			description.Face = 0
		end

		humanoid:ApplyDescription(description)
		resolve()
	end)
end

function AvatarVpComponent:updateVp()
	if not self.props.productsInfo then
		return
	end
	if not self.props.Visible then
		return
	end

	self.updateLoading(true)

	Promise.new(function(resolve, reject)
		-- Create Player Avatar --
		return Promise.new(function(modelFound, _)
			if self.props.userId ~= modelData.userId then
				if not self.props.userId then
					self.props.userId = localPlayer.UserId
				end
				modelData.userId = self.props.userId
				modelData.model = Players:CreateHumanoidModelFromUserId(modelData.userId)
			end

			if not modelData.model then
				if not localPlayer.Character then
					localPlayer.CharacterAdded:Wait()
				end
				modelData.model = localPlayer.Character
			end

			local clone = PlayerController.cloneCharacter(modelData.model)

			modelFound(clone)
		end)
			:andThen(function(model)
				model.PrimaryPart = model.UpperTorso

				if self.props.focusPart and model:FindFirstChild(self.props.focusPart) then
					model.PrimaryPart = model:FindFirstChild(self.props.focusPart)
				end

				-- Add Emote Player --
				if model:FindFirstChild("Animate") then
					model:FindFirstChild("Animate"):Destroy()
				end
				if self.props.canAnimate then
					local newAnimate = animate:Clone()

					newAnimate.Parent = model
					newAnimate.Disabled = false
				end

				self.dummyModel = model

				local vp = self.vpRef:getValue()

				if not model then
					return
				end
				if not vp then
					return
				end

				self.camera = vp.CurrentCamera
				if not self.camera then
					self.camera = Instance.new("Camera")
					self.camera.Parent = vp
					self.camera.CameraType = Enum.CameraType.Scriptable
					self.camera.DiagonalFieldOfView = 20
					self.camera.FieldOfView = 20
				end

				-- camera.CFrame = CFrame.new(1000, 1000, 1000)
				vp.CurrentCamera = self.camera
				vp.WorldModel:ClearAllChildren()

				model.Parent = vp.WorldModel

				self.vpfModel = VpModelModule.new(vp, self.camera)

				self.vpfModel:SetModel(model)

				local theta = math.rad(180)
				local orientation = CFrame.fromEulerAnglesYXZ(math.rad(0), theta, 0)
				local distance = self.vpfModel:GetFitDistance(model:GetPivot().Position)

				local finalCF = model:GetPivot() * CFrame.new(0, 0, -distance) * orientation
				if self.props.offset then
					finalCF = finalCF * self.props.offset
				end
				self.camera.CFrame = finalCF

				resolve()

				local humanoid = self.dummyModel:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end

				local description: HumanoidDescription = humanoid:GetAppliedDescription()

				local scalingParts = {
					HeadScale = "Head",
					TorsoScale = "UpperTorso",
					LeftArmScale = "LeftUpperArm",
					RightArmScale = "RightUpperArm",
					LeftLegScale = "LeftUpperLeg",
					RightLegScale = "RightUpperLeg",
				}

				local faceData
				if description.FaceAccessory ~= "" then
					faceData = {
						assetId = tonumber(description.FaceAccessory),
						assetType = Constants.FACE_TYPE.FACE_ACCESSORY,
					}
				else
					faceData = {
						assetId = description.Face,
						assetType = Constants.FACE_TYPE.FACE,
					}
				end

				local bodyScale = {}
				for prop, partName in pairs(scalingParts) do
					local part = self.dummyModel:FindFirstChild(partName)
					if not part then
						continue
					end

					local originalSizeValue = part:FindFirstChild("OriginalSize")
					if not originalSizeValue then
						bodyScale[prop] = 1
					end

					local scaling = (part.Size / originalSizeValue.Value).X
					bodyScale[prop] = scaling
				end

				self.props.resetScreen = true

				self.props.scaleBind.update(bodyScale)
				self.props.faceBind.update(faceData)
				self.props.colorBind.update(description.HeadColor)

				self.props.resetScreen = false
			end)
			:catch(function(err)
				reject(err)
			end)
	end)
		:finally(function()
			self.updateLoading(false)
		end)
		:catch(function(err)
			print(tostring(err))
			if self.dummyModel then
				self.dummyModel:Destroy()
			end
		end)
end

function AvatarVpComponent:init()
	self.vpRef = Roact.createRef()
	self.isLoading, self.updateLoading = Roact.createBinding(false)

	self.manullyRotating = false
	self.mousePressed = false
	self.lastMousePos = nil

	self.renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not self.props.canRotate then
			return
		end
		if not self.dummyModel then
			return
		end
		if not self.dummyModel.PrimaryPart then
			return
		end
		if self.manullyRotating then
			return
		end

		self.dummyModel:PivotTo(
			self.dummyModel:GetPivot() * CFrame.fromEulerAnglesXYZ(0, math.rad(AutomaticRotationSpeed * dt), 0)
		)
	end)

	self.inputEndedConnection = UserInputService.InputEnded:Connect(function(input, gp)
		if gp then
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self.mousePressed = false
				self.lastMousePos = nil
				self.manullyRotating = false
				return
			end
			return
		end

		self.mousePressed = false
		self.lastMousePos = nil
		self.manullyRotating = false
	end)

	self.inputBeganConnection = UserInputService.InputChanged:Connect(function(input)
		-- if gp then
		-- 	return
		-- end

		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if not self.props.canManuallyRotate then
			return
		end

		if not self.dummyModel then
			return
		end
		if not self.dummyModel.PrimaryPart then
			return
		end
		if not self.vpRef:getValue() then
			return
		end

		if not self.mousePressed then
			return
		end

		if not self.lastMousePos then
			self.lastMousePos = input.Position
			return
		end

		local delta = input.Position.X - self.lastMousePos.X
		self.lastMousePos = input.Position
		local newRotation = delta / self.vpRef:getValue().AbsoluteSize.X

		self.dummyModel:PivotTo(
			self.dummyModel:GetPivot() * CFrame.fromEulerAnglesXYZ(0, math.rad(newRotation * ManualRotationSpeed), 0)
		)
	end)
end

function AvatarVpComponent:render()
	if not self.props.productsInfo then
		return
	end

	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("ViewportFrame", {
				AnchorPoint = self.props.AnchorPoint,
				BackgroundTransparency = self.props.colorBind.color:map(function(selectedColor)
					if self.props.resetScreen then
						return 1
					end
					if not self.dummyModel then
						return 1
					end

					self:updateColor(selectedColor):andThen(function()
						local scaling = self.props.scaleBind.scale:getValue()

						return self:updateScaling(scaling)
					end)

					return 1
				end),
				BorderSizePixel = self.props.scaleBind.scale:map(function(scaling)
					if self.props.resetScreen then
						return 0
					end
					if not self.dummyModel then
						return 0
					end
					local humanoid = self.dummyModel:FindFirstChildOfClass("Humanoid")

					if humanoid then
						local description: HumanoidDescription = humanoid:GetAppliedDescription()

						humanoid:ApplyDescription(description)
					end

					self:updateScaling(scaling)

					return 0
				end),
				Position = self.props.Position,
				Size = self.props.Size,
				[Roact.Ref] = self.vpRef,
				[roactEvents.InputBegan] = function(_, input)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end
					if input.UserInputState ~= Enum.UserInputState.Begin then
						return
					end

					self.mousePressed = true
					self.manullyRotating = true
				end,
				Visible = self.props.faceBind.face:map(function(selectedFace)
					if self.props.resetScreen then
						return
					end
					if not self.dummyModel then
						return
					end

					self:updateFace(selectedFace):andThen(function()
						local scaling = self.props.scaleBind.scale:getValue()

						return self:updateScaling(scaling)
					end)

					return true
				end),
			}, {
				Loading = createElement("TextLabel", {
					AnchorPoint = theme.ap.center,
					BackgroundColor3 = Color3.new(0.254902, 0.254902, 0.254902),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.5),
					Text = "Loading...",
					TextScaled = true,
					FontFace = theme.fonts.bold,
					TextColor3 = Color3.new(1, 1, 1),
					ZIndex = 2,
					Visible = self.isLoading,
				}, {
					UIPadding = createElement("UIPadding", {
						PaddingLeft = UDim.new(0.2, 0),
						PaddingRight = UDim.new(0.2, 0),
						PaddingTop = UDim.new(0.3, 0),
						PaddingBottom = UDim.new(0.3, 0),
					}),
					UIStroke = createElement("UIStroke", {
						Thickness = UIRatioHandler.CalculateStrokeThickness(7),
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.05, 0),
					}),
				}),
				WorldModel = createElement("WorldModel", {}, {}),
			})
		end,
	})
end

function AvatarVpComponent:didMount()
	self:updateVp()
end

function AvatarVpComponent:didUpdate()
	self:updateVp()
end

function AvatarVpComponent:willUnmount()
	if self.inputEndedConnection then
		self.inputEndedConnection:Disconnect()
	end
	if self.inputBeganConnection then
		self.inputBeganConnection:Disconnect()
	end
	if self.renderSteppedConnection then
		self.renderSteppedConnection:Disconnect()
	end
	if self.dummyModel then
		self.dummyModel:Destroy()
	end
end

return AvatarVpComponent
