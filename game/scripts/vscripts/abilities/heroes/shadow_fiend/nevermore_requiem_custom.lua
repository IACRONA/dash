 nevermore_requiem_custom = class({})
LinkLuaModifier( "modifier_nevermore_requiem_custom", "abilities/heroes/shadow_fiend/nevermore_requiem_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nevermore_requiem_custom_scepter", "abilities/heroes/shadow_fiend/nevermore_requiem_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nevermore_requiem_custom_thinker", "abilities/heroes/shadow_fiend/nevermore_requiem_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nevermore_requiem_custom_pull", "abilities/heroes/shadow_fiend/nevermore_requiem_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nevermore_requiem_custom_cooldown", "abilities/heroes/shadow_fiend/nevermore_requiem_custom", LUA_MODIFIER_MOTION_NONE )
   
function nevermore_requiem_custom:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_enigma/enigma_black_hole_scepter.vpcf", context)
end

function nevermore_requiem_custom:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_nevermore_requiem_custom_cooldown") then 
		caster:AddNewModifier(caster, self, "modifier_nevermore_requiem_custom_cooldown", {duration = self:GetSpecialValueFor("cooldown_pull")})
		self.thinker = CreateModifierThinker(
			caster,
			self,
			"modifier_nevermore_requiem_custom_thinker",
			{},
			caster:GetOrigin(),
			caster:GetTeamNumber(),
			false
		)
		local radius = self:GetSpecialValueFor("requiem_radius")

		self.effect_radius = ParticleManager:CreateParticle( "particles/units/heroes/hero_enigma/enigma_black_hole_scepter.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( self.effect_radius, 0, caster:GetOrigin() )
		ParticleManager:SetParticleControl( self.effect_radius, 1, Vector(radius,radius, 0) )

 	end
	self:PlayEffects1()
	return true -- if success
end
function nevermore_requiem_custom:OnAbilityPhaseInterrupted()
	if self.thinker then self.thinker:Destroy() end
	self.thinker = nil
	self:StopEffects1( false )
end

--------------------------------------------------------------------------------
-- Ability Start
function nevermore_requiem_custom:OnSpellStart()
	if self.thinker then self.thinker:Destroy() end
	self.thinker = nil
	local soul_per_line = self:GetSpecialValueFor("requiem_soul_conversion")

	-- get number of souls
	local lines = 0
	local modifier = self:GetCaster():FindModifierByNameAndCaster( "modifier_nevermore_necromastery", self:GetCaster() )
	if modifier~=nil then
		lines = math.floor(modifier:GetStackCount() / soul_per_line) 
	end

	self:Explode( lines )
 
	if self:GetCaster():HasScepter() then
		local explodeDuration = self:GetSpecialValueFor("requiem_radius") / self:GetSpecialValueFor("requiem_line_speed")
		self:GetCaster():AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_nevermore_requiem_custom_scepter",
			{
				lineDuration = explodeDuration,
				lineNumber = lines,
			}
		)
	end
end

--------------------------------------------------------------------------------
-- Projectile Hit
function nevermore_requiem_custom:OnProjectileHit_ExtraData( hTarget, vLocation, params )
	if hTarget ~= nil then
		-- filter
		pass = false
		if hTarget:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then
			pass = true
		end

		if pass then
			local damage = self.damage
			if params and params.scepter then

				damage = self.damage * (self.damage_pct/100)

				if hTarget:IsHero() then
					local modifier = self:RetATValue( params.modifier )
					modifier:AddTotalHeal( damage )
				end
			end

			-- damage target
			local damageTable = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}
			ApplyDamage( damageTable )

			local direction = hTarget:GetOrigin() - Vector(params.xSpawn, params.ySpawn, 0)
 			local modifier = hTarget:FindModifierByName("modifier_nevermore_requiem_custom")
 			local duration = self:GetSpecialValueFor("requiem_slow_duration")

 			if params and not params.scepter and not params.isDead then 
	 			if modifier then
	 				duration = math.min(duration + modifier:GetRemainingTime(), self:GetSpecialValueFor("requiem_slow_duration_max"))
	 			end

				hTarget:AddNewModifier(
					self:GetCaster(),
					self,
					"modifier_nevermore_requiem_custom",
					{ duration = duration, xDirection =  direction.x, yDirection = direction.y}
				)
			end
		end
	end

	return false
end

function nevermore_requiem_custom:OnOwnerDied()
	if self:GetLevel()<1 then return end

	local soul_per_line = self:GetSpecialValueFor("requiem_soul_conversion")

	local lines = 0
	local modifier =  self:GetCaster():FindModifierByNameAndCaster( "modifier_nevermore_necromastery", self:GetCaster() ) 
	if modifier~=nil then
		lines = math.floor(math.floor(modifier:GetStackCount() * 0.3) / soul_per_line) 
	end

	-- explode
	self:Explode( lines, true )
end


--------------------------------------------------------------------------------
-- Helper
function nevermore_requiem_custom:Explode( lines, isDead )
	-- get references
	self.damage =   self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("requiem_slow_duration")

	-- get projectile
	local particle_line = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
	local line_length = self:GetSpecialValueFor("requiem_radius")
	local width_start = self:GetSpecialValueFor("requiem_line_width_start")
	local width_end = self:GetSpecialValueFor("requiem_line_width_end")
	local line_speed = self:GetSpecialValueFor("requiem_line_speed")
	local max_distance_time = line_length / line_speed

	-- create linear projectile
	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do
		-- Determine velocity
		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed

		local casterPoint = self:GetCaster():GetOrigin()
		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = particle_line,
			vSpawnOrigin = casterPoint,
			fDistance = line_length,
			vVelocity = velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
			ExtraData = {
				xSpawn =  casterPoint.x,
				ySpawn =  casterPoint.y,
				isDead = isDead and 1 or 0
			},
		}
		ProjectileManager:CreateLinearProjectile( info )

	local particle_lines_fx = ParticleManager:CreateParticle(particle_line, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle_lines_fx, 0, casterPoint)

	ParticleManager:SetParticleControl(particle_lines_fx, 1, velocity)
	ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time + 0.2, 0))
	ParticleManager:ReleaseParticleIndex(particle_lines_fx)
	-- Play effects
	end
	self:StopEffects1( true )
	self:PlayEffects2( lines )

end
 

function nevermore_requiem_custom:Implode( lines, modifier )
	-- get data
	self.damage_pct = self:GetSpecialValueFor("requiem_damage_pct_scepter")
	self.damage_heal_pct = self:GetSpecialValueFor("requiem_heal_pct_scepter")

	-- create identifier
	local modifierAT = self:AddATValue( modifier )
	modifier.identifier = modifierAT

	-- get projectile
	local particle_line = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
	local line_length = self:GetSpecialValueFor("requiem_radius")
	local width_start = self:GetSpecialValueFor("requiem_line_width_end")
	local width_end = self:GetSpecialValueFor("requiem_line_width_start")
	local line_speed = self:GetSpecialValueFor("requiem_line_speed")
	local max_distance_time = line_length / line_speed

	-- create linear projectile
	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do
		-- Determine velocity
		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed
 
		local spawnPoint = self:GetCaster():GetOrigin() + facing_vector * line_length
		-- create projectile
		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = particle_line,
			vSpawnOrigin = spawnPoint,
			fDistance = line_length,
			vVelocity = -velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
			ExtraData = {
				scepter = true,
				modifier = modifierAT,
			}
		}
		ProjectileManager:CreateLinearProjectile( info )
		local particle_lines_fx = ParticleManager:CreateParticle(particle_line, PATTACH_CUSTOMORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(particle_lines_fx, 0, spawnPoint)

		ParticleManager:SetParticleControl(particle_lines_fx, 1, -velocity)
		ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time, 0))
		ParticleManager:ReleaseParticleIndex(particle_lines_fx)

	end
end

--------------------------------------------------------------------------------
-- Effects
function nevermore_requiem_custom:PlayEffects1()
	-- Get Resources
	local particle_precast = "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf"
	local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"


	self.effect_precast = ParticleManager:CreateParticle( particle_precast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )	

	EmitSoundOn(sound_precast, self:GetCaster())
end
function nevermore_requiem_custom:StopEffects1( success )
	-- Get Resources
	local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"

	if self.effect_radius then 
		ParticleManager:DestroyParticle( self.effect_radius, false )
		ParticleManager:ReleaseParticleIndex(self.effect_radius)
		self.effect_radius = nil
	end
	-- Destroy Particles
	if not success then
		ParticleManager:DestroyParticle( self.effect_precast, true )
		StopSoundOn(sound_precast, self:GetCaster())
	end

	ParticleManager:ReleaseParticleIndex( self.effect_precast )
end

function nevermore_requiem_custom:PlayEffects2( lines )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local sound_cast = "Hero_Nevermore.RequiemOfSouls"

	-- Create Particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( lines, 0, 0 ) )	-- Lines
	ParticleManager:SetParticleControlForward( effect_cast, 2, self:GetCaster():GetForwardVector() )		-- initial direction
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Play Sounds
	EmitSoundOn(sound_cast, self:GetCaster())
end

--------------------------------------------------------------------------------
-- Helper: Ability Table (AT)
function nevermore_requiem_custom:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function nevermore_requiem_custom:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function nevermore_requiem_custom:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function nevermore_requiem_custom:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	return ret
end

function nevermore_requiem_custom:DelATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
end

modifier_nevermore_requiem_custom_scepter = class({})

--------------------------------------------------------------------------------

function modifier_nevermore_requiem_custom_scepter:IsHidden()
	return true
	-- return true
end

function modifier_nevermore_requiem_custom_scepter:IsPurgable()
	return false
end
function modifier_nevermore_requiem_custom_scepter:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_nevermore_requiem_custom_scepter:OnCreated( kv )
	-- get references
	self.lines = kv.lineNumber
	self.duration = kv.lineDuration
	self.heal = 0

	-- Add timer
	if IsServer() then
		self:StartIntervalThink( self.duration )
	end
end

function modifier_nevermore_requiem_custom_scepter:OnRefresh( kv )
end

function modifier_nevermore_requiem_custom_scepter:OnDestroy()
	if IsServer() then
		if self.identifier then
			self:GetAbility():DelATValue( self.identifier )
		end
	end
end
--------------------------------------------------------------------------------
-- Interval
function modifier_nevermore_requiem_custom_scepter:OnIntervalThink()
	if not self.afterImplode then
		self.afterImplode = true

		-- implode
		self:GetAbility():Implode( self.lines, self )

		-- play effects
		local sound_cast = "Hero_Nevermore.RequiemOfSouls"
		EmitSoundOn(sound_cast, self:GetParent())
	else
		-- Heal
		self:GetParent():Heal( self.heal, self:GetAbility() )
		if self.heal > 0 then
			self:PlayEffects()
		end

		-- remove references
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Helper
function modifier_nevermore_requiem_custom_scepter:AddTotalHeal( value )
	self.heal = self.heal + value
end

--------------------------------------------------------------------------------
-- Effects
function modifier_nevermore_requiem_custom_scepter:PlayEffects()
	local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_nevermore_requiem_custom = class({})

--------------------------------------------------------------------------------

function modifier_nevermore_requiem_custom:IsDebuff()
	return true
end

function modifier_nevermore_requiem_custom:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function modifier_nevermore_requiem_custom:OnCreated( kv )
	self.reduction_ms_pct = self:GetAbility():GetSpecialValueFor("requiem_reduction_ms")
	self.reduction_damage_pct = self:GetAbility():GetSpecialValueFor("requiem_reduction_damage")
	self.requiem_reduction_mres = self:GetAbility():GetSpecialValueFor("requiem_reduction_mres")

	self.direction = Vector(kv.xDirection, kv.yDirection, 0)

	self:OnIntervalThink()
	self:StartIntervalThink(0.2)
end

function modifier_nevermore_requiem_custom:OnDestroy( kv )
	if IsClient() then return end
	self:GetParent():Stop()
end

function modifier_nevermore_requiem_custom:OnIntervalThink()
	if IsClient() then return end
	local parent = self:GetParent()

	parent:MoveToPosition((parent:GetAbsOrigin() + self.direction:Normalized() * 300))
end 

function modifier_nevermore_requiem_custom:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_nevermore_requiem_custom:CheckState()
	local funcs = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return funcs
end

function modifier_nevermore_requiem_custom:GetModifierMagicalResistanceBonus()
	return self.requiem_reduction_mres
end

function modifier_nevermore_requiem_custom:GetModifierMoveSpeedBonus_Percentage()
	return self.reduction_ms_pct
end

function modifier_nevermore_requiem_custom:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

modifier_nevermore_requiem_custom_thinker = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})


function modifier_nevermore_requiem_custom_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "requiem_radius" )
end


function modifier_nevermore_requiem_custom_thinker:OnDestroy()
	if IsServer() then
	 	UTIL_Remove( self:GetParent())
	end
end

function modifier_nevermore_requiem_custom_thinker:IsAura()
	return true
end

function modifier_nevermore_requiem_custom_thinker:GetModifierAura()
	return "modifier_nevermore_requiem_custom_pull"
end

function modifier_nevermore_requiem_custom_thinker:GetAuraRadius()
	return self.radius
end

function modifier_nevermore_requiem_custom_thinker:GetAuraDuration()
	return 0.1
end

function modifier_nevermore_requiem_custom_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_nevermore_requiem_custom_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_nevermore_requiem_custom_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_nevermore_requiem_custom_pull = {}

function modifier_nevermore_requiem_custom_pull:IsHidden()
	return false
end

function modifier_nevermore_requiem_custom_pull:IsDebuff()
	return true
end

function modifier_nevermore_requiem_custom_pull:IsStunDebuff()
	return true
end

function modifier_nevermore_requiem_custom_pull:IsPurgable()
	return true
end

function modifier_nevermore_requiem_custom_pull:OnCreated( kv )
	self.pull_speed = self:GetAbility():GetSpecialValueFor( "pull_drag_speed" )
	self.center = self:GetCaster():GetAbsOrigin()
 
	self:StartIntervalThink(FrameTime())
end

 

function modifier_nevermore_requiem_custom_pull:OnIntervalThink()
	if IsClient() then return end
	local direction = self.center - self:GetParent():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	local point = self:GetParent():GetOrigin() + direction * self.pull_speed * FrameTime()

 	self:GetParent():SetOrigin(point)
end

function modifier_nevermore_requiem_custom_pull:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	end
end

modifier_nevermore_requiem_custom_cooldown = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})