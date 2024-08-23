-- Dependencies --
local Roact = require(game.ReplicatedStorage.Packages.roact)

local BaseTheme = Roact.createContext({
	ap = {
		center = Vector2.new(0.5, 0.5),
		left_center = Vector2.new(0, 0.5),
		right_center = Vector2.new(1, 0.5),
		top_center = Vector2.new(0.5, 0),
		bottom_center = Vector2.new(0.5, 1),
		left_top = Vector2.new(0, 0),
		right_top = Vector2.new(1, 0),
		left_bottom = Vector2.new(0, 1),
		right_bottom = Vector2.new(1, 1),
	},
	pos = {
		center = UDim2.fromScale(0.5, 0.5),
		left_center = UDim2.fromScale(0, 0.5),
		right_center = UDim2.fromScale(1, 0.5),
		top_center = UDim2.fromScale(0.5, 0),
		bottom_center = UDim2.fromScale(0.5, 1),
		left_top = UDim2.fromScale(0, 0),
		right_top = UDim2.fromScale(1, 0),
		left_bottom = UDim2.fromScale(0, 1),
		right_bottom = UDim2.fromScale(1, 1),
	},
	size = UDim2.fromScale(1, 1),
	colors = {
		background = Color3.fromHex("#FCFCFC"),
	},
	fonts = {
		regular = Font.fromName("Arimo", Enum.FontWeight.Regular),
		bold = Font.fromName("Arimo", Enum.FontWeight.ExtraBold),
		italics = Font.fromName("Arimo", Enum.FontWeight.Regular, Enum.FontStyle.Italic),
	},
})

return BaseTheme
