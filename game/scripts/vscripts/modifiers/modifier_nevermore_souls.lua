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
	if IsServer() then
		self.nTick = 0.1
		self.nTimePassed = 0
		self:StartIntervalThink(self.nTick)
	end
end

function modifier_nevermore_souls:OnIntervalThink()
	local hBuff = self:GetParent():FindModifierByName('modifier_nevermore_necromastery')
	if hBuff then
		local hAbility = hBuff:GetAbility()
		if hAbility then
			local nSPS = hAbility:GetSpecialValueFor('souls_per_sec')
			if nSPS > 0 then
				nMax = hAbility:GetSpecialValueFor("necromastery_max_souls")
				local nInterval = 1 / nSPS
				if hBuff:GetStackCount() < nMax and self:GetParent():IsAlive() then
					local nInc = math.floor(self.nTimePassed / nInterval)
					if nInc > 0 then
						hBuff:SetStackCount(math.min(nMax, hBuff:GetStackCount() + nInc))
						self.nTimePassed = self.nTimePassed - nInterval * nInc
					end
					self.nTimePassed = self.nTimePassed + self.nTick
				end
			end
		end
	end
end