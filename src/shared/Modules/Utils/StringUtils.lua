local StringUtils = {}
StringUtils.__index = StringUtils

function StringUtils.truncateString(str: string, len)
	if not str then
		return ""
	end

	if #str <= len then
		return str
	end

	local finalStr = str:sub(1, len)
	finalStr = finalStr .. "..."

	return finalStr
end

return StringUtils
