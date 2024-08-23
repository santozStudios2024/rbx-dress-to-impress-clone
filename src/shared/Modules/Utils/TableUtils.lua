local TableUtils = {}

function TableUtils:sum<T>(tab: { [any]: T }, getValue: ((T) -> number)?)
	local sum: number = 0
	getValue = getValue or function(value: number)
		return value
	end

	for _, value: number in pairs(tab) do
		sum += getValue(value)
	end

	return sum
end

function TableUtils:product(tab: { [any]: number })
	local product: number = 1

	for _, value: number in pairs(tab) do
		product *= value
	end

	return product
end

function TableUtils:unpack<V>(tab: { [any]: { V } }): { V }
	local unpacked = {}

	for _, values: { V } in pairs(tab) do
		for _, value in pairs(values) do
			table.insert(unpacked, value)
		end
	end

	return unpacked
end

function TableUtils:getTopRanked<V>(tab: { V }, fun: (V) -> number)
	local topRank, topRankedKey, topRankedValue = nil, nil

	for key, value: V in pairs(tab) do
		local keyRank = fun(value)

		if (not topRank) or keyRank > topRank then
			topRank = keyRank
			topRankedKey = key
			topRankedValue = value
		end
	end

	return topRankedValue, topRankedKey, topRank
end

function TableUtils:modify(modifications: { any }, target: { any })
	local modifiedTable = TableUtils:clone(target)
	for key, modifiedValue in pairs(modifications) do
		if (type(modifiedValue) == "table") and target[key] then
			modifiedTable[key] = TableUtils:modify(modifiedValue, target[key])
		else
			if type(modifiedValue) == "table" then
				modifiedTable[key] = TableUtils:clone(modifiedValue)
			else
				modifiedTable[key] = modifiedValue
			end
		end
	end
	return modifiedTable
end

function TableUtils:shallowClone<K, V>(tab: { [K]: V }): { [K]: V }
	local shallowClone = {}
	for key: K, value: V in pairs(tab) do
		shallowClone[key] = value
	end
	return shallowClone
end

function TableUtils:shallowEqual(tab1, tab2): boolean
	for i, v in pairs(tab1) do
		if tab2[i] ~= v then
			return false
		end
	end

	for i, v in pairs(tab2) do
		if tab1[i] ~= v then
			return false
		end
	end

	return true
end

function TableUtils:deepEqual(table1, table2)
	if table1 == table2 then
		return true
	end

	local visited = {}
	local function deepEqualHelper(t1, t2)
		visited[t1] = true

		for k, v1 in pairs(t1) do
			local v2 = t2[k]
			if type(v1) == "table" and type(v2) == "table" then
				if not visited[v1] and not deepEqualHelper(v1, v2) then
					return false
				end
			elseif v1 ~= v2 then
				return false
			end
		end

		for k, v2 in pairs(t2) do
			if t1[k] == nil then
				if type(v2) == "table" and not visited[v2] and not deepEqualHelper({}, v2) then
					return false
				else
					return false
				end
			end
		end

		return true
	end

	return deepEqualHelper(table1, table2)
end

function TableUtils:deepClone(tab)
	local clonedTable = {}

	for key, value in pairs(tab) do
		local function clone(x: any)
			if type(x) == "table" then
				return TableUtils:deepClone(x)
			else
				return x
			end
		end

		clonedTable[clone(key)] = clone(value)
	end

	return clonedTable
end

function TableUtils:getValues<K, V>(tab: { [K]: V }): { V }
	local values: { V } = {}

	for _, value: V in pairs(tab) do
		table.insert(values, value)
	end

	return values
end

function TableUtils:traverse(tab: { any }, fun: (any, { string }) -> any, depth: number?, ancestry: { string })
	local depth = depth or math.huge
	local ancestry = ancestry or {}

	for i, v in pairs(tab) do
		local extendedAncestry = TableUtils:append(ancestry, { i })

		if type(v) == "table" and depth > 1 then
			TableUtils:traverse(v, fun, depth - 1, extendedAncestry)
		else
			fun(v, extendedAncestry)
		end
	end
end

function TableUtils:getMax(tab: { number }): number
	local max = nil
	for _, num: number in pairs(tab) do
		if not max or num > max then
			max = num
		end
	end
	return max
end

function TableUtils:buildFrom<U, V>(tab: { U }, fun: (U) -> V): { V }
	local newTable: { V } = {}

	for _, element: U in pairs(tab) do
		local newElement: V = fun(element)
		table.insert(newTable, newElement)
	end

	return newTable
end

function TableUtils:keysTo<U, V>(keys: U, mapTo: V): { [U]: V }
	local tab: { [U]: V } = {}

	for _, key: U in pairs(keys) do
		tab[key] = mapTo
	end

	return tab
end

function TableUtils:zero<U>(keysOrSize: { U } | number)
	if type(keysOrSize) == "number" then
		return table.create(keysOrSize, 0)
	else
		return TableUtils:keysTo(keysOrSize, 0)
	end
end

function TableUtils:buildFrom2<U, V, X, Y>(tab: { [U]: V }, fun: (U, V) -> (X?, Y)): { [X]: Y }
	local newTable: { [X]: Y } = {}

	for key: U, element: V in pairs(tab) do
		local newKey: X?, newElement: Y = fun(key, element)
		if newKey then
			newTable[newKey] = newElement
		else
			table.insert(newTable, newElement)
		end
	end

	return newTable
end

function TableUtils:createN(n: number, create: (number) -> { any })
	local elements: { any } = {}

	for i = 1, n do
		local element: { any }, key: string? = create(i)

		if key then
			elements[key] = element
		else
			table.insert(elements, element)
		end
	end

	return elements
end

function TableUtils:getMaxKey<K>(tab: { [K]: number }): K
	local maxKey, maxValue = nil, nil
	for key: K, value: number in pairs(tab) do
		if not maxValue or value > maxValue then
			maxKey, maxValue = key, value
		end
	end
	return maxKey, maxValue
end

function TableUtils:getKeys<K>(tab: { [K]: any }): { K }
	local keys: { K } = {}

	for key: K, _ in pairs(tab) do
		table.insert(keys, key)
	end

	return keys
end

function TableUtils:getRandomKey<K>(tab: { [K]: any }): K
	local keys: { K } = self:getKeys(tab)
	return keys[math.random(1, #keys)]
end

function TableUtils:createChecklist<K>(tab: { K }): { [K]: boolean }
	local checklist: { [K]: boolean } = {}

	for _, value: K in pairs(tab) do
		checklist[value] = true
	end

	return checklist
end

function TableUtils:apply<K, V, U>(tab: { [K]: V }, fun: (V) -> U): { [K]: U }
	local appliedTab: { [K]: U } = {}
	for key, value in pairs(tab) do
		appliedTab[key] = fun(value)
	end
	return appliedTab
end

function TableUtils:find<K, V>(tab: { [K]: V }, searchFor: V): K | boolean
	for key: K, value: V in pairs(tab) do
		if value == searchFor then
			return key
		end
	end
	return false
end

function TableUtils:addMissingAttributes<K, V>(tab: { [K]: V }, defaultAttributes: { [K]: V })
	for attributeId: K, defaultValue: V in pairs(defaultAttributes) do
		tab[attributeId] = tab[attributeId] or defaultValue
	end
end

function TableUtils:findBy<K, V>(tab: { [K]: V }, equalFunction: ((V, V) -> boolean)?): K | boolean
	for key: K, value: V in pairs(tab) do
		if equalFunction(value) then
			return key, value
		end
	end
	return false
end

function TableUtils:append<V>(tab1: { V }, tab2: { V }, ignoreDuplicates: boolean): { V }
	local appendedTable: { V } = {}
	for _, tab: { V } in pairs({ tab1, tab2 }) do
		for _, v: V in pairs(tab) do
			if (not ignoreDuplicates) or (ignoreDuplicates and not self:find(appendedTable, v)) then
				table.insert(appendedTable, v)
			end
		end
	end
	return appendedTable
end

function TableUtils:appendAll(tables: { { any } }): { any }
	local appended = {}

	for _, tab: { any } in pairs(tables) do
		for _, element in pairs(tab) do
			table.insert(appended, element)
		end
	end

	return appended
end

function TableUtils:filterDuplicateValues<V>(tab: { V })
	local hasAppeared: { [V]: boolean } = {}
	return TableUtils:filter(tab, function(value: V)
		local hasValueAppeared: boolean = hasAppeared[value]
		hasAppeared[value] = true
		return not hasValueAppeared
	end)
end

function TableUtils:filter<K, V>(tab: { V }, fun: (V, K) -> (boolean, K?))
	local filteredTable = {}

	for key, value: V in pairs(tab) do
		local keep: boolean, newKey: any? = fun(value, key)
		if keep then
			if newKey then
				filteredTable[newKey] = value
			else
				table.insert(filteredTable, value)
			end
		end
	end

	return filteredTable
end

function TableUtils:combine<K, V>(tab1: { [K]: V }, tab2: { [K]: V }): { [K]: V }
	local combinedTable: { [K]: V } = {}
	for _, tab in pairs({ tab1, tab2 }) do
		for i, v in pairs(tab) do
			combinedTable[i] = v
		end
	end
	return combinedTable
end

function TableUtils:findFirstMember<K, V>(
	tab: { [any]: V },
	conditionFunction: (V) -> boolean
): (K?, V?) -- Returns the first element of tab which satisfies the conditionFunction
	conditionFunction = conditionFunction or function()
		return true
	end
	for k, v in pairs(tab) do
		if conditionFunction(v) then
			return k, v
		end
	end
	return nil, nil
end

function TableUtils:clone<K, V>(tab: { [K]: V }): { [K]: V }
	local clonedTable: { [K]: V } = {}
	for key: K, value: V in pairs(tab) do
		local keyClone: K = type(key) == "table" and TableUtils:clone(key) or key
		local valueClone: V = type(value) == "table" and TableUtils:clone(value) or value
		clonedTable[keyClone] = valueClone
	end
	return clonedTable
end

function TableUtils:length(tab: {}): number
	local length: number = 0

	for _, _ in pairs(tab) do
		length += 1
	end

	return length
end

function TableUtils:isEmpty(tab: { any }): boolean
	for _, _ in pairs(tab) do
		return false
	end

	return true
end

function TableUtils:getNested(tab: { [any]: any }, keys: { any }): any?
	local ptr: { any }? = tab

	for _, key: any in pairs(keys) do
		ptr = ptr[key]

		if not ptr then
			break
		end
	end

	return ptr
end

function TableUtils:setNested(tab: { [any]: any }, keys: { any }, value: any)
	local ptr: { any }? = tab

	for index, key: any in pairs(keys) do
		if index == #keys then
			ptr[key] = value
		else
			ptr[key] = ptr[key] or {}
		end

		ptr = ptr[key]
	end

	return ptr
end

function TableUtils:incrementNested(tab: { [any]: any }, keys: { any }, incrementBy: any)
	local oldAmount = TableUtils:getNested(tab, keys) or 0
	local newAmount = oldAmount + incrementBy

	TableUtils:setNested(tab, keys, newAmount)
end

return TableUtils
