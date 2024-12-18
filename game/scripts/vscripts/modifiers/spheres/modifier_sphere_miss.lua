modifier_sphere_miss = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
	 	MODIFIER_PROPERTY_EVASION_CONSTANT,
	} end,
})

function modifier_sphere_miss:GetModifierEvasion_Constant()
	return SPHERE_MISS * self:GetStackCount()
end