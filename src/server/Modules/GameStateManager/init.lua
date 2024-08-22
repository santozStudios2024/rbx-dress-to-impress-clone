-- Service --
local Players = game:GetService("Players")

-- Dependencies --
local constants = require(game.ReplicatedStorage.Shared.Modules.Constants)

-- Variables --
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

local GameStateManager = {}
GameStateManager.__index = GameStateManager

local currentStateData = {
	state = constants.GAME_STATES.INTERMISSION,
}
GameStateManager.onStateChanged = Instance.new("BindableEvent")
GameStateManager.onStateChanged.Parent = script

function GameStateManager.validateState(gameState)
	if not gameState then
		return false
	end

	local isValid = false
	for _, validState in pairs(constants.GAME_STATES) do
		if validState == gameState then
			isValid = true
			break
		end
	end

	return isValid
end

function GameStateManager.setState(stateData)
	if not GameStateManager.validateState(stateData.state) then
		warn("Invalid game state: " .. tostring(stateData.state))
		return
	end

	GameStateManager.onStateChanged:Fire(currentStateData, stateData)
	RemoteEvents.GameStateManager_RE:FireAllClients(constants.EVENTS.GAME_STATE_EVENTS.UPDATE_STATE, stateData)
	currentStateData = stateData
end

function GameStateManager.getState()
	return currentStateData
end

local function onPlayerAdded(player)
	RemoteEvents.GameStateManager_RE:FireClient(
		player,
		constants.EVENTS.GAME_STATE_EVENTS.UPDATE_STATE,
		currentStateData
	)
end

Players.PlayerAdded:Connect(onPlayerAdded)

return GameStateManager
