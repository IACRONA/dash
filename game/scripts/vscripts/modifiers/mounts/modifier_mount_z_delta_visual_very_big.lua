modifier_mount_z_delta_visual_very_big = class({})

function modifier_mount_z_delta_visual_very_big:IsHidden()
	return true
end

function modifier_mount_z_delta_visual_very_big:IsPurgeException()
	return false
end

function modifier_mount_z_delta_visual_very_big:IsPurgable()
	return false
end

function modifier_mount_z_delta_visual_very_big:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

function modifier_mount_z_delta_visual_very_big:OnCreated(kv)
end

function modifier_mount_z_delta_visual_very_big:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}

	return funcs
end

function modifier_mount_z_delta_visual_very_big:GetVisualZDelta()
	return 200
end