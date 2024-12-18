bucket_soldier_fear = class({})

LinkLuaModifier( "modifier_bucket_soldier_attack", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bucket_soldier_attack_fear", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bucket_soldier_attack_ready", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )

function bucket_soldier_fear:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_troll_warlord_battletrance.vpcf", context )
	PrecacheResource( "particle", "particles/hw_fx/golem_terror_status_effect.vpcf", context )
	PrecacheResource( "particle", "particles/hw_fx/golem_terror_debuff.vpcf", context )
end

function bucket_soldier_fear:GetIntrinsicModifierName()
	return "modifier_bucket_soldier_attack"
end

if modifier_bucket_soldier_attack_ready == nil then
	modifier_bucket_soldier_attack_ready = class( {} ) 
end

function modifier_bucket_soldier_attack_ready:IsHidden()
	return true
end

function modifier_bucket_soldier_attack_ready:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_bucket_soldier_attack_ready:GetStatusEffectName()
	return "particles/status_fx/status_effect_diretide_hulk.vpcf"
end

function modifier_bucket_soldier_attack_ready:StatusEffectPriority()
	return 140
end

if modifier_bucket_soldier_attack == nil then
	modifier_bucket_soldier_attack = class( {} ) 
end

function modifier_bucket_soldier_attack:IsHidden()
	return false
end

function modifier_bucket_soldier_attack:IsPurgable()
	return false
end

function modifier_bucket_soldier_attack:OnCreated( kv )
	if not self:GetAbility() then
		return
	end

	if IsServer() then
		self.debuff_duration = self:GetAbility():GetSpecialValueFor( "debuff_duration" )
		self.cooldown_reduction_per_buff_level = self:GetAbility():GetSpecialValueFor( "cooldown_reduction_per_buff_level" )
		self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_bucket_soldier_attack_ready", { duration = -1 } )
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_bucket_soldier_attack:OnIntervalThink()
	if IsServer() == false then
		return
	end

	if self:GetAbility():IsCooldownReady() and self:GetCaster():HasModifier( "modifier_bucket_soldier_attack_ready" ) == false then
		self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_bucket_soldier_attack_ready", { duration = -1 } )
	end
end

function modifier_bucket_soldier_attack:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
	}

	return funcs
end

function modifier_bucket_soldier_attack:OnAttackLanded( params )
	if IsServer() then
		if self:GetAbility():IsCooldownReady() == false then
			return
		end

		local hAttacker = params.attacker
		if ( hAttacker == nil ) or hAttacker:IsNull() or ( hAttacker ~= self:GetParent() ) then
			return
		end

		local hVictim = params.target
		if hVictim == nil or hVictim:IsNull() then
			return
		end

		if hVictim:GetTeamNumber() == hAttacker:GetTeamNumber() then
			return
		end

		local bHit = false
		if hVictim:IsIllusion() and not hVictim:IsStrongIllusion() then
			hVictim:Kill( self:GetAbility(), self:GetCaster() )
			bHit = true
		end

		if hVictim:IsHero() and hVictim:IsMagicImmune() == false then
			hVictim:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_bucket_soldier_attack_fear", { run_from_bucket = true, duration = self.debuff_duration } )
			bHit = true
		end

		if bHit then
			self:GetAbility():StartCooldown( -1 )

			self:GetCaster():RemoveModifierByName( "modifier_bucket_soldier_attack_ready" )

			EmitSoundOn( "BucketSoldier.Fear", hVictim )
		end
	end
end

function modifier_bucket_soldier_attack:GetModifierCooldownReduction_Constant( params )
	local fCooldownReduction = 0
	if IsServer() then
		local hBuff = self:GetParent():FindModifierByName( "modifier_creature_buff_dynamic" )
		if hBuff ~= nil then
			local nBuffLevel = hBuff:GetBaseBuffLevel()
			fCooldownReduction = nBuffLevel * self.cooldown_reduction_per_buff_level
		end
	end
	return fCooldownReduction
end

if modifier_bucket_soldier_attack_debuff == nil then
	modifier_bucket_soldier_attack_debuff = class( {} ) 
end

function modifier_bucket_soldier_attack_debuff:IsDebuff()
	return true
end

function modifier_bucket_soldier_attack_debuff:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_bucket_soldier_attack_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_slow.vpcf"
end

function modifier_bucket_soldier_attack_debuff:OnCreated( kv )
	if self:GetAbility() then
		self.movement_speed_slow = self:GetAbility():GetSpecialValueFor( "movement_speed_slow" )
		self.attack_speed_slow = self:GetAbility():GetSpecialValueFor( "attack_speed_slow" )
	else
		return
	end
end

function modifier_bucket_soldier_attack_debuff:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_bucket_soldier_attack_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self.movement_speed_slow
end

function modifier_bucket_soldier_attack_debuff:GetModifierAttackSpeedBonus_Constant( params )
	return self.attack_speed_slow
end

if modifier_bucket_soldier_attack_fear == nil then
	modifier_bucket_soldier_attack_fear = class( {} ) 
end

function modifier_bucket_soldier_attack_fear:IsDebuff()
	return true
end

function modifier_bucket_soldier_attack_fear:GetEffectName()
	return "particles/hw_fx/golem_terror_debuff.vpcf"
end

function modifier_bucket_soldier_attack_fear:GetStatusEffectName()
	return "particles/hw_fx/golem_terror_status_effect.vpcf"
end

function modifier_bucket_soldier_attack_fear:StatusEffectPriority()
	return 35
end

function modifier_bucket_soldier_attack_fear:OnCreated( kv )
	if IsServer() then
		if kv.run_from_bucket == true then
			self.vTargetDir = nil

			local hBuildings = FindUnitsInRadius( self:GetParent():GetTeamNumber(), Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
			for _, hBuilding in ipairs( hBuildings ) do
				if hBuilding:GetUnitName() == "candy_bucket" then
					self.vTargetDir = hBuilding:GetOrigin()
					break
				end
			end

			if self.vTargetDir == nil then
				self.vTargetDir = Vector( 0, 0, 0 )
			else
				self.vTargetDir = self:GetParent():GetAbsOrigin() - self.vTargetDir
				self.vTargetDir.z = 0
			end

			local flDist = ( self:GetParent():GetAbsOrigin() - self.vTargetDir ):Length2D()
			self.vTargetDir = self.vTargetDir / flDist
		else
			self.vTargetDir = Vector( kv.run_direction_x, kv.run_direction_y, kv.run_direction_z )
		end

		self:StartIntervalThink( 0.1 )
		self:OnIntervalThink()

		EmitSoundOn( "BucketSoldier.Fear", self:GetParent() )
	end
end

function modifier_bucket_soldier_attack_fear:OnIntervalThink()
	if IsServer() == false then
		return
	end
	local vDestination = self:GetParent():GetAbsOrigin() + self.vTargetDir * 400
	self:GetParent():OnCommandMoveToDirection( vDestination )
end

function modifier_bucket_soldier_attack_fear:CheckState()
	local state =
	{
		[ MODIFIER_STATE_FEARED ] = true,
		[ MODIFIER_STATE_COMMAND_RESTRICTED ] = true,
		[ MODIFIER_STATE_DISARMED ] = true,
		[ MODIFIER_STATE_SILENCED ] = true,
		[ MODIFIER_STATE_MUTED ] = true,
		[ MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
	}

	return state
end

