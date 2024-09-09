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
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler
local Promise = require(game.ReplicatedStorage.Packages.Promise)

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
local AutomaticRotationSpeed = 30
local ManualRotationSpeed = 180
-- local ACCESSORY_INDEX = {
-- 	[2] = "GraphicTShirt",
-- 	[8] = "HatAccessory",
-- 	[11] = "Shirt",
-- 	[12] = "Pants",
-- 	[17] = "Head",
-- 	[18] = "Face",
-- 	[24] = "Animation",
-- 	[27] = "Torso",
-- 	[28] = "RightArm",
-- 	[29] = "LeftArm",
-- 	[30] = "LeftLeg",
-- 	[31] = "RightLeg",
-- 	[41] = "HairAccessory",
-- 	[42] = "FaceAccessory",
-- 	[43] = "NeckAccessory",
-- 	[44] = "ShouldersAccessory",
-- 	[45] = "FrontAccessory",
-- 	[46] = "BackAccessory",
-- 	[47] = "WaistAccessory",
-- 	[64] = Enum.AccessoryType.TShirt,
-- 	[65] = Enum.AccessoryType.Shirt,
-- 	[66] = Enum.AccessoryType.Pants,
-- 	[67] = Enum.AccessoryType.Jacket,
-- 	[68] = Enum.AccessoryType.Sweater,
-- 	[69] = Enum.AccessoryType.Shorts,
-- 	[70] = Enum.AccessoryType.LeftShoe,
-- 	[71] = Enum.AccessoryType.RightShoe,
-- 	[72] = Enum.AccessoryType.DressSkirt,
-- 	[74] = Enum.AccessoryType.Eyebrow,
-- 	[75] = Enum.AccessoryType.Eyelash,
-- }

local AvatarVpComponent = Roact.Component:extend("AvatarVpComponent")

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

			modelFound(modelData.model)
		end)
			:andThen(function(pm)
				pm.Archivable = true

				task.wait()

				local model = pm:Clone()
				model.PrimaryPart = model.UpperTorso

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

				local camera = vp.CurrentCamera
				if not camera then
					camera = Instance.new("Camera")
					camera.Parent = vp
					camera.CameraType = Enum.CameraType.Scriptable
					camera.DiagonalFieldOfView = 20
					camera.FieldOfView = 20
				end

				-- camera.CFrame = CFrame.new(1000, 1000, 1000)
				vp.CurrentCamera = camera
				vp.WorldModel:ClearAllChildren()

				model.Parent = vp.WorldModel

				local vpfModel = VpModelModule.new(vp, camera)

				vpfModel:SetModel(model)

				local theta = math.rad(180)
				local orientation = CFrame.fromEulerAnglesYXZ(math.rad(0), theta, 0)
				local distance = vpfModel:GetFitDistance(model:GetPivot().Position)

				camera.CFrame = model:GetPivot() * CFrame.new(0, 0, -distance) * orientation

				resolve()
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
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
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
				Visible = self.props.colorBind.color:map(function(selectedColor)
					if not self.dummyModel then
						return
					end

					local bodyColors: BodyColors = self.dummyModel:FindFirstChildOfClass("BodyColors")

					if not bodyColors then
						return
					end

					for _, prop in pairs(Constants.BODY_COLORS) do
						bodyColors[prop] = selectedColor
					end

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
