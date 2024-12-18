modifier_sphere_magic_resistance = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
	 	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	} end,
})

function modifier_sphere_magic_resistance:GetModifierMagicalResistanceBonus()
	return SPHERE_SHIELD_MAGICAL_RESISTANCE * self:GetStackCount()
end