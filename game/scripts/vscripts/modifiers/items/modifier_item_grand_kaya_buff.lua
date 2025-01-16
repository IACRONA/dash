modifier_item_grand_kaya_buff = class({})
--------------------------------------------------------------------------------
function modifier_item_grand_kaya_buff:GetTexture()
    return "item_grand_kaya"
end

function modifier_item_grand_kaya_buff:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_grand_kaya_buff:IsPurgable()
    return false
end
--------------------------------------------------------------------------------

function modifier_item_grand_kaya_buff:OnCreated( kv )
    self.bonus_spell_amplify_percent = self:GetAbility():GetSpecialValueFor( "bonus_spell_amplify_percent" ) / 100
    self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
    self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
    self.mana_regen_multiplier = self:GetAbility():GetSpecialValueFor( "mana_regen_multiplier" ) / 100
    self.spell_lifesteal_amp = self:GetAbility():GetSpecialValueFor( "spell_lifesteal_amp" )

    if IsServer() then
       self:GetParent():CalculateStatBonus( false )
    end 
end

--------------------------------------------------------------------------------

function modifier_item_grand_kaya_buff:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,

    }
    return funcs
end

function modifier_item_grand_kaya_buff:GetModifierSpellLifestealRegenAmplify_Percentage( params )
    return self.spell_lifesteal_amp
end

function modifier_item_grand_kaya_buff:GetModifierBonusStats_Intellect( params )
    return self.bonus_intellect
end

function modifier_item_grand_kaya_buff:GetModifierTotalPercentageManaRegen( params )
    return self.mana_regen_multiplier
end

function modifier_item_grand_kaya_buff:OnTooltip( params )
    if self:GetParent().bBoss then return 25 end
    return math.floor( self:GetParent():GetIntellect(false) * self.bonus_spell_amplify_percent )
end
--------------------------------------------------------------------------------

function modifier_item_grand_kaya_buff:GetModifierSpellAmplify_Percentage( params )
    if self:GetParent().bBoss then return 25 end
    return self.spell_amp + ( math.floor( self:GetParent():GetIntellect(false) * self.bonus_spell_amplify_percent )  )
end

function modifier_item_grand_kaya_buff:OnDestroy()
    if IsServer() then
        --self:GetParent():CalculateStatBonus( false )
    end
end