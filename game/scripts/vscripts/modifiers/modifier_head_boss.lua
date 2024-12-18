modifier_head_boss = class({})

function modifier_head_boss:IsHidden()
	return self:GetStackCount() == 0
end
 
function modifier_head_boss:IsPurgable()
	return false
end

function modifier_head_boss:IsPurgableException()
	return false    
end

function modifier_head_boss:RemoveOnDeath()
	return false
end
 
function modifier_head_boss:GetTexture()
	return "boss_head"
end

function modifier_head_boss:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end


function modifier_head_boss:OnTooltip()
	return self:GetStackCount()
end
