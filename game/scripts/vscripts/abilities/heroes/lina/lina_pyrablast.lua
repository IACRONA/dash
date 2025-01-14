LinkLuaModifier('modifier_lina_pyrablast', 'abilities/heroes/lina/lina_pyrablast', LUA_MODIFIER_MOTION_NONE)

lina_pyrablast = class({})

function lina_pyrablast:Precache(context)
	PrecacheResource("particle", "particles/acrona/lina/lina_pyrablast.vpcf", context)
end

function lina_pyrablast:GetBehavior()
	local caster = self:GetCaster()

	if caster.CastPyrablast then 
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else 
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
	end
end

 
function lina_pyrablast:GetChannelTime()
	return self:GetCaster().CastPyrablast and 0 or self:GetSpecialValueFor("channel_time")
end

function lina_pyrablast:OnSpellStart()
	local caster = self:GetCaster()

	self.target = self:GetCursorTarget()

	if caster.CastPyrablast then 
		self:CastSpell(true)

		Timers:CreateTimer(0.01, function()
			caster:RemoveModifierByName("modifier_lina_pyrablast")
		end)  
	end

	if self:GetChannelTime() ~= 0 then 
		self.soundName = "lina_pyrablast"
		self.animationTimer = Timers:CreateTimer(self:GetChannelTime()-0.3, function()
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
		end)
	else 
		self.soundName = "lina_pyrablast_fast_cast"
		 
	end

	EmitSoundOn(self.soundName, caster)
end

function lina_pyrablast:ProcPyromanic()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_lina_pyrablast", {duration = self:GetSpecialValueFor("buff_duration")})
end

function lina_pyrablast:OnChannelFinish(interrupted)
	local caster = self:GetCaster()
	if self.animationTimer then  
		if interrupted then caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1) end
		Timers:RemoveTimer(self.animationTimer) 
		self.animationTimer = nil
	end 
	if interrupted then return StopSoundOn(self.soundName, caster)  end
	self:CastSpell(false)
end

function lina_pyrablast:CastSpell(isFast)
	local caster = self:GetCaster()
 	ProjectileManager:CreateTrackingProjectile({
 		EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf",
 		Ability = self,
 		Source = caster,
 		Target = self.target,
 		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
 		ExtraData = {
 			isFast = isFast and 1 or 0
 		},
 	})
end

function lina_pyrablast:OnProjectileHit_ExtraData(target, _, data)
	if not target then return end
	local caster = self:GetCaster()
	local crtiMultiple = 1
	local crit = {
		[2] = self:GetSpecialValueFor("crit_2x"),
		[3] = self:GetSpecialValueFor("crit_3x"),
	}

	for crit,chance in pairs(crit) do
		if RollPercentage(chance + (caster.bonusLinaCrit or 0)) then 
			crtiMultiple = crit
		end		 
	end

	local damage = self:GetSpecialValueFor("damage") * crtiMultiple

	if crtiMultiple > 1 then 
		self:ProcPyromanic()
	end
	if self.target:TriggerSpellAbsorb(self) or self.target:TriggerSpellReflect(self) then return end
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	})

	local sound = data.isFast == 1 and "lina_pyrablast_fast_hit" or "lina_pyrablast_hit"
	EmitSoundOn(sound, target)
end

modifier_lina_pyrablast = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
})

function modifier_lina_pyrablast:OnCreated()

	local parent = self:GetParent()
	if IsServer() then parent:EmitSound("lina_pyramanican") end
	parent.CastPyrablast = true
end

function modifier_lina_pyrablast:OnDestroy()
	local parent = self:GetParent()
	parent.CastPyrablast = false
end

function modifier_lina_pyrablast:GetTexture()
	return "lina/lina_pyromaniac"
end