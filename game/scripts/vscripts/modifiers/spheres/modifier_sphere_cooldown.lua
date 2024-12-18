modifier_sphere_cooldown = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    } end,
})

function modifier_sphere_cooldown:GetModifierPercentageCooldown()
	return SPHERE_COOLDOWN * self:GetStackCount()
end