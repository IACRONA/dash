enigma_void_strike = class({})

function enigma_void_strike:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", context)
end

function enigma_void_strike:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function enigma_void_strike:OnSpellStart()
	local caster = self:GetCaster()

	self.target = self:GetCursorTarget()
	if self.target:TriggerSpellAbsorb(self) or self.target:TriggerSpellReflect(self) then 
		return 
	end
	self.soundName = "void_strike_cast"
	EmitSoundOn(self.soundName, caster)
	self.animationTimer = Timers:CreateTimer(self:GetChannelTime()-0.3, function()
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end)
end

function enigma_void_strike:OnChannelFinish(interrupted)
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
    
	if interrupted then
		self:EndCooldown()
	end
	if self.animationTimer then  
		if interrupted then caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1) end
		Timers:RemoveTimer(self.animationTimer) 
	end 
	if interrupted then return StopSoundOn(self.soundName, caster) end
	local radius = self:GetSpecialValueFor("radius")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf",PATTACH_CUSTOMORIGIN,caster)
    ParticleManager:SetParticleControl(particle,0,point)
    ParticleManager:SetParticleControl(particle,1,Vector(radius,radius,radius))
    ParticleManager:ReleaseParticleIndex(particle)

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		point,
		nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		0,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in ipairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster, 
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})		 	 

		enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("duration")})
	end 	
end
