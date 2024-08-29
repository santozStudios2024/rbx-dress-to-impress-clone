-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local ClientModules = script.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local ImageAssets = require(game.ReplicatedStorage.Shared.Assets.ImageAssets)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local LocalGameStateManager = require(ClientModules.LocalGameStateManager)
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local RampWalkModule = require(ClientModules.RampWalkModule)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local Timer = Utils.Timer

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event
local localPlayer = Players.LocalPlayer

local RatingScreen = Roact.Component:extend("RatingScreen")

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

				-- local pageData = self.props.Input.submissions[self.currentIndex]
				-- if not pageData then
				-- 	return
				-- end

				-- RemoteEvents.Competition_RE:FireServer(constants.EVENTS.COMPETITION_EVENTS.RATING, {
				-- 	userId = pageData._id,
				-- 	rating = i,
				-- })

				updateRating(i)
			end,
		})

		table.insert(guis, gui)
	end

	return Roact.createFragment(guis)
end

function RatingScreen:init()
	self.currentIndex = 1

	self.submissionData, self.updateSubmissionData = Roact.createBinding()
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
			})
		end,
	})
end

function RatingScreen:didUpdate()
	Promise.new(function(resolve)
		local gameState = LocalGameStateManager.getState()

		resolve(gameState)
	end):andThen(function(gameState)
		local submissions = gameState.metaData.submissions

		local submissionData = submissions[self.currentIndex]

		if not submissionData then
			self.updateSubmissionData()
			return
		end

		self.updateSubmissionData(submissionData)
	end)
	if not self.props.Input.resetScreen then
		return
	end

	local gameState = LocalGameStateManager.getState()
	self.props.Input.resetScreen = false

	self.timer = self:startTimer({
		endTime = gameState.metaData.endTime,
		updateFunction = function(timeLeft)
			if timeLeft % gameState.metaData.ratingTime ~= 0 then
				return
			end

			local nextIndex = #gameState.metaData.submissions - math.ceil(timeLeft / gameState.metaData.ratingTime) + 1

			if nextIndex == self.currentIndex then
				return
			end

			local submissionData = gameState.metaData.submissions[nextIndex]
			if not submissionData then
				return
			end

			RampWalkModule.startWalk(submissionData):andThen(function(model)
				task.wait(gameState.metaData.ratingTime)

				if not model then
					return
				end

				model:Destroy()
			end)

			self.currentIndex = nextIndex

			self:setState({})
		end,
	})

	local submissionData = gameState.metaData.submissions[self.currentIndex]
	if not submissionData then
		return
	end

	RampWalkModule.startWalk(submissionData):andThen(function(model)
		task.wait(gameState.metaData.ratingTime)

		if not model then
			return
		end

		model:Destroy()
	end)
end

return RatingScreen
