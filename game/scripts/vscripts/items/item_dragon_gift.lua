item_dragon_gift = class({})
LinkLuaModifier( "modifier_item_dragon_gift", "modifiers/items/modifier_item_dragon_gift", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fish_passive", "modifiers/creatures/modifier_fish_passive", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function item_dragon_gift:GetIntrinsicModifierName()
	return "modifier_item_dragon_gift"
end

--------------------------------------------------------------------------------