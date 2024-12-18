modifier_item_ruby_gem_debuff = class({})

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_debuff:GetTexture()
    return "item_ruby_gem"
end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_debuff:OnCreated( kv )

    if self:GetAbility() then
        self.caustic_radius = self:GetAbility():GetSpecialValueFor( "caustic_radius" ) 
        self.caustic_damage = self:GetAbility():GetSpecialValueFor( "caustic_damage" )
        self.nArmorReductionPerStack = self:GetAbility():GetSpecialValueFor( "caustic_armor_reduction_pct" )
    else
        self.caustic_radius = 250 
        self.caustic_damage = 20
        self.nArmorReductionPerStack = 1
    end

end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_debuff:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_debuff:GetModifierPhysicalArmorBonus()
    if self.nArmorReductionPerStack == nil then
        return 0
    end
    return self.nArmorReductionPerStack * self:GetStackCount() * -1
end

-----------------------------------------------------------------------------------------

function modifier_item_ruby_gem_debuff:OnDeath( params )
    if IsServer() then
       
        if params.unit == self:GetParent() then
            EmitSoundOn( "Item.LotusOrb.Destroy", self:GetCaster() )
            
            local nSmokeFX = ParticleManager:CreateParticle( "particles/gems/gem_ruby_debuff.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( nSmokeFX, 0, self:GetParent():GetAbsOrigin() )  
            ParticleManager:ReleaseParticleIndex( nSmokeFX )

            local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.caustic_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
            for _,hEnemy in pairs( enemies ) do
                if hEnemy ~= nil and hEnemy:IsAlive() and hEnemy:IsInvulnerable() == false then
                    local damageInfo = 
                    {
                        victim = hEnemy,
                        attacker = self:GetCaster(),
                        damage = self.caustic_damage * self:GetStackCount(),
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self,
                    }
                    ApplyDamage( damageInfo )
                end
            end
        end
    end
    return 0
end