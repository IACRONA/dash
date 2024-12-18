windranger_powershot_custom = class({})
LinkLuaModifier( "modifier_windranger_powershot_custom", "abilities/heroes/windranger/windranger_powershot_custom", LUA_MODIFIER_MOTION_NONE )

function windranger_powershot_custom:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local sound_cast = "Ability.PowershotPull"
	EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Ability Channeling
function windranger_powershot_custom:OnChannelFinish( bInterrupted )
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	-- load data
	local damage = self:GetSpecialValueFor( "powershot_damage" )
	local reduction = 1-(self:GetSpecialValueFor( "damage_reduction" )/100)
	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	
	local projectile_name = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
	local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
	local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)

	-- register projectile data
	self.projectiles[projectile] = {}
	self.projectiles[projectile].damage = damage*channel_pct
	self.projectiles[projectile].reduction = reduction
	self.projectiles[projectile].spawnOrigin = caster:GetAbsOrigin()
	self.projectiles[projectile].channelPct = channel_pct

	-- Play effects
	local sound_cast = "Ability.Powershot"
	EmitSoundOn( sound_cast, caster )
end


windranger_powershot_custom.projectiles = {}

function windranger_powershot_custom:OnProjectileHitHandle( target, location, handle )
	local caster = self:GetCaster()

	if not target then
		-- unregister projectile

		-- create Vision
		local vision_radius = self:GetSpecialValueFor( "vision_radius" )
		local vision_duration = self:GetSpecialValueFor( "vision_duration" )
		AddFOWViewer( caster:GetTeamNumber(), location, vision_radius, vision_duration, false )

		if caster:HasModifier("modifier_item_aghanims_shard") and not self.projectiles[handle].isShard then
			local damage = self:GetSpecialValueFor( "powershot_damage" )
			local reduction = 1-(self:GetSpecialValueFor( "damage_reduction" )/100)
			local vision_radius = self:GetSpecialValueFor( "vision_radius" )
			
			local projectile_name = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
			local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
			local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
			local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
			local projectile_direction = self.projectiles[handle].spawnOrigin-location
			projectile_direction.z = 0
			projectile_direction = projectile_direction:Normalized()

				local info = {
					Source = caster,
					Ability = self,
					vSpawnOrigin = location,
					
				    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				    
				    EffectName = projectile_name,
				    fDistance = projectile_distance,
				    fStartRadius = projectile_radius,
				    fEndRadius = projectile_radius,
					vVelocity = projectile_direction * projectile_speed,
				
					bProvidesVision = true,
					iVisionRadius = vision_radius,
					iVisionTeamNumber = caster:GetTeamNumber(),
				}
				local projectile = ProjectileManager:CreateLinearProjectile(info)

				-- register projectile data
				self.projectiles[projectile] = {}
				self.projectiles[projectile].damage = damage*self.projectiles[handle].channelPct
				self.projectiles[projectile].reduction = reduction
				self.projectiles[projectile].isShard = true
				-- Play effects
				local sound_cast = "Ability.Powershot"
				EmitSoundOn( sound_cast, caster )

		end
			self.projectiles[handle] = nil

		return
	end

	-- get data
	local data = self.projectiles[handle]
	local damage = data.damage

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- reduce damage
	data.damage = damage * data.reduction

	target:AddNewModifier(caster, self, "modifier_windranger_powershot_custom", {duration = self:GetSpecialValueFor("slow_duration")})
	-- Play effects
	local sound_cast = "Hero_Windrunner.PowershotDamage"
	EmitSoundOn( sound_cast, target )

 
end

function windranger_powershot_custom:OnProjectileThink( location )
	-- destroy trees
	local tree_width = self:GetSpecialValueFor( "tree_width" )
	GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
end

modifier_windranger_powershot_custom = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    } end,
})

function modifier_windranger_powershot_custom:OnCreated()
	self.slowMoveSpeed = self:GetAbility():GetSpecialValueFor("slow_move_speed")
end

function modifier_windranger_powershot_custom:GetModifierMoveSpeedBonus_Percentage()
	return -self.slowMoveSpeed
end