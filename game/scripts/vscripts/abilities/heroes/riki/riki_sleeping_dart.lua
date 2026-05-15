riki_sleeping_dart = class({})
LinkLuaModifier("modifier_riki_sleeping_dart", "abilities/heroes/riki/riki_sleeping_dart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_stealth_cast",  "abilities/heroes/riki/riki_sleeping_dart", LUA_MODIFIER_MOTION_NONE)


local PFX = "particles/units/heroes/hero_riki/"
local SLEEP_PFX = "particles/bane_nightmare.vpcf"
local DART_PFX = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf"

function riki_sleeping_dart:Precache(context)
    PrecacheResource("particle", SLEEP_PFX, context)
    PrecacheResource("particle", DART_PFX, context)
    PrecacheResource("soundfile", "soundevents/game_sounds_custom_announcer.vsndevts", context)
end

function riki_sleeping_dart:GetAbilityTextureName()
    return "riki/riki_sleeping_dart"
end

function riki_sleeping_dart:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not caster or not target then return end
    if target:TriggerSpellAbsorb(self) then return end

    -- Инвиз не мигает при касте
    caster:AddNewModifier(caster, self, "modifier_riki_stealth_cast", { duration = 0.5 })

    -- Анимация
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

    -- Звуки
    EmitSoundOn("Riki.SleepingDart.Cast", caster)

    -- Партикл каста (кинжал в руке)
    local cast_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_dagger_group.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(cast_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(cast_pfx)

    -- Снаряд
    ProjectileManager:CreateTrackingProjectile({
        Target            = target,
        Source            = caster,
        Ability           = self,
        EffectName        = DART_PFX,
        iMoveSpeed        = 1800,
        bDodgeable        = false,
        bVisibleToEnemies = true,
        bProvidesVision   = false,
    })

    EmitSoundOn("Riki.SleepingDart.Throw", caster)
end

local DIMINISH_FACTOR = 0.5   -- каждое следующее применение -50%
local DIMINISH_RESET  = 40    -- через 40с от последнего хита счётчик сбрасывается

function riki_sleeping_dart:OnProjectileHit(target, location)
    if not target or not IsValidEntity(target) or not target:IsAlive() then return false end

    local caster   = self:GetCaster()
    local duration = self:GetSpecialValueFor("sleep_duration")

    -- Diminishing returns: каждое повторное усыпление -50%, сброс через минуту
    caster.sleeping_dart_history = caster.sleeping_dart_history or {}
    local now = GameRules:GetGameTime()
    local tid = target:entindex()
    local rec = caster.sleeping_dart_history[tid]

    local stacks = 0
    if rec and (now - rec.last) < DIMINISH_RESET then
        stacks = rec.stacks
    end
    caster.sleeping_dart_history[tid] = { last = now, stacks = stacks + 1 }

    local actual_dur = duration * (DIMINISH_FACTOR ^ stacks) * (1 - target:GetStatusResistance())
    target:AddNewModifier(caster, self, "modifier_riki_sleeping_dart", { duration = actual_dur })

    EmitSoundOn("Riki.SleepingDart.Impact", target)

    -- Попадание дротика
    local hit_pfx = ParticleManager:CreateParticle(PFX .. "riki_tricks_dagger_hit.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(hit_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(hit_pfx)

    return true
end

--------------------------------------------------------------------------------
-- Модификатор сна
--------------------------------------------------------------------------------

modifier_riki_sleeping_dart = class({})

function modifier_riki_sleeping_dart:IsHidden() return false end
function modifier_riki_sleeping_dart:IsPurgable() return false end
function modifier_riki_sleeping_dart:IsDebuff() return true end
function modifier_riki_sleeping_dart:GetTexture() return "riki/riki_sleeping_dart" end

function modifier_riki_sleeping_dart:OnCreated()
    local parent = self:GetParent()
    parent:Interrupt()
    parent:FadeGesture(ACT_DOTA_IDLE)
    parent:StartGestureWithPlaybackRate(ACT_DOTA_DISABLED, 0.5)
    self.sleep_pfx = ParticleManager:CreateParticle(SLEEP_PFX, PATTACH_OVERHEAD_FOLLOW, parent)
end

function modifier_riki_sleeping_dart:OnDestroy()
    self:GetParent():FadeGesture(ACT_DOTA_DISABLED)
    if self.sleep_pfx then
        ParticleManager:DestroyParticle(self.sleep_pfx, false)
        ParticleManager:ReleaseParticleIndex(self.sleep_pfx)
        self.sleep_pfx = nil
    end
end

function modifier_riki_sleeping_dart:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_riki_sleeping_dart:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_riki_sleeping_dart:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.ability and params.ability:GetAbilityName() == "riki_sleeping_dart" then return end
    if params.damage <= 0 then return end
    self:Destroy()
end

--------------------------------------------------------------------------------
-- Инвиз на время каста
--------------------------------------------------------------------------------

modifier_riki_stealth_cast = class({})

function modifier_riki_stealth_cast:IsHidden() return true end
function modifier_riki_stealth_cast:IsPurgable() return false end

function modifier_riki_stealth_cast:DeclareFunctions()
    return { MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

-- Не использует MODIFIER_STATE_INVISIBLE — это true sight-bypass.
-- Через INVISIBILITY_LEVEL варды/sentry'и видят как обычный инвиз Рики.
function modifier_riki_stealth_cast:GetModifierInvisibilityLevel()
    return 1.0
end

return riki_sleeping_dart
