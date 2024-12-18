modifier_cursed_leader = class({})

function modifier_cursed_leader:IsHidden()
	return self:GetStackCount() == 0
end
 
function modifier_cursed_leader:IsPurgable()
	return false
end

function modifier_cursed_leader:IsPurgableException()
	return false
end

function modifier_cursed_leader:RemoveOnDeath()
	return false
end

function modifier_cursed_leader:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end


function modifier_cursed_leader:GetTexture()
	return "cursed_leader"
end


function modifier_cursed_leader:OnCreated()
    self:GetParent().cursedLeaderModifier = self
	self.incomingDamage = 0
	self.outgoingDamage = 0
end

function modifier_cursed_leader:GetModifierTotalDamageOutgoing_Percentage(event)
	if self:GetStackCount() == 0 then return end

    local parent = self:GetParent()
    local attacker = event.attacker
 
	if attacker == self:GetParent()  then 
 	    return self.outgoingDamage
	end
end
 
function modifier_cursed_leader:GetModifierIncomingDamage_Percentage(event)
    if self:GetStackCount() == 0 then return end
	local damageType = event.damage_type

    if damageType == DAMAGE_TYPE_PHYSICAL or damageType == DAMAGE_TYPE_MAGICAL then
		return self.incomingDamage
	end
end