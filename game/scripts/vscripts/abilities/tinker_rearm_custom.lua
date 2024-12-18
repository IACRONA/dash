tinker_rearm_custom = class({})

function tinker_rearm_custom:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function tinker_rearm_custom:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Tinker.Rearm")
    self:GetCaster():StartGesture(ACT_DOTA_TINKER_REARM..self:GetLevel())
end

function tinker_rearm_custom:OnChannelFinish( bInterrupted )

    if bInterrupted then 
    	self:GetCaster():RemoveGesture(ACT_DOTA_CAST4_STATUE)
    	self:GetCaster():RemoveGesture(ACT_DOTA_TINKER_REARM1)
    	self:GetCaster():RemoveGesture(ACT_DOTA_TINKER_REARM2)
    	self:GetCaster():RemoveGesture(ACT_DOTA_TINKER_REARM3)
    	return 
    end

    for i=0,self:GetCaster():GetAbilityCount()-1 do
        local ability = self:GetCaster():GetAbilityByIndex( i )
        if ability and ability:GetAbilityType()~=DOTA_ABILITY_TYPE_ATTRIBUTES then
            ability:RefreshCharges()
            ability:EndCooldown()
        end
    end

    for i=0,8 do
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            local pass = false
            if item:GetPurchaser()==self:GetCaster() and not self:IsItemException( item ) then
                pass = true
            end
            if pass then
                item:EndCooldown()
            end
        end
    end

    local item = self:GetCaster():GetItemInSlot(16)
    if item then
        local pass = false
        if item:GetPurchaser()==self:GetCaster() and not self:IsItemException( item ) then
            pass = true
        end
        if pass then
            item:EndCooldown()
        end
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    --self:GetCaster():EmitSound("Hero_Tinker.RearmStart")
end

function tinker_rearm_custom:IsItemException( item )
    return self.ItemException[item:GetName()]
end

tinker_rearm_custom.ItemException = 
{
    ["item_aeon_disk"] = true,
	["item_arcane_boots"] = true,
	["item_black_king_bar"] = true,
	["item_hand_of_midas"] = true,
	["item_helm_of_the_dominator"] = true,
	["item_meteor_hammer"] = true,
	["item_necronomicon"] = true,
	["item_necronomicon_2"] = true,
	["item_necronomicon_3"] = true,
	["item_refresher"] = true,
	["item_refresher_shard"] = true,
	["item_pipe"] = true,
	["item_sphere"] = true,
}
