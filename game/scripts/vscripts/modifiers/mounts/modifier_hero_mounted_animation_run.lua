modifier_hero_mounted_animation_run = class({})

-------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run:IsHidden()
	return false
end

function modifier_hero_mounted_animation_run:IsPurgable()
	return false
end


function modifier_hero_mounted_animation_run:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run:GetOverrideAnimation( params )
	return ACT_DOTA_CAPTURE
end