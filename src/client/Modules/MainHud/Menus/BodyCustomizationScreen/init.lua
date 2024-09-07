-- Services --
local Players = game:GetService("Players")

-- Dpendencies --
local ClientModules = script.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local ColorPicker = require(ClientModules.Components.ColorPicker)
local AvatarVpComponent = require(ClientModules.Components.AvatarVpComponent)

-- Variables --
local localPlayer = Players.LocalPlayer
local createElement = Roact.createElement

local BodyCustomizationScreen = Roact.Component:extend("BodyCustomizationScreen")

function BodyCustomizationScreen:init() end

function BodyCustomizationScreen:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement(TweeningFrame, {
				BackgroundTransparency = 1,
				theme = theme,
				Visible = true,
			}, {
				ColorPickerBg = createElement("Frame", {
					AnchorPoint = theme.ap.right_center,
					Position = UDim2.fromScale(0.9, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					ColorPicker = createElement(ColorPicker),
				}),
				PlayerAvatarBg = createElement("Frame", {
					AnchorPoint = theme.ap.left_center,
					Position = UDim2.fromScale(0.05, 0.5),
					Size = UDim2.fromScale(0.4, 0.55),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					Avatar = createElement(AvatarVpComponent, {
						userId = localPlayer.UserId,
						canAnimate = true,
						canRotate = true,
						canManuallyRotate = true,
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						productsInfo = {},
						Visible = true,
					}),
				}),
			})
		end,
	})
end

return BodyCustomizationScreen
