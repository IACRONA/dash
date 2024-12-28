enigma_black_hole_custom = {}

LinkLuaModifier( "modifier_enigma_black_hole_custom_thinker", "abilities/heroes/enigma/enigma_black_hole_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_enigma_black_hole_custom_scepter_thinker", "abilities/heroes/enigma/enigma_black_hole_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_enigma_black_hole_custom_pull", "abilities/heroes/enigma/enigma_black_hole_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_enigma_black_hole_custom_debuff", "abilities/heroes/enigma/enigma_black_hole_custom", LUA_MODIFIER_MOTION_HORIZONTAL )
 
function enigma_black_hole_custom:Precache(context)
	PrecacheResource("particle", "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", context)
end
	 
function enigma_black_hole_custom:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function enigma_black_hole_custom:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")

	self.thinker = CreateModifierThinker(
		caster,
		self,
		"modifier_enigma_black_hole_custom_thinker",
		{ duration = duration },
		point,
		caster:GetTeamNumber(),
		false
	)
	self.thinker = self.thinker:FindModifierByName("modifier_enigma_black_hole_custom_thinker")

	if caster:HasScepter() then 
		self.thinkerScepter = CreateModifierThinker(
			caster,
			self,
			"modifier_enigma_black_hole_custom_scepter_thinker",
			{ duration = duration },
			point,
			caster:GetTeamNumber(),
			false
		)
		self.thinkerScepter = self.thinkerScepter:FindModifierByName("modifier_enigma_black_hole_custom_scepter_thinker")
	end
end

function enigma_black_hole_custom:OnChannelFinish( bInterrupted )
	if self.thinker and not self.thinker:IsNull() then
		self.thinker:Destroy()
	end
	if self.thinkerScepter and not self.thinkerScepter:IsNull() then
		self.thinkerScepter:Destroy()
	end
end

modifier_enigma_black_hole_custom_debuff = {}

function modifier_enigma_black_hole_custom_debuff:IsHidden()
	return false
end

function modifier_enigma_black_hole_custom_debuff:IsDebuff()
	return true
end

function modifier_enigma_black_hole_custom_debuff:IsStunDebuff()
	return true
end

function modifier_enigma_black_hole_custom_debuff:IsPurgable()
	return true
end

function modifier_enigma_black_hole_custom_debuff:OnCreated( kv )
	self.rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )
	self.pull_speed = self:GetAbility():GetSpecialValueFor( "pull_speed" )
	self.rotate_speed = self:GetAbility():GetSpecialValueFor( "pull_rotate_speed" )

	if IsServer() then
		self.center = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_enigma_black_hole_custom_debuff:OnRefresh( kv )
	
end

function modifier_enigma_black_hole_custom_debuff:OnRemoved()
end

function modifier_enigma_black_hole_custom_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_enigma_black_hole_custom_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_enigma_black_hole_custom_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_enigma_black_hole_custom_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_enigma_black_hole_custom_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_enigma_black_hole_custom_debuff:UpdateHorizontalMotion( me, dt )
	local target = self:GetParent():GetOrigin()-self.center
	target.z = 0
	local targetL = target:Length2D()-self.pull_speed*dt

	local targetN = target:Normalized()
	local deg = math.atan2( targetN.y, targetN.x )
	local targetN = Vector( math.cos(deg+self.rotate_speed*dt), math.sin(deg+self.rotate_speed*dt), 0 );

	self:GetParent():SetOrigin( self.center + targetN * targetL )


end

function modifier_enigma_black_hole_custom_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end

modifier_enigma_black_hole_custom_thinker = {}

function modifier_enigma_black_hole_custom_thinker:IsHidden()
	return false
end

function modifier_enigma_black_hole_custom_thinker:IsPurgable()
	return false
end

function modifier_enigma_black_hole_custom_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.interval = 1
	self.ticks = math.floor(self:GetDuration()/self.interval+0.5)
	self.tick = 0

	if IsServer() then
 
 
		local damage = self:GetAbility():GetSpecialValueFor( "damage" )  
        local spell_amp = self:GetCaster():GetSpellAmplification(false)

 		self.damageTable = {
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}
 
          
		self:StartIntervalThink( self.interval )

		local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )

		self:AddParticle(
			effect_cast,
			false,
			false,
			-1,
			false,
			false
		)

	end
	EmitSoundOn( "Hero_Enigma.Black_Hole", self:GetParent() )

end


function modifier_enigma_black_hole_custom_thinker:OnDestroy()
 
 	StopSoundOn( "Hero_Enigma.Black_Hole", self:GetParent() )
	EmitSoundOn( "Hero_Enigma.Black_Hole.Stop", self:GetParent() )

	if IsServer() then
		 
		if self:GetRemainingTime()<0.01 and self.tick<self.ticks then
			self:OnIntervalThink()
		end
	 
		UTIL_Remove( self:GetParent() )
	end
 
 
end

function modifier_enigma_black_hole_custom_thinker:OnIntervalThink()
 
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )

         local spell_amp = self:GetCaster():GetSpellAmplification(false)

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		if self:GetCaster():IsAlive() then 
		    self.damageTable.victim = enemy

		    if self:GetCaster():HasScepter() then 
		    	self.damageTable.damage = enemy:GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("scepter_pct_damage")/100) + damage
			end
		    ApplyDamage( self.damageTable )
		end
	end

	self.tick = self.tick + 1
end

function modifier_enigma_black_hole_custom_thinker:IsAura()
	return true
end

function modifier_enigma_black_hole_custom_thinker:GetModifierAura()
	return "modifier_enigma_black_hole_custom_debuff"
end

function modifier_enigma_black_hole_custom_thinker:GetAuraRadius()
	return self.radius
end

function modifier_enigma_black_hole_custom_thinker:GetAuraDuration()
	return 0.1
end

function modifier_enigma_black_hole_custom_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_enigma_black_hole_custom_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_enigma_black_hole_custom_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_enigma_black_hole_custom_scepter_thinker = {}

function modifier_enigma_black_hole_custom_scepter_thinker:IsHidden()
	return true
end

function modifier_enigma_black_hole_custom_scepter_thinker:IsPurgable()
	return false
end

function modifier_enigma_black_hole_custom_scepter_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "scepter_radius" )

	if IsServer() then
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_enigma/enigma_black_hole_scepter.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector(self.radius,self.radius, 0) )

		self:AddParticle(
			effect_cast,
			false,
			false,
			-1,
			false,
			false
		)
	end
end


function modifier_enigma_black_hole_custom_scepter_thinker:OnDestroy()
	if IsServer() then
	 	UTIL_Remove( self:GetParent())
	end
end

function modifier_enigma_black_hole_custom_scepter_thinker:IsAura()
	return true
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetModifierAura()
	return "modifier_enigma_black_hole_custom_pull"
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetAuraRadius()
	return self.radius
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetAuraDuration()
	return 0.1
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_enigma_black_hole_custom_scepter_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_enigma_black_hole_custom_pull = {}

function modifier_enigma_black_hole_custom_pull:IsHidden()
	return false
end

function modifier_enigma_black_hole_custom_pull:IsDebuff()
	return true
end

function modifier_enigma_black_hole_custom_pull:IsStunDebuff()
	return true
end

function modifier_enigma_black_hole_custom_pull:IsPurgable()
	return true
end

function modifier_enigma_black_hole_custom_pull:GetEffectName()
	return "particles/units/heroes/hero_enigma/enigma_black_hole_scepter_pull_debuff.vpcf"
end

function modifier_enigma_black_hole_custom_pull:OnCreated( kv )
	self.pull_speed = self:GetAbility():GetSpecialValueFor( "scepter_drag_speed" )
	self.rotate_speed = self:GetAbility():GetSpecialValueFor( "scepter_pull_rotate_speed" )

	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_enigma/enigma_black_hole_scepter_pull_debuff.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetOrigin() )
		self:AddParticle( nFXIndex, false, false, -1, false, false )
		self.center = Vector( kv.aura_origin_x, kv.aura_origin_y, self:GetParent():GetAbsOrigin().z )

	end

	self:StartIntervalThink(FrameTime())
end

 

function modifier_enigma_black_hole_custom_pull:OnIntervalThink()
	if IsClient() then return end
	if self:GetParent():HasModifier("modifier_enigma_black_hole_custom_debuff") then return end
	local parentPos = self:GetParent():GetOrigin()
	local target = parentPos-self.center
	target.z = 0

	local targetL = target:Length2D()-self.pull_speed*FrameTime()

	local targetN = target:Normalized()
	local deg = math.atan2( targetN.y, targetN.x )
	local targetN = Vector( math.cos(deg+self.rotate_speed*FrameTime()), math.sin(deg+self.rotate_speed*FrameTime()), 0 );
	local newPos = self.center + targetN * targetL
	newPos.z = parentPos.z
	self:GetParent():SetOrigin( newPos )
end

function modifier_enigma_black_hole_custom_pull:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	end
end
