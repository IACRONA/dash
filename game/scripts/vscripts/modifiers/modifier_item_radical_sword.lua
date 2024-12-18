modifier_item_radical_sword = class({})
--------------------------------------------------------------------------------
function modifier_item_radical_sword:IsHidden()
    return true
end

function modifier_item_radical_sword:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_radical_sword:GetTexture()
    return "item_radical_sword"
end

function modifier_item_radical_sword:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword:OnCreated( kv )
    self.bSplash = false
    self.bIsCrit = false
    self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
    self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.hp_as_damage = self:GetAbility():GetSpecialValueFor( "hp_as_damage" )
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )

    self.corruption_duration = self:GetAbility():GetSpecialValueFor( "corruption_duration" )
    self.area_effect = self:GetAbility():GetSpecialValueFor( "area_effect" )
    self.hHitTargets = {}
end

--------------------------------------------------------------------------------

function modifier_item_radical_sword:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
    return funcs
end

function modifier_item_radical_sword:GetModifierBonusStats_Strength( params )
    return self.bonus_strength
end

function modifier_item_radical_sword:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        local hTarget = params.target
        local hAttacker = params.attacker

        if hAttacker:IsIllusion() then
            return 0
        end

        if hTarget and ( hTarget:IsBuilding() == false ) and ( hTarget:IsOther() == false )
            and hAttacker and ( hAttacker == self:GetParent() )
            and ( hAttacker:GetTeamNumber() ~= hTarget:GetTeamNumber() ) then
            if RollPseudoRandomPercentage( self.crit_chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, hAttacker ) == true then
                self.bIsCrit = true
                return self.crit_multiplier
            end
        end
    end

    return 0
end

-----------------------------------------------------------------------------------------

function modifier_item_radical_sword:OnAttackLanded( params )
    if IsServer() then

        if self:GetParent() ~= params.attacker then
            return 0
        end
        
        local hTarget = params.target
        local hAttacker = params.attacker
        local hAbility = self:GetAbility()

        if hTarget == nil or hAttacker == nil or self:GetAbility() == nil then
            return 0
        end

        if hAttacker:IsIllusion() then
            return 0
        end

        hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_item_radical_sword_debuff", { duration = self.corruption_duration } )

        if self.bSplash == true then
            self.bSplash = false
            self.hHitTargets = {}
            
        else
            if self.bIsCrit then
                self.bIsCrit = false
            end
        end

        if ( self:GetParent():IsRangedAttacker() == true ) then
            return 0
        end

        local flCooldownTime = self:GetAbility():GetCooldownTimeRemaining()
        
        if ( not self.bSplash ) and flCooldownTime <= 0 then
            self.bSplash = true
            local hAllies = FindUnitsInRadius( hTarget:GetTeamNumber(), hTarget:GetOrigin(), nil, self.area_effect, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
            for _, hAlly in pairs ( hAllies ) do
                if hAlly ~= nil and not hAlly:IsNull() and hAlly:IsAlive() == true and self:HasHitTarget( hAlly ) == false then
                    self:TryToHitTarget( hAlly )
                end
            end
            local hCdRecalc = hAbility:GetCooldown(-1)
            if self:GetCaster():FindModifierByName("modifier_item_octarine_core") then hCdRecalc = hCdRecalc - 3 end -- ugly hack. self.BaseClass.GetCooldown does not really works as it should be.
            self:GetAbility():StartCooldown( hCdRecalc )
            
        end
    end
    return 0
end

function modifier_item_radical_sword:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_damage
end

function modifier_item_radical_sword:TryToHitTarget( enemy )
    self:AddHitTarget( enemy )
end

function modifier_item_radical_sword:HasHitTarget( hTarget )
    for _, target in pairs( self.hHitTargets ) do
        if target == hTarget then
            return true
        end
    end
    
    return false
end

function modifier_item_radical_sword:AddHitTarget( hTarget )

    local flAverageDamage = self:GetParent():GetMaxHealth() * self.hp_as_damage / 100
    local damageInfo = 
    {
        victim = hTarget,
        attacker = self:GetParent(),
        damage = flAverageDamage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage( damageInfo )

    local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/chaos_knight_chain_jump_explode.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
    ParticleManager:SetParticleControlEnt( nFXIndex, 3, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )

    SendOverheadEventMessage( nil, 2, hTarget, flAverageDamage, nil )
    table.insert( self.hHitTargets, hTarget )
end

