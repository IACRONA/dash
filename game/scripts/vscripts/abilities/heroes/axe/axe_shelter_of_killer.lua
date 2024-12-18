LinkLuaModifier('modifier_axe_shelter_of_killer', 'abilities/heroes/axe/axe_shelter_of_killer', LUA_MODIFIER_MOTION_NONE)

axe_shelter_of_killer = class({})

function axe_shelter_of_killer:GetIntrinsicModifierName()
	return "modifier_axe_shelter_of_killer"
end

modifier_axe_shelter_of_killer = class({
	IsHidden 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    } end,
})

function modifier_axe_shelter_of_killer:OnCreated()
	self.levelRequired = self:GetAbility():GetSpecialValueFor("level_required")
end

function modifier_axe_shelter_of_killer:GetModifierOverrideAbilitySpecial( params )
	local ability = params.ability
	if self:GetParent() == nil or ability == nil or (self:GetParent():GetLevel() or 0) < (self.levelRequired or 0) then return 0 end
 	if ability:GetName() == "axe_counter_helix" then return 1 end
 end

function modifier_axe_shelter_of_killer:GetModifierOverrideAbilitySpecialValue( params )
	local ability = params.ability
	local specialValue = params.ability_special_value
	local specialLevel = params.ability_special_level
	local baseValue = ability:GetLevelSpecialValueNoOverride( specialValue, specialLevel )
	local ability = self:GetAbility()

	if specialValue == "damage" then 
		local parent = self:GetParent()
		if parent.spellAmpPure then 
	   	 	local multiple = (parent.spellAmpPure:GetStackCount()/100 + 1)
	    	return (baseValue + ability:GetSpecialValueFor("damage")) * multiple
		else
	    	return baseValue + ability:GetSpecialValueFor("damage")
		end
	elseif specialValue == "radius" then 
	    return baseValue + ability:GetSpecialValueFor("radius")
	elseif specialValue == "trigger_attacks" then 
	   	return baseValue + ability:GetSpecialValueFor("trigger_attacks")
	else
	    return baseValue
	end
end
