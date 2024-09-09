-- Services --
local Players = game:GetService("Players")

-- Dependencies --
local ClientModules = script.Parent
local Constants = require(game.ReplicatedStorage.Shared.Modules.Constants)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local ZonePlus = require(game.ReplicatedStorage.Packages.zoneplus)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local BodyPadGui = require(script.BodyPadGui)
local LocalGameStateManager = require(ClientModules.LocalGameStateManager)

-- Variables --
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", math.huge)

local BodyPadController = {}
BodyPadController.__index = BodyPadController

function BodyPadController.new(bodypad)
	local zone = bodypad:FindFirstChild("Zone")
	if not zone then
		return
	end

	local self = setmetatable({}, BodyPadController)

	self.bodypad = bodypad
	self.padJanitor = Janitor.new()

	self:initGui()

	self.zone = ZonePlus.new(zone)
	self.zone.localPlayerEntered:Connect(function()
		self:onPlayerEntered()
	end)
	self.zone.localPlayerExited:Connect(function()
		self:onPlayerExited()
	end)

	self.padJanitor:Add(self.zone, "Destroy")
	return self
end

function BodyPadController:onPlayerEntered()
	print("Player Entered")
	if not self.guiHandle then
		return
	end

	local gameState = LocalGameStateManager.getState()
	if gameState.state ~= Constants.GAME_STATES.ROUND_STARTED then
		return
	end

	Roact.update(
		self.guiHandle,
		Roact.createElement(BodyPadGui, {
			Visible = true,
			Input = {
				toggleBodyPad = function(enable)
					local character = localPlayer.Character
					if not character then
						return
					end

					if enable then
						local charPos = self.bodypad.CharPos
						if not charPos then
							return
						end

						character:PivotTo(charPos.CFrame)
						character.PrimaryPart.Anchored = true
					else
						character.PrimaryPart.Anchored = false
					end
				end,
			},
		})
	)
end

function BodyPadController:onPlayerExited()
	print("Player Exited")
	if not self.guiHandle then
		return
	end

	Roact.update(
		self.guiHandle,
		Roact.createElement(BodyPadGui, {
			Visible = false,
			Input = {
				toggleBodyPad = function(enable)
					local character = localPlayer.Character
					if not character then
						return
					end

					if enable then
						local charPos = self.bodypad.charPos
						if not charPos then
							return
						end

						character:PivotTo(charPos.CFrame)
						character.PrimaryPart.Anchored = true
					else
						character.PrimaryPart.Anchored = false
					end
				end,
			},
		})
	)
end

function BodyPadController:initGui()
	local bbGui = Instance.new("BillboardGui")
	bbGui.ResetOnSpawn = false
	bbGui.LightInfluence = 0
	bbGui.Size = UDim2.fromScale(5, 5)
	bbGui.AlwaysOnTop = true
	bbGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	bbGui.Parent = playerGui
	bbGui.Adornee = self.bodypad.Pad

	local bg = Instance.new("Frame")
	bg.Parent = bbGui
	bg.Name = "Bg"
	bg.AnchorPoint = Vector2.new(0.5, 0.5)
	bg.Position = UDim2.fromScale(0.5, 0.5)
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundTransparency = 1

	self.guiHandle = Roact.mount(
		Roact.createElement(BodyPadGui, {
			Visible = false,
			Input = {
				toggleBodyPad = function(enable)
					local character = localPlayer.Character
					if not character then
						return
					end

					if enable then
						local charPos = self.bodypad.charPos
						if not charPos then
							return
						end

						character:PivotTo(charPos.CFrame)
						character.PrimaryPart.Anchored = true
					else
						character.PrimaryPart.Anchored = false
					end
				end,
			},
		}),
		bg,
		"InfoGui"
	)

	self.padJanitor:Add(bbGui)
end

function BodyPadController:destroy()
	self.padJanitor:CleanUp()
end

return BodyPadController
