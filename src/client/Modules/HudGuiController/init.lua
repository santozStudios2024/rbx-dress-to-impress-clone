-- Services --
local Players = game:GetService("Players")
--local UserInputService = game:GetService("UserInputService")

-- Dependencies --
local menuDataGetter = require(script.MenuDataGetter)
local Roact = require(game.ReplicatedStorage.Packages.roact)
local Utils = require(game.ReplicatedStorage.Shared.Modules.Utils)
local TableUtils = Utils.TableUtils

-- Variables --
local screenGui
local components = {}
local menuHandles = {}
local openMenuId
local componentInputs = {}
local elementsDisabled = {}
local elementHandles = {}
local localPlayer = Players.LocalPlayer

local HudGuiController = {}

function HudGuiController.initialise(menus, menuDatas, popUps)
	menuDataGetter.initialise(menuDatas)

	local playerGui = localPlayer.PlayerGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false
	screenGui.Name = "MainHUD"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true

	local bg = Instance.new("Frame")
	bg.Parent = screenGui
	bg.AnchorPoint = Vector2.new(0.5, 0.5)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BackgroundTransparency = 1
	bg.Position = UDim2.fromScale(0.5, 0.5)
	bg.Size = UDim2.fromScale(1, 1)
	bg.Name = "BG"

	for _, _components in pairs({ menus, popUps }) do
		for componentId, component in pairs(_components) do
			HudGuiController.initialiseComponenet(componentId, component)
		end
	end

	-- Set Orientation --
	--[[if UserInputService.TouchEnabled then
		playerGui.ScreenOrientation = Enum.ScreenOrientation.Portrait
	else
		playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
	end]]
	--
end

function HudGuiController.initialiseComponenet(componentId, component)
	local handlesTable = menuHandles

	components[componentId] = component
	local visibleByDefault = HudGuiController.isMenuOpen(componentId)

	handlesTable[componentId] = Roact.mount(
		Roact.createElement(component, {
			Visible = visibleByDefault,
			Input = HudGuiController.getMenuInput(componentId),
		}),
		screenGui.BG,
		componentId
	)
end

function HudGuiController._setComponentOpen(componentId, Visible)
	local componentHandle = menuHandles[componentId]
	local component = components[componentId]

	if component and componentHandle then
		Roact.update(
			componentHandle,
			Roact.createElement(component, {
				Visible = Visible,
				Input = componentInputs[componentId] or {},
			})
		)
	end
end

-- Elements --
function HudGuiController._setElementEnabled(elementId: string, isEnabled: boolean)
	elementsDisabled[elementId] = not isEnabled
	HudGuiController._setComponentOpen(elementId, HudGuiController.isElementVisible(elementId))
end

function HudGuiController.enableElement(elementId: string, input)
	componentInputs[elementId] = input or {}

	return HudGuiController._setElementEnabled(elementId, true)
end

function HudGuiController.disableElement(elementId: string)
	return HudGuiController._setElementEnabled(elementId, false)
end

function HudGuiController.disableElements(elementIds: { string })
	for _, elementId: string in pairs(elementIds) do
		HudGuiController.disableElement(elementId)
	end
end

function HudGuiController.disableAllElements()
	HudGuiController.disableElements(TableUtils:getKeys(elementHandles))
end

function HudGuiController.enableAllElements()
	HudGuiController.enableElements(TableUtils:getKeys(elementHandles))
end

function HudGuiController.enableElements(elementIds: { string })
	for _, elementId: string in pairs(elementIds) do
		HudGuiController.enableElement(elementId)
	end
end

function HudGuiController.isElementVisible(elementId: string): boolean
	return (not elementsDisabled[elementId]) or false
end

-- Menus --
function HudGuiController.toggleMenu(menuId, input)
	if HudGuiController.isMenuOpen(menuId) then
		HudGuiController.closeMenu(menuId)
	else
		HudGuiController.openMenu(menuId, input)
	end
end

function HudGuiController.openMenu(menuId, input)
	if openMenuId == menuId and not input then
		return false
	end

	if openMenuId then
		HudGuiController.closeMenu(openMenuId)
	end

	componentInputs[menuId] = input or {}
	openMenuId = menuId

	HudGuiController._setComponentOpen(menuId, true)

	return true
end

function HudGuiController.closeMenu(menuId)
	if openMenuId == menuId then
		openMenuId = nil

		HudGuiController._setComponentOpen(menuId, false)

		--HudGuiController.Closed:Fire()
		--HudGuiController.MenuUpdated:Fire(menuId, false)
		return true
	end

	return false
end

function HudGuiController.getOpenMenu()
	return openMenuId
end

function HudGuiController.isMenuOpen(menuId)
	return HudGuiController.getOpenMenu() == menuId
end

function HudGuiController.getMenuInput(menuId)
	return componentInputs[menuId] or {}
end

return HudGuiController
