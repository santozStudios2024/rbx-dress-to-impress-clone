-- Dependencies --
local ClientModules = script.Parent.Parent.Parent.Parent
local Roact = require(game.ReplicatedStorage.Packages.roact)
local BaseTheme = require(ClientModules.BaseTheme)
local Faces = require(game.ReplicatedStorage.Shared.Assets.Faces)
local LayoutUtil = require(ClientModules.LayoutUtil)
local ImageAssets = require(game.ReplicatedStorage.Shared.Assets.ImageAssets)
local GameLoadingManager = require(game.ReplicatedStorage.Shared.Modules.GameLoadingManager)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local UIRatioHandler = Utils.UIRatioHandler

-- Variables --
local createElement = Roact.createElement
local roactEvents = Roact.Event

local FacesGui = Roact.Component:extend("FacesGui")

function FacesGui:getFaces(theme)
	if not GameLoadingManager.isGameLoaded() then
		return
	end

	local guis = {}

	for name, faceData in pairs(Faces) do
		local gui = createElement("CanvasGroup", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			LayoutOrder = #guis + 1,
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.15),
			}),
			FaceImageBg = createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 1,
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0.1),
					PaddingLeft = UDim.new(0.1),
					PaddingRight = UDim.new(0.1),
					PaddingTop = UDim.new(0.1),
				}),
				FaceImage = createElement("ImageLabel", {
					AnchorPoint = theme.ap.center,
					Position = theme.pos.center,
					Size = theme.size,
					BackgroundTransparency = 1,
					Image = "rbxthumb://type=Asset&id=" .. faceData.assetId .. "&w=150&h=150",
					ScaleType = Enum.ScaleType.Fit,
				}),
			}),
			Info = createElement("TextLabel", {
				AnchorPoint = theme.ap.bottom_center,
				Position = theme.pos.bottom_center,
				Size = UDim2.fromScale(1, 0.2),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.5,
				Text = name,
				TextScaled = true,
				FontFace = theme.fonts.bold,
				TextColor3 = Color3.new(1, 1, 1),
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0.05),
					PaddingLeft = UDim.new(0.05),
					PaddingRight = UDim.new(0.05),
					PaddingTop = UDim.new(0.05),
				}),
			}),
			SelectionFrame = createElement("Frame", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(0, 0, 0),
				ZIndex = 5,
				Visible = self.props.faceBind.face:map(function(selectedFace)
					if not selectedFace then
						return false
					end

					return selectedFace.assetId == faceData.assetId
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
			Button = createElement("ImageButton", {
				AnchorPoint = theme.ap.center,
				Position = theme.pos.center,
				Size = theme.size,
				BackgroundTransparency = 1,
				ZIndex = 10,
				[roactEvents.Activated] = function()
					local currentFace = self.props.faceBind.face:getValue()

					if currentFace and currentFace.assetId == faceData.assetId then
						self.props.faceBind.update(nil)
					else
						self.props.faceBind.update(faceData)
					end
				end,
			}),
		})

		table.insert(guis, gui)
	end

	return Roact.createFragment(guis)
end

function FacesGui:init()
	self.canvasPos, self.updateCanvasPos = Roact.createBinding(Vector2.new(0, 0))
	self.scrollingFrame = Roact.createRef()

	GameLoadingManager.gameLoadedSignal:Connect(function()
		self:setState({})
	end)
end

function FacesGui:render()
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
					PaddingLeft = UDim.new(0.05),
					PaddingRight = UDim.new(0.05),
					PaddingTop = UDim.new(0.05),
				}),
				LoadingScreen = createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = "LOADING FACES . . .",
					TextScaled = true,
					FontFace = theme.fonts.bold,
					TextColor3 = Color3.new(1, 1, 1),
					Visible = not GameLoadingManager.isGameLoaded(),
				}, {
					UIPadding = createElement("UIPadding", {
						PaddingBottom = UDim.new(0.3),
						PaddingLeft = UDim.new(0.3),
						PaddingRight = UDim.new(0.3),
						PaddingTop = UDim.new(0.3),
					}),
				}),
				FacesList = createElement("ScrollingFrame", {
					AnchorPoint = theme.ap.center,
					Position = theme.pos.center,
					Size = theme.size,
					BackgroundTransparency = 1,
					CanvasPosition = self.canvasPos,
					[Roact.Ref] = self.scrollingFrame,
					ScrollBarThickness = UIRatioHandler.CalculateStrokeThickness(10),
					BorderSizePixel = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ScrollBarImageColor3 = Color3.new(1, 1, 1),
				}, {
					UIGridLayout = createElement("UIGridLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						CellSize = UDim2.fromScale(0.3, 0.32),
						CellPadding = UDim2.fromScale(0.05, 0.08),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Faces = self:getFaces(theme),
				}),
			})
		end,
	})
end

function FacesGui:didMount()
	if not self.scrollingFrame:getValue() then
		return
	end
	LayoutUtil.new(self.scrollingFrame:getValue())
end

function FacesGui:didUpdate()
	if not self.scrollingFrame:getValue() then
		return
	end
	LayoutUtil.new(self.scrollingFrame:getValue())
end

return FacesGui
