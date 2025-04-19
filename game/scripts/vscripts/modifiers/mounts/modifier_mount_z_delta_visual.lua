modifier_mount_z_delta_visual = class({})

function modifier_mount_z_delta_visual:IsHidden()
	return true
end

function modifier_mount_z_delta_visual:IsPurgeException()
	return false
end

function modifier_mount_z_delta_visual:IsPurgable()
	return false
end

function modifier_mount_z_delta_visual:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_mount_z_delta_visual:OnCreated(kv)
	
end

function modifier_mount_z_delta_visual:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}

	return funcs
end

function modifier_mount_z_delta_visual:GetVisualZDelta()
	return 85
end