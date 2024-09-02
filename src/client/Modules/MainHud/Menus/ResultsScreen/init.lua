-- Services --
local LightingService = game:GetService("Lighting")

-- Dependencies --
local ClientModules = script.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local TweeningFrame = require(ClientModules.Components.TweeningFrame)
local LayoutUtil = require(ClientModules.LayoutUtil)
local ImageAssets = require(game.ReplicatedStorage.Shared.Assets.ImageAssets)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
-- local roactEvents = Roact.Event

local ResultsScreen = Roact.Component:extend("ResultsScreen")

function ResultsScreen:updateVisibility()
	if self.props.Visible then
		self.blurMotor:setGoal(Flipper.Spring.new(24, {
			frequency = 10,
			dampingRatio = 1,
		}))
	else
		self.blurMotor:setGoal(Flipper.Spring.new(0, {
			frequency = 10,
			dampingRatio = 1,
		}))
	end
end

function ResultsScreen:getLeaderboard()
	if not self.props.Input.submissions then
		return
	end
	local guis = {}

	local colors = {
		Color3.new(0.992156, 0.929411, 0.349019),
		Color3.new(0.901960, 0.901960, 0.901960),
		Color3.new(0.850980, 0.478431, 0.247058),
		Color3.new(0, 0, 0),
	}

	for index, outfitData in ipairs(self.props.Input.submissions) do
		local gui = createElement(BaseTheme.Consumer, {
			render = function(theme)
				return createElement("Frame", {
					Size = UDim2.fromScale(0.9, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					MainFrame = createElement("Frame", {
						AnchorPoint = theme.ap.center,
						Position = theme.pos.center,
						BackgroundColor3 = colors[index] or colors[4],
						Size = UDim2.new(
							1,
							-2 * UIRatioHandler.CalculateStrokeThickness(5),
							1,
							-2 * UIRatioHandler.CalculateStrokeThickness(5)
						),
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingTop = UDim.new(0.05),
							PaddingBottom = UDim.new(0.05),
							PaddingLeft = UDim.new(0.05),
							PaddingRight = UDim.new(0.05),
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.1),
						}),
						UIStroke = createElement("UIStroke", {
							Thickness = UIRatioHandler.CalculateStrokeThickness(5),
						}),
						PlayerName = createElement("TextLabel", {
							AnchorPoint = theme.ap.left_center,
							Position = theme.pos.left_center,
							Size = UDim2.fromScale(0.6, 0.8),
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamMedium,
							Text = outfitData.player.Name,
							TextScaled = true,
							TextColor3 = Color3.new(1, 1, 1),
							TextXAlignment = Enum.TextXAlignment.Left,
						}, {
							UIStroke = createElement("UIStroke", {
								Thickness = UIRatioHandler.CalculateStrokeThickness(5),
							}),
						}),
						RatingFrame = createElement("Frame", {
							AnchorPoint = theme.ap.right_center,
							Position = theme.pos.right_center,
							Size = UDim2.fromScale(0.35, 0.9),
							BackgroundTransparency = 1,
						}, {
							StarImage = createElement("ImageLabel", {
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.fromScale(1, 0.5),
								Size = UDim2.fromScale(0.3, 1),
								BackgroundTransparency = 1,
								Image = ImageAssets.rating_screen.star_filled,
								ScaleType = Enum.ScaleType.Fit,
							}),
							RatingText = createElement("TextLabel", {
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.fromScale(0.6, 0.5),
								Size = UDim2.fromScale(0.6, 1),
								BackgroundTransparency = 1,
								Font = Enum.Font.FredokaOne,
								Text = outfitData.rating,
								TextScaled = true,
								TextColor3 = Color3.new(1, 1, 1),
								TextXAlignment = Enum.TextXAlignment.Right,
							}, {
								UIStroke = createElement("UIStroke", {
									Thickness = UIRatioHandler.CalculateStrokeThickness(5),
								}),
							}),
						}),
					}),
				})
			end,
		})

		table.insert(guis, gui)
	end

	return Roact.createFragment(guis)
end

function ResultsScreen:init()
	self.leaderboardList = Roact.createRef()

	self.blur, self.updateBlur = Roact.createBinding(0)
	self.blurMotor = Flipper.SingleMotor.new(0)
	self.blurMotor:onStep(self.updateBlur)
end

function ResultsScreen:render()
	return createElement(BaseTheme.Consumer, {
		render = function(theme)
			return createElement(TweeningFrame, {
				theme = theme,
				BackgroundTransparency = 1,
				Visible = self.props.Visible,
			}, {
				BlurPortal = createElement(Roact.Portal, {
					target = LightingService,
				}, {
					Blur = createElement("BlurEffect", {
						Size = self.blur,
					}),
				}),
				LeaderBoardFrame = createElement("Frame", {
					AnchorPoint = theme.ap.top_center,
					Position = UDim2.fromScale(0.5, 0.15),
					Size = UDim2.fromScale(0.75, 0.8),
					BackgroundTransparency = 1,
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
					Info = createElement("TextLabel", {
						AnchorPoint = theme.ap.top_center,
						Position = UDim2.fromScale(0.5, 0.05),
						Size = UDim2.fromScale(0.5, 0.1),
						BackgroundTransparency = 1,
						Text = "RESULTS",
						FontFace = theme.fonts.bold,
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
					}),
					ResultsList = createElement("ScrollingFrame", {
						AnchorPoint = theme.ap.top_center,
						Position = UDim2.fromScale(0.5, 0.2),
						Size = UDim2.fromScale(0.75, 0.75),
						BackgroundTransparency = 1,
						[Roact.Ref] = self.leaderboardList,
						ScrollBarImageColor3 = Color3.new(0, 0, 0),
						ScrollBarThickness = UIRatioHandler.CalculateStrokeThickness(8),
						ScrollingDirection = Enum.ScrollingDirection.Y,
					}, {
						UIListLayout = createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0.05),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							FillDirection = Enum.FillDirection.Vertical,
						}),
						Players = self:getLeaderboard(),
					}),
				}),
			})
		end,
	})
end

function ResultsScreen:didMount()
	if self.leaderboardList:getValue() and not self.leaderboardListLayout then
		self.leaderboardListLayoutList = LayoutUtil.new(self.leaderboardList:getValue())
	end

	self:updateVisibility()
end

function ResultsScreen:didUpdate()
	self:updateVisibility()
	if self.leaderboardList:getValue() and not self.leaderboardListLayout then
		self.leaderboardListLayoutList = LayoutUtil.new(self.leaderboardList:getValue())
	end
end

return ResultsScreen
