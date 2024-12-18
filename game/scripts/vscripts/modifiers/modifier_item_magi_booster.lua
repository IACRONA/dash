modifier_item_magi_booster = class({})

--------------------------------------------------------------------------------

function modifier_item_magi_booster:IsHidden() 
    return true
end

function modifier_item_magi_booster:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function modifier_item_magi_booster:IsPurgable()
    return false
end

----------------------------------------

function modifier_item_magi_booster:IsAura()
    return true
end

----------------------------------------

function modifier_item_magi_booster:GetModifierAura()
    return  "modifier_item_magi_booster_effect"
end

----------------------------------------

function modifier_item_magi_booster:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

----------------------------------------

function modifier_item_magi_booster:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

----------------------------------------

function modifier_item_magi_booster:GetAuraRadius()
    return self.radius
end

----------------------------------------

function modifier_item_magi_booster:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.bonus_intelligence = self:GetAbility():GetSpecialValueFor( "bonus_intelligence" )
end

----------------------------------------

function modifier_item_magi_booster:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }

    return funcs
end

----------------------------------------

function modifier_item_magi_booster:GetModifierBonusStats_Intellect( params )
    return self.bonus_intelligence
end
----------------------------------------

function modifier_item_magi_booster:GetModifierPercentageCasttime( params )
    return self.bonus_intelligence
end