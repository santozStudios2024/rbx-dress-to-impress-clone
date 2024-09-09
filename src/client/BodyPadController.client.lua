-- Services --
local CollectionService = game:GetService("CollectionService")

-- Dependencies --
local ClientModules = script.Parent.Modules
local Constatns = require(game.ReplicatedStorage.Shared.Modules.Constants)
local BodyPadController = require(ClientModules.BodyPadController)

-- Variables --
local bodypadAddedSignal = CollectionService:GetInstanceAddedSignal(Constatns.TAGS.BODY_PAD)
local bodypadRemovedSignal = CollectionService:GetInstanceRemovedSignal(Constatns.TAGS.BODY_PAD)
local bodypads = {}

local function onBodyPadAdded(bodypad)
	bodypads[bodypad] = BodyPadController.new(bodypad)
end

local function onBodyPadRemoved(bodypad)
	if not bodypads[bodypad] then
		return
	end

	bodypads[bodypad]:destroy()
end

for _, bodypad in ipairs(CollectionService:GetTagged(Constatns.TAGS.BODY_PAD)) do
	onBodyPadAdded(bodypad)
end

bodypadAddedSignal:Connect(onBodyPadAdded)
bodypadRemovedSignal:Connect(onBodyPadRemoved)
