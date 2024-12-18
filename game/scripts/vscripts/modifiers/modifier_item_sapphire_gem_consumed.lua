modifier_item_sapphire_gem_consumed = class({})

--------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:GetTexture()
    return "item_sapphire_gem"
end

function modifier_item_sapphire_gem_consumed:IsHidden()
    return false
end

function modifier_item_sapphire_gem_consumed:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:OnCreated( kv )
    self.mana_regen_sec = self:GetAbility():GetSpecialValueFor( "mana_regen_sec" )
    self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )   
    self.max_stack_count = self:GetAbility():GetSpecialValueFor( "max_stack_count" )
    self.sapphire_duration = self:GetAbility():GetSpecialValueFor( "sapphire_duration" )
    self.intellect_amount = self:GetAbility():GetSpecialValueFor( "intellect_amount" )
end

--------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_sapphire_gem_consumed:GetModifierConstantManaRegen( params )
    return self.mana_regen_sec
end


function modifier_item_sapphire_gem_consumed:GetModifierMoveSpeedBonus_Constant( params )
    return self.bonus_movement_speed
end
--------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:GetModifierBonusStats_Intellect( params )
    return self.intellect_amount
end
-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_consumed:OnAttackLanded( params )
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
            local hTarget = params.target
            if hTarget ~= nil then
                local hGemBuff = hTarget:FindModifierByName( "modifier_item_sapphire_gem_debuff" )
                if hGemBuff == nil then
                    hGemBuff = hTarget:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_sapphire_gem_debuff", { duration = self.sapphire_duration } )
                    if hGemBuff ~= nil then
                        hGemBuff:SetStackCount( 0 )
                    end
                end
                if hGemBuff ~= nil then
                    hGemBuff:SetStackCount( math.min( hGemBuff:GetStackCount() + 1, self.max_stack_count ) )
                    hGemBuff:SetDuration( self.sapphire_duration, true )
                end
            end
        end
    end
    return 0 
end

--------------------------------------------------------------------------------
