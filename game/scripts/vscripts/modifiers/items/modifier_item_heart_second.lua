modifier_item_heart_second = class({})
--------------------------------------------------------------------------------
function modifier_item_heart_second:GetTexture()
    return "item_heart_of_ingrida"
end

function modifier_item_heart_second:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_heart_second:IsHidden()
    return false
end
--------------------------------------------------------------------------------

function modifier_item_heart_second:IsPurgable()
    return true
end
--------------------------------------------------------------------------------

function modifier_item_heart_second:OnCreated( kv )
    local ability = self:GetAbility()
    if ability then
        self.bonus_strength = ability:GetSpecialValueFor("bonus_strength")
        self.bonus_health = ability:GetSpecialValueFor("bonus_health")
        self.health_regen_pct = ability:GetSpecialValueFor("health_regen_pct")
        self.bonus_spell_resist = ability:GetSpecialValueFor("bonus_spell_resist")
        self.tooltip_resist = ability:GetSpecialValueFor("tooltip_resist")
    end
end

--------------------------------------------------------------------------------

function modifier_item_heart_second:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_item_heart_second:GetModifierHealthBonus( params )
    return self.bonus_health
end

function modifier_item_heart_second:GetModifierBonusStats_Strength( params )
    return self.bonus_strength
end

function modifier_item_heart_second:GetModifierHealthRegenPercentage( params )
    return self.health_regen_pct
end

function modifier_item_heart_second:GetModifierMagicalResistanceBonus( params )
    return self.bonus_spell_resist
end

function modifier_item_heart_second:OnTooltip( params )
    return self.tooltip_resist
end
--------------------------------------------------------------------------------

