modifier_warsong_soldier_upgrade = class({})

function modifier_warsong_soldier_upgrade:RemoveOnDeath() return true end
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
	self.lastStack = -1
	self:SetHasCustomTransmitterData(true)
	self:_ApplyUpgrade()
	self:StartIntervalThink(30.0)
end

function modifier_warsong_soldier_upgrade:_ApplyUpgrade()
	if not self.time or not self.hp_upgrade then return end
	local nMinute = math.floor(GameRules:GetDOTATime(false, false) / 60)
	if nMinute < self.time then return end
	local nStacks = math.floor(nMinute / self.time)
	if nStacks == self.lastStack then return end
	self.lastStack = nStacks
	self:SetStackCount(nStacks)
	local nHP = self.base + nStacks * self.hp_upgrade
	self:GetParent():SetBaseMaxHealth(nHP)
	self:GetParent():SetMaxHealth(nHP)
	self:GetParent():SetHealth(nHP)
	self:SendBuffRefreshToClients()
end

function modifier_warsong_soldier_upgrade:OnIntervalThink()
	if not IsServer() then return end
	self:_ApplyUpgrade()
end

function modifier_warsong_soldier_upgrade:DeclareFunctions()
	return
	{
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
	return self:GetStackCount() * (self.dmg_upgrade or 0)
end

function modifier_warsong_soldier_upgrade:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * (self.armor_upgrade or 0)
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
    return DOTA_UNIT_TARGET_HERO
end

function modifier_warsong_soldier_upgrade:GetAuraDuration()
    return 0.5  -- Увеличено с 0.1 до 0.5 для оптимизации производительности
end