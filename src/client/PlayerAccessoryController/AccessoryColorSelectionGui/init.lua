-- Services --
local LightingService = game:GetService("Lighting")

-- Dpendencies --
local ClientModules = script.Parent.Parent.Modules
local Assets = game.ReplicatedStorage.Shared.Assets
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local ColorPicker = require(ClientModules.Components.ColorPicker)
local ModelVpComponent = require(ClientModules.Components.ModelVpComponent)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local HudGuiController = require(ClientModules.HudGuiController)
local ImageAssets = require(Assets.ImageAssets)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local raoctEvents = Roact.Event
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

local AccessoryColorSelectionGui = Roact.Component:extend("AccessoryColorSelectionGui")

function AccessoryColorSelectionGui:updateAccessoryColor()
	local selectedColor = self.selectedColor:getValue()
	local currentSelectionIndex = self.currentSelectionIndex:getValue()

	local model = self.props.Input.model
	if not model then
		return
	end

	local accessory = model:FindFirstChildOfClass("Accessory")
	if not accessory then
		return
	end

	local colorParts = accessory:FindFirstChild("ColorParts")
	if not colorParts then
		return
	end

	if #colorParts:GetChildren() <= 0 then
		return
	end

	for _, objectValue in ipairs(colorParts[tostring(currentSelectionIndex)]:GetChildren()) do
		if not objectValue:IsA("ObjectValue") then
			continue
		end

		local part = objectValue.Value
		if not part then
			continue
		end

		part.Color = selectedColor
	end
end

function AccessoryColorSelectionGui:saveCustomization()
	RemoteEvents.AccessoryManager_RE:FireServer(Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY, {
		accessory = self.props.Input.accessory,
		colors = self.colors,
	})
end

function AccessoryColorSelectionGui:updateVisibility()
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

function AccessoryColorSelectionGui:init()
	self.selectedColor, self.updateSelectedColor = Roact.createBinding(Color3.new(1, 1, 1))
	self.currentSelectionIndex, self.updateCurrentSelectionIndex = Roact.createBinding(1)

	self.blur, self.updateBlur = Roact.createBinding(0)
	self.blurMotor = Flipper.SingleMotor.new(0)
	self.blurMotor:onStep(self.updateBlur)
end

function AccessoryColorSelectionGui:render()
	self.updateCurrentSelectionIndex(1)

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
				AccessoryColorFrame = createElement("Frame", {
					AnchorPoint = theme.ap.right_center,
					Position = UDim2.fromScale(0.9, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundTransparency = 1,
				}, {
					AccessoryInfoBg = createElement("Frame", {
						AnchorPoint = theme.ap.top_center,
						Position = theme.pos.top_center,
						Size = UDim2.fromScale(0.95, 0.25),
						BackgroundTransparency = 1,
					}, {
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0.05),
						}),
						LeftArrow = createElement("ImageButton", {
							Size = UDim2.fromScale(0.2, 0.9),
							BackgroundTransparency = 1,
							Image = ImageAssets.accessory_coloring_screen.left_arrow,
							[raoctEvents.Activated] = function()
								local currentSelectionIndex = self.currentSelectionIndex:getValue()

								local model = self.props.Input.model
								if not model then
									return
								end

								local accessory = model:FindFirstChildOfClass("Accessory")
								if not accessory then
									return
								end

								local colorParts = accessory:FindFirstChild("ColorParts")
								if not colorParts then
									return
								end

								if #colorParts:GetChildren() <= 0 then
									return
								end

								local nextSelectionIndex = currentSelectionIndex - 1
								if nextSelectionIndex < 1 then
									nextSelectionIndex = #colorParts:GetChildren()
								end

								self.updateCurrentSelectionIndex(nextSelectionIndex)

								local part =
									colorParts[tostring(nextSelectionIndex)]:FindFirstChildOfClass("ObjectValue").Value
								if not part then
									return
								end

								self.updateSelectedColor(part.Color)
							end,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.6, 0.9),
							BackgroundTransparency = 1,
							Text = self.currentSelectionIndex:map(function(currentSelectionIndex)
								local model = self.props.Input.model
								if not model then
									return
								end

								local accessory = model:FindFirstChildOfClass("Accessory")
								if not accessory then
									return ""
								end

								local colorParts = accessory:FindFirstChild("ColorParts")
								if not colorParts then
									return ""
								end

								if #colorParts:GetChildren() <= 0 then
									return ""
								end

								for _, colorFolder in ipairs(colorParts:GetChildren()) do
									for _, objectValue in ipairs(colorFolder:GetChildren()) do
										if not objectValue:IsA("ObjectValue") then
											continue
										end

										local part = objectValue.Value
										local highlight = part:FindFirstChildOfClass("Highlight")

										if not highlight then
											continue
										end

										if colorFolder.Name == tostring(currentSelectionIndex) then
											highlight.OutlineTransparency = 0
										else
											highlight.OutlineTransparency = 1
										end
									end
								end

								return string.upper(self.props.Input.accessory.Name)
									.. "\n"
									.. math.clamp(currentSelectionIndex, 1, #colorParts:GetChildren())
									.. "/ "
									.. #colorParts:GetChildren()
							end),
							TextScaled = true,
							FontFace = theme.fonts.bold,
							TextColor3 = Color3.new(1, 1, 1),
							Visible = self.selectedColor:map(function()
								self:updateAccessoryColor()

								return true
							end),
						}),
						RightArrow = createElement("ImageButton", {
							Size = UDim2.fromScale(0.2, 0.9),
							BackgroundTransparency = 1,
							Image = ImageAssets.accessory_coloring_screen.right_arrow,
							[raoctEvents.Activated] = function()
								local currentSelectionIndex = self.currentSelectionIndex:getValue()

								local model = self.props.Input.model
								if not model then
									return
								end

								local accessory = model:FindFirstChildOfClass("Accessory")
								if not accessory then
									return
								end

								local colorParts = accessory:FindFirstChild("ColorParts")
								if not colorParts then
									return
								end

								if #colorParts:GetChildren() <= 0 then
									return
								end

								local nextSelectionIndex = currentSelectionIndex + 1
								if nextSelectionIndex > #colorParts:GetChildren() then
									nextSelectionIndex = 1
								end

								self.updateCurrentSelectionIndex(nextSelectionIndex)

								local part =
									colorParts[tostring(nextSelectionIndex)]:FindFirstChildOfClass("ObjectValue").Value
								if not part then
									return
								end

								self.updateSelectedColor(part.Color)
							end,
						}),
					}),
					ColorPickerBg = createElement("Frame", {
						AnchorPoint = theme.ap.bottom_center,
						Position = theme.pos.bottom_center,
						Size = UDim2.fromScale(0.95, 0.75),
						BackgroundColor3 = Color3.new(0, 0, 0),
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.05),
						}),
						ColorPicker = createElement(ColorPicker, {
							colorBind = {
								color = self.selectedColor,
								update = self.updateSelectedColor,
							},
						}),
					}),
				}),
				AccessoryModelBg = createElement("Frame", {
					AnchorPoint = theme.ap.left_center,
					Position = UDim2.fromScale(0.05, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.05),
					}),
					Accessory = createElement(ModelVpComponent, {
						dummyModel = self.props.Input.model,
						canAnimate = true,
						canRotate = false,
						canManuallyRotate = true,
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						Visible = true,
						resetScreen = true,
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

							if self.props.Input.toggleBodyPad then
								self.props.Input.toggleBodyPad(false)
							end

							HudGuiController.closeMenu("AccessoryColorSelectionGui")
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

							if self.props.Input.toggleBodyPad then
								self.props.Input.toggleBodyPad(false)
							end

							HudGuiController.closeMenu("AccessoryColorSelectionGui")

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

function AccessoryColorSelectionGui:didMount()
	self:updateVisibility()
end

function AccessoryColorSelectionGui:didUpdate()
	self:updateVisibility()
end

return AccessoryColorSelectionGui
