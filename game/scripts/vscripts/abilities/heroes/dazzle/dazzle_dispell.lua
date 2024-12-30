dazzle_dispell = class({})

function dazzle_dispell:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", context)
end
function dazzle_dispell:GetCastRange()
	return self:GetSpecialValueFor("AbilityCastRange")
end
function dazzle_dispell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local modifiers = target:FindAllModifiers() 
	if not self.netTable then 
		self.netTable = CustomNetTables:GetTableValue("abilities_damage", "abilities") 
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
  	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
  	EmitSoundOn("dazzle_dispel_cast", target)
	for _, modifier in pairs(modifiers) do
		if modifier:IsDebuff() then 
			local ability = modifier:GetAbility()
			if ability == nil then break end
			if ability and ability:IsItem() then
				modifier:Destroy() 
				break
			end
			local abilityName = ability and ability:GetName()
			local abilityInTable = self.netTable[abilityName]
			if abilityInTable and abilityInTable.dispell ~= "SPELL_DISPELLABLE_NO" then
				modifier:Destroy()
				break
			end
		end 
	end
end