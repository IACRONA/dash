riki_venous_strike = class({})
LinkLuaModifier("modifier_riki_venous_silence", "abilities/heroes/riki/riki_venous_strike",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_venous_bleed",   "abilities/heroes/riki/riki_venous_strike",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_break_invis",    "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)

local PFX = "particles/units/heroes/hero_riki/"
local BLOOD_PFX = "particles/generic_gameplay/generic_hit_blood.vpcf"

function riki_venous_strike:Precache(context)
    PrecacheResource("particle", BLOOD_PFX, context)
end

function riki_venous_strike:GetAbilityTextureName()
    return "riki/riki_venous_strike"
end

function riki_venous_strike:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not caster or not target then return end
    if target:TriggerSpellAbsorb(self) then return end

    -- Анимация атаки (вид удара с руки)
    caster:StartGesture(ACT_DOTA_ATTACK)

    EmitSoundOn("Riki.VenousStrike.Cast", caster)

    -- Принудительно ломаем инвиз на 1.5с
    caster:AddNewModifier(caster, self, "modifier_riki_break_invis", { duration = 1.5 })

    -- Микро-атака
    caster:PerformAttack(target, true, true, true, false, false, false, true)

    local silence_dur = self:GetSpecialValueFor("silence_duration")
    local bleed_dur   = self:GetSpecialValueFor("bleed_duration")

    target:AddNewModifier(caster, self, "modifier_riki_venous_silence", {
        duration = silence_dur * (1 - target:GetStatusResistance())
    })

    target:AddNewModifier(caster, self, "modifier_riki_venous_bleed", {
        duration = bleed_dur
    })

    -- Кольцо backstab вокруг цели
    local ring_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_backstab_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(ring_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(ring_pfx)

    -- Брызги крови
    local blood_pfx = ParticleManager:CreateParticle(BLOOD_PFX, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(blood_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(blood_pfx)

    -- Backstab эффект
    local stab_pfx = ParticleManager:CreateParticle(PFX .. "riki_backstab.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(stab_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(stab_pfx)
end

--------------------------------------------------------------------------------
-- Немота
--------------------------------------------------------------------------------

modifier_riki_venous_silence = class({})

function modifier_riki_venous_silence:IsHidden() return false end
function modifier_riki_venous_silence:IsPurgable() return true end
function modifier_riki_venous_silence:IsDebuff() return true end
function modifier_riki_venous_silence:GetTexture() return "riki/riki_venous_strike" end

function modifier_riki_venous_silence:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true }
end

function modifier_riki_venous_silence:DeclareFunctions() return {} end

--------------------------------------------------------------------------------
-- Кровотечение
--------------------------------------------------------------------------------

modifier_riki_venous_bleed = class({})

function modifier_riki_venous_bleed:IsHidden() return false end
function modifier_riki_venous_bleed:IsPurgable() return true end
function modifier_riki_venous_bleed:IsDebuff() return true end
function modifier_riki_venous_bleed:GetTexture() return "riki_backstab" end

function modifier_riki_venous_bleed:OnCreated()
    -- Капли крови на цели пока идёт кровотечение
    self.bleed_pfx = ParticleManager:CreateParticle(
        PFX .. "riki_backstab_hit_blood_droplets.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(self.bleed_pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

    if IsServer() then self:StartIntervalThink(1.0) end
end

function modifier_riki_venous_bleed:OnDestroy()
    if self.bleed_pfx then
        ParticleManager:DestroyParticle(self.bleed_pfx, true)
        ParticleManager:ReleaseParticleIndex(self.bleed_pfx)
        self.bleed_pfx = nil
    end
end

function modifier_riki_venous_bleed:OnIntervalThink()
    if not IsServer() then return end
    local target  = self:GetParent()
    local ability = self:GetAbility()
    if not ability then return end

    ApplyDamage({
        victim       = target,
        attacker     = self:GetCaster(),
        damage       = ability:GetSpecialValueFor("bleed_dps"),
        damage_type  = DAMAGE_TYPE_PURE,
        ability      = ability,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
    })
end

function modifier_riki_venous_bleed:DeclareFunctions() return {} end

return riki_venous_strike
