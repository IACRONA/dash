LinkLuaModifier( "cursed_knight_deadman_field_thinker", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier_cursed", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "cursed_knight_deadman_field_modifier_enemy", "abilities/heroes/cursed_knight/cursed_knight_deadman_field",LUA_MODIFIER_MOTION_NONE )




cursed_knight_deadman_field = cursed_knight_deadman_field or {}
function cursed_knight_deadman_field:OnUpgrade()
    self:SetAbilityIndex(4)
end
function cursed_knight_deadman_field:GetAOERadius() return self:GetSpecialValueFor("radius") end
function cursed_knight_deadman_field:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("field_duration")
    local point = caster:GetOrigin()
    local team_id = caster:GetTeamNumber()

    local thinker = CreateModifierThinker(caster, self, "cursed_knight_deadman_field_thinker", {["duration"] = duration}, point, team_id, false)
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
    elseif parent == caster then
        parent:AddNewModifier(caster, ability, "cursed_knight_deadman_field_modifier_cursed", {})
    end
end
function cursed_knight_deadman_field_modifier:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    
    -- Удаляем модификаторы "enemy" и "cursed" при уничтожении основного модификатора
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

    local damage_table = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_second,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage(damage_table)
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

function cursed_knight_deadman_field_modifier_cursed:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function cursed_knight_deadman_field_modifier_cursed:GetModifierIncomingDamage_Percentage()
    return -90 -- Снижение урона на 90%
end
function cursed_knight_deadman_field_modifier_cursed:OnTakeDamage(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    if keys.unit == parent and keys.damage_type == DAMAGE_TYPE_MAGICAL  then
        local attacker = keys.attacker
        if attacker and attacker ~= parent  and not attacker:HasModifier("cursed_knight_deadman_field_modifier_enemy") then
            local reflect_damage = keys.damage
            ApplyDamage({
                victim = attacker,
                attacker = caster,
                damage = reflect_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = ability,
            })
            EmitSoundOn("Hero_Antimage.Counterspell.Target", attacker)
        end
    end
end
