modifier_sphere_radiance = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
	} end,
})

function modifier_sphere_radiance:OnCreated()
end

function modifier_sphere_radiance:OnIntervalThink()
end