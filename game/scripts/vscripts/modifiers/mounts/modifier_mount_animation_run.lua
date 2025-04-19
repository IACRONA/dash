modifier_mount_animation_run = class({})

-------------------------------------------------------------------------------
function modifier_mount_animation_run:IsHidden()
	return true
end

function modifier_mount_animation_run:IsPurgable()
	return false
end

function modifier_mount_animation_run:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

--------------------------------------------------------------------------------
function modifier_mount_animation_run:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_mount_animation_run:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_mount_animation_run:GetOverrideAnimationRate()
	return 1
end

function modifier_mount_animation_run:OnRemoved()
	if IsServer() then
		self:GetParent():FadeGesture(ACT_DOTA_RUN)
	end
end