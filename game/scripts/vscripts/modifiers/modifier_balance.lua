modifier_balance = class({})

function modifier_balance:IsHidden()
	return self:GetStackCount() == 0
end
 
function modifier_balance:IsPurgable()
	return false
end

function modifier_balance:IsPurgableException()
	return false
end

function modifier_balance:RemoveOnDeath()
	return false
end

function modifier_balance:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end


function modifier_balance:GetTexture()
	return "balance"
end


function modifier_balance:OnCreated()
    self:GetParent().balanceModifier = self
	self.incomingDamage = 0
	self.outgoingDamage = 0
end

function modifier_balance:GetModifierTotalDamageOutgoing_Percentage(event)
	if self:GetStackCount() == 0 then return end

    local parent = self:GetParent()
    local attacker = event.attacker
 
	if attacker == self:GetParent()  then 
 	    return self.outgoingDamage
	end
end
 
function modifier_balance:GetModifierIncomingDamage_Percentage(event)
    if self:GetStackCount() == 0 then return end
	local damageType = event.damage_type

    if damageType == DAMAGE_TYPE_PHYSICAL or damageType == DAMAGE_TYPE_MAGICAL then
		return self.incomingDamage
	end
end