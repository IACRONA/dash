item_mantis_sword = class({})
LinkLuaModifier( "modifier_item_mantis_visuals", "modifiers/items/modifier_item_mantis_visuals", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_mantis_sword:Precache( context )
	PrecacheResource( "particle", "particles/items/mantis_buff.vpcf", context )
end

function item_mantis_sword:GetIntrinsicModifierName()
	return "modifier_item_butterfly"
end

--------------------------------------------------------------------------------

function item_mantis_sword:OnSpellStart()
	if IsServer() then		
		EmitSoundOn( "DOTA_Item.Butterfly", self:GetCaster() )

		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_butterfly_extra", {duration = 5} )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_mantis_visuals",  {duration = 5} )
	end
end
--------------------------------------------------------------------------------

