return function(t, hAddon)
	local hMainUnit = EntIndexToHScript(t.units['0'] or -1)
	if not hMainUnit then return true end

	-- Правый клик ПО ловушке Lethal Surge → влёт в неё
	if t.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		local hTarget = EntIndexToHScript(t.entindex_target or -1)
		if hTarget and hTarget.ta_surge_ability and not hTarget.ta_surge_ability:IsNull() then
			local abil = hTarget.ta_surge_ability
			if abil:GetCaster() == hMainUnit and abil:TrySurgeOrder(hTarget) then
				return false
			end
		end
	end

	-- Правый клик ПО ЗЕМЛЕ рядом с ловушкой (промах мимо юнита) → тоже влёт
	if t.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION and hMainUnit.ta_surge_ability then
		local abil = hMainUnit.ta_surge_ability
		if not abil:IsNull() and abil:GetCaster() == hMainUnit then
			local vTarget = Vector(t.position_x, t.position_y, t.position_z)
			if abil:TrySurgeAtPoint(vTarget) then
				return false
			end
		end
	end

	if t.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		local vTarget = Vector(t.position_x, t.position_y, t.position_z)
		if hMainUnit then
			local tPortal = hAddon:GetPortalAt(vTarget)
			if tPortal then
				if tPortal:CanPass(hMainUnit) then
					local bQueue = t.queue ~= 0
					local nRadius = math.max(16, tPortal.nRadius - 32)
					for _, nUnit in pairs(t.units) do
						local hUnit = EntIndexToHScript(nUnit)
						if hUnit then
							Use(hUnit, tPortal.vPos, nRadius, bQueue, function()
								tPortal:Teleport(hUnit)
							end)
						end
					end
					return true
				else
					local player = PlayerResource:GetPlayer(hMainUnit:GetPlayerOwnerID())
					if player then
						if HasFlag(hMainUnit) then
							CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_cant_portal_with_flag"})
						end
						if tPortal:IsEnemyPortal(hMainUnit) then
							CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_cant_portal_enemy"})
						end
					end
				end
			end
		end
	end

	if t.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local hTarget = EntIndexToHScript(t.entindex_target or - 1)
		if hTarget then
			local hItem = hTarget:GetContainedItem()
			if hItem and hItem.nStashTeam and hItem.nStashTeam ~= hMainUnit:GetTeam() then
				local v = hTarget:GetOrigin()
				t.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				t.position_x = v.x
				t.position_y = v.y
				t.position_z = v.z
				return true
			end
		end
	end

	if t.order_type == DOTA_UNIT_ORDER_DROP_ITEM_AT_FOUNTAIN or t.order_type == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
	or (t.order_type == DOTA_UNIT_ORDER_DROP_ITEM and t.queue == 0 and hMainUnit:HasModifier('modifier_fountain_aura_buff')) then
		local hItem = EntIndexToHScript(t.entindex_ability or -1)
		if hItem and hItem.nStashTeam then
			local hParent = hItem:GetParent()
			if hParent then
				hParent:TakeItem(hItem)
				CreateItemOnPositionSync(GetStashPos(hItem.nStashTeam, hItem.nStashTier, hItem.nStashIndex), hItem)
				return false
			end
		end
	end
	if t.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET  then
		if GetMapName() == "dash" then
			local target = EntIndexToHScript(t.entindex_target)
			local player = PlayerResource:GetPlayer(hMainUnit:GetPlayerOwnerID())
			 if target and target.IsBuilding and target:IsBuilding() and target:HasModifier("modifier_for_middle_towers_for_unvulbure")   then  
				CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_topa_and_bota_towers_are_live"})
				return false
			end
		end
	end 
	return true
end