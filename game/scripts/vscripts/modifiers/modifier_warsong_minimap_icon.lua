modifier_warsong_minimap_icon = class{}

function modifier_warsong_minimap_icon:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_warsong_minimap_icon:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = self:GetStackCount() ~= 0,
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
end

function modifier_warsong_minimap_icon:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }
    return decFuncs
end

function modifier_warsong_minimap_icon:GetModifierProvidesFOWVision()
  	return 1
end