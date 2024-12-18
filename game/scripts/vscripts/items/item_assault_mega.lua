item_assault_mega = class({})
LinkLuaModifier( "modifier_item_assault_mega_aura", "modifiers/items/modifier_item_assault_mega_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_assault_mega_aura_effect", "modifiers/items/modifier_item_assault_mega_aura_effect", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_assault_mega:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_phasma.vpcf", context )
end
--------------------------------------------------------------------------------

function item_assault_mega:GetIntrinsicModifierName()
	return "modifier_item_assault_mega_aura"
end

function item_assault_mega:OnSpellStart()
	if IsServer() then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_blade_mail", { duration = self:GetSpecialValueFor( "duration" ) } )
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_blade_mail_reflect", { duration = self:GetSpecialValueFor( "duration" ) } )
        EmitSoundOn( "DOTA_Item.BladeMail.Activate", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------