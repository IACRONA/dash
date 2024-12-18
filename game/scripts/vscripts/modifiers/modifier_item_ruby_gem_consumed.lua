modifier_item_ruby_gem_consumed = class({})
--------------------------------------------------------------------------------
function modifier_item_ruby_gem_consumed:GetTexture()
    return "item_ruby_gem"
end

function modifier_item_ruby_gem_consumed:IsHidden()
    return false
end

function modifier_item_ruby_gem_consumed:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:OnCreated( kv )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
    self.caustic_duration = self:GetAbility():GetSpecialValueFor( "caustic_duration" )
    self.max_stack_count = self:GetAbility():GetSpecialValueFor( "max_stack_count" )
end

--------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:OnAttackLanded( params )
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
                local hExplosiveBuff = hTarget:FindModifierByName( "modifier_item_ruby_gem_debuff" )
                if hExplosiveBuff == nil then
                    hExplosiveBuff = hTarget:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_ruby_gem_debuff", { duration = self.caustic_duration } )
                    if hExplosiveBuff ~= nil then
                        hExplosiveBuff:SetStackCount( 0 )
                    end
                end
                if hExplosiveBuff ~= nil then
                    hExplosiveBuff:SetStackCount( math.min( hExplosiveBuff:GetStackCount() + 1, self.max_stack_count ) )
                    hExplosiveBuff:SetDuration( self.caustic_duration, true )
                end
            end
        end
    end
    return 0 
end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_damage
end

--------------------------------------------------------------------------------

function modifier_item_ruby_gem_consumed:GetModifierAttackSpeedBonus_Constant( params )
    return self.bonus_attack_speed
end