require("settings/game_settings")
LinkLuaModifier('modifier_warsong_fate_murder_cooldown', 'modifiers/modifier_warsong_fate_murder', LUA_MODIFIER_MOTION_NONE)

modifier_warsong_fate_murder = class({})

function modifier_warsong_fate_murder:GetTexture() 
    return "fate_murder" 
end

function modifier_warsong_fate_murder:IsPurgable() 
    return false 
end

function modifier_warsong_fate_murder:IsPurgeException() 
    return false 
end

function modifier_warsong_fate_murder:RemoveOnDeath() 
    return false 
end

function modifier_warsong_fate_murder:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_warsong_fate_murder:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_murder:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_warsong_fate_murder:OnAbilityFullyCast(params)
    if not IsServer() then return end

    local parent = self:GetParent()

    if params.unit ~= parent then return end

    if params.ability:IsItem() or params.ability:IsToggle() then return end
    local abilityName = params.ability:GetAbilityName()
    if abilityName == "invoker_quas" or
       abilityName == "invoker_wex" or
       abilityName == "invoker_exort" or
       abilityName == "invoker_invoke" or
       abilityName == "ability_use" or
       abilityName == "ui_custom_ability_jump" then
       return
    end

    if params.ability:GetCooldown(params.ability:GetLevel()) <= 1 then 
        return 
    end
    if parent:HasModifier("modifier_warsong_fate_murder_cooldown") then return end

    local chance = MURDER_SETTINGS_KILL_REFRESH_LAST_SPELL[self:GetStackCount()]
    if RollPercentage(chance) then
        Timers:CreateTimer(0.1, function()
            params.ability:EndCooldown()
            parent:EmitSound("DOTA_Item.Refresher.Activate")
            local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)
            parent:AddNewModifier(parent, nil, "modifier_warsong_fate_murder_cooldown", {duration = 15})
        end)
    end
end

function modifier_warsong_fate_murder:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if params.attacker ~= parent or params.unit == parent then 
        return 
    end
    if parent.proc_murder then return end

    local stackCount = self:GetStackCount()
    local one_chance = MURDER_SETTINGS_CRITICAL_CHANCE_DOUBLE[stackCount]
    local two_chance = MURDER_SETTINGS_CRITICAL_CHANCE_TRIPPLE[stackCount]
    local three_chance = MURDER_SETTINGS_CRITICAL_CHANCE_FOUR[stackCount]
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
        parent.proc_murder = true
        ApplyDamage({
            victim = params.unit,
            attacker = parent,
            damage = params.damage * damage_mult,
            damage_type = params.damage_type,
            ability = params.ability
        })
        parent.proc_murder = nil

        local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        local counter_speed = 1 
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(damage_mult, counter_speed, 0))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        local soundIndex = math.min(damage_mult - 1, 3)
        local sound_cast = "Hero_OgreMagi.Fireblast.x" .. soundIndex
        if soundIndex > 0 then
            parent:EmitSound(sound_cast)
        end
    end
end 

modifier_warsong_fate_murder_cooldown = class({
    IsHidden = function(self) return true end,
    IsPurgable = function(self) return false end,
    IsBuff = function(self) return true end,
    RemoveOnDeath = function(self) return false end,
    IsPurgeException = function(self) return false end,
})
