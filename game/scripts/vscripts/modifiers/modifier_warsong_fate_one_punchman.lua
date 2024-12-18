LinkLuaModifier("modifier_warsong_fate_one_punchman_debuff", "modifiers/modifier_warsong_fate_one_punchman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_one_punchman_buff", "modifiers/modifier_warsong_fate_one_punchman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_one_punchman_cooldown", "modifiers/modifier_warsong_fate_one_punchman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_one_punchman_cooldown_kill", "modifiers/modifier_warsong_fate_one_punchman", LUA_MODIFIER_MOTION_NONE)

require("settings/game_settings")

modifier_warsong_fate_one_punchman = class({})
function modifier_warsong_fate_one_punchman:GetTexture() return "fate_one_punchman" end
function modifier_warsong_fate_one_punchman:IsPurgable() return false end
function modifier_warsong_fate_one_punchman:IsPurgeException() return false end
function modifier_warsong_fate_one_punchman:RemoveOnDeath() return false end

function modifier_warsong_fate_one_punchman:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_warsong_fate_one_punchman:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_one_punchman:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_warsong_fate_one_punchman:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if not params.target:IsHero() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsBuilding() then return end
    local chance = ONE_PUNCHMAN_SETTINGS_CHANCE[self:GetStackCount()]
    local chance_soul = ONE_PUNCHMAN_SETTINGS_CHANCE_SOUL[self:GetStackCount()]
    local cooldown = ONE_PUNCHMAN_SETTINGS_COOLDOWN
    local cooldown_kill = ONE_PUNCHMAN_SETTINGS_COOLDOWN_KILL
    local duration = ONE_PUNCHMAN_SETTINGS_DURATION
    if RollPercentage(chance) and not self:GetCaster():HasModifier("modifier_warsong_fate_one_punchman_cooldown_kill") then
        params.target:AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_one_punchman_debuff", {duration = 1})
        self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_warsong_fate_one_punchman_cooldown_kill", {duration = cooldown_kill})
    end
    if RollPercentage(chance_soul) then
        if not self:GetCaster():HasModifier("modifier_warsong_fate_one_punchman_cooldown") then
            self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_warsong_fate_one_punchman_cooldown", {duration = cooldown})
            local modifier_warsong_fate_one_punchman_buff = self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_warsong_fate_one_punchman_buff", {duration = duration, count = self:GetStackCount()})
            modifier_warsong_fate_one_punchman_buff:SetStackCount(self:GetStackCount())
            self:GetParent():EmitSound("Hero_Bane.BrainSap")
            params.target:EmitSound("Hero_Bane.BrainSap.Target")
        end
    end
end

modifier_warsong_fate_one_punchman_debuff = class({})
function modifier_warsong_fate_one_punchman_debuff:IsPurgable() return false end
function modifier_warsong_fate_one_punchman_debuff:IsHidden() return true end
function modifier_warsong_fate_one_punchman_debuff:OnCreated()
    if not IsServer() then return end
    local speed = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local info = {Target = self:GetParent(), Source = self:GetCaster(), Ability = nil, EffectName = "particles/units/heroes/hero_muerta/muerta_parting_shot_projectile.vpcf", iMoveSpeed = speed, vSourceLoc= self:GetCaster():GetAbsOrigin(), bDodgeable = false}
    ProjectileManager:CreateTrackingProjectile(info)
end

function modifier_warsong_fate_one_punchman_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("fate_one_punchman_cast")
    local parent = self:GetParent()
    parent.one_punchman_die = true
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetParent():GetMaxHealth(), damage_type = DAMAGE_TYPE_PURE})
    if self:GetParent():IsAlive() then
        self:GetParent():Kill(nil, self:GetCaster())
    end
    Timers:CreateTimer(1, function()
        parent.one_punchman_die = nil
    end)
end

modifier_warsong_fate_one_punchman_cooldown = class({})
function modifier_warsong_fate_one_punchman_cooldown:IsPurgable() return false end
function modifier_warsong_fate_one_punchman_cooldown:IsHidden() return true end


modifier_warsong_fate_one_punchman_buff = class({})
function modifier_warsong_fate_one_punchman_buff:GetTexture() return "fate_one_punchman" end
function modifier_warsong_fate_one_punchman_buff:IsPurgable() return false end
function modifier_warsong_fate_one_punchman_buff:OnCreated(params)
    if not IsServer() then return end
    self.attack_speed = ONE_PUNCHMAN_SETTINGS_ATTACK_SPEED[params.count]
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_warsong_fate_one_punchman_buff:AddCustomTransmitterData()
    return 
    {
        attack_speed = self.attack_speed,
    }
end

function modifier_warsong_fate_one_punchman_buff:HandleCustomTransmitterData( data )
    self.attack_speed = data.attack_speed
end

function modifier_warsong_fate_one_punchman_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_warsong_fate_one_punchman_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_warsong_fate_one_punchman_buff:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local heal = params.original_damage / 100 * ONE_PUNCHMAN_SETTINGS_LIFESTEAL[self:GetStackCount()]
    self:GetParent():Heal(heal, nil)
    local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_warsong_fate_one_punchman_cooldown_kill = class({})
function modifier_warsong_fate_one_punchman_cooldown_kill:IsPurgable() return false end
function modifier_warsong_fate_one_punchman_cooldown_kill:IsHidden() return true end
