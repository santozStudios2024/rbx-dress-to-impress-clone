-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")

-- Variables --
local Shared = ReplicatedStorage:WaitForChild("Shared", math.huge)
local Assets = Shared:WaitForChild("Assets", math.huge)

-- Dependencies --
local Constants = require(Shared:WaitForChild("Modules", math.huge):WaitForChild("Constants", math.huge))
local GameLoadingManager = require(Shared:WaitForChild("Modules"):WaitForChild("GameLoadingManager", math.huge))
local ImageAssets = require(Assets:WaitForChild("ImageAssets", math.huge))
local Faces = require(Assets:WaitForChild("Faces", math.huge))

local function LoadAsset(asset)
	ContentProvider:PreloadAsync({ asset })
end

local function GetAssetInfo(assetId)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(assetId)
	end)

	if not success then
		return
	end

	return info
end

print("Loading Started.")
for faceName, face in pairs(Faces) do
	print(faceName .. " loading")
	LoadAsset("rbxassetid://" .. face)

	local info = GetAssetInfo(face)

	local assetId = face
	local assetType
	if info.AssetTypeId == 18 then
		assetType = Constants.FACE_TYPE.FACE
	elseif info.AssetTypeId == 42 then
		assetType = Constants.FACE_TYPE.FACE_ACCESSORY
	end

	Faces[faceName] = {
		assetId = assetId,
		assetType = assetType,
	}
end

for _, images in pairs(ImageAssets) do
	for _, image in pairs(images) do
		LoadAsset(image)
	end
end

GameLoadingManager.gameLoaded()
print("Game Loaded")
