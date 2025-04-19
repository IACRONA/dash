modifier_hero_mounted_animation_run_mounts = class({})

-------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run_mounts:IsHidden()
	return false
end

function modifier_hero_mounted_animation_run_mounts:IsPurgable()
	return false
end


function modifier_hero_mounted_animation_run_mounts:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run_mounts:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run_mounts:GetOverrideAnimation( params )
	return ACT_DOTA_RUN
end

--------------------------------------------------------------------------------
function modifier_hero_mounted_animation_run_mounts:GetActivityTranslationModifiers()
	return "run"
end