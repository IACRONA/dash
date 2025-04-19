modifier_mount_z_delta_visual_small = class({})

function modifier_mount_z_delta_visual_small:IsHidden()
	return true
end

function modifier_mount_z_delta_visual_small:IsPurgeException()
	return false
end

function modifier_mount_z_delta_visual_small:IsPurgable()
	return false
end

function modifier_mount_z_delta_visual_small:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_mount_z_delta_visual_small:OnCreated(kv)
end

function modifier_mount_z_delta_visual_small:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}

	return funcs
end

function modifier_mount_z_delta_visual_small:GetVisualZDelta()
	return 35
end