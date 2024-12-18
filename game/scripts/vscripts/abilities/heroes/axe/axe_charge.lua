LinkLuaModifier('modifier_axe_charge', 'abilities/heroes/axe/axe_charge', LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier('modifier_axe_charge_debuff', 'abilities/heroes/axe/axe_charge', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_axe_charge_shield', 'abilities/heroes/axe/axe_charge', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_axe_charge_passive_reflect', 'abilities/heroes/axe/axe_charge', LUA_MODIFIER_MOTION_NONE)
  
axe_charge = class({})

function axe_charge:Precache(context)
	PrecacheResource("particle", "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_anim_run_haste.vpcf", context)
end

function axe_charge:CastFilterResultTarget(target)
    if target == self:GetCaster() then
        return UF_FAIL_CUSTOM
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
    end
end

function axe_charge:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "#dota_hud_error_cant_cast_on_self"
    end
end


function axe_charge:GetIntrinsicModifierName()
	return "modifier_axe_charge_passive_reflect"
end

function axe_charge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	caster:EmitSound("axe_charge_cast")
	caster:AddNewModifier(caster, self, "modifier_axe_charge", {target = target:entindex()})
end

modifier_axe_charge = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	GetEffectName 			= function() return "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_anim_run_haste.vpcf" end,
    CheckState      = function(self) return 
    {
    	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    } end,
})

function modifier_axe_charge:OnCreated(data)
	if IsClient() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()

	parent:StartGestureWithPlaybackRate(ACT_DOTA_RUN, 2.5)
	self.target = EntIndexToHScript(data.target)
	self.speed = ability:GetSpecialValueFor("speed")

	if not self:ApplyHorizontalMotionController() then self:Destroy() end
end

function modifier_axe_charge:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()

    parent:InterruptMotionControllers( true )
	parent:FadeGesture(ACT_DOTA_RUN)

    ResolveNPCPositions(parent:GetAbsOrigin(), 128)

    if not parent:IsChanneling() then 
         parent:MoveToTargetToAttack(self.target)
    end
end

function modifier_axe_charge:UpdateHorizontalMotion(me, dt)
	local parent = self:GetParent()
	local point = parent:GetOrigin()
	local targetPoint = self.target:GetOrigin()

	if not self.target:IsAlive() then self:Destroy() end

	if (targetPoint - point):Length2D() < 80 then 
		self:OnCharge()
		return self:Destroy()
	end

	local direction = targetPoint - point
	direction.z = 0
	local target = point + direction:Normalized() * (self.speed * dt)

	parent:SetOrigin(target)
	parent:FaceTowards(targetPoint)
end

function modifier_axe_charge:OnHorizontalMotionInterrupted()
	if IsServer() then self:Destroy() end
end

function modifier_axe_charge:OnCharge() 
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local isCrit = RollPercentage(ability:GetSpecialValueFor("crit_chance"))

	if self.target:GetTeamNumber() ~= parent:GetTeamNumber() then 
		ApplyDamage({
			victim = self.target,
			attacker = parent,
			damage = ability:GetSpecialValueFor("damage") * (isCrit and 2 or 1),
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
		self.target:AddNewModifier(parent, ability, "modifier_axe_charge_debuff", {duration = ability:GetSpecialValueFor("duration")})
		self.target:AddNewModifier(parent, ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
	end
	
	parent:AddNewModifier(parent, ability, "modifier_axe_charge_shield", {duration = ability:GetSpecialValueFor("duration_shield")})
end

modifier_axe_charge_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    } end,
})

function modifier_axe_charge_debuff:OnCreated()
	local ability = self:GetAbility()

	self.tick = 0
	self.slowDuration = ability:GetSpecialValueFor("slow_duration")
	self.slowMoveSpeed = ability:GetSpecialValueFor("slow_move_speed")
	self:StartIntervalThink(1)
end

function modifier_axe_charge_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.tick > self.slowDuration and 0 or self.slowMoveSpeed
end
 
function modifier_axe_charge_debuff:OnIntervalThink()
	self.tick = self.tick + 1
	if IsClient() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local parent = self:GetParent()

	ApplyDamage({
		victim = parent,
		attacker = caster,
		damage = ability:GetSpecialValueFor("damage_debuff"),
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})	
end



function modifier_axe_charge_debuff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

modifier_axe_charge_shield = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
    } end,
})

function modifier_axe_charge_shield:GetAbsorbSpell( params )
	if IsServer() then
		self:PlayEffects( true )
		return 1
	end
end

modifier_axe_charge_shield.reflected_spell = nil
function modifier_axe_charge_shield:GetReflectSpell( params )
	if IsServer() then

		if params.ability==nil or self.reflect_exceptions[params.ability:GetName()] then
			return 0
		end

		self.reflect = true

		if self.reflected_spell~=nil then
			self:GetParent():RemoveAbility( self.reflected_spell:GetAbilityName() )
		end

		local sourceAbility = params.ability
		local selfAbility = self:GetParent():AddAbility( sourceAbility:GetAbilityName() )
		selfAbility.isReflectSpell = true
		selfAbility:SetLevel( sourceAbility:GetLevel() )
		selfAbility:SetStolen( true )
		selfAbility:SetHidden( true )

		self.reflected_spell = selfAbility

		self:GetParent():SetCursorCastTarget( sourceAbility:GetCaster() )
		selfAbility:CastAbility()

		self:PlayEffects( false )
		return 1
	end
end

modifier_axe_charge_shield.reflect_exceptions = {
	["rubick_spell_steal_lua"] = true
}
--------------------------------------------------------------------------------
function modifier_axe_charge_shield:PlayEffects( bBlock )
	local particle_cast = ""
	local sound_cast = ""

	if bBlock then
		particle_cast = "particles/items_fx/immunity_sphere.vpcf"
		sound_cast = "DOTA_Item.LinkensSphere.Activate"
	else
		particle_cast = "particles/items3_fx/lotus_orb_reflect.vpcf"
		sound_cast = "Item.LotusOrb.Activate"
	end

	-- Play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), 
		true 
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetParent() )
end

modifier_axe_charge_passive_reflect = class({
	IsHidden 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE ,
    } end,
})

function modifier_axe_charge_passive_reflect:GetModifierTotalDamageOutgoing_Percentage(event)
  local parent = self:GetParent()
  local attacker = event.attacker

    if attacker == self:GetParent() and  event.inflictor and event.inflictor.isReflectSpell then 
      return self:GetAbility():GetSpecialValueFor("reflect_damage") - 100
    end
end