modifier_item_jade_gem_debuff = class({})

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem_debuff:GetTexture()
    return "item_jade_gem"
end
-----------------------------------------------------------------------------------------

function modifier_item_jade_gem_debuff:OnCreated( kv )

    if self:GetAbility() then
        self.enchant_radius = self:GetAbility():GetSpecialValueFor( "enchant_radius" ) 
        self.enchant_slow = self:GetAbility():GetSpecialValueFor( "enchant_slow" )
        self.nMissChancePerStack = self:GetAbility():GetSpecialValueFor( "slow_attack_speed" )
    else
        self.enchant_radius = 250
        self.enchant_slow = -15
        self.nMissChancePerStack = -10
    end
    
end

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem_debuff:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem_debuff:GetModifierMiss_Percentage()
    if self.nMissChancePerStack == nil then
        return 0
    end
    return self.nMissChancePerStack * self:GetStackCount()
end

function modifier_item_jade_gem_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    return self.enchant_slow
end

-----------------------------------------------------------------------------------------

function modifier_item_jade_gem_debuff:OnDeath( params )
    if IsServer() then
       
        if params.unit == self:GetParent() then
            EmitSoundOn( "DOTA_Item.Butterfly", self:GetCaster() )
            
            local nSmokeFX = ParticleManager:CreateParticle( "particles/gems/gem_jade_debuff.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( nSmokeFX, 0, self:GetParent():GetAbsOrigin() )  
            ParticleManager:ReleaseParticleIndex( nSmokeFX )

            local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.enchant_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
            for _,hEnemy in pairs( enemies ) do
                if hEnemy ~= nil and hEnemy:IsAlive() and hEnemy:IsInvulnerable() == false then
                    hEnemy:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_enchantress_untouchable_slow", { duration = 1} )
                end
            end
        end
    end
    return 0
end