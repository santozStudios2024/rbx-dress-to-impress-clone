-- Services --
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Dependencies --
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)

local CollisionGroupUtils = {}

function CollisionGroupUtils.addCollisionGroup(cgID)
	if RunService:IsClient() then
		warn("CAN NOT CREATE COLLISION GROUP ON CLIENT")
		return
	end

	PhysicsService:RegisterCollisionGroup(cgID)
end

function CollisionGroupUtils.setCollidable(cgID_a, cgID_b, isCollidable)
	if RunService:IsClient() then
		warn("CAN NOT CREATE COLLISION GROUP ON CLIENT")
		return
	end

	PhysicsService:CollisionGroupSetCollidable(cgID_a, cgID_b, isCollidable)
end

function CollisionGroupUtils.setCollisionGroup(object, cgID)
	if object:IsA("BasePart") then
		object.CollisionGroup = cgID
	end

	for _, child in ipairs(object:GetDescendants()) do
		if not child:IsA("BasePart") then
			continue
		end

		child.CollisionGroup = cgID
	end
end

function CollisionGroupUtils.disableCollision(cgID_a)
	for _, cgID_b in pairs(Constants.CG_IDS) do
		CollisionGroupUtils.setCollidable(cgID_a, cgID_b, false)
	end
end

return CollisionGroupUtils
