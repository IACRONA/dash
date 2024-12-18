item_jade_gem = class({})
LinkLuaModifier( "modifier_item_jade_gem", "modifiers/items/modifier_item_jade_gem", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_jade_gem_debuff", "modifiers/items/modifier_item_jade_gem_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_jade_gem_consumed", "modifiers/items/modifier_item_jade_gem_consumed", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_jade_gem:Precache( context )
	PrecacheResource( "model", "models/gems/dummy_gem.vmdl", context )
	PrecacheResource( "particle", "particles/gems/dropped_gem_jade.vpcf", context )
	PrecacheResource( "particle", "particles/gems/gem_jade_debuff.vpcf", context )
end

function item_jade_gem:OnSpellStart()
	if IsServer() then

		local hTarget = self:GetCursorTarget()

		if (not hTarget:FindModifierByName("modifier_item_jade_gem_consumed")) then
            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_jade_gem_consumed", { duration = -1 } )
            EmitSoundOn( "Item.DropGemShop", hTarget )
            self:SpendCharge(0.1)
        else
        	return
        end
	end
end

--------------------------------------------------------------------------------

function item_jade_gem:GetIntrinsicModifierName()
	return "modifier_item_jade_gem"
end

--------------------------------------------------------------------------------

function item_jade_gem:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_jade_gem:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end

--------------------------------------------------------------------------------

function item_jade_gem:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end