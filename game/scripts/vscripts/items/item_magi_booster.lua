item_magi_booster = class({})
LinkLuaModifier( "modifier_item_magi_booster", "modifiers/items/modifier_item_magi_booster", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_magi_booster_effect", "modifiers/items/modifier_item_magi_booster_effect", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_magi_booster:GetIntrinsicModifierName()
	return "modifier_item_magi_booster"
end

--------------------------------------------------------------------------------