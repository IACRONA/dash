modifier_freeze_time_start = class{}

function modifier_freeze_time_start:IsHidden()
	return false
end

function modifier_freeze_time_start:IsDebuff()
	return false
end

function modifier_freeze_time_start:IsPurgable()
	return false
end

function modifier_freeze_time_start:RemoveOnDeath()
	return true
end

function modifier_freeze_time_start:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_freeze_time_start:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_DISABLE_TURNING,
	}

	return funcs
end

function modifier_freeze_time_start:GetModifierDisableTurning()
	return 1
end

function modifier_freeze_time_start:GetTexture()
	return "freeze_time"
end