LinkLuaModifier("modifier_morphling_boss_frostbite", "abilities/morphling_boss_frostbite", LUA_MODIFIER_MOTION_NONE)

morphling_boss_frostbite = class({})

function morphling_boss_frostbite:Start(target)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster,self,"modifier_morphling_boss_frostbite",{ duration = duration * ( 1 - target:GetStatusResistance() ) })
	self:PlayEffects( caster, target )
end

function morphling_boss_frostbite:PlayEffects( caster, target )
	local projectile_name = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf"
	local projectile_speed = 1000
	local info = {Target = target,Source = caster,Ability = self,EffectName = projectile_name,iMoveSpeed = projectile_speed,vSourceLoc= caster:GetAbsOrigin(),bDodgeable = false}
	ProjectileManager:CreateTrackingProjectile(info)
end

modifier_morphling_boss_frostbite = class({})
function modifier_morphling_boss_frostbite:IsHidden() return false end
function modifier_morphling_boss_frostbite:IsDebuff() return true end
function modifier_morphling_boss_frostbite:IsStunDebuff() return false end
function modifier_morphling_boss_frostbite:IsPurgable() return true end

function modifier_morphling_boss_frostbite:OnCreated( kv )
	local tick_damage = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
	self.interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	if IsServer() then
		self.damageTable = {victim = self:GetParent(),attacker = self:GetCaster(),damage = tick_damage*self.interval,damage_type = DAMAGE_TYPE_MAGICAL,ability = self:GetAbility()}
		self:StartIntervalThink( self.interval )
		self:GetParent():EmitSound("hero_Crystal.frostbite")
	end
end

function modifier_morphling_boss_frostbite:OnRefresh( kv )
	self:OnCreated()
end

function modifier_morphling_boss_frostbite:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("hero_Crystal.frostbite")
end

function modifier_morphling_boss_frostbite:CheckState()
	local state = {[MODIFIER_STATE_DISARMED] = true,[MODIFIER_STATE_ROOTED] = true,[MODIFIER_STATE_INVISIBLE] = false}
	return state
end

function modifier_morphling_boss_frostbite:OnIntervalThink()
    if not IsServer() then return end
	ApplyDamage( self.damageTable )
end

function modifier_morphling_boss_frostbite:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_morphling_boss_frostbite:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end