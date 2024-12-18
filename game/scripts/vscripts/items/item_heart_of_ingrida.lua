item_heart_of_ingrida = class({})
LinkLuaModifier( "modifier_item_heart_second", "modifiers/items/modifier_item_heart_second", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_heart_of_ingrida:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_heart.vpcf", context )
end
--------------------------------------------------------------------------------

function item_heart_of_ingrida:GetIntrinsicModifierName()
	return "modifier_item_heart_second"
end

function item_heart_of_ingrida:OnSpellStart()
	if IsServer() then

		local duration = self:GetSpecialValueFor( "barrier_duration" )
		local caster = self:GetCaster()

		caster:AddNewModifier( caster, self, "modifier_item_eternal_shroud_barrier", { duration = duration} )
		--caster:RemoveModifierByName( "modifier_item_pipe_aura" )
        EmitSoundOn( "DOTA_Item.HotD.Activate", caster )


        self.hEffects = ParticleManager:CreateParticle( "particles/econ/events/ti9/shovel/shovel_baby_roshan_spawn_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.hEffects, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )

        caster:SetContextThink( "KillEffects", function() return self:KillEffects( self.hEffects ) end, 1 )
	end
end

function item_heart_of_ingrida:KillEffects( hEffects )
	if hEffects ~= nil then
		ParticleManager:DestroyParticle( self.hEffects, false )
	end
end

--------------------------------------------------------------------------------