item_necklace = class({})
LinkLuaModifier( "modifier_item_necklace", "modifiers/items/modifier_item_necklace", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function item_necklace:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_necklace.vpcf", context )
end

--------------------------------------------------------------------------------

function item_necklace:GetIntrinsicModifierName()
	return "modifier_item_necklace"
end

--------------------------------------------------------------------------------

function item_necklace:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_necklace:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end
--------------------------------------------------------------------------------

function item_necklace:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end
