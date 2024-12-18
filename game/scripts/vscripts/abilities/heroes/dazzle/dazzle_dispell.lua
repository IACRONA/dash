dazzle_dispell = class({})

function dazzle_dispell:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", context)
end

function dazzle_dispell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local modifiers = target:FindAllModifiers() 
	local index = #modifiers
	if not self.netTable then 
		self.netTable = CustomNetTables:GetTableValue("abilities_damage", "abilities") 
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
  	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
  	EmitSoundOn("dazzle_dispel_cast", target)
	while index ~= 0 do 
		local modifier = modifiers[index]
		index = index - 1
		if modifier:IsDebuff() then 
			local ability = modifier:GetAbility()
			if ability:IsItem() then return modifier:Destroy() end
			local abilityInTable = self.netTable[ability:GetName()]

			if (abilityInTable and abilityInTable.dispell ~= "SPELL_DISPELLABLE_NO") then 
				return	modifier:Destroy()
			end
		end
	end
end