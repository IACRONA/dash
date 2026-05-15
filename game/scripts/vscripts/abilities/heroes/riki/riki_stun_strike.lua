riki_stun_strike = class({})
LinkLuaModifier("modifier_riki_stun",            "abilities/heroes/riki/riki_stun_strike",          LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_stun_crit_buff",  "abilities/heroes/riki/riki_stun_strike",          LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_break_invis",     "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)

local PFX = "particles/units/heroes/hero_riki/"

function riki_stun_strike:GetAbilityTextureName()
    return "riki/riki_stun_strike"
end

function riki_stun_strike:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not caster or not target then return end
    if target:TriggerSpellAbsorb(self) then return end

    -- Анимация атаки (вид удара с руки)
    caster:StartGesture(ACT_DOTA_ATTACK)

    EmitSoundOn("Riki.StunStrike.Cast", caster)

    -- Принудительно ломаем инвиз на 1.5с
    caster:AddNewModifier(caster, self, "modifier_riki_break_invis", { duration = 1.5 })

    -- Бафф крит-урона на 1 удар (срабатывает в OnAttackLanded)
    caster:AddNewModifier(caster, self, "modifier_riki_stun_crit_buff", { duration = 5 })

    -- Микро-атака с руки (1 удар, доп.урон от баффа)
    caster:PerformAttack(target, true, true, true, false, false, false, true)

    -- Партикл броска кинжала с руки
    local cast_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_dagger_group.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(cast_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(cast_pfx)

    -- Снаряд — летящий кинжал
    ProjectileManager:CreateTrackingProjectile({
        Target            = target,
        Source            = caster,
        Ability           = self,
        EffectName        = PFX .. "riki_tricks_dagger_plain.vpcf",
        iMoveSpeed        = 1400,
        bDodgeable        = true,
        bVisibleToEnemies = true,
        bProvidesVision   = false,
    })
end

function riki_stun_strike:OnProjectileHit(target, location)
    if not target or not IsValidEntity(target) or not target:IsAlive() then return false end

    local caster        = self:GetCaster()
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    local actual_duration = stun_duration * (1 - target:GetStatusResistance())
    target:AddNewModifier(caster, self, "modifier_riki_stun", { duration = actual_duration })

    -- Партикл попадания кинжала
    local hit_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_dagger_hit.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(hit_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(hit_pfx)

    -- Искры от попадания
    local spark_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_dagger_hit_sparks.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(spark_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(spark_pfx)

    return true
end

--------------------------------------------------------------------------------

modifier_riki_stun = class({})

function modifier_riki_stun:IsHidden() return false end
function modifier_riki_stun:IsPurgable() return true end
function modifier_riki_stun:IsDebuff() return true end
function modifier_riki_stun:GetTexture() return "riki/riki_stun_strike" end

function modifier_riki_stun:OnCreated()
    self:GetParent():StartGesture(ACT_DOTA_DISABLED)
end

function modifier_riki_stun:OnDestroy()
    self:GetParent():FadeGesture(ACT_DOTA_DISABLED)
end

function modifier_riki_stun:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_riki_stun:DeclareFunctions() return {} end

--------------------------------------------------------------------------------
-- Бафф крит-урона на 1 удар после каста
--------------------------------------------------------------------------------

modifier_riki_stun_crit_buff = class({})

function modifier_riki_stun_crit_buff:IsHidden() return true end
function modifier_riki_stun_crit_buff:IsPurgable() return false end
function modifier_riki_stun_crit_buff:RemoveOnDeath() return true end

function modifier_riki_stun_crit_buff:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_riki_stun_crit_buff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local ability = self:GetAbility()
    if not ability then self:Destroy() return end
    local pct = ability:GetSpecialValueFor("bonus_attack_damage_pct")
    if pct and pct > 0 then
        local attack_dmg = self:GetParent():GetAverageTrueAttackDamage(params.target)
        local bonus = attack_dmg * pct / 100
        ApplyDamage({
            victim      = params.target,
            attacker    = self:GetParent(),
            damage      = bonus,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability     = ability,
        })
    end
    self:Destroy()
end

return riki_stun_strike
