LinkLuaModifier("modifier_warsong_fate_himaron_buff", "modifiers/modifier_warsong_fate_himaron", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_himaron_cooldown", "modifiers/modifier_warsong_fate_himaron", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_himaron_sword", "modifiers/modifier_warsong_fate_himaron", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_himaron_sword_cooldown", "modifiers/modifier_warsong_fate_himaron", LUA_MODIFIER_MOTION_NONE)

require("settings/game_settings")

modifier_warsong_fate_himaron = class({})
function modifier_warsong_fate_himaron:GetTexture() return "fate_demon" end
function modifier_warsong_fate_himaron:IsPurgable() return false end
function modifier_warsong_fate_himaron:IsPurgeException() return false end
function modifier_warsong_fate_himaron:RemoveOnDeath() return false end

function modifier_warsong_fate_himaron:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_warsong_fate_himaron:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_himaron:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_warsong_fate_himaron:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.damage < 1 then return end
    if params.unit == self:GetParent() then return end
    if RollPercentage(HIMARON_SETTINGS_CHANCE[self:GetStackCount()]) and not self:GetParent():HasModifier("modifier_warsong_fate_himaron_cooldown") then
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_himaron_cooldown", {duration = HIMARON_SETTINGS_COOLDOWN})
        local modifier_warsong_fate_himaron_buff = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_himaron_buff", {duration = HIMARON_SETTINGS_DURATION})
        modifier_warsong_fate_himaron_buff.settings = self.settings
        modifier_warsong_fate_himaron_buff:SetStackCount(self:GetStackCount())
        self:GetParent():EmitSound("demon_buff")
    end
end

modifier_warsong_fate_himaron_cooldown = class({})
function modifier_warsong_fate_himaron_cooldown:IsHidden() return true end
function modifier_warsong_fate_himaron_cooldown:IsPurgable() return false end

modifier_warsong_fate_himaron_sword_cooldown = class({})
function modifier_warsong_fate_himaron_sword_cooldown:IsHidden() return true end
function modifier_warsong_fate_himaron_sword_cooldown:IsPurgable() return false end

modifier_warsong_fate_himaron_buff = class({})
function modifier_warsong_fate_himaron_buff:IsPurgable() return false end
function modifier_warsong_fate_himaron_buff:GetTexture() return "fate_demon" end
function modifier_warsong_fate_himaron_buff:OnCreated(params)
    if not IsServer() then return end
    self.damage = HIMARON_SETTINGS_DAMAGE
    self.movespeed = HIMARON_SETTINGS_MOVESPEED
    self.cooldown_reduction = HIMARON_SETTINGS_COOLDOWN_REDUCTION
    self.spell_amp = HIMARON_SETTINGS_SPELL_AMPLIFY
    self.increase_damage_self = DEMON_SETTINGS_INCREASE_DAMAGE_SELF
    print(self.damage)
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_warsong_fate_himaron_buff:AddCustomTransmitterData()
    return 
    {
        damage = self.damage,
        movespeed = self.movespeed,
        cooldown_reduction = self.cooldown_reduction,
        spell_amp = self.spell_amp,
        increase_damage_self = self.increase_damage_self,
    }
end

function modifier_warsong_fate_himaron_buff:HandleCustomTransmitterData( data )
    self.damage = data.damage
    self.movespeed = data.movespeed
    self.cooldown_reduction = data.cooldown_reduction
    self.spell_amp = data.spell_amp
    self.increase_damage_self = data.increase_damage_self
end

function modifier_warsong_fate_himaron_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_warsong_fate_himaron_buff:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_warsong_fate_himaron_buff:GetModifierMoveSpeedBonus_Constant()
    return self.movespeed
end

function modifier_warsong_fate_himaron_buff:GetModifierPercentageCooldown()
    return self.cooldown_reduction
end

function modifier_warsong_fate_himaron_buff:GetModifierSpellAmplify_Percentage()
    return self.spell_amp
end

function modifier_warsong_fate_himaron_buff:GetModifierIncomingDamage_Percentage()
    return self.increase_damage_self
end

function modifier_warsong_fate_himaron_buff:GetModifierDamageOutgoing_Percentage(params)
    if params.damage_type == DAMAGE_TYPE_PURE then
        return HIMARON_SETTINGS_PURE_DAMAGE_INCREASE[self:GetStackCount()]
    end
end

function modifier_warsong_fate_himaron_buff:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.damage < 1 then return end
    if params.unit == self:GetParent() then return end
    if params.unit:IsBuilding() then return end
    if self:GetParent():IsIllusion() then return end
    local chance = DEMON_SETTINGS_CHANCE[self:GetStackCount()]
    if RollPercentage(chance) and not self:GetParent():HasModifier("modifier_warsong_fate_himaron_sword_cooldown") then
        local modifier_warsong_fate_himaron_sword = params.unit:AddNewModifier(self:GetCaster(), nil, "modifier_warsong_fate_himaron_sword", {duration = 3.45})
        modifier_warsong_fate_himaron_sword:SetStackCount(self:GetStackCount())
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_warsong_fate_himaron_sword_cooldown", {duration = HIMARON_SWORD_COOLDOWN})
    end
end

modifier_warsong_fate_himaron_sword = class({})
function modifier_warsong_fate_himaron_sword:IsHidden() return true end
function modifier_warsong_fate_himaron_sword:IsPurgable() return false end
function modifier_warsong_fate_himaron_sword:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_warsong_fate_himaron_sword:OnCreated(params)
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/acrona/ghost_sword/ghost_sword_projectile_juggernaut.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControlForward(particle, 0, self:GetCaster():GetForwardVector())
    ParticleManager:SetParticleControlEnt(particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    local particle = ParticleManager:CreateParticle("particles/acrona/ghost_sword/ghost_sword_ghosts.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)

    self:GetParent():EmitSound("demon_cast")
end

function modifier_warsong_fate_himaron_sword:OnDestroy()
    if not IsServer() then return end
    local damage_min = DEMON_SETTINGS_MIN_DAMAGE[self:GetStackCount()]
    local damage_max = DEMON_SETTINGS_MAX_DAMAGE[self:GetStackCount()]
    local damage = RandomInt(damage_min, damage_max)
    local damage_table = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = nil
    }
    ApplyDamage(damage_table)
end

function modifier_warsong_fate_himaron_sword:CheckState()
    return
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
end

function modifier_warsong_fate_himaron_sword:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DISABLE_TURNING
    }
end

function modifier_warsong_fate_himaron_sword:GetModifierDisableTurning()
    return 1
end