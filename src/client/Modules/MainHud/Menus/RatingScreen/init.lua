-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local ClientModules = script.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local ImageAssets = require(game.ReplicatedStorage.Shared.Assets.ImageAssets)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local LocalGameStateManager = require(ClientModules.LocalGameStateManager)
local RampWalkModule = require(ClientModules.RampWalkModule)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local LayoutUtil = require(ClientModules.LayoutUtil)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local Timer = Utils.Timer
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event
local localPlayer = Players.LocalPlayer
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local assets = game.ReplicatedStorage.Shared.Assets
local catWalkEmotes = assets.CatWalkEmotes

local RatingScreen = Roact.Component:extend("RatingScreen")

function RatingScreen:showNextPlayer(gameState)
	local nextIndex = self.currentIndex + 1

	local submissionData = gameState.metaData.submissions[nextIndex]
	if not submissionData then
		warn("NO SUBMISSION DATA FOUND")
		return
	end

	self.showNext = true

	self.updateSubmissionData(submissionData)

	if submissionData.player == localPlayer then
		self.emotesFrameMotor:setGoal(Flipper.Spring.new(0.98, {
			frequency = 2,
			dampingRatio = 1.2,
		}))
	else
		self.emotesFrameMotor:setGoal(Flipper.Spring.new(1.5, {
			frequency = 2,
			dampingRatio = 1.2,
		}))
	end
	RampWalkModule.startWalk(submissionData, function(player)
		local selectedPosingAnimation = player:FindFirstChild("SelectedPosingAnimation")

		if not selectedPosingAnimation then
			return
		end

		return selectedPosingAnimation
	end):andThen(function(model)
		RampWalkModule.tweenCamera(model, true)

		task.wait(gameState.metaData.ratingTime)

		if not model then
			return
		end

		model:Destroy()
	end)

	self.currentIndex = nextIndex

	self:setState({})
end

function RatingScreen:getEmotesList()
	local guis = {}

	for i, emote in ipairs(self.emotes) do
		local gui = createElement(BaseTheme.Consumer, {
			render = function(theme)
				return createElement("CanvasGroup", {
					Size = UDim2.fromScale(0.9, 0.3),
					BackgroundColor3 = Color3.new(1, 1, 1),
					LayoutOrder = i,
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.2),
					}),
					MainFrame = createElement("Frame", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						BackgroundTransparency = 1,
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingLeft = UDim.new(0.1),
							PaddingRight = UDim.new(0.1),
							PaddingTop = UDim.new(0.1),
							PaddingBottom = UDim.new(0.1),
						}),
						EmoteName = createElement("TextLabel", {
							AnchorPoint = theme.ap.center,
							Position = theme.pos.center,
							Size = theme.size,
							BackgroundTransparency = 1,
							Text = emote.Name,
							TextColor3 = Color3.new(0, 0, 0),
							TextScaled = true,
							FontFace = theme.fonts.bold,
						}),
					}),
					SelectionFrame = createElement("Frame", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						BackgroundTransparency = 0.5,
						BackgroundColor3 = Color3.new(0, 0, 0),
						ZIndex = 5,
						Visible = self.selectedEmote:map(function(selectedEmote)
							return selectedEmote == emote
						end),
					}, {
						TickImage = createElement("ImageLabel", {
							AnchorPoint = theme.ap.center,
							Position = theme.pos.center,
							Size = UDim2.fromScale(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = ImageAssets.rating_screen.tick_mark,
							ScaleType = Enum.ScaleType.Fit,
						}),
					}),
					SelectionButton = createElement("ImageButton", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = theme.size,
						BackgroundTransparency = 1,
						ZIndex = 10,
						[roactEvents.Activated] = function()
							local selectedEmote = self.selectedEmote:getValue()

							if selectedEmote == emote then
								self.updateSelectedEmote()
							else
								self.updateSelectedEmote(emote)
							end
							RemoteEvents.Competition_RE:FireServer(
								Constants.EVENTS.COMPETITION_EVENTS.SELECT_POSING_ANIMATION,
								{
									emote = self.selectedEmote:getValue(),
								}
							)
						end,
					}),
				})
			end,
		})

		table.insert(guis, gui)
	end

	return Roact.createFragment(guis)
end

function RatingScreen:startTimer(timerData)
	if self.timer then
		self.timer:cancel()
	end

	return Timer:startTimer(timerData)
end

function RatingScreen:getStars()
	local guis = {}

	local selectedRating, updateRating = Roact.createBinding(0)
	for i = 1, 5 do
		local gui = createElement("ImageButton", {
			Size = UDim2.fromScale(0.15, 1),
			BackgroundTransparency = 1,
			Image = selectedRating:map(function(value)
				return value >= i and ImageAssets.rating_screen.star_filled or ImageAssets.rating_screen.star_empty
			end),
			ScaleType = Enum.ScaleType.Fit,
			[roactEvents.Activated] = function()
				if selectedRating:getValue() == i then
					return
				end

				local gameState = LocalGameStateManager.getState()
				if not gameState.metaData then
					warn("NO META DATA FOUND!!")
					return
				end

				local submissions = gameState.metaData.submissions
				if not submissions then
					return
				end

				local outfitData = submissions[self.currentIndex]
				if not outfitData then
					return
				end

				RemoteEvents.Competition_RE:FireServer(Constants.EVENTS.COMPETITION_EVENTS.RATING, {
					ratedPlayer = outfitData.player,
					rating = i,
				})

				updateRating(i)
			end,
		})

		table.insert(guis, gui)
	end

	return Roact.createFragment(guis)
end

function RatingScreen:init()
	self.currentIndex = 0

	self.submissionData, self.updateSubmissionData = Roact.createBinding()

	self.emotes = catWalkEmotes:GetChildren()

	self.emotesList = Roact.createRef()
	self.selectedEmote, self.updateSelectedEmote = Roact.createBinding()
	self.emotesVisible, self.updateEmotesVisible = Roact.createBinding(false)
	self.emotesFramePos, self.updateEmotesFramePos = Roact.createBinding(UDim2.fromScale(1.5, 0.23))
	self.emotesFrameMotor = Flipper.SingleMotor.new(1.5)
	self.emotesFrameMotor:onStep(function(value)
		self.updateEmotesFramePos(UDim2.fromScale(value, 0.23))
	end)
	self.emotesFrameMotor:onComplete(function()
		local value = self.emotesFrameMotor:getValue()

		if value > 1.2 then
			self.updateEmotesVisible(false)
		else
			self.updateEmotesVisible(true)
		end
	end)

	self.perRatingTime = 0
	self.showNext = true
end

function RatingScreen:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement(TweeningFrame, {
				theme = theme,
				BackgroundTransparency = 1,
				Visible = self.props.Visible,
			}, {
				RatingFrame = createElement("Frame", {
					AnchorPoint = theme.ap.bottom_center,
					Position = UDim2.fromScale(0.5, 0.95),
					Size = UDim2.fromScale(0.5, 0.25),
					BackgroundTransparency = 1,
					Visible = self.submissionData:map(function(submissionData)
						if not submissionData then
							return false
						end

						if not submissionData.player then
							return false
						end

						return submissionData.player.UserId ~= localPlayer.UserId
					end),
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 2.5,
					}),
					Main = createElement("Frame", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
					}, {
						UIListLayout = createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Vertical,
							Padding = UDim.new(0.03),
						}),
						Info = createElement("TextLabel", {
							Size = UDim2.fromScale(1, 0.3),
							BackgroundTransparency = 1,
							LayoutOrder = 1,
							TextColor3 = Color3.new(0, 0, 0),
							FontFace = theme.fonts.bold,
							Text = self.submissionData:map(function(submissionData)
								if not submissionData then
									return ""
								end

								if not submissionData.player then
									return ""
								end

								return "Rate " .. submissionData.player.Name .. "'s Outfit"
							end),
							TextScaled = true,
						}),
						Rating = createElement("Frame", {
							Size = UDim2.fromScale(1, 0.65),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							LayoutOrder = 2,
						}, {
							UICorner = createElement("UICorner", {
								CornerRadius = UDim.new(0.1),
							}),
							UIPadding = createElement("UIPadding", {
								PaddingBottom = UDim.new(0.1),
								PaddingTop = UDim.new(0.1),
							}),
							UIListLayout = createElement("UIListLayout", {
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(0.06),
							}),
							Stars = self:getStars(),
						}),
					}),
				}),
				EmotesFrame = createElement("Frame", {
					AnchorPoint = theme.ap.right_top,
					Position = self.emotesFramePos,
					Size = UDim2.fromScale(0.15, 0.75),
					BackgroundColor3 = Color3.new(0, 0, 0),
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 0.35,
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.15),
					}),
					UIStroke = createElement("UIStroke", {
						Thickness = UIRatioHandler.CalculateStrokeThickness(5),
						Color = Color3.new(1, 1, 1),
					}),
					-- UIGradient = createElement("UIGradient", {
					-- 	Color = ColorSequence.new({
					-- 		ColorSequenceKeypoint.new(0, Color3.new(0.572549, 0.572549, 0.572549)),
					-- 		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
					-- 	}),
					-- 	Rotation = 45,
					-- }),
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0.05),
					}),
					UIPadding = createElement("UIPadding", {
						PaddingBottom = UDim.new(0.05),
						PaddingTop = UDim.new(0.05),
						PaddingLeft = UDim.new(0.05),
						PaddingRight = UDim.new(0.05),
					}),
					Info = createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.1),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Text = "Emotes",
						FontFace = theme.fonts.bold,
						TextScaled = true,
						TextColor3 = Color3.new(1, 1, 1),
					}),
					EmotesList = createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 0.85),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						[Roact.Ref] = self.emotesList,
						ScrollBarThickness = UIRatioHandler.CalculateStrokeThickness(6),
						ScrollBarImageColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							Padding = UDim.new(0.05),
						}),
						Emotes = self:getEmotesList(),
					}),
				}),
			})
		end,
	})
end

function RatingScreen:didMount()
	local emotesList = self.emotesList:getValue()
	if emotesList and not self.emotesListLayout then
		self.emotesListLayout = LayoutUtil.new(emotesList)
	end
end

function RatingScreen:didUpdate()
	local emotesList = self.emotesList:getValue()
	if emotesList and not self.emotesListLayout then
		self.emotesListLayout = LayoutUtil.new(emotesList)
	end

	local gameState = LocalGameStateManager.getState()

	if self.props.Input.resetScreen then
		self.props.Input.resetScreen = false
		self.perRatingTime = (gameState.metaData.endTime - os.time()) / #gameState.metaData.submissions
		self.showNext = true
		self.currentIndex = 0
	end

	if not self.showNext then
		return
	end

	if self.currentIndex == 0 then
		print("SHOW FIRST PLAYER")
		self:showNextPlayer(gameState)
	end

	self.showNext = false

	self.timer = self:startTimer({
		endTime = os.time() + self.perRatingTime,
	}):andThen(function()
		print("Show Next player")
		self:showNextPlayer(gameState)
	end)
end

return RatingScreen
