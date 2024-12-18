modifier_item_sapphire_gem_debuff = class({})

-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_debuff:GetTexture()
    return "item_sapphire_gem"
end

-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_debuff:OnCreated( kv )
   
    if self:GetAbility() then
         self.magic_reduction_pct = self:GetAbility():GetSpecialValueFor( "magic_reduction_pct" )
    else
        self.magic_reduction_pct = 10
    end

end

-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_debuff:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_debuff:GetModifierMagicalResistanceBonus()
    if self.magic_reduction_pct == nil then
        return 0
    end
    return self.magic_reduction_pct * self:GetStackCount() * -1
end

-----------------------------------------------------------------------------------------

function modifier_item_sapphire_gem_debuff:OnDeath( params )
    if IsServer() then

        if params.unit == self:GetParent() then
            EmitSoundOn( "DOTA_Item.ArcaneRing.Cast", self:GetCaster() )
           
            local nSmokeFX = ParticleManager:CreateParticle( "particles/gems/gem_sapphire_debuff.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( nSmokeFX, 0, self:GetParent():GetAbsOrigin() )  
            ParticleManager:ReleaseParticleIndex( nSmokeFX )

            local flManaAmount = self.magic_reduction_pct * self:GetStackCount()
            SendOverheadEventMessage( nil, OVERHEAD_ALERT_MANA_ADD, self:GetCaster(), flManaAmount, nil )
            self:GetCaster():GiveMana( flManaAmount )
        end
    end
    return 0
end