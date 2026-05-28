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
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_head_boss:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage > 0 then
		self:GetParent()._last_damage_time = GameRules:GetGameTime()
	end
end

function modifier_head_boss:OnTooltip()
	return self:GetStackCount()
end
