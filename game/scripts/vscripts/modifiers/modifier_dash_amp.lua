modifier_dash_amp = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    IsPurgableException = function() return false end,
    RemoveOnDeath = function() return false end,
})
function modifier_dash_amp:OnCreated(kkd)
    if not IsServer() then return end
    local lvl = kkd.lvl
    self.HEALTH_AMP = (HEALTH_AMP/100) * lvl
    self.ARMOR_AMP = (ARMOR_AMP/100) * lvl
    self.DAMAGE_AMP = (DAMAGE_AMP/100) * lvl
    self.creep_dmg = self:GetParent():GetAttackDamage()
    self.creep_armor = self:GetParent():GetPhysicalArmorValue(false)
    self:SetHasCustomTransmitterData(true)
end
function modifier_dash_amp:OnRefresh(kkd)
    if not IsServer() then return end
    self:OnCreated(kkd)
end
function modifier_dash_amp:AddCustomTransmitterData()
    return {
        creep_dmg = self.creep_dmg,
        creep_armor = self.creep_armor,
        HEALTH_AMP = self.HEALTH_AMP,
        ARMOR_AMP = self.ARMOR_AMP,
        DAMAGE_AMP = self.DAMAGE_AMP,
    }
end

function modifier_dash_amp:HandleCustomTransmitterData(data)
    self.creep_dmg = data.creep_dmg
    self.HEALTH_AMP = data.HEALTH_AMP
    self.creep_armor = data.creep_armor
    self.ARMOR_AMP = data.ARMOR_AMP
    self.DAMAGE_AMP = data.DAMAGE_AMP
end
function modifier_dash_amp:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_dash_amp:GetModifierExtraHealthBonus()
    if self.HEALTH_AMP == nil then return end
	return self.HEALTH_AMP * self:GetParent():GetMaxHealth()
end

function modifier_dash_amp:GetModifierPreAttack_BonusDamage()
    if self.HEALTH_AMP == nil then return end
	return self.HEALTH_AMP * self.creep_dmg
end

function modifier_dash_amp:GetModifierArmorBonus()
    if self.ARMOR_AMP == nil then return end
	return self.ARMOR_AMP * self.creep_armor
end