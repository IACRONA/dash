modifier_item_assault_mega_aura = class({})
------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:IsHidden() 
    return true
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:IsPurgable()
    return false
end
--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:OnCreated( kv )
    self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:IsAura()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:GetModifierAura()
    return  "modifier_item_assault_mega_aura_effect"
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_assault_mega_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_item_assault_mega_aura:GetAuraDuration()
    return 0.5
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:GetAuraRadius()
    return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_item_assault_mega_aura:GetModifierAttackSpeedBonus_Constant( params )
    return self.bonus_attack_speed
end

function modifier_item_assault_mega_aura:GetModifierPhysicalArmorBonus( params )
    return self.bonus_armor
end

--------------------------------------------------------------------------------