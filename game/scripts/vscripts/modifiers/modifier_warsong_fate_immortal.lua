LinkLuaModifier("modifier_warsong_fate_immortal_buff", "modifiers/modifier_warsong_fate_immortal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_immortal_bkb", "modifiers/modifier_warsong_fate_immortal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_immortal_bkb_cooldown", "modifiers/modifier_warsong_fate_immortal", LUA_MODIFIER_MOTION_NONE)
  
require("settings/game_settings")

modifier_warsong_fate_immortal = class({})
function modifier_warsong_fate_immortal:GetTexture() return "fate_immortal" end
function modifier_warsong_fate_immortal:IsPurgable() return false end
function modifier_warsong_fate_immortal:IsPurgeException() return false end
function modifier_warsong_fate_immortal:RemoveOnDeath() return false end

function modifier_warsong_fate_immortal:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_warsong_fate_immortal:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_immortal:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_REINCARNATION
    }
end

function modifier_warsong_fate_immortal:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    local chance = IMMORTAL_SETTINGS_CHANCE_RESPAWN[self:GetStackCount()]
    if RollPercentage(chance) then

        --local modifier_warsong_fate_immortal_buff = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_immortal_buff", {duration = 3})
        --modifier_warsong_fate_immortal_buff:SetStackCount(self:GetStackCount())

    end

    if not self:GetParent():HasModifier("modifier_warsong_fate_immortal_bkb_cooldown") and RollPercentage(IMMORTAL_SETTINGS_CHANCE_BKB[self:GetStackCount()]) then
        self:GetParent():EmitSound("fate_immortal_cast")
        local modifier = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_immortal_bkb", {duration = IMMORTAL_SETTINGS_DURATION_BKB[self:GetStackCount()]})
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_immortal_bkb_cooldown", {duration = IMMORTAL_SETTINGS_COOLDOWN_BKB[self:GetStackCount()]})
    end
end

function modifier_warsong_fate_immortal:OnDeath(params)
    if not IsServer() then return end
    local unit = params.unit
    local reincarnate = params.reincarnate
    if self:GetParent() ~= unit then return end
    local damage = IMMORTAL_SETTINGS_DAMAGE[self:GetStackCount()]
    local chance_explosion = IMMORTAL_SETTINGS_CHANCE_EXPLOSION[self:GetStackCount()]
    if RollPercentage(chance_explosion) then
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
        for _,unit in pairs(units) do
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = nil })
        end
        self:GetParent():EmitSound("Hero_Techies.Suicide")
        local particle_explosion_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_explosion_fx)
    end
    if reincarnate then
        self:ReincarnationStart( params )
    end
end

function modifier_warsong_fate_immortal:ReincarnationStart( params )
    local unit = params.unit
    local reincarnate = params.reincarnate
    if reincarnate then
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_CUSTOMORIGIN, params.unit)
        ParticleManager:SetParticleAlwaysSimulate(particle)
        ParticleManager:SetParticleControl(particle, 0, params.unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(1, 0, 0))
        ParticleManager:SetParticleControl(particle, 11, Vector(200, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetParent():EmitSound("fate_immortal_cast")
        params.unit:EmitSound("Hero_SkeletonKing.Reincarnate")
    end
end

function modifier_warsong_fate_immortal:ReincarnateTime()
    if not IsServer() then return end
    local chance = IMMORTAL_SETTINGS_CHANCE_RESPAWN[self:GetStackCount()]

    if RollPercentage(chance) then
        return 1
    end
end

modifier_warsong_fate_immortal_buff = class({})
function modifier_warsong_fate_immortal_buff:IsHidden() return true end
function modifier_warsong_fate_immortal_buff:IsPurgable() return false end
function modifier_warsong_fate_immortal_buff:RemoveOnDeath() return false end

function modifier_warsong_fate_immortal_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_REINCARNATION,
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_warsong_fate_immortal_buff:ReincarnationStart( params )
    local unit = params.unit
    local reincarnate = params.reincarnate
    if reincarnate then
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_CUSTOMORIGIN, params.unit)
        ParticleManager:SetParticleAlwaysSimulate(particle)
        ParticleManager:SetParticleControl(particle, 0, params.unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(1, 0, 0))
        ParticleManager:SetParticleControl(particle, 11, Vector(200, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetParent():EmitSound("fate_immortal_cast")
        params.unit:EmitSound("Hero_SkeletonKing.Reincarnate")
    end
end

function modifier_warsong_fate_immortal_buff:ReincarnateTime()
    if IsServer() then
        return 1
    end
end

function modifier_warsong_fate_immortal_buff:OnDeath(params)
    if not IsServer() then return end
    local unit = params.unit
    local reincarnate = params.reincarnate
    if self:GetParent() ~= unit then return end
    self:ReincarnationStart( params )
end

 
modifier_warsong_fate_immortal_bkb = class({
    IsHidden                 = function(self) return false end,
    IsPurgable                 = function(self) return false end,
    RemoveOnDeath             = function(self) return true end,
    CheckState      = function(self) return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    } end,
})

function modifier_warsong_fate_immortal_bkb:GetTexture() return "fate_immortal" end


function modifier_warsong_fate_immortal_bkb:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_warsong_fate_immortal_bkb:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_warsong_fate_immortal_bkb:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_warsong_fate_immortal_bkb:StatusEffectPriority()
    return 99999
end

modifier_warsong_fate_immortal_bkb_cooldown = class({
    IsHidden                 = function(self) return false end,
    IsPurgable                 = function(self) return false end,
    RemoveOnDeath             = function(self) return false end,
})
function modifier_warsong_fate_immortal_bkb_cooldown:GetTexture() return "fate_immortal" end
