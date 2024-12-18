item_sapphire_gem = class({})
LinkLuaModifier( "modifier_item_sapphire_gem", "modifiers/items/modifier_item_sapphire_gem", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_sapphire_gem_debuff", "modifiers/items/modifier_item_sapphire_gem_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_sapphire_gem_consumed", "modifiers/items/modifier_item_sapphire_gem_consumed", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_sapphire_gem:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/gems/dropped_gem_sapphire.vpcf", context )
	PrecacheResource( "particle", "particles/gems/gem_sapphire_debuff.vpcf", context )

end

function item_sapphire_gem:OnSpellStart()
	if IsServer() then

		local hTarget = self:GetCursorTarget()

		if not hTarget:FindModifierByName("modifier_item_sapphire_gem_consumed") then
            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_sapphire_gem_consumed", { duration = -1 } )
            EmitSoundOn( "Item.DropGemShop", hTarget )
            self:SpendCharge(0.1)
        end
	end
end

--------------------------------------------------------------------------------

function item_sapphire_gem:GetIntrinsicModifierName()
	return "modifier_item_sapphire_gem"
end

--------------------------------------------------------------------------------

function item_sapphire_gem:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_sapphire_gem:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end

--------------------------------------------------------------------------------

function item_sapphire_gem:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end