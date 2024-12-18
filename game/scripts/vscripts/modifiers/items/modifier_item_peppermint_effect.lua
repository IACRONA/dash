modifier_item_peppermint_effect = class({})

------------------------------------------------------------------------------

function modifier_item_peppermint_effect:GetTexture()
    return "item_peppermint"
end

------------------------------------------------------------------------------

function modifier_item_peppermint_effect:IsPurgable()
    return false
end

------------------------------------------------------------------------------

function modifier_item_peppermint_effect:OnCreated( kv )
    self.aura_bonus_magic_resist = self:GetAbility():GetSpecialValueFor( "aura_bonus_magic_resist" )
end

--------------------------------------------------------------------------------

function modifier_item_peppermint_effect:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_item_peppermint_effect:GetModifierMagicalResistanceBonus( params )
    return self.aura_bonus_magic_resist
end

--------------------------------------------------------------------------------