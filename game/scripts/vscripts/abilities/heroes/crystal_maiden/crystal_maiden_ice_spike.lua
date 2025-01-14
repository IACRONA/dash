LinkLuaModifier('modifier_crystal_maiden_ice_spike_debuff', 'abilities/heroes/crystal_maiden/crystal_maiden_ice_spike', LUA_MODIFIER_MOTION_NONE)

crystal_maiden_ice_spike = class({})
 
function crystal_maiden_ice_spike:OnSpellStart()
	local caster = self:GetCaster()

	self.target = self:GetCursorTarget()
	self.soundName = "ice_spike_cast_".. RandomInt(1, 2)
	EmitSoundOn(self.soundName, self:GetCaster())
	self.animationTimer = Timers:CreateTimer(self:GetChannelTime()-0.3, function()
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	end)
end

function crystal_maiden_ice_spike:OnChannelFinish(interrupted)
	local caster = self:GetCaster()
	if self.animationTimer then  
		if interrupted then caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1) end
		Timers:RemoveTimer(self.animationTimer) 
	end 
	if interrupted then return StopSoundOn(self.soundName, caster) end
 	ProjectileManager:CreateTrackingProjectile({
 		EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast.vpcf",
 		Ability = self,
 		Source = caster,
 		Target = self.target,
 		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
 		ExtraData = {
 			isShard = 0
 		}
 	})
end

function crystal_maiden_ice_spike:OnProjectileHit_ExtraData(target, _,data)
	if not target then return end
	local caster = self:GetCaster()
 	local targetIsFrozen = target:HasModifier("modifier_crystal_maiden_frostbite") or target:HasModifier("modifier_crystal_maiden_frozen_shield_frozen") or target:HasModifier("modifier_water_elemental_frozen") 
	local damage = targetIsFrozen and self:GetSpecialValueFor("damage_frozen") or self:GetSpecialValueFor("damage")
	local hasCrit = RollPercentage(self:GetSpecialValueFor("chance_crit")) and 2 or 1
	local isShard = data.isShard == 1
	if self.target:TriggerSpellAbsorb(self) or self.target:TriggerSpellReflect(self) then 
		return 
	end
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = (isShard and self:GetSpecialValueFor("shard_damage_reduce")/100 or 1) * damage * hasCrit,
		damage_type = targetIsFrozen and DAMAGE_TYPE_PURE or self:GetAbilityDamageType(),
		ability = self,
	})

	EmitSoundOn("ice_spike_target", target)
	target:AddNewModifier(caster, self, "modifier_crystal_maiden_ice_spike_debuff", {duration = self:GetSpecialValueFor("duration")})

	if caster:HasScepter() and not isShard then 
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil, self:GetSpecialValueFor("radius"),
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			0,
			FIND_ANY_ORDER,
			false
		)

		for _,enemy in ipairs(enemies) do
		 	ProjectileManager:CreateTrackingProjectile({
		 		EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast.vpcf",
		 		Ability = self,
		 		Source = target,
		 		Target = enemy,
		 		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		 		 ExtraData = {
		 			isShard = 1
		 		}
		 	})
 		end
	end
end

modifier_crystal_maiden_ice_spike_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    } end,
})

function modifier_crystal_maiden_ice_spike_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_crystal_maiden_ice_spike_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end