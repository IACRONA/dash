--------------------------------------------------------------------------------
-- Riki Stun Strike
-- Способность стана для скрытого бара способностей
--------------------------------------------------------------------------------

riki_stun_strike = class({})

--------------------------------------------------------------------------------
-- При успешном применении способности
--------------------------------------------------------------------------------
function riki_stun_strike:OnSpellStart()
    -- Получаем кастера и цель
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    -- Базовая проверка
    if not caster or not target then return end
    
    -- Если цель блокировала способность Linken's Sphere
    if target:TriggerSpellAbsorb(self) then
        return
    end
    
    -- Получаем значения из способности
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    
    -- Создаём снаряд
    local projectile_info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
        iMoveSpeed = 1200,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
    }
    
    ProjectileManager:CreateTrackingProjectile(projectile_info)
    
    -- Звук броска
    EmitSoundOn("Hero_BountyHunter.Shuriken", caster)
end

--------------------------------------------------------------------------------
-- При попадании снаряда
--------------------------------------------------------------------------------
function riki_stun_strike:OnProjectileHit(target, location)
    if not target then return end
    
    -- Проверяем, что цель валидна и жива
    if not IsValidEntity(target) or not target:IsAlive() then
        return false
    end
    
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    
    -- Наносим урон
    local damage_table = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
    
    ApplyDamage(damage_table)
    
    -- Применяем стан с учётом сопротивления эффектам
    local actual_duration = stun_duration * (1 - target:GetStatusResistance())
    
    -- Отладочный вывод
    print("[RIKI STUN] Applying stun:")
    print("  - Target:", target:GetUnitName())
    print("  - Base Duration:", stun_duration)
    print("  - Actual Duration:", actual_duration)
    print("  - Damage:", damage)
    
    target:AddNewModifier(
        caster,
        self,
        "modifier_stunned",
        { duration = actual_duration }
    )
    
    -- Звук попадания
    EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", target)
    
    -- Эффект попадания
    local particle = ParticleManager:CreateParticle(
        "particles/generic_gameplay/generic_stunned.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        target
    )
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    
    return true
end

return riki_stun_strike
