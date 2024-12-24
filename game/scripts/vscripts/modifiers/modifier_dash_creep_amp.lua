modifier_dash_creep_amp = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    IsPurgableException = function() return false end,
    RemoveOnDeath = function() return false end,
})
function modifier_dash_creep_amp:OnCreated(kkd)
    self.CREEP_AMP = kkd.CREEP_AMP
end

function modifier_dash_creep_amp:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_dash_creep_amp:GetModifierHealthBonus()
	return self.CREEP_AMP * self:GetParent():GetMaxHealth()
end

function modifier_dash_creep_amp:GetModifierPreAttack_BonusDamage()
    if IsClient() then return 0 end
	return self.CREEP_AMP * self:GetParent():GetAttackDamage()
end
