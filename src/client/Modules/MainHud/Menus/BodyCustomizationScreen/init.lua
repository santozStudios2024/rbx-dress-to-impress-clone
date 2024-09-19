-- Services --
local Players = game:GetService("Players")
local LightingService = game:GetService("Lighting")

-- Dpendencies --
local ClientModules = script.Parent.Parent.Parent
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local ColorPicker = require(ClientModules.Components.ColorPicker)
local AvatarVpComponent = require(ClientModules.Components.AvatarVpComponent)
-- local BodyScalingGui = require(script.BodyScalingGui)
local PartScalingGui = require(script.PartScalingGui)
local FacesGui = require(script.FacesGui)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local HudGuiController = require(ClientModules.HudGuiController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local localPlayer = Players.LocalPlayer
local createElement = Roact.createElement
local raoctEvents = Roact.Event
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

local BodyCustomizationScreen = Roact.Component:extend("BodyCustomizationScreen")

function BodyCustomizationScreen:saveCustomization()
	print("Save Body Customization")
	RemoteEvents.AccessoryManager_RE:FireServer(Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_BODY_COLOR, {
		bodyColor = self.selectedColor:getValue(),
		bodyScale = self.bodyScale:getValue(),
		selectedFace = self.selectedFace:getValue(),
	})
end

function BodyCustomizationScreen:updateVisibility()
	if self.props.Visible then
		self.blurMotor:setGoal(Flipper.Spring.new(24, {
			frequency = 10,
			dampingRatio = 1,
		}))
	else
		self.blurMotor:setGoal(Flipper.Spring.new(0, {
			frequency = 10,
			dampingRatio = 1,
		}))
	end
end

function BodyCustomizationScreen:getCustomization()
	if not self.props.Input.customization then
		return
	end

	if self.props.Input.customization == Constants.BODY_CUSTOMIZATIONS.COLOR then
		return createElement(ColorPicker, {
			colorBind = {
				color = self.selectedColor,
				update = self.updateSelectedColor,
			},
		})
	elseif self.props.Input.customization == Constants.BODY_CUSTOMIZATIONS.SCALE then
		-- return createElement(BodyScalingGui, {
		-- 	scaleBind = {
		-- 		scale = self.bodyScale,
		-- 		update = self.updateBodyScale,
		-- 	},
		-- })
		return createElement(PartScalingGui, {
			scaleBind = {
				scale = self.bodyScale,
				update = self.updateBodyScale,
			},
		})
	elseif self.props.Input.customization == Constants.BODY_CUSTOMIZATIONS.FACES then
		return createElement(FacesGui, {
			faceBind = {
				face = self.selectedFace,
				update = self.updateSelectedFace,
			},
		})
	end
end

function BodyCustomizationScreen:init()
	self.selectedColor, self.updateSelectedColor = Roact.createBinding(Color3.new(1, 1, 1))

	self.bodyScale, self.updateBodyScale = Roact.createBinding({
		-- BodyHeightScale = 1,
		-- BodyWidthScale = 1,
		-- BodyDepthScale = 1,
		-- HeadScale = 1,
		HeadScale = 1,
		TorsoScale = 1,
		LeftArmScale = 1,
		LeftLegScale = 1,
		RightArmScale = 1,
		RightLegScale = 1,
	})

	self.selectedFace, self.updateSelectedFace = Roact.createBinding()

	self.blur, self.updateBlur = Roact.createBinding(0)
	self.blurMotor = Flipper.SingleMotor.new(0)
	self.blurMotor:onStep(self.updateBlur)
end

function BodyCustomizationScreen:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement(TweeningFrame, {
				BackgroundTransparency = 1,
				theme = theme,
				Visible = self.props.Visible,
			}, {
				BlurPortal = createElement(Roact.Portal, {
					target = LightingService,
				}, {
					Blur = createElement("BlurEffect", {
						Size = self.blur,
					}),
				}),
				CustomizationBg = createElement("Frame", {
					AnchorPoint = theme.ap.right_center,
					Position = UDim2.fromScale(0.9, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.05),
					}),
					Customization = self:getCustomization(),
				}),
				PlayerAvatarBg = createElement("Frame", {
					AnchorPoint = theme.ap.left_center,
					Position = UDim2.fromScale(0.05, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.05),
					}),
					Avatar = createElement(AvatarVpComponent, {
						userId = localPlayer.UserId,
						canAnimate = true,
						canRotate = self.props.Input.customization ~= Constants.BODY_CUSTOMIZATIONS.FACES,
						canManuallyRotate = true,
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						productsInfo = {},
						Visible = true,
						resetScreen = true,
						colorBind = {
							color = self.selectedColor,
							update = self.updateSelectedColor,
						},
						scaleBind = {
							scale = self.bodyScale,
							update = self.updateBodyScale,
						},
						faceBind = {
							face = self.selectedFace,
							update = self.updateSelectedFace,
						},
						focusPart = self.props.Input.customization == Constants.BODY_CUSTOMIZATIONS.FACES and "Head"
							or nil,
						offset = self.props.Input.customization == Constants.BODY_CUSTOMIZATIONS.FACES
								and CFrame.new(0, 0, -15)
							or nil,
					}),
				}),
				ActionButtons = createElement("Frame", {
					AnchorPoint = theme.ap.right_bottom,
					Position = UDim2.fromScale(0.95, 0.95),
					Size = UDim2.fromScale(0.45, 0.1),
					BackgroundTransparency = 1,
				}, {
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0.05),
					}),
					CancelButton = createElement("TextButton", {
						Size = UDim2.fromScale(0.45, 0.95),
						BackgroundColor3 = Color3.new(0, 0, 0),
						Text = "Cancel",
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						FontFace = theme.fonts.bold,
						[raoctEvents.Activated] = function()
							if self.props.Input.backButtonClicked then
								self.props.Input.backButtonClicked()
							end

							if not self.props.Input.toggleBodyPad then
								self.props.Input.toggleBodyPad(false)
							end

							HudGuiController.closeMenu("BodyCustomizationScreen")
						end,
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.3),
						}),
						UIStroke = createElement("UIStroke", {
							Thickness = UIRatioHandler.CalculateStrokeThickness(10),
							Color = Color3.new(1, 1, 1),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						}),
						UIPadding = createElement("UIPadding", {
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.1),
							PaddingBottom = UDim.new(0.1),
						}),
					}),
					SaveButton = createElement("TextButton", {
						Size = UDim2.fromScale(0.45, 0.95),
						BackgroundColor3 = Color3.new(0, 0, 0),
						Text = "Save",
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						FontFace = theme.fonts.bold,
						[raoctEvents.Activated] = function()
							if self.props.Input.backButtonClicked then
								self.props.Input.backButtonClicked()
							end

							if not self.props.Input.toggleBodyPad then
								self.props.Input.toggleBodyPad(false)
							end

							HudGuiController.closeMenu("BodyCustomizationScreen")

							self:saveCustomization()
						end,
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.3),
						}),
						UIStroke = createElement("UIStroke", {
							Thickness = UIRatioHandler.CalculateStrokeThickness(10),
							Color = Color3.new(1, 1, 1),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						}),
						UIPadding = createElement("UIPadding", {
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.1),
							PaddingBottom = UDim.new(0.1),
						}),
					}),
				}),
			})
		end,
	})
end

function BodyCustomizationScreen:didMount()
	self:updateVisibility()
end

function BodyCustomizationScreen:didUpdate()
	self:updateVisibility()
end

return BodyCustomizationScreen
