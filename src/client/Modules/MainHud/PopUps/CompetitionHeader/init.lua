-- Services --

-- Variables --
local clientModules = script.Parent.Parent.Parent

-- Dependencies --
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(clientModules.BaseTheme)
local LocalGameStateManager = require(clientModules.LocalGameStateManager)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local HudGuiController = require(clientModules.HudGuiController)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local RampWalkModule = require(clientModules.RampWalkModule)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler
local Timer = Utils.Timer

local createElement = Roact.createElement

local CompetitionHeader = Roact.Component:extend("CompetitionHeader")

function CompetitionHeader:startTimer(timerData)
	if self.timer then
		self.timer:cancel()
	end

	return Timer:startTimer(timerData)
end

function CompetitionHeader:gameStateUpdated(_, currentStateData)
	if self.timer then
		self.timer:cancel()
	end

	if currentStateData.state == Constants.GAME_STATES.INTERMISSION then
		if currentStateData.metaData then
			self.updateThemeText(currentStateData.metaData.themeData.theme)
			self.updateRoundInfo("INTERMISSION")

			self.timer = self:startTimer({
				endTime = currentStateData.metaData.endTime,
				updateFunction = function(timeLeft)
					local timeLeftMin = math.max(timeLeft, 0)

					self.updateTimerText(string.format("%02d:%02d", math.floor(timeLeftMin / 60), timeLeftMin % 60))
				end,
			}):catch(function(err)
				warn(tostring(err))
			end)
		else
			self.updateRoundInfo("")
			self.updateTimerText("")
		end
	elseif currentStateData.state == Constants.GAME_STATES.ROUND_STARTED then
		if currentStateData.metaData then
			self.updateThemeText(currentStateData.metaData.themeData.theme)
			self.updateRoundInfo("ROUND")

			self.timer = self:startTimer({
				endTime = currentStateData.metaData.endTime,
				updateFunction = function(timeLeft)
					local timeLeftMin = math.max(timeLeft, 0)
					self.updateTimerText(string.format("%02d:%02d", math.floor(timeLeftMin / 60), timeLeftMin % 60))
				end,
			}):catch(function(err)
				warn(tostring(err))
			end)
		else
			-- self.updateRoundInfo('<font color="rgb(75, 252, 255)">Round:</font>\n')
			self.updateRoundInfo("")
		end
	elseif currentStateData.state == Constants.GAME_STATES.RATING then
		if currentStateData.metaData then
			self.updateThemeText(currentStateData.metaData.themeData.theme)
			self.updateRoundInfo("RATING")

			self.timer = self:startTimer({
				endTime = currentStateData.metaData.endTime,
				updateFunction = function(timeLeft)
					local timeLeftMin = math.max(timeLeft, 0)
					self.updateTimerText(string.format("%02d:%02d", math.floor(timeLeftMin / 60), timeLeftMin % 60))
				end,
			}):catch(function(err)
				warn(tostring(err))
			end)

			RampWalkModule.toggleCamera(true)
			PlayerController.toggleControls(false)

			HudGuiController.openMenu("RatingScreen", {
				resetScreen = true,
			})
		else
			self.updateRoundInfo("")
			self.updateTimerText("")
		end
	elseif currentStateData.state == Constants.GAME_STATES.RESULTS then
		HudGuiController.closeMenu("RatingScreen")
		RampWalkModule.toggleCamera(false)
		PlayerController.toggleControls(true)
		if currentStateData.metaData then
			self.updateThemeText(currentStateData.metaData.themeData.theme)
			self.updateRoundInfo("RESULTS")

			self.timer = self:startTimer({
				endTime = currentStateData.metaData.endTime,
				updateFunction = function(timeLeft)
					local timeLeftMin = math.max(timeLeft, 0)
					self.updateTimerText(string.format("%02d:%02d", math.floor(timeLeftMin / 60), timeLeftMin % 60))
				end,
			}):catch(function(err)
				warn(tostring(err))
			end)
		else
			-- self.updateRoundInfo('<font color="rgb(75, 252, 255)">Results:</font>\n')
			self.updateRoundInfo("")
			self.updateTimerText("")
		end
	end
end

function CompetitionHeader:init()
	self.timer = nil

	self.roundInfo, self.updateRoundInfo = Roact.createBinding("")
	self.timerText, self.updateTimerText = Roact.createBinding("")
	self.themeText, self.updateThemeText = Roact.createBinding("")

	self.janitor = Janitor.new()
end

function CompetitionHeader:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement("Frame", {
				AnchorPoint = theme.ap.center,
				BackgroundTransparency = 1,
				Position = theme.pos.center,
				Size = theme.size,
				ZIndex = 100,
				Visible = self.props.Visible,
			}, {
				Bg = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				}, {
					ThemeBg = createElement("ImageLabel", {
						AnchorPoint = theme.ap.top_center,
						Position = UDim2.fromScale(0.5, 0.03),
						Size = UDim2.fromScale(0.4, 0.07),
						BackgroundTransparency = 1,
					}, {
						-- UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						-- 	AspectRatio = 5.866,
						-- }),
						Theme = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.95, 1),
							-- BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(0, 0, 0),
							Text = self.themeText:map(function(themeValue)
								return "THEME: " .. string.upper(themeValue)
							end),
							TextScaled = true,
							FontFace = Font.fromName("Inconsolata", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
							TextColor3 = Color3.new(1, 1, 1),
							-- TextXAlignment = Enum.TextXAlignment.Left,
							Visible = self.themeText:map(function(themeText)
								if not themeText then
									return false
								end

								if themeText == "" then
									return false
								end

								return true
							end),
						}, {
							UIPadding = createElement("UIPadding", {
								PaddingTop = UDim.new(0.05),
								PaddingBottom = UDim.new(0.05),
								PaddingLeft = UDim.new(0.05),
								PaddingRight = UDim.new(0.05),
							}),
							UICorner = createElement("UICorner", {
								CornerRadius = UDim.new(0.3),
							}),
							UIStroke = createElement("UIStroke", {
								Color = Color3.new(1, 1, 1),
								Thickness = UIRatioHandler.CalculateStrokeThickness(6),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							}),
						}),
					}),
					InfoBg = createElement("ImageLabel", {
						AnchorPoint = theme.ap.right_top,
						Position = UDim2.fromScale(0.98, 0.05),
						Size = UDim2.fromScale(0.2, 0.13),
						-- BackgroundTransparency = 1,
						BackgroundColor3 = Color3.new(0, 0, 0),
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingTop = UDim.new(0.05),
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.05),
							PaddingRight = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.3),
						}),
						UIStroke = createElement("UIStroke", {
							Color = Color3.new(1, 1, 1),
							Thickness = UIRatioHandler.CalculateStrokeThickness(6),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						}),
						UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
							AspectRatio = 1.805,
						}),
						Info = createElement("TextLabel", {
							AnchorPoint = theme.ap.top_center,
							Position = theme.pos.top_center,
							Size = UDim2.fromScale(0.98, 0.45),
							BackgroundTransparency = 1,
							Text = self.roundInfo,
							TextScaled = true,
							RichText = true,
							FontFace = Font.fromName("Inconsolata", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
							TextColor3 = Color3.new(1, 1, 1),
						}),
						Timer = createElement("TextLabel", {
							AnchorPoint = theme.ap.bottom_center,
							Position = theme.pos.bottom_center,
							Size = UDim2.fromScale(0.98, 0.45),
							BackgroundTransparency = 1,
							Text = self.timerText,
							TextScaled = true,
							RichText = true,
							FontFace = Font.fromName("Inconsolata", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
							TextColor3 = Color3.fromRGB(195, 195, 195),
						}),
					}),
				}),
			})
		end,
	})
end

function CompetitionHeader:didMount()
	Promise.delay(1):andThen(function()
		self:gameStateUpdated(nil, LocalGameStateManager.getState())

		self.janitor:Add(
			LocalGameStateManager.onGameStateUpdated:Connect(function(prevStateData, currentStateData)
				self:gameStateUpdated(prevStateData, currentStateData)
			end),
			"Disconnect"
		)

		HudGuiController.enableElement("CompetitionHeader")
	end)
end

function CompetitionHeader:didUpdate() end

function CompetitionHeader:willUnmount()
	self.janitor:Cleanup()
end

return CompetitionHeader
