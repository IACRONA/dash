modifier_item_coral_consumed = class({})
----------------------------------------

function modifier_item_coral_consumed:GetTexture()
    return "item_coral"
end

----------------------------------------

function modifier_item_coral_consumed:IsHidden()
    return false
end

----------------------------------------

function modifier_item_coral_consumed:RemoveOnDeath()
    return false
end

----------------------------------------

function modifier_item_coral_consumed:IsPurgable()
    return false
end

----------------------------------------

function modifier_item_coral_consumed:OnCreated( kv )
    self.stats_bonus = self:GetAbility():GetSpecialValueFor( "stats_bonus" )
end

----------------------------------------

function modifier_item_coral_consumed:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_TOOLTIP,
    }
    return funcs
end

function modifier_item_coral_consumed:GetModifierConstantManaRegen( params )
    return self:GetStackCount() * self.stats_bonus
end
--------------------------------------------------------------------------------

function modifier_item_coral_consumed:OnTooltip( params )
    return self:GetStackCount() * self.stats_bonus
end

function modifier_item_coral_consumed:GetModifierConstantHealthRegen( params )
    return self:GetStackCount() * self.stats_bonus
end

----------------------------------------

