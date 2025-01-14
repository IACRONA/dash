LinkLuaModifier('modifier_lina_fire_bomb', 'abilities/heroes/lina/lina_fire_bomb', LUA_MODIFIER_MOTION_NONE)

lina_fire_bomb = class({})

function lina_fire_bomb:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", context)
end

function lina_fire_bomb:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) or target:TriggerSpellReflect(self) then 
		return 
	end

	target:AddNewModifier(caster, self, "modifier_lina_fire_bomb", {duration = self:GetSpecialValueFor("duration")})
	target:EmitSound("lina_fire_bomb")
end

modifier_lina_fire_bomb = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	GetEffectName 			= function(self) return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf" end,
})

function modifier_lina_fire_bomb:OnCreated()
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
	self.crit2x = ability:GetSpecialValueFor("crit_2x")
	self.radius = ability:GetSpecialValueFor("radius")
	self.damageExplode = ability:GetSpecialValueFor("damage_explode")
	if IsClient() then return end
	self.damageType = ability:GetAbilityDamageType()
	self:StartIntervalThink(1)
end

function modifier_lina_fire_bomb:DestroyOnExpire()
	if IsClient() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		parent:GetAbsOrigin(),
		nil,  self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		0,
		FIND_ANY_ORDER,
		false
	)
	local damageTable = {
		attacker = caster,
		damage = self.damageExplode,
		damage_type = self.damageType,
		ability = ability
	}

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))

	for _,enemy in ipairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end
end

function modifier_lina_fire_bomb:OnIntervalThink()
	if IsClient() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local hasCrit = RollPercentage(self.crit2x + (caster.bonusLinaCrit or 0))
	local damage = hasCrit and self.damage * 2 or self.damage

	if hasCrit then 
		local pyrablast = caster:FindAbilityByName("lina_pyrablast")
		if pyrablast then 
			pyrablast:ProcPyromanic()
		end
	end

	ApplyDamage({
		victim = parent,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self.damageType,
	})
end

