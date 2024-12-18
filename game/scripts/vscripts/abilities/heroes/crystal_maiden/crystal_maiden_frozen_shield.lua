LinkLuaModifier('modifier_crystal_maiden_frozen_shield', 'abilities/heroes/crystal_maiden/crystal_maiden_frozen_shield', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_crystal_maiden_frozen_shield_frozen', 'abilities/heroes/crystal_maiden/crystal_maiden_frozen_shield', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_crystal_maiden_frozen_shield_slow', 'abilities/heroes/crystal_maiden/crystal_maiden_frozen_shield', LUA_MODIFIER_MOTION_NONE)
 
crystal_maiden_frozen_shield = class({})

function crystal_maiden_frozen_shield:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", context)
	PrecacheResource("particle", "particles/acrona/frost_shield/frost_shield.vpcf", context)
end


function crystal_maiden_frozen_shield:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("ice_barier_cast", caster)
	caster:AddNewModifier(caster, self, "modifier_crystal_maiden_frozen_shield", {duration = self:GetSpecialValueFor("duration")})
end

modifier_crystal_maiden_frozen_shield = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
   		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
   		MODIFIER_EVENT_ON_ATTACK_LANDED,
    } end,
})

function modifier_crystal_maiden_frozen_shield:OnCreated()
	local shieldHealth = self:GetAbility():GetSpecialValueFor("shield_health")
	local ability = self:GetAbility()
	local parent = self:GetParent()

	self.frozenDuration = ability:GetSpecialValueFor("frozen_duration") 
	self.slowDuration = ability:GetSpecialValueFor("slow_duration") 
	self.nfx = ParticleManager:CreateParticle("particles/acrona/frost_shield/frost_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
  ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

 
	if not IsServer() then return end
	self:SetStackCount(shieldHealth)
end

function modifier_crystal_maiden_frozen_shield:OnDestroy()
	ParticleManager:DestroyParticle(self.nfx, false)

	if IsClient() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_CUSTOMORIGIN, parent)
	ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
	EmitSoundOn("ice_barier_absorb", parent)
	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetAbsOrigin(),
		nil, ability:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		0,
		FIND_ANY_ORDER,
		false
	)
	local damageTable = {
		attacker = parent,
		damage = ability:GetSpecialValueFor("aoe_damage"),
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	}
	for _,enemy in ipairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		enemy:AddNewModifier(parent, ability, "modifier_crystal_maiden_frozen_shield_frozen", {duration = self.frozenDuration})
	end
end

function modifier_crystal_maiden_frozen_shield:GetModifierIncomingDamageConstant(event)
	if IsClient() then   return self:GetStackCount() end

	if not IsServer() then return end
	if event.inflictor and event.inflictor == self:GetAbility() then 
	  return
	end

	if self:GetStackCount() > event.damage then
	    self:SetStackCount(self:GetStackCount() - event.damage)
	    local i = event.damage
	    return -i
	else
	    local i = self:GetStackCount()
	    self:SetStackCount(0)
	    self:Destroy()
	    return -i
	end
end

function modifier_crystal_maiden_frozen_shield:OnAttackLanded(event)
	local parent = self:GetParent()

	if event.target ~= parent then return end
	if event.attacker:IsBuilding() then return end
	local ability = self:GetAbility()
	local attacker = event.attacker

	if RollPercentage(ability:GetSpecialValueFor("chance_frozen")) then 
		return attacker:AddNewModifier(parent, ability, "modifier_crystal_maiden_frozen_shield_frozen", {duration = self.frozenDuration})
	end

	attacker:AddNewModifier(parent, ability, "modifier_crystal_maiden_frozen_shield_slow", {duration = self.slowDuration})
end

 

modifier_crystal_maiden_frozen_shield_slow = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
    } end,
})


function modifier_crystal_maiden_frozen_shield_slow:OnCreated()
	local ability = self:GetAbility()
	self.reduceAttackSpeed = ability:GetSpecialValueFor("reduce_attack_speed_pct")
	self.slowMoveSpeed = ability:GetSpecialValueFor("slow_move_speed_pct")
end
 
function modifier_crystal_maiden_frozen_shield_slow:GetModifierAttackSpeedPercentage()
	return self.reduceAttackSpeed 
end

function modifier_crystal_maiden_frozen_shield_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slowMoveSpeed
end
 
function modifier_crystal_maiden_frozen_shield_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end

modifier_crystal_maiden_frozen_shield_frozen = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
    CheckState      = function(self) return 
    {
      [MODIFIER_STATE_ROOTED] = true,
    } end,
})

function modifier_crystal_maiden_frozen_shield_frozen:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end