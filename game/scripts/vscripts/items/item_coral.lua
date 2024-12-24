---@diagnostic disable: undefined-global
item_coral = class({})
LinkLuaModifier( "modifier_item_coral_consumed", "modifiers/items/modifier_item_coral_consumed", LUA_MODIFIER_MOTION_NONE )

function item_coral:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/gameplay/item_coral.vpcf", context )
end

--------------------------------------------------------------------------------
function item_coral:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hCharges = self:GetCurrentCharges()
 
		local particleImpact = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/red_zuus_arc_lightning_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(
			particleImpact,
			1,
			hCaster,
			PATTACH_ABSORIGIN_FOLLOW,
			"",
			hCaster:GetAbsOrigin(),
			true
		)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/red_zuus_arc_lightning_head.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(
			particle,
			0,
			hCaster:GetAbsOrigin()
		)
		ParticleManager:SetParticleControl(
			particle,
			1,
			hCaster:GetAbsOrigin()
		)
		local particleHead = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(
			particleHead,
			1,
			target,
			PATTACH_ABSORIGIN_FOLLOW,
			"",
			hCaster:GetAbsOrigin(),
			true
		)

		for i = 1, hCharges do

				local bCoralBuff = hCaster:FindModifierByName( "modifier_item_coral_consumed" )

				if bCoralBuff == nil then
					bCoralBuff = hCaster:AddNewModifier( self:GetParent(), self, "modifier_item_coral_consumed", { duration = -1} )
				end

				if bCoralBuff ~= nil then
					bCoralBuff:SetStackCount( bCoralBuff:GetStackCount() + 1 )
				end

			-- self:SpendCharge(0.1)
		end

		EmitSoundOnClient( "soundboard.eto_sochno", hCaster:GetPlayerOwner() )

	end
end
--------------------------------------------------------------------------------