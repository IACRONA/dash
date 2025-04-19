modifier_mount_invis_states = class({})

----------------------------------------------------------------------------------
function modifier_mount_invis_states:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_invis_states:IsPurgable()
	return false
end

----------------------------------------------------------------------------------
function modifier_mount_invis_states:OnCreated( kv )
	if IsServer() then
	end
end

function modifier_mount_invis_states:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}

	return funcs
end

function modifier_mount_invis_states:GetModifierInvisibilityLevel()
	return 1
end