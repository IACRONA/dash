modifier_sphere_radiance = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
	{
	} end,
})

function modifier_sphere_radiance:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_sphere_radiance:OnIntervalThink()
	if IsClient() then return end
	local parent = self:GetParent()
	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetAbsOrigin(),
		nil, SPHERE_RADIANCE_RADIUS,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, FIND_ANY_ORDER, false
	)

	for _,enemy in ipairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = parent,
			damage = SPHERE_RADIANCE_DAMAGE * self:GetStackCount(),
			damage_type = DAMAGE_TYPE_MAGICAL,
		})
	end
end