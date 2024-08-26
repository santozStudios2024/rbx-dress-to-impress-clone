-- Services --
local Players = game:GetService("Players")

-- Variables --
local localPlayer = Players.LocalPlayer

-- Dependencies --
local LocalGameStateManager = require(script.Parent.Modules.LocalGameStateManager)

local function UpdateCharacterPos(state)
	local teleportParts = game.Workspace.World.Models:FindFirstChild("TeleportParts")
	if not teleportParts then
		return
	end

	local partToTeleportTo = teleportParts:FindFirstChild(state)
	if not partToTeleportTo then
		return
	end

	local character = localPlayer.Character
	if not character then
		return
	end

	character:WaitForChild("HumanoidRootPart")

	print("Character Moved")
	character:PivotTo(partToTeleportTo.CFrame * CFrame.new(0, 5, 0))
end

local function OnGameStateUpdated(_, currentState)
	UpdateCharacterPos(currentState.state)
end

local function OnCharacterAdded()
	local stateData = LocalGameStateManager.getState()

	UpdateCharacterPos(stateData.state)
end

localPlayer.CharacterAppearanceLoaded:Connect(OnCharacterAdded)
localPlayer.CharacterAdded:Connect(OnCharacterAdded)
LocalGameStateManager.onGameStateUpdated:Connect(OnGameStateUpdated)

OnGameStateUpdated(nil, LocalGameStateManager.getState())
