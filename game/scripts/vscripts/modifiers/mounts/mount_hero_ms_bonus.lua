mount_hero_ms_bonus = class({})

----------------------------------------------------------------------------------
function mount_hero_ms_bonus:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function mount_hero_ms_bonus:IsPurgable()
	return false
end



function mount_hero_ms_bonus:OnCreated( kv )
	self.movementSpeedBonus = 250
end
function DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function mount_hero_ms_bonus:GetModifierMoveSpeedBonus_Constant()
	return self.movementSpeedBonus
end





