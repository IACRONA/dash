modifier_mount_clones_invulnerable = class({})

----------------------------------------------------------------------------------
function modifier_mount_clones_invulnerable:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_clones_invulnerable:IsPurgable()
	return false
end

----------------------------------------------------------------------------------
function modifier_mount_clones_invulnerable:OnCreated( kv )
	if IsServer() then
	end
end

function modifier_mount_clones_invulnerable:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end