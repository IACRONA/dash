
modifier_summon_mount = class({})

----------------------------------------------------------------------------------

function modifier_summon_mount:IsHidden()
	return true
end

----------------------------------------------------------------------------------

function modifier_summon_mount:IsPurgable()
	return false
end

----------------------------------------------------------------------------------

function modifier_summon_mount:OnCreated()
	if IsServer() == false then
		return
	end
end

-----------------------------------------------------------------------------------------

function modifier_summon_mount:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

----------------------------------------------------------------------------------

function modifier_summon_mount:GetModifierIncomingDamage_Percentage( params )
	if not IsServer() then
		return 0
	end

	local hAttacker = params.attacker
	if hAttacker == nil or hAttacker:IsNull() then
		return 0
	end

	-- if we're mounted don't put the ability on cd so that we can activate it again to dismount
	if self:GetParent():HasModifier( "modifier_mounted" ) then
		return 0
	end

	if self:GetAbility() then
		self:GetAbility():EndChannel(true)
	end

	return 0
end

-----------------------------------------------------------------------
