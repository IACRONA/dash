enigma_portal = class({})

function enigma_portal:Precache(context)
	PrecacheResource("particle", "particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_outer_swirl.vpcf", context)
	PrecacheResource("particle", "particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf", context)
end

function enigma_portal:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	if not caster:HasScepter() then return end
	self.portal = point
	self.vision = AddFOWViewer(caster:GetTeamNumber(), point, self:GetSpecialValueFor("vision_radius"), 999999, false)
	if not caster:HasAbility("enigma_portal_teleport") then caster:AddAbility("enigma_portal_teleport"):SetLevel(1) end
	EmitSoundOn("portal_cast", caster)

    self.particle = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_outer_swirl.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(self.particle,0,point)

	caster:SwapAbilities("enigma_portal_teleport", "enigma_portal", true, false)

	self.timer = Timers:CreateTimer(self:GetSpecialValueFor("duration"), function() 
		ParticleManager:DestroyParticle(self.particle, false)
		RemoveFOWViewer(caster:GetTeamNumber(), self.vision)
		caster:SwapAbilities("enigma_portal", "enigma_portal_teleport", true, false)
		EmitSoundOn("portal_teleport_cast", caster)
	end)
end

enigma_portal_teleport = class({})

function enigma_portal_teleport:OnSpellStart()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("enigma_portal")
	local difference = (caster:GetAbsOrigin() - ability.portal)
	local distance = difference:Length()

	if distance <= ability:GetSpecialValueFor("distance") then 
		Timers:RemoveTimer(ability.timer)
		local particle = ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		FindClearSpaceForUnit(caster, ability.portal, true)
		ParticleManager:DestroyParticle(ability.particle, false)
		RemoveFOWViewer(caster:GetTeamNumber(), ability.vision)
		caster:SwapAbilities("enigma_portal", "enigma_portal_teleport", true, false)
		EmitSoundOn("portal_teleport_cast", caster)
	else 
		CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "CreateIngameErrorMessage", {message="#dota_enigma_error_distance"})
	end
end