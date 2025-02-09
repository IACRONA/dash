LinkLuaModifier("modifier_kuyudzaki_dash", "abilities/heroes/juggernaut/kuyudzaki_slash", LUA_MODIFIER_MOTION_NONE)
kuyudzaki_slash = class({})

function kuyudzaki_slash:OnSpellStart()
    local caster = self:GetCaster()
    local target_position = self:GetCursorPosition()
    local ability = self
    
    local crit_chance = self:GetSpecialValueFor("crit_chance")
    local crit_multiplier = self:GetSpecialValueFor("crit_multiplier") / 100

    -- Вычисляем реальную дистанцию до точки
    local direction = (target_position - caster:GetAbsOrigin()):Normalized()
    local distance_to_target = (target_position - caster:GetAbsOrigin()):Length2D()
    local max_dash_distance = self:GetCastRange(target_position, nil)
    local dash_distance = math.min(distance_to_target, max_dash_distance)
    local dash_duration = 0.2
    
    caster:AddNewModifier(caster, ability, "modifier_kuyudzaki_dash", {
        duration = dash_duration, 
        distance = dash_distance, 
        direction_x = direction.x, 
        direction_y = direction.y
    })

    -- Поиск ближайшего врага в радиусе атаки
    Timers:CreateTimer(dash_duration, function()
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            250,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_CLOSEST,
            false
        )

        if #enemies > 0 then
            local enemy = enemies[1]
            if RollPseudoRandomPercentage(crit_chance, 1, caster) then
                local damage = caster:GetAttackDamage() * crit_multiplier
                ApplyDamage({
                    victim = enemy,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = ability
                })
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, enemy, damage, nil)
            else
                caster:PerformAttack(enemy, true, true, true, false, true, false, false)
            end
        end
    end)
end

-- Модификатор для плавного перемещения
modifier_kuyudzaki_dash = class({})
function modifier_kuyudzaki_dash:IsHidden() return true end
function modifier_kuyudzaki_dash:OnCreated(kv)
    if not IsServer() then return end
    
    self.direction = Vector(kv.direction_x, kv.direction_y, 0)
    self.distance = kv.distance
    self.duration = self:GetDuration()
    self.elapsed_time = 0
    self.start_position = self:GetParent():GetAbsOrigin()
    self.end_position = self.start_position + self.direction * self.distance
    
    -- Добавляем дополнительный эффект движения
    local particle_dash = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf",
        PATTACH_CUSTOMORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControl(particle_dash, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle_dash, false, false, -1, false, false)
    
    -- Добавляем звук рывка
    EmitSoundOn("Hero_Juggernaut.OmniSlash", self:GetParent())
    
    self:StartIntervalThink(FrameTime())
end

function modifier_kuyudzaki_dash:OnIntervalThink()
    if not IsServer() then return end
    
    local parent = self:GetParent()
    self.elapsed_time = self.elapsed_time + FrameTime()
    
    -- Используем синусоидальную интерполяцию для более плавного движения
    local progress = math.min(self.elapsed_time / self.duration, 1.0)
    local smooth_progress = (1 - math.cos(progress * math.pi)) / 2
    
    local new_position = LerpVectors(self.start_position, self.end_position, smooth_progress)
    new_position.z = GetGroundHeight(new_position, parent)
    
    parent:SetAbsOrigin(new_position)
end

function modifier_kuyudzaki_dash:CheckState()
    return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_kuyudzaki_dash:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_kuyudzaki_dash:GetActivityTranslationModifiers()
    return "haste"
end

function modifier_kuyudzaki_dash:OnDestroy()
    if not IsServer() then return end
    
    -- Эффект в конце рывка
    local particle_end = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf",
        PATTACH_CUSTOMORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(particle_end, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_end)
    
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end