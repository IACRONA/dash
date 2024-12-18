modifier_item_mantis_visuals = class({})
--------------------------------------------------------------------------------

function modifier_item_mantis_visuals:IsHidden() 
    return true
end

--------------------------------------------------------------------------------
function modifier_item_mantis_visuals:RemoveOnDeath()
    return true
end

--------------------------------------------------------------------------------

function modifier_item_mantis_visuals:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_item_mantis_visuals:OnCreated( kv )
    if IsServer() then        
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/items/mantis_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
    end
end

--------------------------------------------------------------------------------

function modifier_item_mantis_visuals:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
    end
end

--------------------------------------------------------------------------------