item_amphisbaena_bow = class({})
LinkLuaModifier( "modifier_item_amphisbaena_bow", "modifiers/items/modifier_item_amphisbaena_bow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_amphisbaena_bow_debuff", "modifiers/items/modifier_item_amphisbaena_bow_debuff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_amphisbaena_bow:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_amphisbaena.vpcf", context )
	PrecacheResource( "particle", "particles/econ/events/fall_2022/attack2/attack2_modifier_fall2022_base.vpcf", context )
end
--------------------------------------------------------------------------------

function item_amphisbaena_bow:GetIntrinsicModifierName()
	if not self:GetCaster():FindModifierByName("modifier_item_amphisbaena_bow") then -- dirty method, but we do what we must // 11/08/2021
        EmitSoundOn( "DOTA_Item.Swift_Blink.Activate", self:GetCaster() )
    end

	return "modifier_item_amphisbaena_bow"
end

--------------------------------------------------------------------------------
