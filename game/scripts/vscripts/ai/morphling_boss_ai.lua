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
    if not IsServer() then return end
    if not thisEntity:IsAlive() then return end
    if GameRules:IsGamePaused() then return 0.1 end
    if thisEntity:IsChanneling() then return 0.1 end

    if not thisEntity:HasModifier("modifier_custom_morph_boss_ai") then
        thisEntity:AddNewModifier(thisEntity, nil, "modifier_custom_morph_boss_ai", {})
    end

    if thisEntity:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
        return
    end

    local selfEntity = thisEntity
    local current_target = nil
    local current_portal = nil
    local origin = selfEntity:GetAbsOrigin()

    if selfEntity.current_target and not selfEntity.current_target:IsNull() and selfEntity.current_target:IsAlive() then
        local targetCandidate = selfEntity.current_target
        local dist = (origin - targetCandidate:GetAbsOrigin()):Length2D()
        if dist < 2000 then
            current_target = targetCandidate
        else
            selfEntity.current_target = nil
        end
    end

    if not current_target then
        local find_targets = FindUnitsInRadius(
            selfEntity:GetTeamNumber(),
            origin,
            nil,
            2000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            bit.bor(DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD),
            FIND_CLOSEST,
            false
        )
        for _, unit in pairs(find_targets) do
            if unit and not unit:IsNull() and unit:IsAlive() then
                current_target = unit
                selfEntity.current_target = unit
                break
            end
        end
    end

    if selfEntity.current_target and (selfEntity.current_target:IsNull() or not selfEntity.current_target:IsAlive()) then
        current_target = nil
        selfEntity.current_target = nil
    end

    if not current_target or not GridNav:CanFindPath(origin, current_target:GetAbsOrigin()) then
        local portals = GameRules.AddonTemplate.aPortals
        current_portal = portals[1]
        if current_portal and selfEntity.portal_cooldown[current_portal.index] and selfEntity.portal_cooldown_full[current_portal.index] then
            current_portal = portals[2]
        end

        local best_distance = (current_portal.vPos - origin):Length2D()
        for _, tPortal in ipairs(portals) do
            if tPortal.nTeam == 0 and tPortal ~= current_portal then
                local candidate_distance = (tPortal.vPos - origin):Length2D()
                if candidate_distance < best_distance and not selfEntity.portal_cooldown[tPortal.index] and not selfEntity.portal_cooldown_full[tPortal.index] then
                    current_portal = tPortal
                    best_distance = candidate_distance
                end
            end
        end

        if current_portal and current_portal.nTeam ~= 0 then
            current_portal = nil
        end
    end

    if not current_portal and not current_target then
        selfEntity.portal_cooldown_full = {}
    end

    if current_portal then
        selfEntity:MoveToPosition(current_portal.vPos)
        if current_portal:IsTouching(selfEntity:GetAbsOrigin()) then
            local next_portal = current_portal.tNext
            selfEntity.portal_cooldown_full[current_portal.index] = true
            selfEntity.portal_cooldown[next_portal.index] = true
            Timers:CreateTimer(5, function()
                selfEntity.portal_cooldown[next_portal.index] = nil
            end)
            local nParticle1 = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(nParticle1, 0, selfEntity:GetAbsOrigin())
            EmitSoundOnLocationWithCaster(selfEntity:GetAbsOrigin(), "Hero_AbyssalUnderlord.DarkRift.Cancel", selfEntity)
            
            FindClearSpaceForUnit(selfEntity, next_portal.vPos, true)
            
            local nParticle2 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(nParticle2, 0, selfEntity:GetAbsOrigin())
            EmitSoundOnLocationWithCaster(selfEntity:GetAbsOrigin(), "Hero_Underlord.Portal.Out", selfEntity)
            
            selfEntity:SetThink(function()
                ParticleManager:DestroyParticle(nParticle1, false)
                ParticleManager:DestroyParticle(nParticle2, false)
                ParticleManager:ReleaseParticleIndex(nParticle1)
                ParticleManager:ReleaseParticleIndex(nParticle2)
            end, 0.6)
        end
    end

    if current_target then
        if not selfEntity:HasModifier("modifier_boss_delay_anim") then
            selfEntity:MoveToTargetToAttack(current_target)
        end
    end

    return FrameTime()
end
