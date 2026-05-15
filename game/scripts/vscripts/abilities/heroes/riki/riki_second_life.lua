riki_second_life = class({})
LinkLuaModifier("modifier_riki_second_life",            "abilities/heroes/riki/riki_second_life",   LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_second_life_passive",    "abilities/heroes/riki/riki_second_life",   LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_second_life_invuln",     "abilities/heroes/riki/riki_second_life",   LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_stealth_cast",           "abilities/heroes/riki/riki_sleeping_dart", LUA_MODIFIER_MOTION_NONE)

local PFX = "particles/units/heroes/hero_riki/"
local SAVE_PFX = "particles/units/heroes/hero_skeletonking/wraith_king_curse_overhead_skull.vpcf"

function riki_second_life:GetAbilityTextureName()
    return "riki/riki_second_life"
end

function riki_second_life:GetIntrinsicModifierName()
    return "modifier_riki_second_life_passive"
end

function riki_second_life:OnSpellStart()
    local caster   = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    EmitSoundOn("Riki.SecondLife.Cast", caster)

    -- Инвиз не мигает
    caster:AddNewModifier(caster, self, "modifier_riki_stealth_cast", { duration = 0.5 })

    -- Очищаем все дебаффы
    caster:Purge(false, true, false, true, true)

    caster:AddNewModifier(caster, self, "modifier_riki_second_life", { duration = duration })

    -- Вспышка исчезновения
    local start_pfx = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(start_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(start_pfx)

    local smoke_pfx = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_start_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(smoke_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(smoke_pfx)

    local spark_pfx = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_start_sparkles.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(spark_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(spark_pfx)
end

--------------------------------------------------------------------------------
-- Активный бафф плаща
--------------------------------------------------------------------------------

modifier_riki_second_life = class({})

function modifier_riki_second_life:IsHidden() return false end
function modifier_riki_second_life:IsPurgable() return false end
function modifier_riki_second_life:IsDebuff() return false end
function modifier_riki_second_life:GetTexture() return "riki/riki_second_life" end

function modifier_riki_second_life:OnCreated()
    local parent = self:GetParent()
    self.aura_pfx  = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_slow.vpcf",            PATTACH_ABSORIGIN_FOLLOW, parent)
    self.glow_pfx  = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_slow_inner_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    self.smoke_pfx = ParticleManager:CreateParticle(PFX .. "riki_blink_strike_slow_smoke.vpcf",      PATTACH_ABSORIGIN_FOLLOW, parent)
end

function modifier_riki_second_life:OnDestroy()
    for _, k in ipairs({"aura_pfx", "glow_pfx", "smoke_pfx"}) do
        if self[k] then
            ParticleManager:DestroyParticle(self[k], true)
            ParticleManager:ReleaseParticleIndex(self[k])
            self[k] = nil
        end
    end
end

function modifier_riki_second_life:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_AVOID_DAMAGE,
    }
end

function modifier_riki_second_life:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist_bonus")
end

function modifier_riki_second_life:GetModifierAvoidDamage(params)
    local miss = self:GetAbility():GetSpecialValueFor("miss_chance")
    if RandomInt(1, 100) <= miss then return 1 end
    return 0
end

--------------------------------------------------------------------------------
-- Пассивный спас от смерти (активен только если взят талант)
--------------------------------------------------------------------------------

modifier_riki_second_life_passive = class({})

function modifier_riki_second_life_passive:IsHidden()
    -- Видим только когда талант взят и пассивка реально активна
    return not self:HasTalent()
end
function modifier_riki_second_life_passive:IsPurgable() return false end
function modifier_riki_second_life_passive:RemoveOnDeath() return false end
function modifier_riki_second_life_passive:GetTexture() return "riki/riki_second_life" end

function modifier_riki_second_life_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_DEATH_PREVENTED,
    }
end

function modifier_riki_second_life_passive:HasTalent()
    local hero = self:GetParent()
    local t = hero:FindAbilityByName("special_bonus_unique_riki_second_life_unlock")
    return t and t:GetLevel() >= 1
end

function modifier_riki_second_life_passive:GetMinHealth()
    if not self:HasTalent() then return 0 end
    if self.save_cd_until and GameRules:GetGameTime() < self.save_cd_until then return 0 end
    self.bDeathPrevented = true
    return 1
end

function modifier_riki_second_life_passive:OnDeathPrevented(params)
    if params.unit ~= self:GetParent() then return end
    if not self.bDeathPrevented then return end
    self.bDeathPrevented = false

    local ability = self:GetAbility()
    local cd = ability:GetSpecialValueFor("passive_save_cooldown")
    self.save_cd_until = GameRules:GetGameTime() + cd

    -- Подбрасываем хп до 50
    self:GetParent():SetHealth(50)

    EmitSoundOn("Riki.SecondLife.Save", self:GetParent())
    self:GetParent():Purge(false, true, false, true, true)
    local invuln_mod = self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_riki_second_life_invuln", { duration = 0.5 })

    -- Череп над головой — удалится при истечении модификатора неуязвимости
    local pfx = ParticleManager:CreateParticle(SAVE_PFX, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    if invuln_mod then invuln_mod.skull_pfx = pfx end
end

--------------------------------------------------------------------------------
-- Кратковременная неуязвимость после спаса
--------------------------------------------------------------------------------

modifier_riki_second_life_invuln = class({})

function modifier_riki_second_life_invuln:IsHidden() return true end
function modifier_riki_second_life_invuln:IsPurgable() return false end
function modifier_riki_second_life_invuln:RemoveOnDeath() return true end

function modifier_riki_second_life_invuln:OnDestroy()
    if self.skull_pfx then
        ParticleManager:DestroyParticle(self.skull_pfx, false)
        ParticleManager:ReleaseParticleIndex(self.skull_pfx)
        self.skull_pfx = nil
    end
end

function modifier_riki_second_life_invuln:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

return riki_second_life
