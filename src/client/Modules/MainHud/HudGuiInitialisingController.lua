-- Services --
local StarterGui = game:GetService("StarterGui")

local startPage = "RoundPage"

-- Variables --
local folders = {
	Menus = script.Parent.Menus,
	PopUps = script.Parent.PopUps,
}

-- Dependencies --
local HudController = require(script.Parent.Parent.HudGuiController)
local CoreGuiToDisable = require(script.Parent.CoreGuiToDisable)

local HudGuiInitialisingController = {}

function HudGuiInitialisingController.init()
	local menuDatas = require(script.Parent.MenuDatas)

	local components = { Menus = {}, PopUps = {} }

	for folderTypeName, folder in pairs(folders) do
		for _, module in ipairs(folder:GetChildren()) do
			if not module:IsA("ModuleScript") then
				continue
			end

			local componentName = module.Name
			components[folderTypeName][componentName] = require(module)
		end

		folder.ChildAdded:Connect(function(module)
			if not module:IsA("ModuleScript") then
				return
			end

			local componentName = module.Name
			components[folderTypeName][componentName] = require(module)

			HudController.initialiseComponenet(componentName, components[folderTypeName][componentName])
		end)
	end

	HudController.initialise(components.Menus, menuDatas, components.PopUps)

	HudController.openMenu(startPage)

	for _, coreGui in pairs(CoreGuiToDisable) do
		StarterGui:SetCoreGuiEnabled(coreGui, false)
	end
end

return HudGuiInitialisingController
