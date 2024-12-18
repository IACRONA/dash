item_dragonbelt = class({})
LinkLuaModifier( "modifier_item_dragonbelt", "modifiers/items/modifier_item_dragonbelt", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function item_dragonbelt:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/items/dropped_dragonbelt.vpcf", context )
end

--------------------------------------------------------------------------------

function item_dragonbelt:GetIntrinsicModifierName()
	return "modifier_item_dragonbelt"
end

--------------------------------------------------------------------------------

function item_dragonbelt:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_dragonbelt:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end
--------------------------------------------------------------------------------

function item_dragonbelt:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end
