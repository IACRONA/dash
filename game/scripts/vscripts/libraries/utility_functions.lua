function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function in_array(target, table)
	if table == nil then return nil end
	
	for _,v in pairs(table) do
		if v == target then return true end
	end
	return false
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

function Use(hUnit, xTarget, nRadius, bQueue, fCallback)
	local hAbility = hUnit:FindAbilityByName('ability_use')
	if not hAbility then
		hAbility = hUnit:AddAbility('ability_use')
		if hAbility then
			hAbility:SetLevel(1)
		else
			error("ability_use doesn't exists", 2)
		end
	end

	local bPos = (type(xTarget) == 'userdata' and xTarget.x and xTarget.y and xTarget.z and true or false)
	local bTree = false
	local nTarget
	local vTarget

	if bPos then
		vTarget = xTarget
	else
		nTarget = xTarget:entindex()
		if xTarget.CutDownRegrowAfter then
			bTree = true
		end
	end

	function hAbility:OnSpellStart()
		fCallback()
	end

	function hAbility:GetCastRange(vLocation, hTarget)
		return nRadius
	end

	ExecuteOrderFromTable({
		UnitIndex = hUnit:entindex(),
		OrderType = bPos and DOTA_UNIT_ORDER_CAST_POSITION or (bTree and DOTA_UNIT_ORDER_CAST_TARGET_TREE or DOTA_UNIT_ORDER_CAST_TARGET),
		AbilityIndex = hAbility:entindex(),
		TargetIndex = nTarget,
		Position = vTarget,
		Queue = bQueue,
	})
end

function CreateMinimapIcon(sUnit, nTeam, vPos)
	local hUnit = CreateUnitByName(sUnit, vPos, false, nil, nil, nTeam)
	hUnit:AddNewModifier(hUnit, nil, 'modifier_warsong_minimap_icon', {})
	return hUnit
end

function SetIconVisibe(hUnit, bVisible)
	if hUnit then
		hUnit:FindModifierByName('modifier_warsong_minimap_icon'):SetStackCount(bVisible and 0 or 1)
	end
end

function GetOppositeTeam(nTeam)
	if nTeam == DOTA_TEAM_GOODGUYS then
		return DOTA_TEAM_BADGUYS
	else
		return DOTA_TEAM_GOODGUYS
	end
end

function GetFirstPlayerInTeam(nTeam)
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:GetSelectedHeroEntity(i) and PlayerResource:GetPlayer(i) and PlayerResource:GetTeam(i) == nTeam then
			return i
		end
	end
end

function GetStashPos(nTeam, nTier, nIndex)
	local hStashPoint = Entities:FindByName(nil, 'neutral_stash_' .. nTeam)
	if hStashPoint then
		local v = hStashPoint:GetOrigin()
		v.x = v.x + 128 * nTier
		v.y = v.y + 64 * nIndex
		return GetGroundPosition(v, nil)
	else
		return Vector(0,0,0)
	end
end

function GetFlagScale(nTeam)
	if nTeam == DOTA_TEAM_GOODGUYS then
		return GOOD_FLAG_SCALE
	else
		return BAD_FLAG_SCALE
	end
end

function GetMaterial(hFlagItem)
	local s = hFlagItem:GetAbilityKeyValues().Material
	if s then
		return tostring(s)
	end
end

function SetMaterial(hProp, hFlagItem)
	local s = GetMaterial(hFlagItem)
	if s then
		hProp:SetMaterialGroup(tostring(s))
	end
end

function CreateHints(text, player_id)
    if player_id then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id), "warsong_game_hint_create", {text = text})
        return
    end
    CustomGameEventManager:Send_ServerToAllClients("warsong_game_hint_create", {text = text})
end

function DoWithAllPlayers(func)
	for i=0, PlayerResource:GetPlayerCount() - 1 do 
	  local player = PlayerResource:GetPlayer(i)
	  local hero = PlayerResource:GetSelectedHeroEntity(i) 
	  if  PlayerResource:IsValidPlayer(i) then func(player, hero, i) end
	end 
  end

function EmitSoundClient(sound, player)
	CustomGameEventManager:Send_ServerToPlayer(player, "sound_on_client", {sound = sound})
end
function ipairs_rev(tbl)
    local i = #tbl + 1
    return function()
        i = i - 1
        if i > 0 then
            return i, tbl[i]
        end
    end
end
function GetRandomPathablePositionWithin(vPos, nRadius, nMinRadius )
    if IsServer() then
        local nMaxAttempts = 10
        local nAttempts = 0
        local vTryPos

        if nMinRadius == nil then
            nMinRadius = nRadius
        end

        repeat
            vTryPos = vPos + RandomVector( RandomFloat( nMinRadius, nRadius ) )

            nAttempts = nAttempts + 1
            if nAttempts >= nMaxAttempts then
                break
            end
        until ( GridNav:CanFindPath( vPos, vTryPos ) )

        return vTryPos
    end
end

