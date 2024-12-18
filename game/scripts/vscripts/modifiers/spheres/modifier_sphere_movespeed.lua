modifier_sphere_movespeed = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    } end,
})

function modifier_sphere_movespeed:GetModifierMoveSpeedBonus_Constant()
	return SPHERE_MOVESPEED * self:GetStackCount()
end