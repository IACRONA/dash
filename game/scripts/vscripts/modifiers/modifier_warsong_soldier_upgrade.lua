modifier_warsong_soldier_upgrade = class({})

function modifier_warsong_soldier_upgrade:RemoveOnDeath() return false end
function modifier_warsong_soldier_upgrade:IsPurgable() return false end
function modifier_warsong_soldier_upgrade:IsPurgeException() return false end
function modifier_warsong_soldier_upgrade:IsHidden() return true end

function modifier_warsong_soldier_upgrade:OnCreated(data)
	if not IsServer() then return end
	self.dmg_upgrade = data.dmg_upgrade
	self.hp_upgrade = data.hp_upgrade
	self.armor_upgrade = data.armor_upgrade
	self.time = data.time
	self.base = self:GetParent():GetBaseMaxHealth()
	if (math.floor(GameRules:GetDOTATime(false, false) / 60)) >= self.time then
		self:SetStackCount(math.floor((math.floor(GameRules:GetDOTATime(false, false) / 60)) / self.time))
		self:GetParent():SetBaseMaxHealth(self.base + self:GetStackCount() * self.hp_upgrade)
		self:GetParent():SetMaxHealth(self.base + self:GetStackCount() * self.hp_upgrade)
		self:GetParent():SetHealth(self.base + self:GetStackCount() * self.hp_upgrade)
	end
	self:SetHasCustomTransmitterData(true)
	self:StartIntervalThink(0.1)
end

function modifier_warsong_soldier_upgrade:OnIntervalThink()
	if not IsServer() then return end
	if (math.floor(GameRules:GetDOTATime(false, false) / 60)) >= self.time then
		self:SetStackCount(math.floor((math.floor(GameRules:GetDOTATime(false, false) / 60)) / self.time))
		self:GetParent():SetBaseMaxHealth(self.base + self:GetStackCount() * self.hp_upgrade)
		self:GetParent():SetMaxHealth(self.base + self:GetStackCount() * self.hp_upgrade)
	end
	self:SendBuffRefreshToClients()
end

function modifier_warsong_soldier_upgrade:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_warsong_soldier_upgrade:AddCustomTransmitterData()
    return 
    {
        dmg_upgrade = self.dmg_upgrade,
        hp_upgrade = self.hp_upgrade,
        armor_upgrade = self.armor_upgrade,
        time = self.time,
    }
end

function modifier_warsong_soldier_upgrade:HandleCustomTransmitterData( data )
    self.dmg_upgrade = data.dmg_upgrade
    self.hp_upgrade = data.hp_upgrade
    self.armor_upgrade = data.armor_upgrade
    self.time = data.time
end

function modifier_warsong_soldier_upgrade:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.dmg_upgrade
end

function modifier_warsong_soldier_upgrade:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self.armor_upgrade
end

function modifier_warsong_soldier_upgrade:IsAura()
    return true
end

function modifier_warsong_soldier_upgrade:IsPurgable()
    return false
end

function modifier_warsong_soldier_upgrade:GetAuraRadius()
    return 900
end

function modifier_warsong_soldier_upgrade:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_warsong_soldier_upgrade:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_warsong_soldier_upgrade:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_warsong_soldier_upgrade:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_warsong_soldier_upgrade:GetAuraDuration()
    return 0.1
end