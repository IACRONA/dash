modifier_item_bloodstone_custom = class({})
--------------------------------------------------------------------------------
function modifier_item_bloodstone_custom:GetTexture()
    return "item_vecna"
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:OnCreated( kv )
    self.lifesteal_multiplier = self:GetAbility():GetSpecialValueFor( "lifesteal_multiplier" )
    self.spell_lifesteal = self:GetAbility():GetSpecialValueFor( "spell_lifesteal" )
    self.bonus_health = self:GetAbility():GetSpecialValueFor( "bonus_health" )
    self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )
    self.bonus_aoe = self:GetAbility():GetSpecialValueFor( "bonus_aoe" )
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_AOE_BONUS_CONSTANT,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:GetModifierHealthBonus( params )
    return self.bonus_health
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:GetModifierManaBonus( params )
    return self.bonus_mana
end

function modifier_item_bloodstone_custom:GetModifierAoEBonusConstant( params )
    return self.bonus_aoe
end

--------------------------------------------------------------------------------

function modifier_item_bloodstone_custom:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        
        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
            return 0
        end

        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
            return 0
        end

        local flDamage = params.damage
        local spell_lifesteal = self.spell_lifesteal

        if ( not Target:IsConsideredHero() ) then
            spell_lifesteal = spell_lifesteal / 5
        end

        if Attacker:HasModifier( "modifier_item_bloodstone_active" ) then
            spell_lifesteal = spell_lifesteal * self.lifesteal_multiplier
            local flMana = flDamage * spell_lifesteal / 100
            Attacker:GiveMana( flMana )
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        local flLifesteal = flDamage * spell_lifesteal / 100
        Attacker:Heal( flLifesteal, self:GetAbility() )
    end
    return 0
end