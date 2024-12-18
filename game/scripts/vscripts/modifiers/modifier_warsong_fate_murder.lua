require("settings/game_settings")
LinkLuaModifier('modifier_warsong_fate_murder_cooldown', 'modifiers/modifier_warsong_fate_murder', LUA_MODIFIER_MOTION_NONE)

modifier_warsong_fate_murder = class({})
function modifier_warsong_fate_murder:GetTexture() return "fate_murder" end
function modifier_warsong_fate_murder:IsPurgable() return false end
function modifier_warsong_fate_murder:IsPurgeException() return false end
function modifier_warsong_fate_murder:RemoveOnDeath() return false end

function modifier_warsong_fate_murder:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_warsong_fate_murder:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_murder:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_warsong_fate_murder:OnAbilityFullyCast(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.ability:IsItem() then return end
    local chance = MURDER_SETTINGS_KILL_REFRESH_LAST_SPELL[self:GetStackCount()]
    if params.ability:IsToggle() then return end
    if params.ability:GetCooldown(params.ability:GetLevel()) <= 1 then return end
    if params.ability:GetAbilityName() == "invoker_quas" then return end
    if params.ability:GetAbilityName() == "invoker_wex" then return end
    if params.ability:GetAbilityName() == "invoker_exort" then return end
    if params.ability:GetAbilityName() == "invoker_invoke" then return end
    if params.ability:GetAbilityName() == "ability_use" then return end
    if params.ability:GetAbilityName() == "ui_custom_ability_jump" then return end
    if self:GetCaster():HasModifier("modifier_warsong_fate_murder_cooldown") then return end
    
    if RollPercentage(chance) then
        Timers:CreateTimer(0.1, function()
            params.ability:EndCooldown()
            self:GetCaster():EmitSound("DOTA_Item.Refresher.Activate")
            local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)
            self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_warsong_fate_murder_cooldown", {duration = 15})
        end)
    end
end

function modifier_warsong_fate_murder:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.unit == self:GetParent() then return end
    if self:GetParent().proc_murder ~= nil then return end
    local one_chance = MURDER_SETTINGS_CRITICAL_CHANCE_DOUBLE[self:GetStackCount()]
    local two_chance = MURDER_SETTINGS_CRITICAL_CHANCE_TRIPPLE[self:GetStackCount()]
    local three_chance = MURDER_SETTINGS_CRITICAL_CHANCE_FOUR[self:GetStackCount()]
    local damage_mult = 0
    if RollPercentage(one_chance) then
        damage_mult = 1
        if RollPercentage(two_chance) then
            damage_mult = 2
            if RollPercentage(three_chance) then
                damage_mult = 3
            end
        end
    end

    if damage_mult > 0 and params.damage > 80 then
        self:GetParent().proc_murder = true
        ApplyDamage({victim = params.unit, attacker = self:GetParent(), damage = params.damage * damage_mult, damage_type = params.damage_type, ability = params.ability})
        self:GetParent().proc_murder = nil
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( damage_mult, counter_speed, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        local sound = math.min( damage_mult-1, 3 )
        local sound_cast = "Hero_OgreMagi.Fireblast.x" .. sound
        if sound > 0 then
            self:GetParent():EmitSound(sound_cast)
        end
    end
end 

modifier_warsong_fate_murder_cooldown = class({
    IsHidden                 = function(self) return true end,
    IsPurgable                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return false end,
    IsPurgeException             = function(self) return false end,
})