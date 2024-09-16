-- Dependencies --
local Signal = require(game.ReplicatedStorage.Packages.Signal)

-- Variables --
local isGameLoaded = false

local GameLoadingManager = {}
GameLoadingManager.__index = GameLoadingManager

GameLoadingManager.gameLoadedSignal = Signal.new()

function GameLoadingManager.gameLoaded()
	isGameLoaded = true
	GameLoadingManager.gameLoadedSignal:Fire()
end

function GameLoadingManager.isGameLoaded()
	return isGameLoaded
end

return GameLoadingManager
