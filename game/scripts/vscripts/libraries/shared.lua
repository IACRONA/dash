 TalentsUtilities =  TalentsUtilities or {}

 

 function  TalentsUtilities:ParseTalent(talentData, upgrade_name, talentType, abilityName)
	talentData.type = talentType
	talentData.upgrade_name = upgrade_name
	talentData.operator = OPERATOR_TEXT_TO_NUMBER[talentData.operator or " ADD"]
	talentData.ability_name = ability_name 
	

	if talentData.rarity then
		talentData.rarity = RARITY_TEXT_TO_NUMBER[talentData.rarity] or TALENT_RARITY_COMMON
	end

	if talentData.min_rarity then
		talentData.min_rarity = RARITY_TEXT_TO_NUMBER[talentData.min_rarity] or TALENT_RARITY_COMMON
	end


	if talentData.attack_capability then
		talentData.attack_capability = _G[talentData.attack_capability]
	end

	local default_linked_operator = TALENT_OPERATOR.ADD

	if talentData.linked_default_operator then
		default_linked_operator = OPERATOR_TEXT_TO_NUMBER[talentData.linked_default_operator]
		talentData.linked_default_operator = nil
	end

	for _, linked_data in pairs(talentData.linked_special_values or {}) do
		if type(linked_data) == "table" then
			linked_data.operator = (linked_data.operator and OPERATOR_TEXT_TO_NUMBER[linked_data.operator]) or default_linked_operator
		end
	end

	for linked_ability, linked_data in pairs(talentData.linked_abilities or {}) do
		for special_name, linked_special_data in pairs(linked_data or {}) do
			if type(linked_special_data) == "table" then
				linked_special_data.operator = (linked_special_data.operator and OPERATOR_TEXT_TO_NUMBER[linked_special_data.operator]) or default_linked_operator
			end
		end
	end

	 TalentsUtilities:RegisterTalents(talentData.talents or {})
end



function  TalentsUtilities:GetDefaultBaseValue(hero, ability_level, ability_name, talentName)
	if not ability_name or not talentName or ability_name == "generic" then return 0 end

	local ability = hero:FindAbilityByName(ability_name)
	if not IsValidEntity(ability) then return end

	return ability:GetLevelSpecialValueNoOverride(talentName, ability_level or ability:GetLevel()) or 0
end



function  TalentsUtilities:CalculateUpgradeValue(hero, upgrade_value, count, talentData, ability_level, ability_name, talentName)
	local result = 0
	local final_multiplier = 1

	if talentData.facets then
		local facet_id = hero:GetHeroFacetID()
		local value_override = talentData.facets[tostring(facet_id)]
		if value_override then upgrade_value = value_override end
	end

	for talent_name, operation in pairs(talentData.talents or {}) do
		local operator, value

		if type(operation) == "number" then
			operator = "+"
			value = operation
		else
			operator = string.sub(operation, 1, 1)
			value = tonumber(string.sub(operation, 2))
		end

		local talent = hero:FindAbilityByName(talent_name)
		if IsValidEntity(talent) and talent:GetLevel() > 0 then
			if operator == "+" then result = result + value end

			if operator == "x" then final_multiplier = final_multiplier * value end
		end
	end

	upgrade_value = upgrade_value * final_multiplier

	if not talentData.operator or talentData.operator == TALENT_OPERATOR.ADD then
		result = result + upgrade_value * count

		if talentData.increment then

			result = result + count * ((count - 1) * talentData.increment) / 2.0
		end

	elseif talentData.operator == TALENT_OPERATOR.MULTIPLY then
		local target = talentData.multiplicative_target or DEFAULT_MULTIPLICATION_TARGET

		result = result + (talentData.multiplicative_base_value or  TalentsUtilities:GetDefaultBaseValue(hero, ability_level, ability_name, talentName))

		if result - target == 0 then return 0 end

		upgrade_value = math.abs(upgrade_value / (result - target))

		result = (target - result) * (1 - (1 - upgrade_value) ^ count)
	end

	return result
end
