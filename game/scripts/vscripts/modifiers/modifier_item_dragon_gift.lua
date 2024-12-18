modifier_item_dragon_gift = class({})

------------------------------------------------------------------------------

function modifier_item_dragon_gift:IsHidden() 
    return true
end

--------------------------------------------------------------------------------

function modifier_item_dragon_gift:IsPurgable()
    return false
end

----------------------------------------

function modifier_item_dragon_gift:OnCreated( kv )
    self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
    self.chance_to_resist_death = self:GetAbility():GetSpecialValueFor( "chance_to_resist_death" )
    self.bDeathPrevented = false
end

--------------------------------------------------------------------------------

function modifier_item_dragon_gift:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_DEATH_PREVENTED,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_item_dragon_gift:GetModifierBonusStats_Strength( params )
    return self.bonus_all_stats
end 
--------------------------------------------------------------------------------

function modifier_item_dragon_gift:GetModifierBonusStats_Agility( params )
    return self.bonus_all_stats
end
--------------------------------------------------------------------------------

function modifier_item_dragon_gift:GetModifierBonusStats_Intellect( params )
    return self.bonus_all_stats
end 

--------------------------------------------------------------------------------

function modifier_item_dragon_gift:GetMinHealth( params )
    if IsServer() then
        if RollPercentage( self.chance_to_resist_death ) then
            self.bDeathPrevented = true
            return 1
        end
    end
    return 0
end 

--------------------------------------------------------------------------------

function modifier_item_dragon_gift:OnDeathPrevented( params )
    if IsServer() then
        if self:GetParent() == params.unit and self:GetParent():IsAlive() and self.bDeathPrevented then
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_invulnerable", { duration = 3 } )
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_winter_wyvern_cold_embrace", { duration = 3 } )
            self.bDeathPrevented = false
        end
    end
    return 0
end