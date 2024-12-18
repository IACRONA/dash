modifier_item_magi_booster_effect = class({})

----------------------------------------

function modifier_item_magi_booster_effect:GetTexture()
    return "item_magi_booster"
end

----------------------------------------

function modifier_item_magi_booster_effect:OnCreated( kv )
    self.aura_magic_reduction = self:GetAbility():GetSpecialValueFor( "aura_magic_reduction" )
end

----------------------------------------

function modifier_item_magi_booster_effect:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

----------------------------------------

function modifier_item_magi_booster_effect:GetModifierMagicalResistanceBonus( params )
    return self.aura_magic_reduction
end

----------------------------------------