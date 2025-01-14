LinkLuaModifier('modifier_enigma_house_bolt_debuff', 'abilities/heroes/enigma/enigma_house_bolt', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enigma_house_bolt_fear', 'abilities/heroes/enigma/enigma_house_bolt', LUA_MODIFIER_MOTION_NONE)

enigma_house_bolt = class({})

function enigma_house_bolt:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf", context)
end

function enigma_house_bolt:OnSpellStart()
	local caster = self:GetCaster()

	self.target = self:GetCursorTarget()
	self.soundName = "house_bolt_cast"
	EmitSoundOn(self.soundName, caster)
	self.animationTimer = Timers:CreateTimer(self:GetChannelTime()-0.3, function()
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end)
end

function enigma_house_bolt:OnChannelFinish(interrupted)
	local caster = self:GetCaster()
	if self.animationTimer then  
		if interrupted then caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1) end
		Timers:RemoveTimer(self.animationTimer) 
	end 
	if interrupted then
		return StopSoundOn(self.soundName, caster)
	end
 	ProjectileManager:CreateTrackingProjectile({
 		EffectName = "particles/units/heroes/hero_necrolyte/necrolyte_death_seeker_enemy.vpcf",
 		Ability = self,
 		Source = caster,
 		Target = self.target,
 		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
 	})
end

function enigma_house_bolt:OnProjectileHit_ExtraData(target, _,data)
	if not target then return end
	local caster = self:GetCaster()
	local random = RandomInt(1,100)
	local crtiMultiple = 1
	local crit = {
		[2] = self:GetSpecialValueFor("crit_2"),
		[3] = self:GetSpecialValueFor("crit_3"),
		[5] = self:GetSpecialValueFor("crit_5"),
	}

	for crit,chance in pairs(crit) do
		if random <= chance and crtiMultiple < crit then 
			crtiMultiple = crit
		end		 
	end

	if self.target:TriggerSpellAbsorb(self) or self.target:TriggerSpellReflect(self) then return end

	local damage = self:GetSpecialValueFor("damage") * crtiMultiple

	EmitSoundOn("ice_spike_target", target)
	ApplyDamage({
		victim = target,
		attacker = caster, 
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self
	})	
	target:AddNewModifier(caster, self, "modifier_enigma_house_bolt_debuff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_enigma_house_bolt_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {

    } end,
})

function modifier_enigma_house_bolt_debuff:OnCreated()
	if IsClient() then return end
	local ability = self:GetAbility()
	self.damageTick = ability:GetSpecialValueFor("damage_tick")
	self.durationFear = ability:GetSpecialValueFor("duration_fear")

	self:StartIntervalThink(1)
end

function modifier_enigma_house_bolt_debuff:OnIntervalThink()
	if IsClient() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	ApplyDamage({
		victim = parent,
		attacker = caster, 
		damage = self.damageTick,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})
end

function modifier_enigma_house_bolt_debuff:GetTexture()
	return "enigma/enigma_house_bolt_debuff"
end

function modifier_enigma_house_bolt_debuff:OnDestroy()
	if IsClient() then return end
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil, ability:GetSpecialValueFor("radius"),
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			0,
			FIND_ANY_ORDER,
			false
		)
		local point = parent:GetAbsOrigin()

		for _,enemy in ipairs(enemies) do	 	 
			if parent == enemy then point = caster:GetAbsOrigin() end
     		local direction = (enemy:GetAbsOrigin() - point)  

			enemy:AddNewModifier(caster, ability, "modifier_enigma_house_bolt_fear", {duration = self.durationFear, xDirection = direction.x, yDirection = direction.y})
 		end 
end

modifier_enigma_house_bolt_fear = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
    CheckState        = function(self) return 
    {
    	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    } end,
})

function modifier_enigma_house_bolt_fear:OnCreated(data)
	if IsClient() then return end
	self.direction = Vector(data.xDirection, data.yDirection, 0)
	self:OnIntervalThink()
	self:StartIntervalThink(0.3)
end

function modifier_enigma_house_bolt_fear:OnIntervalThink(data)
	if IsClient() then return end
	local parent = self:GetParent()

	parent:MoveToPosition(parent:GetAbsOrigin() + self.direction:Normalized() * 300)
end

function modifier_enigma_house_bolt_fear:OnDestroy(data)
	if IsClient() then return end
	self:GetParent():Stop()
end

function modifier_enigma_house_bolt_fear:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf"
end

function modifier_enigma_house_bolt_fear:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
