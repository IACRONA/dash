item_thunbrace = class({})
--LinkLuaModifier( "modifier_item_thunbrace", "modifiers/items/modifier_item_thunbrace", LUA_MODIFIER_MOTION_NONE ) -- keep it for future. -- okay. 5/19/2023

--------------------------------------------------------------------------------
function item_thunbrace:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_thunbrace.vpcf", context )
end

--------------------------------------------------------------------------------

function item_thunbrace:GetIntrinsicModifierName()
	return "modifier_item_mjollnir"
end

function item_thunbrace:OnSpellStart()
	if IsServer() then

		local hTarget = self:GetCursorTarget()

        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_mjollnir_static", { duration = self:GetSpecialValueFor( "static_duration" ) } )
        EmitSoundOn( "DOTA_Item.Mjollnir.Activate", hTarget )

	end
end

--------------------------------------------------------------------------------