local function StartSoldierRespawnTimer(fnSpawn, nTeam)
	if GetMapName() ~= "dash" then return end
	Timers:CreateTimer(SOLDIER_RESPAWN_DELAY, function()
		local addon = GameRules.AddonTemplate
		local hSoldier = addon.soldiers_units[nTeam]
		if hSoldier and not hSoldier:IsNull() and hSoldier:IsAlive() then
			return
		end
		fnSpawn(addon)
	end)
end

-- Cпавн защитников
function CAddonWarsong:SpawnSoldierRadiant()
	local radiant_spawn = Entities:FindByName(nil, 'flag_radiant')
	if radiant_spawn == nil then return end

	if self.soldiers_units[DOTA_TEAM_GOODGUYS] and self.soldiers_units[DOTA_TEAM_GOODGUYS] ~= nil then
		if not self.soldiers_units[DOTA_TEAM_GOODGUYS]:IsNull() and self.soldiers_units[DOTA_TEAM_GOODGUYS]:IsAlive() then
			self.soldiers_units[DOTA_TEAM_GOODGUYS]:ForceKill(false)
		end
	end

    local vSpawnPos = radiant_spawn:GetAbsOrigin() + RandomVector( 200 )
    local hSoldier = CreateUnitByName( "npc_dota_radiant_bucket_soldier", vSpawnPos, true, nil, nil, DOTA_TEAM_GOODGUYS )
    if hSoldier then
        hSoldier:AddNewModifier(hSoldier, nil, "modifier_warsong_soldier_upgrade", {dmg_upgrade = UPGRADE_DAMAGE, hp_upgrade = UPGRADE_HEALTH, armor_upgrade = UPGRADE_ARMOR, time = UPGRADE_TIME_CHECK})
        self.soldiers_units[DOTA_TEAM_GOODGUYS] = hSoldier
        Timers:CreateTimer(FrameTime(), function()
            if hSoldier and not hSoldier:IsNull() and hSoldier.AI ~= nil then
                hSoldier.AI.hBucket = radiant_spawn
            end
        end)
    end
    StartSoldierRespawnTimer(CAddonWarsong.SpawnSoldierRadiant, DOTA_TEAM_GOODGUYS)
end

function CAddonWarsong:SpawnSoldierDire()
	local dire_spawn = Entities:FindByName(nil, 'flag_dire')
	if dire_spawn == nil then return end

	if self.soldiers_units[DOTA_TEAM_BADGUYS] and self.soldiers_units[DOTA_TEAM_BADGUYS] ~= nil then
		if not self.soldiers_units[DOTA_TEAM_BADGUYS]:IsNull() and self.soldiers_units[DOTA_TEAM_BADGUYS]:IsAlive() then
			self.soldiers_units[DOTA_TEAM_BADGUYS]:ForceKill(false)
		end
	end

    local vSpawnPos = dire_spawn:GetAbsOrigin() + RandomVector( 200 )
    local hSoldier = CreateUnitByName( "npc_dota_dire_bucket_soldier", vSpawnPos, true, nil, nil, DOTA_TEAM_BADGUYS )
    if hSoldier then
        hSoldier:AddNewModifier(hSoldier, nil, "modifier_warsong_soldier_upgrade", {dmg_upgrade = UPGRADE_DAMAGE, hp_upgrade = UPGRADE_HEALTH, armor_upgrade = UPGRADE_ARMOR, time = UPGRADE_TIME_CHECK})
        self.soldiers_units[DOTA_TEAM_BADGUYS] = hSoldier
        Timers:CreateTimer(FrameTime(), function()
            if hSoldier and not hSoldier:IsNull() and hSoldier.AI ~= nil then
                hSoldier.AI.hBucket = dire_spawn
            end
        end)
    end
    StartSoldierRespawnTimer(CAddonWarsong.SpawnSoldierDire, DOTA_TEAM_BADGUYS)
end

function CAddonWarsong:SpawnMorphling()
    EmitGlobalSound("titan_fight")
    local morphling = CreateUnitByName("npc_custom_boss_morphling", Vector(1032.94,59.1523,171.338), true, nil, nil, DOTA_TEAM_NEUTRALS)
    if morphling then
        if SPAWN_MORPHLING_STUN_DELAY ~= 0 then
            morphling:AddNewModifier(morphling, nil, "modifier_morphling_boss_delay_spawn", {duration = SPAWN_MORPHLING_STUN_DELAY})
        end
        if SPAWN_MORPHLING_STUN_DELAY_HERO ~= 0 then
            CreateModifierThinker(morphling, nil, "modifier_morphling_boss_thinker_spawn", {duration = SPAWN_MORPHLING_STUN_DELAY_HERO}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
        end

        CustomGameEventManager:Send_ServerToAllClients('start_morphling_notification', {})

        for team, _ in pairs(self.nCapturedFlagsCount) do
            GameRules:ExecuteTeamPing( team, 1032.94, 59.1523, morphling, 0 )
        end

        Timers:CreateTimer(FrameTime(), function()
            morphling:SetBaseMaxHealth(BASE_MORPH_MAX_HEALTH)
            morphling:SetMaxHealth(BASE_MORPH_MAX_HEALTH)
            morphling:SetHealth(BASE_MORPH_MAX_HEALTH)
            morphling:SetMaxMana(BASE_MORPH_MAX_MANA)
            morphling:SetMana(BASE_MORPH_MAX_MANA)
            morphling:SetBaseDamageMin(BASE_MORPH_MIN_DAMAGE)
            morphling:SetBaseDamageMax(BASE_MORPH_MAX_DAMAGE)
            morphling:SetBaseMagicalResistanceValue(BASE_MORPH_MAGICAL_RESISTANCE)
            morphling:SetPhysicalArmorBaseValue(BASE_MORPH_PHYSICAL_ARMOR)
            morphling:SetBaseMoveSpeed(BASE_MORPH_MOVESPEED)
        end)
        
        Timers:CreateTimer(SPAWN_MORPHLING_STUN_DELAY, function()
            local modifier_kill = morphling:AddNewModifier(morphling, nil, "modifier_kill", {duration = MORPHLING_LIFE_TIME})
            CustomGameEventManager:Send_ServerToAllClients('start_morphling_timer', {time = modifier_kill:GetRemainingTime()})
            -- ОПТИМИЗАЦИЯ: Увеличен интервал с FrameTime() до 0.1s
            Timers:CreateTimer(0.1, function()
                if modifier_kill and not modifier_kill:IsNull() then
                    CustomGameEventManager:Send_ServerToAllClients('tick_morphling_timer', {time = modifier_kill:GetRemainingTime()})
                    return 0.1
                end
                if morphling and morphling.die == nil then
                    if MORPH_OUT_TIME_STUN ~= 0 then
                        CreateModifierThinker(GameRules:GetGameModeEntity(), nil, "modifier_morphling_boss_thinker_spawn", {duration = MORPH_OUT_TIME_STUN}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
                    end
                    CustomGameEventManager:Send_ServerToAllClients('out_morphling_notification', {})
                else
                    StopGlobalSound("titan_fight")
                end
                CustomGameEventManager:Send_ServerToAllClients('end_morphling_timer', {})
                return
            end)
        end)
    end
end