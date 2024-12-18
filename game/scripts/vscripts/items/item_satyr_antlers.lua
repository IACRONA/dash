item_satyr_antlers = class({})
LinkLuaModifier( "modifier_item_satyr_antlers", "modifiers/modifier_item_satyr_antlers", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_satyr_antlers:GetIntrinsicModifierName()
	return "modifier_item_satyr_antlers"
end

--------------------------------------------------------------------------------

function item_satyr_antlers:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_satyr_antlers:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end

--------------------------------------------------------------------------------

function item_satyr_antlers:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end
