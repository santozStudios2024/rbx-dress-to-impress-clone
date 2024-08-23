-- Services --
local TextService = game:GetService("TextService")

local UIRatioHandler = {}

function UIRatioHandler.GetRatio(direction)
	local orignalSize, currentSize

	if direction == Enum.ScrollingDirection.X then
		orignalSize = 1920
		currentSize = workspace.CurrentCamera.ViewportSize.X
	elseif direction == Enum.ScrollingDirection.Y then
		orignalSize = 1080
		currentSize = workspace.CurrentCamera.ViewportSize.Y
	elseif direction == Enum.ScrollingDirection.XY then
		orignalSize = 1920 * 1080
		currentSize = workspace.CurrentCamera.ViewportSize.X * workspace.CurrentCamera.ViewportSize.Y
	end

	local ratio = currentSize / orignalSize

	return ratio
end

function UIRatioHandler.CalculateStrokeThickness(currentThickness)
	local ratio = UIRatioHandler.GetRatio(Enum.ScrollingDirection.X)

	return math.max(1.5, currentThickness * ratio)
end

function UIRatioHandler.CalculateTextSize(fontSize)
	local ratio = UIRatioHandler.GetRatio(Enum.ScrollingDirection.X)

	return math.max(5, fontSize * ratio)
end

function UIRatioHandler.GetTextBounds(text, textSize, font, size)
	local ratio = UIRatioHandler.GetRatio(Enum.ScrollingDirection.X)

	local currentSize = workspace.CurrentCamera.ViewportSize

	local containerSize = Vector2.new(currentSize.X * size.X, currentSize.Y * size.Y)

	local bounds = TextService:GetTextSize(text, textSize, font, containerSize)

	local padding = Vector2.new(math.max(10, 50 * ratio), math.max(10, 20 * ratio))

	return bounds + padding
end

return UIRatioHandler
