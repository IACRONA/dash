function Spawn(entityKeyValues)
    if not IsServer() then return end
    if thisEntity == nil then return end

    local agroRadius = 800  
    thisEntity.agroRadius = agroRadius

    thisEntity:SetContextThink("BossThink", BossThink, 1)
end

function BossThink()
    if not IsServer() then return end
    if GameRules:IsGamePaused() or GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME or not thisEntity:IsAlive() or not thisEntity.respoint then
        return 1
    end

    local selfEntity = thisEntity
    local origin = selfEntity:GetAbsOrigin()
    local distanceFromHome = (origin - selfEntity.respoint):Length2D()
    local agroRadius = selfEntity.agroRadius

    local agroTarget = selfEntity:GetAggroTarget()
    
    if agroTarget and (origin - agroTarget:GetAbsOrigin()):Length2D() >= 2000 then
        agroTarget = nil
        selfEntity.current_target = nil
    end

    if not agroTarget then
        local findTargets = FindUnitsInRadius(
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

        for _, unit in pairs(findTargets) do
            if unit and not unit:IsNull() and unit:IsAlive() then
                agroTarget = unit
                selfEntity.current_target = unit
                break
            end
        end
    end

    if selfEntity.current_target and (selfEntity.current_target:IsNull() or not selfEntity.current_target:IsAlive()) then
        agroTarget = nil
        selfEntity.current_target = nil
    end

    local currentPortal = nil

    if not agroTarget or not GridNav:CanFindPath(origin, agroTarget:GetAbsOrigin()) then
        local portals = GameRules.AddonTemplate.aPortals
        currentPortal = portals[1]
        if currentPortal and selfEntity.portal_cooldown[currentPortal.index] and selfEntity.portal_cooldown_full[currentPortal.index] then
            currentPortal = portals[2]
        end

        local bestDistance = (currentPortal.vPos - origin):Length2D()
        for _, tPortal in ipairs(portals) do
            if tPortal.nTeam == 0 and tPortal ~= currentPortal then
                local candidateDistance = (tPortal.vPos - origin):Length2D()
                if candidateDistance < bestDistance and not selfEntity.portal_cooldown[tPortal.index] and not selfEntity.portal_cooldown_full[tPortal.index] then
                    currentPortal = tPortal
                    bestDistance = candidateDistance
                end
            end
        end

        if currentPortal and currentPortal.nTeam ~= 0 then
            currentPortal = nil
        end
    end

    if not currentPortal and not agroTarget then
        selfEntity.portal_cooldown_full = {}
    end

    if currentPortal then
        selfEntity:MoveToPosition(currentPortal.vPos)
        if currentPortal:IsTouching(origin) then
            local next_portal = currentPortal.tNext
            selfEntity.portal_cooldown_full[currentPortal.index] = true
            selfEntity.portal_cooldown[next_portal.index] = true

            Timers:CreateTimer(5, function()
                selfEntity.portal_cooldown[next_portal.index] = nil
            end)

            local nParticle1 = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(nParticle1, 0, origin)
            EmitSoundOnLocationWithCaster(origin, "Hero_AbyssalUnderlord.DarkRift.Cancel", selfEntity)

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
    elseif agroTarget then
        if not selfEntity:HasModifier("modifier_boss_delay_anim") then
            selfEntity:MoveToTargetToAttack(agroTarget)
        end
    end

    return FrameTime()
end

function RetreatHome()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = thisEntity.respoint
    })
end
