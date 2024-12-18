modifier_item_assault_mega_aura_effect = class({})
-----------------------------------------------------------------------------------------

function modifier_item_assault_mega_aura_effect:GetTexture()
    return "item_assault_mega"
end

function modifier_item_assault_mega_aura_effect:IsHidden() 
    return false
end
-----------------------------------------------------------------------------------------

function modifier_item_assault_mega_aura_effect:OnCreated( kv )
    self.aura_attack_speed = self:GetAbility():GetSpecialValueFor( "aura_attack_speed" )
    self.aura_positive_armor = self:GetAbility():GetSpecialValueFor( "aura_positive_armor" )
    self.aura_negative_armor = self:GetAbility():GetSpecialValueFor( "aura_negative_armor" )
end

-----------------------------------------------------------------------------------------

function modifier_item_assault_mega_aura_effect:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_assault_mega_aura_effect:GetModifierAttackSpeedBonus_Constant( params )
    local parent = self:GetParent()
    if parent:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        return self.aura_attack_speed
    end
    return 0
end

function modifier_item_assault_mega_aura_effect:GetModifierPhysicalArmorBonus( params )
    local parent = self:GetParent()
    if parent:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        return self.aura_positive_armor
    elseif parent:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS then
        return self.aura_negative_armor
    end
    return 0
end