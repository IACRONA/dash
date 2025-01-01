LinkLuaModifier("modifier_cursed_knight_cursed_blast", "abilities/heroes/cursed_knight/cursed_knight_cursed_blast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_knight_cursed_blast_slow", "abilities/heroes/cursed_knight/cursed_knight_cursed_blast", LUA_MODIFIER_MOTION_NONE)
cursed_knight_cursed_blast = class({})

function cursed_knight_cursed_blast:GetIntrinsicModifierName()
    return "modifier_cursed_knight_cursed_blast"
end

modifier_cursed_knight_cursed_blast = class({})

function modifier_cursed_knight_cursed_blast:IsHidden()
    return true
end

function modifier_cursed_knight_cursed_blast:IsPurgable()
    return false
end

function modifier_cursed_knight_cursed_blast:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_cursed_knight_cursed_blast:OnAttackLanded(params)
    if not IsServer() then return end
    -- if true then return end
    local parent = self:GetParent()
    if params.attacker ~= parent then return end

    local ability = self:GetAbility()
    if not ability or not ability:IsTrained() then return end
    if not ability:IsCooldownReady() then return end
    local chance = ability:GetSpecialValueFor("chance_blast")
    if RandomInt(1, 100) >= chance then return end

    local radius = ability:GetSpecialValueFor("radius")
    local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
    local stun_duration = ability:GetSpecialValueFor("blast_stun_duration")
    local projectile_speed = ability:GetSpecialValueFor("blast_speed")
    local projectile_name = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf"

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    if #enemies == 0 then return end

    local target = enemies[1]
    for _, enemy in pairs(enemies) do
        if enemy:IsAttacking() then
            target = enemy
            break
        end
    end

    local info = {
        EffectName = projectile_name,
        Ability = ability,
        iMoveSpeed = projectile_speed,
        Source = parent,
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile(info)
    ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
end

function cursed_knight_cursed_blast:OnProjectileHit(hTarget, vLocation)

    if not hTarget or hTarget:IsInvulnerable() or hTarget:IsMagicImmune() or hTarget:TriggerSpellAbsorb(self) then
        return false
    end

    local ability = self
    local caster = self:GetCaster()
    local stun_duration = ability:GetSpecialValueFor("blast_stun_duration")
    local damage = ability:GetSpecialValueFor("damage")
    local slow_duration = ability:GetSpecialValueFor("blast_dot_duration")

    -- Apply damage
    ApplyDamage({
        victim = hTarget,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
    })


    -- Apply slow
    hTarget:AddNewModifier(caster, ability, "modifier_cursed_knight_cursed_blast_slow", { duration = slow_duration })

    hTarget:EmitSound("Hero_SkeletonKing.Hellfire_Blast")
    caster:Heal(damage, ability)
    -- print("!Q@#!@#!@")
    return true
end

modifier_cursed_knight_cursed_blast_slow = class({})

function modifier_cursed_knight_cursed_blast_slow:IsHidden()
    return false
end

function modifier_cursed_knight_cursed_blast_slow:IsDebuff()
    return true
end

function modifier_cursed_knight_cursed_blast_slow:IsPurgable()
    return true
end

function modifier_cursed_knight_cursed_blast_slow:OnCreated(kv)
    if not IsServer() then return end

    self.slow = self:GetAbility():GetSpecialValueFor("blast_slow")
end

function modifier_cursed_knight_cursed_blast_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_cursed_knight_cursed_blast_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end