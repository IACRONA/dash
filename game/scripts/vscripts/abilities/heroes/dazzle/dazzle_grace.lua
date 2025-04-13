LinkLuaModifier('modifier_dazzle_grace', 'abilities/heroes/dazzle/dazzle_grace', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_dazzle_life_shield', 'abilities/heroes/dazzle/dazzle_life_shield', LUA_MODIFIER_MOTION_NONE)

dazzle_grace = class({})

 

function dazzle_grace:Precache(context)
	PrecacheResource("particle", "particles/econ/items/wisp/calavera/io_calavera_attack.vpcf", context)
end

 
function dazzle_grace:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local casterPoint = caster:GetOrigin()

 	local speed = self:GetSpecialValueFor("speed")
 	local delay = self:GetSpecialValueFor("delay")
 	local times = self:GetSpecialValueFor("times")
  	local currentTimes = 0
  	EmitSoundOn("grace_cast", caster)
	if target:GetTeam() ~= caster:GetTeam() then 
		if target:TriggerSpellAbsorb(self) or target:TriggerSpellReflect(self) then return end
	end
  	Timers:CreateTimer(function()
  		if currentTimes >= 3 then return end
		ProjectileManager:CreateTrackingProjectile({
			EffectName = "particles/econ/items/wisp/calavera/io_calavera_attack.vpcf",
			Ability = self,
			Source = caster,
			Target = target,
			iMoveSpeed = speed,
		})
		currentTimes = currentTimes + 1
		return delay
  	end)
end


function dazzle_grace:OnProjectileHit_ExtraData(target, _, extraData)
	if not target then 
		return 
	end
	local caster = self:GetCaster()
	if target:GetTeam() == caster:GetTeam() then
		local heal = caster:HasScepter() and target:GetMaxHealth() * (self:GetSpecialValueFor("heal_pct_scepter")/100) or self:GetSpecialValueFor("heal")
		target:Heal(heal, self)
    	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)
		if RollPercentage(self:GetSpecialValueFor("chance_heal")) then 
			target:AddNewModifier(caster, self, "modifier_dazzle_grace", {duration=self:GetSpecialValueFor("buff_duration")})
		end
		if RollPercentage(self:GetSpecialValueFor("chance_shield")) then 
			local ability = caster:FindAbilityByName("dazzle_life_shield")
			if ability then 
				target:AddNewModifier(caster, ability, "modifier_dazzle_life_shield", {duration=self:GetSpecialValueFor("shield_duration"), isLightVersion=true})
			end
		end
	else
		local dmg = self:GetSpecialValueFor("heal")
		ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type= DAMAGE_TYPE_MAGICAL})
	end

    
end

modifier_dazzle_grace = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsBuff                  = function(self) return true end,
})

function modifier_dazzle_grace:OnCreated()
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("tick")
	self.heal = ability:GetSpecialValueFor("buff_heal_pct")/100
	self:OnIntervalThink()
	self:StartIntervalThink(tick)
end

function modifier_dazzle_grace:OnIntervalThink()
	if IsClient() then return end
	local parent = self:GetParent()
	local heal = parent:GetMaxHealth() * self.heal
	parent:Heal(heal, self)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, nil)
end