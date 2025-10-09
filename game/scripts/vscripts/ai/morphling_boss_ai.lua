LinkLuaModifier("modifier_custom_morph_boss_ai", "modifiers/modifier_custom_morph_boss_ai", LUA_MODIFIER_MOTION_NONE)

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end
    thisEntity.cooldown_portal = {}
    thisEntity.current_target = nil
    thisEntity.portal_cooldown = {}
    thisEntity.portal_cooldown_full = {}
    thisEntity:SetContextThink( "Morphling_AI_think", Morphling_AI_think, 1 )
end

function Morphling_AI_think()
    if not thisEntity:IsAlive() then return end
    if GameRules:IsGamePaused() then return 0.1 end
    if thisEntity:IsChanneling() then return 0.1 end
    if not thisEntity:HasModifier("modifier_custom_morph_boss_ai") then
        thisEntity:AddNewModifier(thisEntity, nil, "modifier_custom_morph_boss_ai", {})
    end
    if thisEntity:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then return end

    local current_target = nil
    local current_portal = nil

    -- Поиск цели в радиусе
    if thisEntity.current_target and not thisEntity.current_target:IsNull() and thisEntity.current_target:IsAlive() then
        current_target = thisEntity.current_target
        local length = (thisEntity:GetAbsOrigin() - thisEntity.current_target:GetAbsOrigin()):Length2D()
        if length >= 2000 then
            current_target = nil
            thisEntity.current_target = nil
        end
    else
        local find_targets = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
        for _, find_target in pairs(find_targets) do
            if find_target and not find_target:IsNull() and find_target:IsAlive() then
                current_target = find_target
                thisEntity.current_target = find_target
                break
            end
        end
    end

    if thisEntity.current_target and (thisEntity.current_target:IsNull() or not thisEntity.current_target:IsAlive()) then
        current_target = nil
        thisEntity.current_target = nil
    end

    -- Поиск портала
    if current_target == nil or not GridNav:CanFindPath(thisEntity:GetAbsOrigin(), current_target:GetAbsOrigin()) then
        current_portal = GameRules.AddonTemplate.aPortals[1]

        if current_portal and thisEntity.portal_cooldown[current_portal.index] ~= nil and thisEntity.portal_cooldown_full[current_portal.index] ~= nil then
            current_portal = GameRules.AddonTemplate.aPortals[2]
        end

        local distance = (current_portal.vPos - thisEntity:GetAbsOrigin()):Length2D()
        for _, tPortal in ipairs(GameRules.AddonTemplate.aPortals) do
            if tPortal.nTeam == 0 and (tPortal ~= current_portal) and ( (tPortal.vPos - thisEntity:GetAbsOrigin()):Length2D() < distance ) and not thisEntity.portal_cooldown[tPortal.index] and not thisEntity.portal_cooldown_full[tPortal.index] then
                current_portal = tPortal
                distance = (current_portal.vPos - thisEntity:GetAbsOrigin()):Length2D()
            end
        end
        if current_portal.nTeam ~= 0 then current_portal = nil end
    end

    if not current_portal and not current_target then
        thisEntity.portal_cooldown_full = {}
    end

    -- Ходьба до портала
    if current_portal ~= nil then
        thisEntity:MoveToPosition(current_portal.vPos)
        if current_portal:IsTouching(thisEntity:GetAbsOrigin()) then
            local next_portal = current_portal.tNext
            thisEntity.portal_cooldown_full[current_portal.index] = true
            thisEntity.portal_cooldown[next_portal.index] = true
            Timers:CreateTimer(5, function()
                thisEntity.portal_cooldown[next_portal.index] = nil
            end)

			local nParticle1 = ParticleManager:CreateParticle('particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf', PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nParticle1, 0, thisEntity:GetOrigin())
            EmitSoundOnLocationWithCaster(thisEntity:GetOrigin(), 'Hero_AbyssalUnderlord.DarkRift.Cancel', thisEntity)

            FindClearSpaceForUnit(thisEntity, next_portal.vPos, true)

			local nParticle2 = ParticleManager:CreateParticle('particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf', PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nParticle2, 0, thisEntity:GetOrigin())
            EmitSoundOnLocationWithCaster(thisEntity:GetOrigin(), 'Hero_Underlord.Portal.Out', thisEntity)

            thisEntity:SetThink(function()
                ParticleManager:DestroyParticle(nParticle1, false)
                ParticleManager:DestroyParticle(nParticle2, false)
                ParticleManager:ReleaseParticleIndex(nParticle1)
                ParticleManager:ReleaseParticleIndex(nParticle2)
            end, 0.6)
        end
    end

    -- Атакуем цель
    if current_target ~= nil then
        if not thisEntity:HasModifier("modifier_boss_delay_anim") then
            thisEntity:MoveToTargetToAttack(current_target)
        end
    end

    -- ОПТИМИЗАЦИЯ: Увеличен интервал с FrameTime() (~0.03s) до 0.2s
    return 0.2
end