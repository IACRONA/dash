modifier_item_peppermint = class({})

------------------------------------------------------------------------------

function modifier_item_peppermint:IsHidden() 
    return true
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:OnCreated( kv )
    self.bonus_magic_resist = self:GetAbility():GetSpecialValueFor( "bonus_magic_resist" )
    self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:IsAura()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:GetModifierAura()
    return  "modifier_item_peppermint_effect"
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:GetAuraRadius()
    return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_item_peppermint:GetModifierMagicalResistanceBonus( params )
    return self.bonus_magic_resist
end

function modifier_item_peppermint:GetModifierBonusStats_Strength( params )
    return self.bonus_strength
end

--------------------------------------------------------------------------------