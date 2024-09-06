-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local Promise = require(game.ReplicatedStorage.Packages.Promise)
local GameStateManager = require(game.ServerScriptService.Server.Modules.GameStateManager)
local constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local CompetitionSettings = require(script.CompetitionSettings)
local PlayerController = require(game.ReplicatedStorage.Shared.Modules.PlayerController)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
local currentThemeData
local intermission
local roundSubmissions = {}
local RemoteEvents = game.ReplicatedStorage.RemoteEvents

-- Constants --
local COMPETITION_DATA = {
	INTERMISSION_TIME = 30,
	ROUND_TIME = 30,
	RATING_TIME_PER_SUBMISSION = 18,
	RESULTS_TIME = 20,
}

local function validateCompetitionSettings()
	for key, value in pairs(COMPETITION_DATA) do
		if CompetitionSettings[key] then
			continue
		end

		CompetitionSettings[key] = value
	end
end

local function selectPosingAnimation(player, data)
	local selectedPosingAnimation = player:FindFirstChild("SelectedPosingAnimation")
	if not selectedPosingAnimation then
		selectedPosingAnimation = Instance.new("ObjectValue")
		selectedPosingAnimation.Name = "SelectedPosingAnimation"
		selectedPosingAnimation.Parent = player
	end

	selectedPosingAnimation.Value = data.emote
end

local function rateCreation(player, ratingData)
	-- local index = TableUtils:findBy(roundSubmissions, function(outfitData)
	-- 	return outfitData.player.UserId == ratingData.userId
	-- end)

	-- if not index then
	-- 	return
	-- end

	if player == ratingData.ratedPlayer then
		return
	end

	local outfitData = roundSubmissions[ratingData.ratedPlayer]
	if not outfitData then
		return
	end

	if not outfitData.playerRatings then
		outfitData.playerRatings = {}
	end

	outfitData.playerRatings[player.UserId] = ratingData.rating
end

local function onPlayerAdded(player)
	local selectedPosingAnimation = Instance.new("ObjectValue")
	selectedPosingAnimation.Name = "SelectedPosingAnimation"
	selectedPosingAnimation.Parent = player
end

local function onPlayerRemoved(player)
	-- local index = TableUtils:findBy(roundSubmissions, function(outfitData)
	-- 	return outfitData.player.UserId == player.userId
	-- end)

	-- if not index then
	-- 	return
	-- end

	-- table.remove(roundSubmissions, index)
	roundSubmissions[player] = nil
end

local function OnCompetitionEvent_RE(player, eventName, eventData)
	if eventName == constants.EVENTS.COMPETITION_EVENTS.RATING then
		rateCreation(player, eventData)
	elseif eventName == constants.EVENTS.COMPETITION_EVENTS.SELECT_POSING_ANIMATION then
		selectPosingAnimation(player, eventData)
	end
end

function startRound()
	-- Round Specific vars
	local roundEndTime = nil

	return Promise.resolve()
		:andThen(function()
			roundSubmissions = {}

			-- Set Round specific Variablea
			roundEndTime = os.time() + CompetitionSettings.ROUND_TIME

			GameStateManager.setState({
				state = constants.GAME_STATES.ROUND_STARTED,
				metaData = {
					endTime = roundEndTime,
					themeData = currentThemeData,
				},
			})
		end)
		:andThenCall(Promise.delay, CompetitionSettings.ROUND_TIME)
		:andThen(function()
			for _, player in ipairs(Players:GetPlayers()) do
				roundSubmissions[player] = {
					player = player,
				}
			end

			local submissions = TableUtils:getValues(roundSubmissions)
			if #submissions <= 0 then
				print("NO SUBMISSIONS!!!")

				return Promise.reject(intermission)
			end

			for _, outfitData in pairs(submissions) do
				outfitData.rating = 0
			end

			GameStateManager.setState({
				state = constants.GAME_STATES.RATING,
				metaData = {
					endTime = os.time()
						+ #TableUtils:getValues(submissions) * CompetitionSettings.RATING_TIME_PER_SUBMISSION,
					ratingTime = CompetitionSettings.RATING_TIME_PER_SUBMISSION,
					submissions = submissions,
					themeData = currentThemeData,
				},
			})
		end)
		:andThen(function()
			local delay = CompetitionSettings.RATING_TIME_PER_SUBMISSION * #TableUtils:getValues(roundSubmissions)
			return Promise.delay(delay)
		end)
		:andThen(function()
			for _, outfitData in pairs(roundSubmissions) do
				outfitData.rating = 0

				if not outfitData.playerRatings then
					continue
				end

				for _, rating in pairs(outfitData.playerRatings) do
					outfitData.rating += rating
				end
			end

			local submission = TableUtils:getValues(roundSubmissions)
			table.sort(submission, function(a, b)
				return a.rating > b.rating
			end)

			GameStateManager.setState({
				state = constants.GAME_STATES.RESULTS,
				metaData = {
					submissions = submission,
					endTime = os.time() + CompetitionSettings.RESULTS_TIME,
					themeData = currentThemeData,
				},
			})
		end)
		:andThenCall(Promise.delay, CompetitionSettings.RESULTS_TIME)
		:andThen(function()
			for _, player in ipairs(Players:GetPlayers()) do
				PlayerController.resetDescription(player)
			end
			return intermission
		end)
		:catch(function(state)
			warn(tostring(state))
			return state
		end)
end

intermission = function()
	return Promise.race({
		Promise
			.resolve()
			:andThen(function()
				currentThemeData = {
					theme = "Wild West",
				}

				GameStateManager.setState({
					state = constants.GAME_STATES.INTERMISSION,
					metaData = {
						endTime = os.time() + CompetitionSettings.INTERMISSION_TIME,
						themeData = currentThemeData,
					},
				})
			end)
			:andThenCall(Promise.delay, CompetitionSettings.INTERMISSION_TIME)
			-- :andThen(function()
			-- 	task.wait(intermissionTime)
			-- 	return true
			-- end)
			:andThen(
				function()
					return startRound
				end
			),
	}):catch(function(state)
		warn(tostring(state))
		return state
	end)
end

RemoteEvents.Competition_RE.OnServerEvent:Connect(OnCompetitionEvent_RE)
Players.PlayerRemoving:Connect(onPlayerRemoved)
Players.PlayerAdded:Connect(onPlayerAdded)

currentThemeData = {
	theme = "Wild West",
}

validateCompetitionSettings()
local nextState = intermission
while true do
	nextState = nextState():expect()
	task.wait(1)
end
