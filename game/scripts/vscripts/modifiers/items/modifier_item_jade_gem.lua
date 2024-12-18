modifier_item_jade_gem = class({})

--------------------------------------------------------------------------------

function modifier_item_jade_gem:IsHidden()
    return true
end

function modifier_item_jade_gem:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_jade_gem:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_jade_gem:OnCreated( kv )
    self.evasion_bonus_pct = self:GetAbility():GetSpecialValueFor( "evasion_bonus_pct" )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.enchant_duration = self:GetAbility():GetSpecialValueFor( "enchant_duration" )
    self.max_stack_count = self:GetAbility():GetSpecialValueFor( "max_stack_count" )
end

--------------------------------------------------------------------------------

function modifier_item_jade_gem:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem:OnAttackLanded( params )
    if IsServer() then

        local hAttacker = params.attacker
        local hTarget = params.target

        if hTarget == nil or hAttacker == nil then
            return 0
        end

        if hAttacker:IsIllusion() then
            return 0
        end

        if hAttacker == self:GetParent() then
            if hTarget ~= nil then
                local hMissBuff = hTarget:FindModifierByName( "modifier_item_jade_gem_debuff" )
                if hMissBuff == nil then
                    hMissBuff = hTarget:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_jade_gem_debuff", { duration = self.enchant_duration } )
                    if hMissBuff ~= nil then
                        hMissBuff:SetStackCount( 0 )
                    end
                end
                if hMissBuff ~= nil then
                    hMissBuff:SetStackCount( math.min( hMissBuff:GetStackCount() + 1, self.max_stack_count ) )
                    hMissBuff:SetDuration( self.enchant_duration, true )
                end
            end
        end
    end
    return 0 
end

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_damage
end

--------------------------------------------------------------------------------

function modifier_item_jade_gem:GetModifierEvasion_Constant( params )
    return self.evasion_bonus_pct
end