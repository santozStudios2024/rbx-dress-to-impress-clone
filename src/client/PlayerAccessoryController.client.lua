-- Services --
local CollectionService = game:GetService("CollectionService")
-- local Players = game:GetService("Players")

-- Dependencies --
local Constatns = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)

-- Variables --
local accessoryAddedSignal = CollectionService:GetInstanceAddedSignal(Constatns.TAGS.ACCESSORY)
local accessoryRemovedSignal = CollectionService:GetInstanceRemovedSignal(Constatns.TAGS.ACCESSORY)
local accessories = {}
-- local localPlayer = Players.LocalPlayer
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

-- local function ToggleAccessory(accessoryModel)
-- 	local assetIdValue = accessoryModel:FindFirstChild("AssetID")
-- 	local assetTypeIdValue = accessoryModel:FindFirstChild("AssetTypeId")

-- 	local accessory = accessoryModel:FindFirstChildOfClass("Accessory")
-- 	if not accessory then
-- 		return
-- 	end

-- 	local character = localPlayer.Character
-- 	if not character then
-- 		return
-- 	end

-- 	local humanoid = character:FindFirstChild("Humanoid")
-- 	if not humanoid then
-- 		return
-- 	end
-- 	local hd: HumanoidDescription = humanoid:GetAppliedDescription()
-- 	hd.Parent = script

-- 	local AccessoryType = ACCESSORY_INDEX[assetTypeIdValue.Value]

-- 	local success, _ = pcall(function()
-- 		if hd[AccessoryType] and assetTypeIdValue.Value ~= 11 and assetTypeIdValue.Value ~= 12 then
-- 			hd[AccessoryType] = hd[AccessoryType] .. "," .. assetIdValue.Value
-- 		else
-- 			hd[AccessoryType] = assetIdValue.Value
-- 		end
-- 	end)

-- 	if not success then
-- 		return
-- 	end

-- 	humanoid:ApplyDescriptionReset(hd)

-- 	hd:Destroy()

-- 	local existingAccessory = character:FindFirstChild(accessory.Name)

-- 	if existingAccessory then
-- 		existingAccessory:Destroy()
-- 	else
-- 		local accessoryClone = accessory:Clone()
-- 		accessoryClone.Parent = nil

-- 		TableUtils:apply(accessoryClone:GetDescendants(), function(child)
-- 			if not child:IsA("BasePart") then
-- 				return
-- 			end

-- 			child.Anchored = false
-- 		end)

-- 		humanoid:AddAccessory(accessoryClone)
-- 	end
-- end

local function OnAccessoryAdded(accessory)
	print("On Accessory added")

	local cd = Instance.new("ClickDetector")
	cd.Parent = accessory

	local highlight = Instance.new("Highlight")
	highlight.Parent = accessory
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	local janitor = Janitor.new()

	local clickedConnection = cd.MouseClick:Connect(function()
		-- ToggleAccessory(accessory)
		RemoteEvents.AccessoryManager_RE:FireServer(Constatns.EVENTS.ACCESSORY_MANAGER_EVENTS.TOGGLE_ACCESSORY, {
			accessoryModel = accessory,
		})
	end)

	local mouseEnterConnection = cd.MouseHoverEnter:Connect(function()
		highlight.OutlineTransparency = 0
	end)

	local mouseLeaveConnection = cd.MouseHoverLeave:Connect(function()
		highlight.OutlineTransparency = 1
	end)

	janitor:Add(clickedConnection, "Disconnect")
	janitor:Add(mouseEnterConnection, "Disconnect")
	janitor:Add(mouseLeaveConnection, "Disconnect")

	accessories[accessory] = janitor
end

local function OnAccessoryRemoved(accessory)
	if not accessories[accessory] then
		return
	end

	accessories[accessory]:Cleanup()
end

for _, accessory in ipairs(CollectionService:GetTagged(Constatns.TAGS.ACCESSORY)) do
	OnAccessoryAdded(accessory)
end

accessoryAddedSignal:Connect(OnAccessoryAdded)
accessoryRemovedSignal:Connect(OnAccessoryRemoved)
