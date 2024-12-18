modifier_item_necklace = class({})

--------------------------------------------------------------------------------

function modifier_item_necklace:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_necklace:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_necklace:OnCreated( kv )
    self.spell_lifesteal_pct = self:GetAbility():GetSpecialValueFor( "spell_lifesteal_pct" )
    self.cooldown_reduction_pct = self:GetAbility():GetSpecialValueFor( "cooldown_reduction_pct" )
    self.mana_cost_reduction_pct = self:GetAbility():GetSpecialValueFor( "mana_cost_reduction_pct" )
    self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

--------------------------------------------------------------------------------

function modifier_item_necklace:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_UNIT_STATS_NEEDS_REFRESH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_item_necklace:GetModifierBonusStats_Intellect( params )
    return self.bonus_intellect
end

--------------------------------------------------------------------------------

function modifier_item_necklace:GetModifierPercentageCooldown( params )
    return self.cooldown_reduction_pct
end

--------------------------------------------------------------------------------

function modifier_item_necklace:GetModifierPercentageManacostStacking( params )
    return self.mana_cost_reduction_pct
end

--------------------------------------------------------------------------------

function modifier_item_necklace:GetModifierUnitStatsNeedsRefresh( params )
    return 1
end

--------------------------------------------------------------------------------

function modifier_item_necklace:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
            return 0
        end
        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
            return 0
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        Attacker:Heal( flLifesteal, self:GetAbility() )
    end
    return 0
end