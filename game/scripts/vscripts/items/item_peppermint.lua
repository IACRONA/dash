item_peppermint = class({})
LinkLuaModifier( "modifier_item_peppermint", "modifiers/items/modifier_item_peppermint", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_peppermint_effect", "modifiers/items/modifier_item_peppermint_effect", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function item_peppermint:GetIntrinsicModifierName()
	return "modifier_item_peppermint"
end

--------------------------------------------------------------------------------