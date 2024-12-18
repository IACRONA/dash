LinkLuaModifier('modifier_lina_fire_shield', 'abilities/heroes/lina/lina_fire_shield', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_lina_fire_shield_debuff', 'abilities/heroes/lina/lina_fire_shield', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

lina_fire_shield = class({})

function lina_fire_shield:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf", context)
end

function lina_fire_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_lina_fire_shield", {duration = self:GetSpecialValueFor("duration")})
	caster:EmitSound("lina_fire_shield")
end

modifier_lina_fire_shield = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_EVENT_ON_ATTACK_LANDED,
    	MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
    } end,
})

function modifier_lina_fire_shield:OnCreated(event)
	local ability = self:GetAbility()

	self.maxShield = ability:GetSpecialValueFor("shield")

	self.damage = ability:GetSpecialValueFor("damage")
	local parent = self:GetParent()
	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_flame_cloak.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)

	if not IsServer() then return end
	self:SetStackCount(self.maxShield) 
end

function modifier_lina_fire_shield:OnDestroy()
	ParticleManager:DestroyParticle(self.nfx, false)

	if IsClient() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
	local parentPoint = parent:GetAbsOrigin()

	local particle = ParticleManager:CreateParticle("particles/items5_fx/havoc_hammer.vpcf", PATTACH_CUSTOMORIGIN, parent)
	ParticleManager:SetParticleControl(particle, 0, parentPoint)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius,radius,radius))
	ParticleManager:ReleaseParticleIndex(particle)
	EmitSoundOn("Hero_Lina.DragonSlave", parent)

	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parentPoint,
		nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		0,
		FIND_ANY_ORDER,
		false
	)
 
	for _,enemy in ipairs(enemies) do
		local direction = enemy:GetAbsOrigin() - parentPoint
		direction.z = 0
		direction = direction:Normalized()

		enemy:AddNewModifier(parent, ability, "modifier_generic_knockback_lua",
	        {
	            direction_x = direction.x,
	            direction_y = direction.y,
	            distance = ability:GetSpecialValueFor("knoback_distance"),
	            height = 0,	
	            duration = ability:GetSpecialValueFor("knoback_duration"),
	            IsStun = true,
	        }
	    )
		enemy:AddNewModifier(parent, ability, "modifier_lina_fire_shield_debuff", {duration = ability:GetSpecialValueFor("duration_debuff")})
	end
end

function modifier_lina_fire_shield:OnAttackLanded(event)
	if IsClient() then return end

	local parent = self:GetParent()

	if event.target ~= parent then return end
	local attacker = event.attacker

 	if attacker:IsBuilding() then return end
 	local ability = self:GetAbility()

 	ApplyDamage({
 		victim = attacker,
 		attacker = parent,
 		damage = self.damage,
 		damage_type = ability:GetAbilityDamageType(),
 		ability = ability
 	})
end

function modifier_lina_fire_shield:GetModifierIncomingPhysicalDamageConstant(params)
	if IsClient() then 
	  if params.report_max then 
	    return self.maxShield 
	  else 
	    return self:GetStackCount()
	  end 
	end
end

function modifier_lina_fire_shield:GetModifierIncomingSpellDamageConstant(params)
	if IsClient() then 
	  if params.report_max then 
	    return self.maxShield 
	  else 
	    return self:GetStackCount()
	  end 
	end
end



function modifier_lina_fire_shield:GetModifierIncomingDamageConstant(params)
	if not IsServer() then return end

	if self:GetStackCount() == 0 then return end
	if params.damage_type == DAMAGE_TYPE_PHYSICAL or params.damage_type == DAMAGE_TYPE_MAGICAL then 
		if self:GetStackCount() > params.damage then
		    self:SetStackCount(self:GetStackCount() - params.damage)
		    local i = params.damage
		    return -i
		else
		    local i = self:GetStackCount()
		    self:Destroy()
		    return -i
		end
	end
end

modifier_lina_fire_shield_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    } end,
})

function modifier_lina_fire_shield_debuff:OnCreated()
	local ability = self:GetAbility()
	self.moveSpeed = ability:GetSpecialValueFor("slow_move_speed_pct")
end


function modifier_lina_fire_shield_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf"
end


function modifier_lina_fire_shield_debuff:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

function modifier_lina_fire_shield_debuff:StatusEffectPriority()
	return 2
end

function modifier_lina_fire_shield_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.moveSpeed
end