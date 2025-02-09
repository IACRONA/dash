modifier_dash_amp = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    IsPurgableException = function() return false end,
    RemoveOnDeath = function() return false end,
})
function modifier_dash_amp:OnCreated(kkd)
    if not IsServer() then return end
    local lvl = kkd.lvl
    if lvl == nil  or lvl == 0 then return self:Destroy() end
    local ha = HEALTH_AMP or 0
    local ar = ARMOR_AMP or 0
    local da = DAMAGE_AMP or 0
    self.HEALTH_AMP = (ha/100) * lvl
    self.ARMOR_AMP = (ar/100) * lvl
    self.DAMAGE_AMP = (da/100) * lvl
    self.creep_dmg = self:GetParent():GetAttackDamage()
    self.creep_armor = self:GetParent():GetPhysicalArmorValue(false)
    self:SetHasCustomTransmitterData(true)
    self:SetStackCount(lvl)
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
    if self.HEALTH_AMP == nil or self:GetParent():GetMaxHealth() == nil then return end
	return self.HEALTH_AMP * self:GetParent():GetMaxHealth()
end

function modifier_dash_amp:GetModifierPreAttack_BonusDamage()
    if self.HEALTH_AMP == nil or self.creep_dmg == nil then return end
	return self.HEALTH_AMP * self.creep_dmg
end

function modifier_dash_amp:GetModifierPhysicalArmorBonus()
    if self.creep_armor == 0 then return self.ARMOR_AMP * 1 end
    if self.ARMOR_AMP == nil or self.creep_armor == nil then return end
	return self.ARMOR_AMP * self.creep_armor
end