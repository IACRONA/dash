modifier_item_amphisbaena_bow_debuff = class({})

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow_debuff:GetTexture()
    return "item_amphisbaena_bow"
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow_debuff:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow_debuff:OnCreated( kv )
    self.corruption_armor = self:GetAbility():GetSpecialValueFor( "corruption_armor" )
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

--------------------------------------------------------------------------------


function modifier_item_amphisbaena_bow_debuff:GetModifierPhysicalArmorBonus( params )
    return self.corruption_armor
end 

--------------------------------------------------------------------------------