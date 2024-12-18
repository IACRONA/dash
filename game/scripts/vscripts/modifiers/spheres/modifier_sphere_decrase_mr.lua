LinkLuaModifier('modifier_sphere_decrase_mr_debuff', 'modifiers/spheres/modifier_sphere_decrase_mr', LUA_MODIFIER_MOTION_NONE)

modifier_sphere_decrase_mr = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    } end,
})

function modifier_sphere_decrase_mr:GetModifierTotalDamageOutgoing_Percentage(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local ability = event.inflictor

	if attacker == self:GetParent() then 
 		local modif = parent:AddNewModifier(parent, nil, "modifier_sphere_decrase_mr_debuff", {duration = 1})
 		modif:SetStackCount(self:GetStackCount())
	end
end

modifier_sphere_decrase_mr_debuff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
	 	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    } end,
})

function modifier_sphere_decrase_mr_debuff:GetModifierMagicalResistanceBonus()
	return SPHERE_SHIELD_DECRASE_MAGIC_RESIST * self:GetStackCount()
end