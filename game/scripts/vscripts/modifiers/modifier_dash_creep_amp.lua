modifier_dash_creep_amp = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    IsPurgableException = function() return false end,
    RemoveOnDeath = function() return false end,
})
function modifier_dash_creep_amp:OnCreated(kkd)
    if not IsServer() then return end
    self.CREEP_AMP = kkd.CREEP_AMP
    self.creep_dmg = self:GetParent():GetAttackDamage()
    self:SetHasCustomTransmitterData(true)
end
function modifier_dash_creep_amp:AddCustomTransmitterData()
    return {
        creep_dmg = self.creep_dmg,
        CREEP_AMP = self.CREEP_AMP
    }
end
function modifier_dash_creep_amp:HandleCustomTransmitterData(data)
    self.creep_dmg = data.creep_dmg
    self.CREEP_AMP = data.CREEP_AMP
end
function modifier_dash_creep_amp:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_dash_creep_amp:GetModifierExtraHealthBonus()
    if self.CREEP_AMP == nil then return end
	return self.CREEP_AMP * self:GetParent():GetMaxHealth()
end

function modifier_dash_creep_amp:GetModifierPreAttack_BonusDamage()
    if self.CREEP_AMP == nil then return end
	return self.CREEP_AMP * self.creep_dmg
end
