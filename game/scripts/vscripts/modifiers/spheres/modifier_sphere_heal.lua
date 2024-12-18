modifier_sphere_heal = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    } end,
})

function modifier_sphere_heal:GetModifierHPRegenAmplify_Percentage()
	return SPHERE_HEAL * self:GetStackCount()
end