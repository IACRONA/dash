LinkLuaModifier('modifier_mirana_fire_arrow', 'abilities/heroes/mirana/mirana_fire_arrow', LUA_MODIFIER_MOTION_NONE)

mirana_fire_arrow = class({})

function mirana_fire_arrow:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context)
end

function mirana_fire_arrow:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_name = "particles/units/heroes/hero_mars/mars_spear.vpcf"
	local projectile_speed = self:GetSpecialValueFor("arrow_speed")
	local projectile_distance = self:GetCastRange(origin, nil) + caster:GetCastRangeBonus()
	local projectile_start_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_end_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_vision = self:GetSpecialValueFor("arrow_vision")

	local bonus_damage = self:GetSpecialValueFor( "arrow_bonus_damage" )
	local min_stun = self:GetSpecialValueFor( "arrow_min_stun" )
	local max_stun = self:GetSpecialValueFor( "arrow_max_stun" )
	local max_distance = self:GetSpecialValueFor( "arrow_max_stunrange" )

	local projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

	-- logic
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = caster:GetTeamNumber(),

		ExtraData = {
			originX = origin.x,
			originY = origin.y,
			originZ = origin.z,

			max_distance = max_distance,
			min_stun = min_stun,
			max_stun = max_stun,

			min_damage = min_damage,
			bonus_damage = bonus_damage,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- Effects
	local sound_cast = "Hero_Mirana.ArrowCast"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function mirana_fire_arrow:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if hTarget==nil then return end

	local damage = self:GetSpecialValueFor("damage")

	if RollPercentage(self:GetSpecialValueFor("chance_crit_3x")) then 
		damage = damage * 3
	elseif RollPercentage(self:GetSpecialValueFor("chance_crit_2x")) then 
		damage = damage * 2
	end

	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = damage ,
		damage_type = self:GetAbilityDamageType(),
		ability = self, 
	}
	ApplyDamage(damageTable)

	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_mirana_fire_arrow", {duration = self:GetSpecialValueFor("duration")})
	AddFOWViewer( self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false )

	-- effects
	local sound_cast = "Hero_Mirana.ArrowImpact"
	EmitSoundOn( sound_cast, hTarget )

	return true
end

modifier_mirana_fire_arrow = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	GetEffectName 			= function() return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf" end,
})

function modifier_mirana_fire_arrow:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_fire")
	self:StartIntervalThink(1)
end

function modifier_mirana_fire_arrow:OnIntervalThink()
	if IsClient() then return end
	local ability = self:GetAbility()

	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
	})
end