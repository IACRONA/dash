---@diagnostic disable: undefined-global
LinkLuaModifier( "cursed_knight_deadman_field_thinker", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier_cursed", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier_enemy", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )




cursed_knight_deadman_field = cursed_knight_deadman_field or {}
function cursed_knight_deadman_field:GetAOERadius() return self:GetSpecialValueFor("radius") end
function cursed_knight_deadman_field:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("field_duration")
    local point = caster:GetOrigin()
    local team_id = caster:GetTeamNumber()
    
    CreateModifierThinker(caster, self, "cursed_knight_deadman_field_thinker", {["duration"] = duration}, point, team_id, false)
    EmitSoundOn("deadman_field", caster)
end
cursed_knight_deadman_field_thinker = cursed_knight_deadman_field_thinker or {}
function cursed_knight_deadman_field_thinker:OnCreated(event)
    local thinker = self:GetParent()
    local ability = self:GetAbility() 
    self.radius = ability:GetSpecialValueFor("radius")
    
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_cursed_k/cursed_shield_green.vpcf", PATTACH_ABSORIGIN, thinker)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, self.radius))
end
function cursed_knight_deadman_field_thinker:OnDestroy()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
function cursed_knight_deadman_field_thinker:IsAura()
	return true
end

function cursed_knight_deadman_field_thinker:GetAuraRadius()
	return self.radius
end

function cursed_knight_deadman_field_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end
function cursed_knight_deadman_field_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-- function cursed_knight_deadman_field_thinker:GetAuraSearchFlags()
-- 	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
-- end
function cursed_knight_deadman_field_thinker:GetModifierAura()
	return "cursed_knight_deadman_field_modifier"
end

cursed_knight_deadman_field_modifier = cursed_knight_deadman_field_modifier or {}
function cursed_knight_deadman_field_modifier:IsHidden() return true end
function cursed_knight_deadman_field_modifier:IsPurgable() return false end
function cursed_knight_deadman_field_modifier:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    
    if parent:GetTeam() ~= caster:GetTeam() then
        parent:AddNewModifier(caster, ability, "cursed_knight_deadman_field_modifier_enemy", {})
    else
        parent:AddNewModifier(caster, ability, "cursed_knight_deadman_field_modifier_cursed", {})
    end
end
function cursed_knight_deadman_field_modifier:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()

    if parent:HasModifier("cursed_knight_deadman_field_modifier_enemy") then
        parent:RemoveModifierByName("cursed_knight_deadman_field_modifier_enemy")
    end

    if parent:HasModifier("cursed_knight_deadman_field_modifier_cursed") then
        parent:RemoveModifierByName("cursed_knight_deadman_field_modifier_cursed")
    end
end

cursed_knight_deadman_field_modifier_enemy = cursed_knight_deadman_field_modifier_enemy or {}

function cursed_knight_deadman_field_modifier_enemy:IsHidden() return false end
function cursed_knight_deadman_field_modifier_enemy:IsPurgable() return false end

function cursed_knight_deadman_field_modifier_enemy:OnCreated()
    if not IsServer() then return end
    
    self.damage_per_second = self:GetAbility():GetSpecialValueFor("damage_per_sec_in_field")
    self.slow_percentage = self:GetAbility():GetSpecialValueFor("slow_movement_in_field") or 0

    self:StartIntervalThink(1.0)
end

function cursed_knight_deadman_field_modifier_enemy:OnIntervalThink()
    if not IsServer() then return end
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_second,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    })
end

function cursed_knight_deadman_field_modifier_enemy:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function cursed_knight_deadman_field_modifier_enemy:GetModifierMoveSpeedBonus_Percentage()
    if not self.slow_percentage then return 0 end
    return -self.slow_percentage
end
cursed_knight_deadman_field_modifier_cursed = cursed_knight_deadman_field_modifier_cursed or {}

function cursed_knight_deadman_field_modifier_cursed:IsHidden() return false end
function cursed_knight_deadman_field_modifier_cursed:IsPurgable() return false end

function cursed_knight_deadman_field_modifier_cursed:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    self.bonus_damage_in_field = ability:GetSpecialValueFor("bonus_damage_in_field") or 0
    self:SetHasCustomTransmitterData(true)
end
function cursed_knight_deadman_field_modifier_cursed:AddCustomTransmitterData()
    return {
        bonus_damage_in_field = self.bonus_damage_in_field
    }
end

function cursed_knight_deadman_field_modifier_cursed:HandleCustomTransmitterData(data)
    self.bonus_damage_in_field = data.bonus_damage_in_field

end
function cursed_knight_deadman_field_modifier_cursed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_REFLECT_SPELL,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_ABSORB_SPELL,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end
 
local EXCEPTION_SPELLS = {
    ["rubick_spell_steal"] = true,
    ["legion_commander_duel"] = true,
    ["phantom_assassin_phantom_strike"] = true,
    ["riki_blink_strike"] = true,
    ["morphling_replicate"]	= true,
}

local INSTANT_ABSORB_SPELLS = {
    ["tusk_snowball"] = true,
}

function cursed_knight_deadman_field_modifier_cursed:GetAbsorbSpell(keys)
    if not IsServer() then return end
    
    local ability = keys.ability
    local caster = ability:GetCaster()
    return 1
end

function cursed_knight_deadman_field_modifier_cursed:GetReflectSpell(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local original_ability = keys.ability
    local is_absorb = false
    
    if not original_ability or not original_ability:GetCaster() then return end
    if original_ability:GetCaster():GetTeamNumber() == parent:GetTeamNumber() then return end
    
    local attacker = original_ability:GetCaster()
    if attacker == parent then return end
    
    if INSTANT_ABSORB_SPELLS[original_ability:GetAbilityName()] then
        is_absorb = true
    end
    
    if not is_absorb and self:IsUnitInDome(attacker) then return end
    if attacker:TriggerSpellAbsorb(original_ability) then return end
    
    local ability_name = original_ability:GetAbilityName()
    if EXCEPTION_SPELLS[ability_name] then return end
    
    local reflect_damage_pct = ability:GetSpecialValueFor("reflect_spell_damage") or 100
    EmitSoundOn("Hero_Antimage.Counterspell.Target", attacker)
    
    -- Ищем существующую способность или создаем новую
    local reflected_ability = parent:FindAbilityByName(ability_name)
    if not reflected_ability then
        reflected_ability = parent:AddAbility(ability_name)
    end
    
    if reflected_ability then
        self:SetupReflectedAbility(reflected_ability, original_ability, attacker, reflect_damage_pct)
    end
    
    return false
end

function cursed_knight_deadman_field_modifier_cursed:SetupReflectedAbility(reflected_ability, original_ability, target, reflect_damage_pct)
    -- Активируем способность, если она была деактивирована
    reflected_ability:SetActivated(true)
    reflected_ability:SetLevel(original_ability:GetLevel())
    reflected_ability:SetStolen(true)
    reflected_ability:SetHidden(true)
    
    local parent = self:GetParent()
    parent:SetCursorCastTarget(target)
    
    pcall(function()
        reflected_ability:OnSpellStart()
    end)
    
    reflected_ability.reflect_spell_damage_percentage = reflect_damage_pct
    
    if reflected_ability:GetBehavior() == DOTA_ABILITY_BEHAVIOR_CHANNELLED then
        reflected_ability:OnChannelFinish(true)
    end
    
    -- Деактивируем способность после использования
    Timers:CreateTimer(0.1, function()
        if reflected_ability and not reflected_ability:IsNull() then
            reflected_ability:SetLevel(1)
            reflected_ability:SetHidden(true)
            reflected_ability:SetActivated(false)
            
            if reflected_ability:GetIntrinsicModifierName() then 
                local modifier = parent:FindModifierByName(reflected_ability:GetIntrinsicModifierName())
                if modifier then
                    modifier:Destroy()
                end
            end
        end
    end)
end

function cursed_knight_deadman_field_modifier_cursed:IsUnitInDome(unit)
    local dome_center = self:GetAbility():GetCaster():GetOrigin()
    local unit_pos = unit:GetOrigin()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    
    local distance = (dome_center - unit_pos):Length2D()
    
    return distance <= radius
end



function cursed_knight_deadman_field_modifier_cursed:OnTakeDamage(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local _oridamage = keys.original_damage
    local attacker = keys.attacker
    local target = keys.unit
    local _oriability = keys.inflictor
    if target == parent then 
        if keys.damage_type == DAMAGE_TYPE_MAGICAL then
            local reduced_damage = _oridamage * ability:GetSpecialValueFor("damage_resist_magic_in_field") / 100 
            parent:SetHealth(parent:GetHealth() + reduced_damage)
        elseif keys.damage_type == DAMAGE_TYPE_PHYSICAL then
            local reduced_damage = _oridamage * ability:GetSpecialValueFor("damage_resist_physical_in_field") / 100 
            parent:SetHealth(parent:GetHealth() + reduced_damage)
        end
    elseif attacker == parent then
        if _oriability and _oriability.reflect_spell_damage_percentage and parent:FindAbilityByName("special_bonus_unique_skeleton_king_deadman_field_amp_reflect_spell_damage"):GetLevel() > 0 then
            local reflect_percentage = _oriability.reflect_spell_damage_percentage / 100
            local reflected_damage = _oridamage * reflect_percentage - _oridamage
            _oriability.reflect_spell_damage_percentage = nil
            ApplyDamage({
                victim = target,
                attacker = parent,  
                damage = reflected_damage,
                damage_type = keys.damage_type,
                ability = _oriability,
            })
        end
    end
end