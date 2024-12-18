item_ice_frog_combined = class({})
LinkLuaModifier( "modifier_item_ice_frog_buff", "modifiers/items/modifier_item_ice_frog_buff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function item_ice_frog_combined:Precache( context )
	PrecacheResource( "model", "models/props_gameplay/cold_frog.vmdl", context )
	PrecacheResource( "particle", "particles/generic_gameplay/dropped_aegis.vpcf", context )
end

function item_ice_frog_combined:OnSpellStart()
	if IsServer() then

		local hTarget = self:GetCursorTarget()

		 EmitSoundOn( "Item.DropGemWorld", hTarget )

		if not hTarget:FindModifierByName("modifier_item_ice_frog_buff") then
            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_ice_frog_buff", { duration = -1 } )

            self:SpendCharge(0.1)
        end
	end
end

--------------------------------------------------------------------------------

function item_ice_frog_combined:GetIntrinsicModifierName()
	return "modifier_item_ice_frog_buff"
end

--------------------------------------------------------------------------------