function IsDamageSpecialValue(specialName)
	local name = string.lower(specialName)

	local matchNames = {
		"damage",
	}

	local notMatchNames = {
		"reduction", "duration", "radius", "add",
	}

	for _,value in ipairs(matchNames) do
		if not string.find(name,value) then 
			return false
		end
	end

	for _,value in ipairs(notMatchNames) do
		if string.find(name,value) then 
			return false
		end
	end

	return true
end