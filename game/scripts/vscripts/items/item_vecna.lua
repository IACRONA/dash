item_vecna = class({})
LinkLuaModifier( "modifier_item_bloodstone_custom", "modifiers/items/modifier_item_bloodstone_custom", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_vecna:Precache( context )
	--
end

function item_vecna:GetIntrinsicModifierName()
	return "modifier_item_bloodstone_custom"
end

--------------------------------------------------------------------------------

function item_vecna:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_bloodstone_active", {duration = self:GetSpecialValueFor( "buff_duration" )} ) -- visual only - you know it doesn't work :P
	end
end
--------------------------------------------------------------------------------

