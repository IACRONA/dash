modifier_item_radical_sword_debuff = class({})

--------------------------------------------------------------------------------

function modifier_item_radical_sword_debuff:GetTexture()
    return "item_radical_sword"
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword_debuff:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword_debuff:OnCreated( kv )
    self.corruption_armor = self:GetAbility():GetSpecialValueFor( "corruption_armor" )
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

--------------------------------------------------------------------------------


function modifier_item_radical_sword_debuff:GetModifierPhysicalArmorBonus( params )
    return self.corruption_armor
end 

--------------------------------------------------------------------------------