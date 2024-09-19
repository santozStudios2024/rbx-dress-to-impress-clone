-- Dependencies --
local GameStateManager = require(game.ServerScriptService.Server.Modules.GameStateManager)
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)

-- Variables --
local assetsJanitor = Janitor.new()
local PodiumAssets = script.Assets.Podiums
local RampWalkAssets = script.Assets.Ramps
local assetsAdded = false
local modelsFolder = workspace:WaitForChild("World"):WaitForChild("Models")

local function AddAssets(state)
	local metaData = state.metaData
	if not metaData then
		return
	end

	local themeData = metaData.themeData
	if not themeData then
		return
	end

	local theme = themeData.theme
	if not theme then
		return
	end

	assetsJanitor:Cleanup()

	-- Add Ramp Walk --
	local ramp = RampWalkAssets:FindFirstChild(theme)
	if not ramp then
		ramp = RampWalkAssets:FindFirstChild("Default")
	end
	ramp = ramp:Clone()
	ramp.Name = "Ramp"
	ramp.Parent = modelsFolder
	assetsJanitor:Add(ramp)

	-- Add Podium --
	local podium = PodiumAssets:FindFirstChild(theme)
	if not podium then
		podium = PodiumAssets:FindFirstChild("Default")
	end
	podium = podium:Clone()
	podium.Name = "Podium"
	podium.Parent = modelsFolder
	assetsJanitor:Add(podium)

	assetsAdded = true
end

local function OnGameStateChanged(_, newState)
	print("On Game State updated")
	if newState.state ~= Constants.GAME_STATES.INTERMISSION and assetsAdded then
		print("Return")
		return
	end

	AddAssets(newState)
end

GameStateManager.onStateChanged.Event:Connect(OnGameStateChanged)
OnGameStateChanged(nil, GameStateManager.getState())
