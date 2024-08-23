local MenuDataGetter = {}

local menuDatas = {}

function MenuDataGetter.initialise(_menuDatas)
	menuDatas = _menuDatas
end

function MenuDataGetter.getMenuData(menuId)
	return menuDatas[menuId]
end

return MenuDataGetter
