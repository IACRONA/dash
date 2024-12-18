LinkLuaModifier('modifier_axe_culling_blade_rage', 'abilities/heroes/axe/axe_culling_blade_rage', LUA_MODIFIER_MOTION_NONE)

axe_culling_blade_rage = class({})

function axe_culling_blade_rage:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local threshold = self:GetSpecialValueFor("kill_threshold")
	local radius = self:GetSpecialValueFor("speed_aoe")
	local duration = self:GetSpecialValueFor("speed_duration")

	local success = false
	if target:GetHealth()<=damage and target:IsHero() then success = true end

	self:PlayEffects( target, success )

	if success then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,  
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,  
		}
		ApplyDamage(damageTable)

		self:EndCooldown()
 		caster:AddNewModifier(caster, self, "modifier_axe_culling_blade_rage", {duration = self:GetSpecialValueFor("duration")})
 		caster:Heal(caster:GetMaxHealth() * (self:GetSpecialValueFor("heal_pct")/100), self)
	else
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, 
		}
		ApplyDamage(damageTable)		
	end
end

function axe_culling_blade_rage:PlayEffects( target, success )
	local particle_cast = ""
	local sound_cast = ""
	if success then
		particle_cast = "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf"
		sound_cast = "Hero_Axe.Culling_Blade_Success"
	else
		particle_cast = "particles/units/heroes/hero_axe/axe_culling_blade.vpcf"
		sound_cast = "Hero_Axe.Culling_Blade_Fail"
	end

	-- load data
	local direction = (target:GetOrigin()-self:GetCaster():GetOrigin()):Normalized()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 4, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 3, direction )
	ParticleManager:SetParticleControlForward( effect_cast, 4, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, target )
end

modifier_axe_culling_blade_rage = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    } end,
})

function modifier_axe_culling_blade_rage:GetModifierAttackSpeedBonus_Constant()  
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_axe_culling_blade_rage:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_axe_culling_blade_rage:GetModifierPreAttack_CriticalStrike(event)
  local target = event.target
  local parent = self:GetParent()

  if not target or target:IsNull() then
    return 0
  end

  if target.GetUnitName == nil then
    return 0
  end

  if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() or not target:IsAlive() then
    return 0
  end

  local ability = self:GetAbility()

  if RollPercentage(ability:GetSpecialValueFor("chance_crit_5x")) then
    return 400
  end

  if RollPercentage(ability:GetSpecialValueFor("chance_crit_3x")) then
    return 200
  end

   if RollPercentage(ability:GetSpecialValueFor("chance_crit_2x")) then
    return 100
  end
end
