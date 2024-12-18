modifier_item_dragonbelt = class({})

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:OnCreated( kv )
    self.bonus_agility = self:GetAbility():GetSpecialValueFor( "bonus_agility" )
    self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
    self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )

    self.bIsCrit = false
end

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

----------------------------------------

-----------------------------------------------------------------------------------------

function modifier_item_dragonbelt:GetModifierBonusStats_Agility( params )
    return self.bonus_agility
end

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        local hTarget = params.target
        local hAttacker = params.attacker

        if hTarget and ( hTarget:IsBuilding() == false ) and ( hTarget:IsOther() == false ) and hAttacker and ( hAttacker:GetTeamNumber() ~= hTarget:GetTeamNumber() ) then
            if RandomFloat( 0, 100 ) < self.crit_chance then -- expose RollPseudoRandomPercentage?
                self.bIsCrit = true
                return self.crit_multiplier
            end
        end
    end

    return 0.0
end

--------------------------------------------------------------------------------

function modifier_item_dragonbelt:OnAttackLanded( params )
    if IsServer() then
        -- play sounds and stuff
        if self:GetParent() == params.attacker then
            local hTarget = params.target
            if hTarget ~= nil and self.bIsCrit then
                EmitSoundOn( "DOTA_Item.Daedelus.Crit", self:GetParent() )
                self.bIsCrit = false
            end
        end
    end

    return 0.0
end

--------------------------------------------------------------------------------