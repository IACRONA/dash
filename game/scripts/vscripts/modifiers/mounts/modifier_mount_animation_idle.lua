modifier_mount_animation_idle = class({})

-------------------------------------------------------------------------------
function modifier_mount_animation_idle:IsHidden()
	return true
end

function modifier_mount_animation_idle:IsPurgable()
	return false
end

function modifier_mount_animation_idle:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

--------------------------------------------------------------------------------
function modifier_mount_animation_idle:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_mount_animation_idle:GetOverrideAnimation()
	return ACT_DOTA_IDLE_RARE
end

function modifier_mount_animation_idle:GetOverrideAnimationRate()
	return 0.5
end

function modifier_mount_animation_idle:OnRemoved()
	if IsServer() then
		self:GetParent():FadeGesture(ACT_DOTA_IDLE_RARE)
	end
end