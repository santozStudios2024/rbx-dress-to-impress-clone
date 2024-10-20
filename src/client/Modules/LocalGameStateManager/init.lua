-- Variables --
local RemoteEvents = game.ReplicatedStorage.RemoteEvents
local RemoteFunctions = game.ReplicatedStorage.RemoteFunctions
local currentStateData = nil

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Signal = require(game.ReplicatedStorage.Packages.Signal)

local LocalGameStateManager = {}
LocalGameStateManager.__index = LocalGameStateManager
LocalGameStateManager.onGameStateUpdated = Signal.new()

-- Private Functions --
local function SetState(stateData)
	currentStateData = stateData
	LocalGameStateManager.onGameStateUpdated:Fire(currentStateData, stateData)
end

local function OnGameStateEvent(eventName, eventData)
	if eventName == Constants.EVENTS.GAME_STATE_EVENTS.UPDATE_STATE then
		SetState(eventData)
	end
end

function LocalGameStateManager.getState()
	if not currentStateData then
		local stateData = RemoteFunctions.GameStateManager_RF:InvokeServer(Constants.EVENTS.GAME_STATE_EVENTS.GET_STATE)
		SetState(stateData)
	end

	return currentStateData
end

RemoteEvents.GameStateManager_RE.OnClientEvent:Connect(OnGameStateEvent)

return LocalGameStateManager
