-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local ClientModules = script.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
-- local HudGuiController = require(ClientModules.HudGuiController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event
local localPlayer = Players.LocalPlayer

local RoundScreen = Roact.Component:extend("RoundScreen")

function RoundScreen:init() end

function RoundScreen:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				BackgroundTransparency = 1,
				Size = theme.size,
				Visible = self.props.Visible,
			}, {
				CatalogueButton = createElement("TextButton", {
					AnchorPoint = theme.ap.right_bottom,
					Position = UDim2.fromScale(0.97, 0.95),
					BackgroundColor3 = Color3.new(0, 0, 0),
					Size = UDim2.fromScale(0.1, 0.2),
					Text = "CATALOGUE",
					FontFace = theme.fonts.bold,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[roactEvents.Activated] = function()
						local PlayerScripts = localPlayer.PlayerScripts
						local BloxbizAPI = require(PlayerScripts:WaitForChild("BloxbizSDK").PublicAPI)

						-- Call to open the catalog
						BloxbizAPI.openCatalog()
					end,
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 3.5,
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.2),
					}),
					UIStroke = createElement("UIStroke", {
						Thickness = UIRatioHandler.CalculateStrokeThickness(5),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.new(1, 1, 1),
					}),
					UIPadding = createElement("UIPadding", {
						PaddingBottom = UDim.new(0.1),
						PaddingLeft = UDim.new(0.1),
						PaddingRight = UDim.new(0.1),
						PaddingTop = UDim.new(0.1),
					}),
				}),
			})
		end,
	})
end

function RoundScreen:didUpdate()
	if not self.props.Visible then
		Promise.new(function()
			local PlayerScripts = game.Players.LocalPlayer.PlayerScripts
			local BloxbizAPI = require(PlayerScripts:WaitForChild("BloxbizSDK").PublicAPI)

			-- Call to close the catalog
			BloxbizAPI.closeCatalog()
		end):catch(warn)
	end
end

return RoundScreen
