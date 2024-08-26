local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

-- Here we load a file just like in the first example
local file = fs.readFile("build.rbxl")
local game = roblox.deserializePlace(file)
local workspace = game:GetService("Workspace")

-- Make sure a directory exists to save our models in
fs.writeDir("World")

-- Then we save all of our instances in Workspace as model files, in our new directory
-- Note that a model file can actually contain several instances at once, so we pass a table here
for _, child in workspace.World:GetChildren() do
	file = roblox.serializeModel({ child })
	fs.writeFile("World/" .. child.Name, file)
end
