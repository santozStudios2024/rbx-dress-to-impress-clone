-- Dependencies --
local ClientModules = script.Parent.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local Slider = require(ClientModules.Components.Slider)

-- Variables --
local createElement = Roact.createElement

local BodyScalingGui = Roact.Component:extend("BodyScalingGui")

function BodyScalingGui:init() end

function BodyScalingGui:render()
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
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.05),
				}),
				BodyHeightScale = createElement("Frame", {
					Size = UDim2.fromScale(1, 0.2),
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
						Padding = UDim.new(0.05),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Info = createElement("TextLabel", {
						Size = UDim2.fromScale(0.3, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Text = "Height",
						FontFace = theme.fonts.bold,
						TextScaled = true,
						TextColor3 = Color3.new(0, 0, 0),
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
								if not value.BodyHeightScale then
									return UDim2.fromScale(0.5, 0.5)
								end

								local prec = value.BodyHeightScale / 2

								return UDim2.fromScale(prec, 0.5)
							end,
							getInfo = function(value)
								if not value.BodyHeightScale then
									return "1.2"
								end

								return string.format("%.1f", value.BodyHeightScale)
							end,
							updateBinding = function(value)
								local scale = self.props.scaleBind.scale:getValue()
								scale.BodyHeightScale = 2 * value

								self.props.scaleBind.update(scale)
							end,
							bind = {
								value = self.props.scaleBind.scale,
								update = self.props.scaleBind.update,
							},
						}),
					}),
				}),
				BodyWidthScale = createElement("Frame", {
					Size = UDim2.fromScale(1, 0.2),
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
						Padding = UDim.new(0.05),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Info = createElement("TextLabel", {
						Size = UDim2.fromScale(0.3, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Text = "Width",
						FontFace = theme.fonts.bold,
						TextScaled = true,
						TextColor3 = Color3.new(0, 0, 0),
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
								if not value.BodyWidthScale then
									return UDim2.fromScale(0.5, 0.5)
								end

								local prec = value.BodyWidthScale / 2

								return UDim2.fromScale(prec, 0.5)
							end,
							getInfo = function(value)
								if not value.BodyWidthScale then
									return "1.2"
								end

								return string.format("%.1f", value.BodyWidthScale)
							end,
							updateBinding = function(value)
								local scale = self.props.scaleBind.scale:getValue()
								scale.BodyWidthScale = 2 * value

								self.props.scaleBind.update(scale)
							end,
							bind = {
								value = self.props.scaleBind.scale,
								update = self.props.scaleBind.update,
							},
						}),
					}),
				}),
				BodyDepthScale = createElement("Frame", {
					Size = UDim2.fromScale(1, 0.2),
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
						Padding = UDim.new(0.05),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Info = createElement("TextLabel", {
						Size = UDim2.fromScale(0.3, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Text = "Depth",
						FontFace = theme.fonts.bold,
						TextScaled = true,
						TextColor3 = Color3.new(0, 0, 0),
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
								if not value.BodyDepthScale then
									return UDim2.fromScale(0.5, 0.5)
								end

								local prec = value.BodyDepthScale / 2

								return UDim2.fromScale(prec, 0.5)
							end,
							getInfo = function(value)
								if not value.BodyDepthScale then
									return "1.2"
								end

								return string.format("%.1f", value.BodyDepthScale)
							end,
							updateBinding = function(value)
								local scale = self.props.scaleBind.scale:getValue()
								scale.BodyDepthScale = 2 * value

								self.props.scaleBind.update(scale)
							end,
							bind = {
								value = self.props.scaleBind.scale,
								update = self.props.scaleBind.update,
							},
						}),
					}),
				}),
				HeadScale = createElement("Frame", {
					Size = UDim2.fromScale(1, 0.2),
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
						Padding = UDim.new(0.05),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Info = createElement("TextLabel", {
						Size = UDim2.fromScale(0.3, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Text = "Head Scale",
						FontFace = theme.fonts.bold,
						TextScaled = true,
						TextColor3 = Color3.new(0, 0, 0),
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
							getKnobPos = function(value)
								if not value.HeadScale then
									return UDim2.fromScale(0.5, 0.5)
								end

								local prec = value.HeadScale / 2

								return UDim2.fromScale(prec, 0.5)
							end,
							getInfo = function(value)
								if not value.HeadScale then
									return "1.2"
								end

								return string.format("%.1f", value.HeadScale)
							end,
							updateBinding = function(value)
								local scale = self.props.scaleBind.scale:getValue()
								scale.HeadScale = 2 * value

								self.props.scaleBind.update(scale)
							end,
							bind = {
								value = self.props.scaleBind.scale,
								update = self.props.scaleBind.update,
							},
						}),
					}),
				}),
			})
		end,
	})
end

return BodyScalingGui
