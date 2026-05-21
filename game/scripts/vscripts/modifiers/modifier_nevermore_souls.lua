modifier_nevermore_souls = class{}

function modifier_nevermore_souls:IsHidden()
	return true
end

function modifier_nevermore_souls:IsPurgeException()
	return false
end

function modifier_nevermore_souls:IsPurgable()
	return false
end

function modifier_nevermore_souls:RemoveOnDeath()
	return false
end

function modifier_nevermore_souls:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_nevermore_souls:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1.0)
end

function modifier_nevermore_souls:OnIntervalThink()
	local hBuff = self:GetParent():FindModifierByName('modifier_nevermore_necromastery')
	if not hBuff then return end
	local hAbility = hBuff:GetAbility()
	if not hAbility then return end
	if not self:GetParent():IsAlive() then return end

	local nMax = hAbility:GetSpecialValueFor("necromastery_max_souls")
	if hBuff:GetStackCount() >= nMax then return end

	local nSPS = GetMapName() == "dash" and (nMax / 60) or (nMax / 20)
	local nInc = math.max(1, math.floor(nSPS))
	hBuff:SetStackCount(math.min(nMax, hBuff:GetStackCount() + nInc))
end