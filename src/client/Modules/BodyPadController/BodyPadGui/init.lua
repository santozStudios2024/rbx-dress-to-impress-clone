-- Services --
local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local ClientModules = script.Parent.Parent
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local LocalGameStateManager = require(ClientModules.LocalGameStateManager)
local HudGuiController = require(ClientModules.HudGuiController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event

local BodyPadGui = Roact.Component:extend("BodyPadGui")

function BodyPadGui:openBodyPadMenu()
	print("Open Body pad menu")
	if not self.props.Input.toggleBodyPad then
		return
	end

	self.props.Input.toggleBodyPad(true)
	self.props.Visible = false

	HudGuiController.openMenu("BodyCustomizationScreen", {
		toggleBodyPad = self.props.Input.toggleBodyPad,
	})

	self:setState({})
end

function BodyPadGui:init()
	local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if not self.props.Visible then
			return
		end

		if input.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		if input.KeyCode ~= Enum.KeyCode.E then
			return
		end

		self:openBodyPadMenu()
	end)

	local gameStateConnection = LocalGameStateManager.onGameStateUpdated:Connect(function(_, newState)
		if newState == Constants.GAME_STATES.ROUND_STARTED then
			return
		end

		if not self.props.Input.toggleBodyPad then
			return
		end

		self.props.Input.toggleBodyPad(false)
	end)

	self.janitor = Janitor.new()
	self.janitor:Add(inputConnection, "Disconnect")
	self.janitor:Add(gameStateConnection, "Disconnect")
end

function BodyPadGui:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("TextButton", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Text = "E",
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = theme.fonts.bold,
				TextScaled = true,
				[roactEvents.Activated] = function()
					self:openBodyPadMenu()
				end,
				Visible = self.props.Visible,
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = UDim.new(0.3),
				}),
				UIStroke = createElement("UIStroke", {
					Thickness = UIRatioHandler.CalculateStrokeThickness(5),
					Color = Color3.new(1, 1, 1),
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),
				UIPadding = createElement("UIPadding", {
					PaddingLeft = UDim.new(0.1),
					PaddingRight = UDim.new(0.1),
					PaddingTop = UDim.new(0.1),
					PaddingBottom = UDim.new(0.1),
				}),
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
			})
		end,
	})
end

function BodyPadGui:willUnmount()
	self.janitor:Cleanup()
end

return BodyPadGui
