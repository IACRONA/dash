modifier_item_thunbrace = class({})

------------------------------------------------------------------------------

function modifier_item_thunbrace:IsHidden() 
    return true
end

--------------------------------------------------------------------------------

function modifier_item_thunbrace:IsPurgable()
    return false
end

----------------------------------------

function modifier_item_thunbrace:OnCreated( kv )
    self.damage_block = self:GetAbility():GetSpecialValueFor( "damage_block" )
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
    self.bonus_hp_regen = self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" )
end

--------------------------------------------------------------------------------

function modifier_item_thunbrace:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end

----------------------------------------

function modifier_item_thunbrace:GetModifierMoveSpeedBonus_Special_Boots( params )
    return self.bonus_movement_speed
end

----------------------------------------

function modifier_item_thunbrace:GetModifierBonusStats_Strength( params )
    return self.bonus_strength
end

--------------------------------------------------------------------------------

function modifier_item_thunbrace:GetModifierConstantHealthRegen( params )
    return self.bonus_hp_regen
end

--------------------------------------------------------------------------------

function modifier_item_thunbrace:GetModifierTotal_ConstantBlock( params )
    return self.damage_block
end


