-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local CollisionGroupUtils = Utils.CollisionGroupUtils

-- Variables --
local playerJanitors = {}
local characterJanitors = {}

local function OnCharacterAdded(player, character: Model)
	if characterJanitors[player] then
		characterJanitors[player]:Cleanup()
	end

	local characterJanitor = Janitor.new()

	CollisionGroupUtils.setCollisionGroup(character, Constants.CG_IDS.PLAYER)

	local partAddedConnection = character.DescendantAdded:Connect(function(descendant)
		CollisionGroupUtils.setCollisionGroup(descendant, Constants.CG_IDS.PLAYER)
	end)

	characterJanitor:Add(partAddedConnection)

	characterJanitors[player] = characterJanitor
end

local function OnCharacterRemoved(player)
	if not characterJanitors[player] then
		return
	end

	characterJanitors[player]:Cleanup()
end

local function OnPlayerAdded(player: Player)
	local playerJanitor = Janitor.new()

	local characterAddedConnection = player.CharacterAdded:Connect(function(character)
		OnCharacterAdded(player, character)
	end)

	local characterRemovedConnection = player.CharacterRemoving:Connect(function()
		OnCharacterRemoved(player)
	end)

	playerJanitor:Add(characterAddedConnection, "Disconnect")
	playerJanitor:Add(characterRemovedConnection, "Disconnect")

	playerJanitors[player] = playerJanitor

	-- Add Player Scaling --
	local scaleValuesFolder = Instance.new("Folder")
	scaleValuesFolder.Parent = player
	scaleValuesFolder.Name = "ScaleValues"

	local scalingValues = {
		"HeadScale",
		"TorsoScale",
		"RightArmScale",
		"LeftArmScale",
		"LeftLegScale",
		"RightLegScale",
		"BodyHeightScale",
		"BodyWidthScale",
		"BodyDepthScale",
	}

	for _, valueName in ipairs(scalingValues) do
		local scalingValue = Instance.new("NumberValue")
		scalingValue.Name = valueName
		scalingValue.Parent = scaleValuesFolder

		scalingValue.Value = 1
	end
end

local function OnPlayerRemoved(player)
	if characterJanitors[player] then
		characterJanitors[player]:Cleanup()
	end

	if playerJanitors[player] then
		playerJanitors[player]:Cleanup()
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoved)
