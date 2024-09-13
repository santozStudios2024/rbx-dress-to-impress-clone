-- Services --
local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local ClientModules = script.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event

local Slider = Roact.Component:extend("Slider")

function Slider:updateValue(x)
	local sliderFrame = self.sliderFrame:getValue()

	if not sliderFrame then
		return
	end

	local absPos = sliderFrame.AbsolutePosition
	local absSize = sliderFrame.AbsoluteSize

	local maxX = absPos.X + absSize.X
	local minX = absPos.X

	local value = math.clamp((x - minX) / (maxX - minX), 0, 1)

	self.props.updateBinding(value)
end

function Slider:init()
	self.updatingValue = false
	self.sliderFrame = Roact.createRef()

	self.inputConnection = UserInputService.InputEnded:Connect(function()
		self.updatingValue = false
	end)
end

function Slider:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 1,
				[Roact.Ref] = self.sliderFrame,
			}, {
				SliderTrack = createElement("Frame", {
					AnchorPoint = theme.ap.center,
					Position = theme.pos.center,
					BackgroundColor3 = self.props.trackColor,
					Size = UDim2.fromScale(1, 0.1),
				}, {
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.3),
					}),
				}),
				Knob = createElement("ImageButton", {
					AnchorPoint = theme.ap.center,
					Position = self.props.bind.value:map(function(value)
						return self.props.getKnobPos(value)
					end),
					Size = UDim2.fromScale(0.2, 1),
					BackgroundColor3 = self.props.knobColor,
					[roactEvents.MouseButton1Down] = function(_, x, _)
						self.updatingValue = true
						self:updateValue(x)
					end,
					[roactEvents.MouseButton1Up] = function()
						self.updatingValue = false
					end,
					[roactEvents.MouseMoved] = function(_, x, _)
						if not self.updatingValue then
							return
						end

						self:updateValue(x)
					end,
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(1),
					}),
					UIPadding = createElement("UIPadding", {
						PaddingLeft = UDim.new(0.2),
						PaddingRight = UDim.new(0.2),
						PaddingTop = UDim.new(0.2),
						PaddingBottom = UDim.new(0.2),
					}),
					Info = createElement("TextLabel", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						BackgroundTransparency = 1,
						Text = self.props.bind.value:map(function(value)
							return self.props.getInfo(value)
						end),
						TextScaled = true,
						FontFace = theme.fonts.bold,
						TextColor3 = self.props.infoColor,
					}),
				}),
				Button = createElement("ImageButton", {
					AnchorPoint = theme.ap.center,
					Position = theme.pos.center,
					Size = theme.size,
					BackgroundTransparency = 1,
					ZIndex = 10,
					[roactEvents.MouseButton1Down] = function(_, x, _)
						self.updatingValue = true
						self:updateValue(x)
					end,
					[roactEvents.MouseButton1Up] = function()
						self.updatingValue = false
					end,
					[roactEvents.MouseMoved] = function(_, x, _)
						if not self.updatingValue then
							return
						end

						self:updateValue(x)
					end,
				}),
			})
		end,
	})
end

return Slider
