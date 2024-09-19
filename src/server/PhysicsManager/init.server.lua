-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local CollisionGroupUtils = Utils.CollisionGroupUtils

local function RegisterCollisionGroups()
	CollisionGroupUtils.addCollisionGroup(Constants.CG_IDS.PLAYER)
	CollisionGroupUtils.addCollisionGroup(Constants.CG_IDS.CATWALK_MODEL)
	CollisionGroupUtils.addCollisionGroup(Constants.CG_IDS.RAMP)

	CollisionGroupUtils.setCollidable(Constants.CG_IDS.PLAYER, Constants.CG_IDS.PLAYER, false)
	CollisionGroupUtils.disableCollision(Constants.CG_IDS.CATWALK_MODEL)
	CollisionGroupUtils.setCollidable(Constants.CG_IDS.CATWALK_MODEL, Constants.CG_IDS.RAMP, true)
end

RegisterCollisionGroups()
