modifier_sphere_armor = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
	 	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	} end,
})

function modifier_sphere_armor:GetModifierPhysicalArmorBonus()
	return SPHERE_SHIELD_ARMOR * self:GetStackCount()
end