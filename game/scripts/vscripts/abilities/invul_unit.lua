LinkLuaModifier('modifier_invul_unit', 'abilities/invul_unit', LUA_MODIFIER_MOTION_NONE)

invul_unit = class({})

function invul_unit:GetIntrinsicModifierName()
	return "modifier_invul_unit"
end

modifier_invul_unit = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    CheckState      = function(self) return 
    {
    	[MODIFIER_STATE_INVULNERABLE] = true,
    	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    	[MODIFIER_STATE_UNSELECTABLE] = true,
    	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
    	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
    } end,
})