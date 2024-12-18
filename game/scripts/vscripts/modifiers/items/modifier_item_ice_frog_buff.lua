modifier_item_ice_frog_buff = class({})

--------------------------------------------------------------------------------

function modifier_item_ice_frog_buff:IsHidden() 
    return true
end

--------------------------------------------------------------------------------

function modifier_item_ice_frog_buff:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_ice_frog_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_FEARED] = false,
    }
    return state
end

--------------------------------------------------------------------------------

function modifier_item_ice_frog_buff:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

----------------------------------------

function modifier_item_ice_frog_buff:OnCreated( kv )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
    self.magic_resistance = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
    self.flMoveSpeed = self:GetParent():GetIdealSpeedNoSlows()
    self:StartIntervalThink( 0.5 )
end

----------------------------------------

function modifier_item_ice_frog_buff:OnIntervalThink()
    self.flMoveSpeed = 0
    self.flMoveSpeed = self:GetParent():GetIdealSpeedNoSlows()
end

----------------------------------------

function modifier_item_ice_frog_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
    return funcs
end

----------------------------------------

function modifier_item_ice_frog_buff:GetModifierPhysicalArmorBonus( params )
    return self.bonus_armor
end

----------------------------------------

function modifier_item_ice_frog_buff:GetModifierMagicalResistanceBonus( params )
    return self.magic_resistance
end

----------------------------------------

function modifier_item_ice_frog_buff:GetModifierMoveSpeed_AbsoluteMin( params )
    return self.flMoveSpeed
end