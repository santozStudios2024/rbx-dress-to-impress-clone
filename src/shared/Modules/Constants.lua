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
		HEAD_COLOR3 = "HeadColor",
		TORSO_COLOR3 = "TorsoColor",
		LEFT_ARM_COLOR3 = "LeftArmColor",
		RIGHT_ARM_COLOR3 = "RightArmColor",
		LEFT_LEG_COLOR3 = "LeftLegColor",
		RIGHT_LEG_COLOR3 = "RightLegColor",
	},
	BODY_CUSTOMIZATIONS = {
		COLOR = "Color",
		SCALE = "Scale",
		FACES = "Faces",
	},
}

return Constants
