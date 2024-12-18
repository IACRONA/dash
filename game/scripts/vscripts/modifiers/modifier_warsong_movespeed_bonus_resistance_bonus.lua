modifier_warsong_movespeed_bonus_resistance_bonus = class({})

function modifier_warsong_movespeed_bonus_resistance_bonus:RemoveOnDeath() return false end
function modifier_warsong_movespeed_bonus_resistance_bonus:IsPurgable() return false end
function modifier_warsong_movespeed_bonus_resistance_bonus:IsPurgeException() return false end
function modifier_warsong_movespeed_bonus_resistance_bonus:IsHidden() return self:GetStackCount() == 1 end

function modifier_warsong_movespeed_bonus_resistance_bonus:OnCreated(data)
	if not IsServer() then return end
	self.phys = data.phys
	self.magical = data.magical
	self.time = data.time
	self:SetHasCustomTransmitterData(true)
	self:SetStackCount(1)
	self:StartIntervalThink(0.1)
end

function modifier_warsong_movespeed_bonus_resistance_bonus:OnIntervalThink()
	if not IsServer() then return end
	if (math.floor(GameRules:GetDOTATime(false, false) / 60)) >= self.time then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
	self:SendBuffRefreshToClients()
end

function modifier_warsong_movespeed_bonus_resistance_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_warsong_movespeed_bonus_resistance_bonus:GetTexture()
	return "item_platemail"
end

function modifier_warsong_movespeed_bonus_resistance_bonus:OnTooltip()
	return self.phys
end

function modifier_warsong_movespeed_bonus_resistance_bonus:AddCustomTransmitterData()
    return 
    {
        phys = self.phys,
        magical = self.magical,
        time = self.time,
    }
end

function modifier_warsong_movespeed_bonus_resistance_bonus:HandleCustomTransmitterData( data )
    self.phys = data.phys
    self.magical = data.magical
    self.time = data.time
end

function modifier_warsong_movespeed_bonus_resistance_bonus:GetModifierMagicalResistanceBonus()
	if self:GetStackCount() == 1 then return end
	return self.magical
end

function modifier_warsong_movespeed_bonus_resistance_bonus:GetModifierIncomingDamage_Percentage(params)
	if params.damage_type == DAMAGE_TYPE_PHYSICAL then
		if self:GetStackCount() == 1 then return end
		return -self.phys
	end
end

