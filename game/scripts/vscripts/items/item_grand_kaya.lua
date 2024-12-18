item_grand_kaya = class({})
LinkLuaModifier( "modifier_item_grand_kaya_buff", "modifiers/items/modifier_item_grand_kaya_buff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_grand_kaya:GetIntrinsicModifierName()
	return "modifier_item_grand_kaya_buff"
end
--------------------------------------------------------------------------------