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
			TOGGLE_BODY_COLOR = "ToggleBodyColor",
		},
		COMPETITION_EVENTS = {
			RATING = "Rating",
			SELECT_POSING_ANIMATION = "SelectPosingAnimation",
		},
	},
	TAGS = {
		ACCESSORY = "Accessory",
		BODY_PAD = "BodyPad",
	},
	BODY_COLORS = {
		HEAD_COLOR3 = "HeadColor3",
		TORSO_COLOR3 = "TorsoColor3",
		LEFT_ARM_COLOR3 = "LeftArmColor3",
		RIGHT_ARM_COLOR3 = "RightArmColor3",
		LEFT_LEG_COLOR3 = "LeftLegColor3",
		RIGHT_LEG_COLOR3 = "RightLegColor3",
	},
}

return Constants
