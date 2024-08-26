-- Services --
local InsertService = game:GetService("InsertService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local MarketPlaceService = game:GetService("MarketplaceService")

-- Variables --
local accessories = { 18360418757 }
local placedAccessories = {}
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

-- Grid Info --
local gridSizeY = 5
local gridSpacing = 10

-- Dependencies --
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

local accessoriesFolder = Instance.new("Folder")
accessoriesFolder.Name = "Accessories"
accessoriesFolder.Parent = workspace.World

local function ToggleAccessory(player, data)
	local character = player.character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local accessoryModel = data.accessoryModel
	local accessory = accessoryModel:FindFirstChildOfClass("Accessory")
	accessory.Name = accessoryModel.Name

	local existingAccessory = character:FindFirstChild(accessoryModel.Name)

	if existingAccessory then
		existingAccessory:Destroy()
	else
		local accessoryClone = accessory:Clone()
		accessoryClone.Parent = nil

		TableUtils:apply(accessoryClone:GetDescendants(), function(child)
			if not child:IsA("BasePart") then
				return
			end

			child.Anchored = false
		end)

		humanoid:AddAccessory(accessoryClone)
	end
end

local function OnAccessoryManagerEvent(player, eventName, eventData)
	if eventName == Constants.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY then
		ToggleAccessory(player, eventData)
	end
end

local function AddAccessoryToGrid(accessory, assetInfo)
	local index = #placedAccessories + 1

	local yPos = (index - 1) % gridSizeY * gridSpacing
	local xPos = 0
	local zPos = math.floor((index - 1) / gridSizeY) * gridSpacing

	TableUtils:apply(accessory:GetDescendants(), function(child)
		if child:IsA("TouchTransmitter") then
			child:Destroy()
		end

		if not child:IsA("BasePart") then
			return
		end

		child.CanTouch = false
		child.CanCollide = false
		child.Anchored = true
	end)

	CollectionService:AddTag(accessory, Constants.TAGS.ACCESSORY)

	-- Add Asset ID Value --
	local assetIdValue = Instance.new("NumberValue")
	assetIdValue.Parent = accessory
	assetIdValue.Name = "AssetID"
	assetIdValue.Value = assetInfo.AssetId

	-- Add Asset Type ID --
	local assetTypeIdValue = Instance.new("NumberValue")
	assetTypeIdValue.Name = "AssetTypeId"
	assetTypeIdValue.Parent = accessory
	assetTypeIdValue.Value = assetInfo.AssetTypeId

	accessory:PivotTo(
		CFrame.new(135, 15, -40) * CFrame.new(xPos, yPos, zPos) * CFrame.fromEulerAnglesXYZ(0, math.rad(45), 0)
	)

	accessory.Name = HttpService:GenerateGUID(false)
	accessory.Parent = accessoriesFolder
end

for _, accessoryId in ipairs(accessories) do
	Promise.new(function(resolve, reject)
		local assetLoadedSuccess, model = pcall(function()
			return InsertService:LoadAsset(accessoryId)
		end)

		local productInfoSuccess, assetInfo = pcall(function()
			return MarketPlaceService:GetProductInfo(accessoryId)
		end)

		if not assetLoadedSuccess or not productInfoSuccess then
			reject("Failed to load asset.")
			return
		end

		resolve(model, assetInfo)
	end)
		:andThen(function(accessoryModel, assetInfo)
			AddAccessoryToGrid(accessoryModel, assetInfo)
		end)
		:catch(warn)
end

RemoteEvents.AccessoryManager_RE.OnServerEvent:Connect(OnAccessoryManagerEvent)
