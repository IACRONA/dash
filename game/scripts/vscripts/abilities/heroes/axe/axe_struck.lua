LinkLuaModifier('modifier_axe_struck_debuff', 'abilities/heroes/axe/axe_struck', LUA_MODIFIER_MOTION_NONE)

axe_struck = class({})

function axe_struck:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context)
end

function axe_struck:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local speed = self:GetSpecialValueFor("projectile_speed")
	if target:TriggerSpellAbsorb(self) or target:TriggerSpellReflect(self) then return end
 	ProjectileManager:CreateTrackingProjectile({
 		EffectName = "particles/acrona/axe_struck/axe_struck_projectile.vpcf",
 		Ability = self,
 		Source = caster,
 		Target = target,
 		iMoveSpeed = speed,
 	})

 	caster:EmitSound("axe_struck_cast")
end

function axe_struck:OnProjectileHit(target)
	if not target then return end
	local caster = self:GetCaster()

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = self:GetSpecialValueFor("damage"),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	})

	target:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
	target:AddNewModifier(caster, self, "modifier_axe_struck_debuff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_axe_struck_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
    CheckState				= function(self) return
    {
    	[MODIFIER_STATE_DISARMED] = true,
    } end,
})

function modifier_axe_struck_debuff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end