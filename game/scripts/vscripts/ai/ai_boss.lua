function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end
 
 	agroRadius = 800
 	
 	thisEntity:SetContextThink( "BossThink", BossThink, 1 )
end

function BossThink()
	if GameRules:IsGamePaused() == true or GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME or thisEntity:IsAlive() == false or not thisEntity.respoint then
		return 1
	end
	 
  	local agroTarget = thisEntity:GetAggroTarget()
 	local position = thisEntity:GetOrigin()
	
	local distance = ( position - thisEntity.respoint ):Length2D()
 
 	if agroTarget then 
		if distance > agroRadius then
			RetreatHome()			 
			return 3
		end
		for i=0,3 do
			local ability = thisEntity:GetAbilityByIndex(i)
			if not ability:IsPassive() and ability:IsFullyCastable() then 
					local abilityBehavior = ability:GetBehavior()
					local executeTable = {
						UnitIndex = thisEntity:entindex(),	 
						AbilityIndex = ability:entindex(), 
					}
					if bit.band( abilityBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
						executeTable.OrderType = DOTA_UNIT_ORDER_CAST_TARGET
						executeTable.TargetIndex = agroTarget:entindex()
					elseif bit.band( abilityBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
						executeTable.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
					elseif bit.band( abilityBehavior, DOTA_ABILITY_BEHAVIOR_POINT ) == DOTA_ABILITY_BEHAVIOR_POINT then
						executeTable.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
						executeTable.Position = agroTarget:GetOrigin()
					end
					if executeTable.OrderType then 
						ExecuteOrderFromTable(executeTable)
					    break 
					end
			end
		end
	else 
		local enemies = FindUnitsInRadius( 
			thisEntity:GetTeamNumber(),		--команда юнита
			thisEntity:GetAbsOrigin(),		--местоположение юнита
			nil,	--айди юнита (необязательно)
			agroRadius,	--радиус поиска
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- юнитов чьей команды ищем вражеской/дружественной
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	--юнитов какого типа ищем 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	--поиск по флагам
			FIND_CLOSEST,	--сортировка от ближнего к дальнему 
		false ) 
		if #enemies == 0 then
 			if distance > 50 then RetreatHome() end		
 		else 
 			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = enemies[1]		
			})
 		end
  	end

	return 0.25	
end
 

function RetreatHome()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity.respoint		
	})
end
 
 