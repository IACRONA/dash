modifier_mount_original_model_invisible = class({})

----------------------------------------------------------------------------------
function modifier_mount_original_model_invisible:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_original_model_invisible:IsPurgable()
	return false
end

function modifier_mount_original_model_invisible:IsPermanent()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_original_model_invisible:OnCreated( kv )
	if IsServer() then
		self:GetParent():SetRenderAlpha(0)
	end
end

function modifier_mount_original_model_invisible:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_mount_original_model_invisible:GetModifierInvisibilityLevel( params )
	return 0.999999
end

function modifier_mount_original_model_invisible:OnRemoved()
	if IsServer() then
		self:GetParent():SetRenderAlpha(1)
	end
end