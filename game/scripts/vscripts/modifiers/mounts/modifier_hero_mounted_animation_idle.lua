modifier_hero_mounted_animation_idle = class({})

-------------------------------------------------------------------------------
function modifier_hero_mounted_animation_idle:IsHidden()
	return false
end

function modifier_hero_mounted_animation_idle:IsPurgable()
	return false
end

function modifier_hero_mounted_animation_idle:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_idle:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_idle:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end