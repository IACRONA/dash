item_radical_sword = class({})
LinkLuaModifier( "modifier_item_radical_sword", "modifiers/items/modifier_item_radical_sword", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_radical_sword_debuff", "modifiers/items/modifier_item_radical_sword_debuff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_radical_sword:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_radical_sword.vpcf", context )
	PrecacheResource( "particle", "particles/heroes/chaos_knight_chain_jump_explode.vpcf", context )
end
--------------------------------------------------------------------------------

function item_radical_sword:GetIntrinsicModifierName()
	if not self:GetCaster():FindModifierByName("modifier_item_radical_sword") then
        EmitSoundOn( "DOTA_Item.Swift_Blink.Activate", self:GetCaster() )
    end
	
	return "modifier_item_radical_sword"
end
--------------------------------------------------------------------------------
