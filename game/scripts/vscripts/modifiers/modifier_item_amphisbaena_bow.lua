modifier_item_amphisbaena_bow = class({})
--------------------------------------------------------------------------------
function modifier_item_amphisbaena_bow:IsHidden()
    return true -- good boy
end

function modifier_item_amphisbaena_bow:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_amphisbaena_bow:GetTexture()
    return "item_amphisbaena_bow"
end

function modifier_item_amphisbaena_bow:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow:OnCreated( kv )
    self.bSplash = false
    self.bIsCrit = false
    self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
    self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )

    self.corruption_duration = self:GetAbility():GetSpecialValueFor( "corruption_duration" )
    self.area_effect = self:GetAbility():GetSpecialValueFor( "area_effect" )
    self.hHitTargets = {}
--[[    if self:GetCaster():IsRangedAttacker() then
        self.szRangedProjectileName = self:GetCaster():GetRangedProjectileName()
        self:GetCaster():SetRangedProjectileName( "particles/econ/events/fall_2022/attack2/attack2_modifier_fall2022_base.vpcf" )
    end--]]
end

--------------------------------------------------------------------------------

function modifier_item_amphisbaena_bow:DeclareFunctions()
    local funcs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_item_amphisbaena_bow:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        local hTarget = params.target
        local hAttacker = params.attacker

        if hAttacker:IsIllusion() then
            return 0
        end

        if hTarget and ( hTarget:IsBuilding() == false ) and ( hTarget:IsOther() == false ) --and ( not hTarget:HasModifier( "modifier_boss_passive" ) )
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

function modifier_item_amphisbaena_bow:OnAttackLanded( params )
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

        local hCdRecalc = hAbility:GetCooldown(-1)

        if self:GetCaster():FindModifierByName("modifier_item_octarine_core") then hCdRecalc = hCdRecalc - 2 end

        if self.bSplash == true then
            self.bSplash = false
            self.hHitTargets = {}
            self:GetAbility():StartCooldown( hCdRecalc )
        else
            if self.bIsCrit then
                self.bIsCrit = false
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
                ParticleManager:SetParticleControl( nFXIndex, 1, hTarget:GetOrigin() )
                ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetParent():GetForwardVector() )
                ParticleManager:SetParticleControlEnt( nFXIndex, 10, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
                EmitSoundOn( "Dungeon.BloodSplatterImpact", hTarget )
            end
        end

        hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_item_amphisbaena_bow_debuff", { duration = self.corruption_duration } )

        if ( self:GetParent():IsRangedAttacker() == false ) then
            return 0
        end

        local flCooldownTime = self:GetAbility():GetCooldownTimeRemaining()
        
        if ( not self.bSplash ) and flCooldownTime <= 0 then
            local hAllies = FindUnitsInRadius( hTarget:GetTeamNumber(), hTarget:GetOrigin(), nil, self.area_effect, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
            for _, hAlly in pairs ( hAllies ) do
                if hAlly ~= nil and not hAlly:IsNull() and hAlly:IsAlive() == true and self:HasHitTarget( hAlly ) == false then
                    self:TryToHitTarget( hAlly )
                    -- This code took a day of my weekend ( 25.10.2021 ) -- and it's still bugged, because you can disassemble it and get a buff for ever (29.04.2023)
                end
            end
            self.bSplash = true
        end
    end
    return 0
end

function modifier_item_amphisbaena_bow:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_damage
end

function modifier_item_amphisbaena_bow:TryToHitTarget( enemy )
    self:AddHitTarget( enemy )
    self:GetCaster():PerformAttack( enemy, false, true, true, false, true, false, true )
end

function modifier_item_amphisbaena_bow:HasHitTarget( hTarget )
    for _, target in pairs( self.hHitTargets ) do
        if target == hTarget then
            return true
        end
    end
    
    return false
end

function modifier_item_amphisbaena_bow:AddHitTarget( hTarget )
    table.insert( self.hHitTargets, hTarget )
end

function modifier_item_amphisbaena_bow:OnDestroy()
    if IsServer() then
        --[[if self:GetParent():IsRangedAttacker() then
            self:GetParent():SetRangedProjectileName( self.szRangedProjectileName )
        end--]]
    end
end
