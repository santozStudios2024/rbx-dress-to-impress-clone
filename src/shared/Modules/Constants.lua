local Constants = {
	GAME_STATES = {
		ROUND_STARTED = "RoundStarted",
		RATING = "Rating",
		RESULTS = "Results",
		INTERMISSION = "Intermission",
	},
	EVENTS = {
		GAME_STATE_EVENTS = {
			UPDATE_STATE = "UpdateState",
			GET_STATE = "GetState",
		},
		ACCESSORY_MANAGER_EVENTS = {
			TOGGLE_ACCESSORY = "ToggleAccessory",
		},
		COMPETITION_EVENTS = {
			RATING = "Rating",
			SELECT_POSING_ANIMATION = "SelectPosingAnimation",
		},
	},
	TAGS = {
		ACCESSORY = "Accessory",
	},
}

return Constants
