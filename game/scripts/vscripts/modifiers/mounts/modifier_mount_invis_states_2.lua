modifier_mount_invis_states_2 = class({})

----------------------------------------------------------------------------------
function modifier_mount_invis_states_2:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_invis_states_2:IsPurgable()
	return false
end

----------------------------------------------------------------------------------
function modifier_mount_invis_states_2:OnCreated( kv )
	if IsServer() then
		-- self.invis = kv.invis or false
		-- self.invisImmune = kv.invis_immune or false
	end
end

-- function modifier_mount_invis_states_2:CheckState()
-- 	local state =
-- 	{
-- 		[MODIFIER_STATE_INVISIBLE] = self.invis,
-- 		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = self.invisImmune,
-- 	}
-- 	return state
-- end

function modifier_mount_invis_states_2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}

	return funcs
end

function modifier_mount_invis_states_2:GetModifierInvisibilityLevel()
	return 2
end