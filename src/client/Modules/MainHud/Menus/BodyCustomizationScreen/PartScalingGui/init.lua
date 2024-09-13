-- Dependencies --
local ClientModules = script.Parent.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local Slider = require(ClientModules.Components.Slider)
local LayoutUtil = require(ClientModules.LayoutUtil)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement

local PartScalingGui = Roact.Component:extend("PartScalingGui")

function PartScalingGui:init()
	self.scrollingFrameRef = Roact.createRef()
end

function PartScalingGui:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 1,
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0.05),
					PaddingLeft = UDim.new(0.1),
					PaddingRight = UDim.new(0.1),
					PaddingTop = UDim.new(0.05),
				}),
				List = createElement("ScrollingFrame", {
					AnchorPoint = theme.ap.center,
					Position = theme.pos.center,
					Size = theme.size,
					BackgroundTransparency = 1,
					ScrollBarImageColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ScrollBarThickness = UIRatioHandler.CalculateStrokeThickness(10),
					[Roact.Ref] = self.scrollingFrameRef,
				}, {
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0.05),
					}),
					HeadScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 1,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "Head",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.HeadScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.HeadScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.HeadScale then
										return "1"
									end

									return string.format("%.1f", value.HeadScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.HeadScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
					TorsoScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 2,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "Torso",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.TorsoScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.TorsoScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.TorsoScale then
										return "1"
									end

									return string.format("%.1f", value.TorsoScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.TorsoScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
					RightArmScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 3,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "RightArm",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.RightArmScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.RightArmScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.RightArmScale then
										return "1"
									end

									return string.format("%.1f", value.RightArmScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.RightArmScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
					LeftArmScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 4,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "LeftArm",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.LeftArmScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.LeftArmScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.LeftArmScale then
										return "1"
									end

									return string.format("%.1f", value.LeftArmScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.LeftArmScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
					RightLegScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 5,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "RightLeg",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.RightLegScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.RightLegScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.RightLegScale then
										return "1"
									end

									return string.format("%.1f", value.RightLegScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.RightLegScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
					LeftLegScaling = createElement("Frame", {
						Size = UDim2.fromScale(0.98, 0.2),
						BackgroundColor3 = Color3.new(1, 1, 1),
						LayoutOrder = 5,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.2),
						}),
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0.1),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(0.3, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							Text = "LeftLeg",
							FontFace = theme.fonts.bold,
							TextScaled = true,
							TextColor3 = Color3.new(0, 0, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SliderBg = createElement("Frame", {
							Size = UDim2.fromScale(0.6, 1),
							BackgroundTransparency = 1,
							LayoutOrder = 2,
						}, {
							Slider = createElement(Slider, {
								trackColor = Color3.new(0, 0, 0),
								knobColor = Color3.new(0.713725, 0.713725, 0.713725),
								infoColor = Color3.new(0, 0, 0),
								maxValue = 3,
								minValue = 0.5,
								getKnobPos = function(value)
									if not value.LeftLegScale then
										return UDim2.fromScale(0.5, 0.5)
									end

									local prec = value.LeftLegScale - 1

									return UDim2.fromScale(prec, 0.5)
								end,
								getInfo = function(value)
									if not value.LeftLegScale then
										return "1"
									end

									return string.format("%.1f", value.LeftLegScale)
								end,
								updateBinding = function(value)
									local scale = self.props.scaleBind.scale:getValue()
									scale.LeftLegScale = 1 + value

									self.props.scaleBind.update(scale)
								end,
								bind = {
									value = self.props.scaleBind.scale,
									update = self.props.scaleBind.update,
								},
							}),
						}),
					}),
				}),
			})
		end,
	})
end

function PartScalingGui:didMount()
	if not self.scrollingFrameRef:getValue() then
		return
	end

	LayoutUtil.new(self.scrollingFrameRef:getValue())
end

function PartScalingGui:didUpdate()
	if not self.scrollingFrameRef:getValue() then
		return
	end

	LayoutUtil.new(self.scrollingFrameRef:getValue())
end

return PartScalingGui
