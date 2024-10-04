-- Services --
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local ClientModules = script.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local VpModelModule = require(game.ReplicatedStorage.Packages.viewportmodel)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event

-- Constants --
local AutomaticRotationSpeed = 30
local ManualRotationSpeed = 180

local ModelVpComponent = Roact.Component:extend("ModelVpComponent")

function ModelVpComponent:updateVp()
	if not self.props.Visible then
		return
	end

	if not self.props.dummyModel then
		return
	end

	self.updateLoading(true)

	Promise.resolve(self.props.dummyModel)
		:andThen(function(model)
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

function ModelVpComponent:init()
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

function ModelVpComponent:render()
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

function ModelVpComponent:didMount()
	self:updateVp()
end

function ModelVpComponent:didUpdate()
	self:updateVp()
end

function ModelVpComponent:willUnmount()
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

return ModelVpComponent
