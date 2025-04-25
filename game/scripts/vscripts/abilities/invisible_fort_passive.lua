LinkLuaModifier('modifier_invisible_fort_passive', 'abilities/invisible_fort_passive', LUA_MODIFIER_MOTION_NONE)

invisible_fort_passive = class({})

function invisible_fort_passive:GetIntrinsicModifierName()
	return "modifier_invisible_fort_passive"
end

modifier_invisible_fort_passive = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    } end,
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

function modifier_invisible_fort_passive:GetModifierModelChange()
    return "models/development/invisiblebox.vmdl"
end


function modifier_invisible_fort_passive:GetPriority()
    return  9999
end



 