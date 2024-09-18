-- Services --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local ClientModules = script.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event
local localPlayer = Players.LocalPlayer

local ColorPicker = Roact.Component:extend("ColorPicker")

function ColorPicker:getColorValueTextBox(props)
	local textBoxRef = Roact.createRef()

	return createElement("Frame", {
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.3),
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0.05),
			PaddingRight = UDim.new(0.05),
			PaddingTop = UDim.new(0.05),
			PaddingBottom = UDim.new(0.05),
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.05),
		}),
		Info = createElement("TextLabel", {
			Size = UDim2.fromScale(0.2, 1),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Text = props.Info,
			TextScaled = true,
			FontFace = props.theme.fonts.bold,
		}),
		Value = createElement("TextBox", {
			Size = UDim2.fromScale(0.75, 1),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			[Roact.Ref] = textBoxRef,
			Text = self.props.colorBind.color:map(props.mappingFunction),
			TextScaled = true,
			ClearTextOnFocus = false,
			FontFace = props.theme.fonts.bold,
			[roactEvents.FocusLost] = function()
				local value = textBoxRef:getValue()
				if not value then
					return
				end

				props.updateFunction(value.Text)
			end,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),
	})
end

function ColorPicker:calculateIgnoreGuiOffset()
	Promise.new(function(resolve)
		local playerGui = localPlayer:WaitForChild("PlayerGui", math.huge)

		resolve(playerGui)
	end):andThen(function(playerGui)
		local screenGui = Instance.new("ScreenGui")
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
		local frame = Instance.new("Frame")
		frame.Parent = screenGui
		if frame.AbsolutePosition.Y == 0 then
			while frame.AbsolutePosition.Y == 0 do
				task.wait()
			end
		end
		self.offset = math.abs(frame.AbsolutePosition.Y)

		screenGui:Destroy()
	end)
end

function ColorPicker:updateSelectedColor(x, y)
	local selectedColor = self.props.colorBind.color:getValue()
	local _, _, v = selectedColor:ToHSV()
	local colorFrmae = self.colorsFrame:getValue()

	if not colorFrmae then
		return
	end

	local absPos = colorFrmae.AbsolutePosition
	local absSize = colorFrmae.AbsoluteSize

	local maxX = absPos.X + absSize.X
	local maxY = absPos.Y + absSize.Y + self.offset

	local minY = absPos.Y + self.offset
	local minX = absPos.X

	local hue = 1 - math.clamp((x - minX) / (maxX - minX), 0, 1)
	local sat = 1 - math.clamp((y - minY) / (maxY - minY), 0, 1)

	self.props.colorBind.update(Color3.fromHSV(hue, sat, v))
end

function ColorPicker:updateSelectedValue(y)
	local selectedColor: Color3 = self.props.colorBind.color:getValue()
	local h, s, _ = selectedColor:ToHSV()

	local valueFrame = self.valueFrame:getValue()

	if not valueFrame then
		return
	end

	local absPos = valueFrame.AbsolutePosition
	local absSize = valueFrame.AbsoluteSize

	local maxY = absPos.Y + absSize.Y + self.offset
	local minY = absPos.Y + self.offset

	local value = 1 - math.clamp((y - minY) / (maxY - minY), 0, 1)

	self.props.colorBind.update(Color3.fromHSV(h, s, value))
end

function ColorPicker:init()
	self.colorsFrame = Roact.createRef()
	self.valueFrame = Roact.createRef()

	self.selectingColor = false
	self.selectingValue = false

	self.offset = 0
	self:calculateIgnoreGuiOffset()

	self.inputConnection = UserInputService.InputEnded:Connect(function()
		self.selectingColor = false
		self.selectingValue = false
	end)
end

function ColorPicker:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 1,
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingLeft = UDim.new(0.05),
					PaddingRight = UDim.new(0.05),
					PaddingTop = UDim.new(0.05),
					PaddingBottom = UDim.new(0.05),
				}),
				Sliders = createElement("Frame", {
					AnchorPoint = theme.ap.top_center,
					Position = theme.pos.top_center,
					Size = UDim2.fromScale(1, 0.75),
					BackgroundTransparency = 1,
				}, {
					Color = createElement("Frame", {
						AnchorPoint = theme.ap.left_center,
						Position = theme.pos.left_center,
						Size = UDim2.fromScale(0.85, 0.9),
						BackgroundColor3 = Color3.new(1, 1, 1),
						[Roact.Ref] = self.colorsFrame,
					}, {
						-- UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						-- 	AspectRatio = 1,
						-- }),
						UIGradient = createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 1)),
								ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 225)),
								ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
							}),
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.481, 0.294),
								NumberSequenceKeypoint.new(1, 0),
							}),
						}),
						White = createElement("Frame", {
							AnchorPoint = theme.ap.center,
							Position = theme.pos.center,
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = Color3.new(1, 1, 1),
						}, {
							UIGradient = createElement("UIGradient", {
								Color = ColorSequence.new(Color3.new(1, 1, 1)),
								Rotation = 270,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 1),
								}),
							}),
							Cursor = createElement("Frame", {
								AnchorPoint = theme.ap.center,
								Position = self.props.colorBind.color:map(function(selectedColor: Color3)
									local h, s, _ = selectedColor:ToHSV()

									return UDim2.fromScale(1 - h, 1 - s)
								end),
								Size = UDim2.fromScale(0.1, 0.1),
								BackgroundColor3 = Color3.new(1, 1, 1),
							}, {
								UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
									AspectRatio = 1,
								}),
								UICorner = createElement("UICorner", {
									CornerRadius = UDim.new(1),
								}),
								UIStroke = createElement("UIStroke", {
									Thickness = UIRatioHandler.CalculateStrokeThickness(6),
								}),
							}),
						}),
						Button = createElement("ImageButton", {
							AnchorPoint = theme.ap.center,
							Position = theme.pos.center,
							Size = theme.size,
							BackgroundTransparency = 1,
							ZIndex = 10,
							[roactEvents.MouseButton1Down] = function(_, x, y)
								self.selectingColor = true
								self:updateSelectedColor(x, y)
							end,
							[roactEvents.MouseButton1Up] = function()
								self.selectingColor = false
							end,
							[roactEvents.MouseMoved] = function(_, x, y)
								if not self.selectingColor then
									return
								end

								self:updateSelectedColor(x, y)
							end,
						}),
					}),
					Value = createElement("Frame", {
						AnchorPoint = theme.ap.right_center,
						Position = theme.pos.right_center,
						Size = UDim2.fromScale(0.1, 0.9),
						BackgroundColor3 = Color3.new(1, 1, 1),
						[Roact.Ref] = self.valueFrame,
					}, {
						UIGradient = createElement("UIGradient", {
							Color = self.props.colorBind.color:map(function(selectedColor: Color3)
								local h, s, _ = selectedColor:ToHSV()

								return ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
									ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1)),
								})
							end),
							Rotation = 270,
						}),
						Cursor = createElement("Frame", {
							AnchorPoint = theme.ap.center,
							Position = self.props.colorBind.color:map(function(selectedColor: Color3)
								local _, _, v = selectedColor:ToHSV()

								return UDim2.fromScale(0.5, 1 - v)
							end),
							Size = UDim2.fromScale(0.85, 0.2),
							BackgroundColor3 = Color3.new(1, 1, 1),
						}, {
							UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
								AspectRatio = 1,
							}),
							UICorner = createElement("UICorner", {
								CornerRadius = UDim.new(1),
							}),
							UIStroke = createElement("UIStroke", {
								Thickness = UIRatioHandler.CalculateStrokeThickness(6),
							}),
						}),
						Button = createElement("ImageButton", {
							AnchorPoint = theme.ap.center,
							Position = theme.pos.center,
							Size = theme.size,
							BackgroundTransparency = 1,
							ZIndex = 10,
							[roactEvents.MouseButton1Down] = function(_, _, y)
								self.selectingValue = true
								self:updateSelectedValue(y)
							end,
							[roactEvents.MouseButton1Up] = function()
								self.selectingValue = false
							end,
							[roactEvents.MouseMoved] = function(_, _, y)
								if not self.selectingValue then
									return
								end

								self:updateSelectedValue(y)
							end,
						}),
					}),
				}),
				Numerics = createElement("Frame", {
					AnchorPoint = theme.ap.bottom_center,
					Position = theme.pos.bottom_center,
					Size = UDim2.fromScale(1, 0.2),
					BackgroundTransparency = 1,
				}, {
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0.15),
					}),
					RGBValues = createElement("Frame", {
						Size = UDim2.fromScale(1, 0.5),
						LayoutOrder = 1,
						BackgroundTransparency = 1,
					}, {
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0.04),
						}),
						R = self:getColorValueTextBox({
							Size = UDim2.fromScale(0.3, 1),
							LayoutOrder = 1,
							Info = "R",
							theme = theme,
							mappingFunction = function(selectedColor: Color3)
								local r = math.floor(selectedColor.R * 255)

								return r
							end,
							updateFunction = function(value)
								local selectedColor = self.props.colorBind.color:getValue()
								if not selectedColor then
									return
								end

								value = math.clamp(value, 0, 255)
								local r = value
								local g = selectedColor.G * 255
								local b = selectedColor.B * 255

								self.props.colorBind.update(Color3.fromRGB(r, g, b))
							end,
						}),
						G = self:getColorValueTextBox({
							Size = UDim2.fromScale(0.3, 1),
							LayoutOrder = 2,
							Info = "G",
							theme = theme,
							mappingFunction = function(selectedColor: Color3)
								local g = math.floor(selectedColor.G * 255)

								return g
							end,
							updateFunction = function(value)
								local selectedColor = self.props.colorBind.color:getValue()
								if not selectedColor then
									return
								end

								value = math.clamp(value, 0, 255)
								local g = value
								local r = selectedColor.R * 255
								local b = selectedColor.B * 255

								self.props.colorBind.update(Color3.fromRGB(r, g, b))
							end,
						}),
						B = self:getColorValueTextBox({
							Size = UDim2.fromScale(0.3, 1),
							LayoutOrder = 3,
							Info = "B",
							theme = theme,
							mappingFunction = function(selectedColor: Color3)
								local b = math.floor(selectedColor.B * 255)

								return b
							end,
							updateFunction = function(value)
								local selectedColor = self.props.colorBind.color:getValue()
								if not selectedColor then
									return
								end

								value = math.clamp(value, 0, 255)
								local b = value
								local r = selectedColor.R * 255
								local g = selectedColor.B * 255

								self.props.colorBind.update(Color3.fromRGB(r, g, b))
							end,
						}),
					}),
					HexValues = createElement("Frame", {
						Size = UDim2.fromScale(1, 0.5),
						LayoutOrder = 2,
						BackgroundTransparency = 1,
					}, {
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0.03),
						}),
						Hex = self:getColorValueTextBox({
							Size = UDim2.fromScale(0.48, 1),
							LayoutOrder = 1,
							Info = "Hex",
							theme = theme,
							mappingFunction = function(selectedColor: Color3)
								local hex = selectedColor:ToHex()

								return "#" .. hex
							end,
							updateFunction = function(value)
								local success, color = pcall(function()
									return Color3.fromHex(value)
								end)

								if not success then
									self.props.colorBind.update(self.props.colorBind.color:getValue())
									return
								end

								self.props.colorBind.update(color)
							end,
						}),
						Color = createElement("Frame", {
							Size = UDim2.fromScale(0.48, 1),
							BackgroundColor3 = self.props.colorBind.color,
							LayoutOrder = 2,
						}),
					}),
				}),
			})
		end,
	})
end

function ColorPicker:willUnmount()
	if self.inputConnection then
		self.inputConnection:Disconnect()
	end
end

return ColorPicker
