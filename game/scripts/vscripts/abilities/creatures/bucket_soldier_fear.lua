bucket_soldier_fear = class({})

LinkLuaModifier( "modifier_bucket_soldier_attack", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bucket_soldier_attack_fear", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bucket_soldier_attack_ready", "abilities/creatures/bucket_soldier_fear", LUA_MODIFIER_MOTION_NONE )

-- intrinsic modifier применяется вручную через AddAbility в bucket_soldier.lua

-- -----------------------------------------------------------------------

if modifier_bucket_soldier_attack_ready == nil then
	modifier_bucket_soldier_attack_ready = class( {} )
end

function modifier_bucket_soldier_attack_ready:IsHidden() return true end

-- -----------------------------------------------------------------------

if modifier_bucket_soldier_attack == nil then
	modifier_bucket_soldier_attack = class( {} )
end

function modifier_bucket_soldier_attack:IsHidden() return false end
function modifier_bucket_soldier_attack:IsPurgable() return false end

function modifier_bucket_soldier_attack:OnCreated( kv )
	if not IsServer() then return end
	if not self:GetAbility() then return end

	self.debuff_duration = self:GetAbility():GetSpecialValueFor( "debuff_duration" )
	if self.debuff_duration == 0 then self.debuff_duration = 2.0 end

	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_bucket_soldier_attack_ready", { duration = -1 } )
	self:StartIntervalThink( 0.25 )
end

function modifier_bucket_soldier_attack:OnIntervalThink()
	if not IsServer() then return end
	local hAbility = self:GetAbility()
	if not hAbility then return end
	if hAbility:IsCooldownReady() and not self:GetCaster():HasModifier( "modifier_bucket_soldier_attack_ready" ) then
		self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_bucket_soldier_attack_ready", { duration = -1 } )
	end
end

function modifier_bucket_soldier_attack:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_bucket_soldier_attack:OnAttackLanded( params )
	if not IsServer() then return end

	local hAbility = self:GetAbility()
	if not hAbility or not hAbility:IsCooldownReady() then return end

	local hAttacker = params.attacker
	if hAttacker == nil or hAttacker:IsNull() or hAttacker ~= self:GetParent() then return end

	local hVictim = params.target
	if hVictim == nil or hVictim:IsNull() then return end
	if hVictim:GetTeamNumber() == hAttacker:GetTeamNumber() then return end

	local bHit = false

	if hVictim:IsIllusion() and not hVictim:IsStrongIllusion() then
		hVictim:Kill( hAbility, self:GetCaster() )
		bHit = true
	end

	if hVictim:IsRealHero() and not hVictim:IsMagicImmune() then
		hVictim:AddNewModifier( self:GetCaster(), hAbility, "modifier_bucket_soldier_attack_fear", { duration = self.debuff_duration } )
		bHit = true
	end

	if bHit then
		hAbility:StartCooldown( 8.0 )
		self:GetCaster():RemoveModifierByName( "modifier_bucket_soldier_attack_ready" )
		EmitSoundOn( "Hero_WarlockGolem.Roar", hVictim )
	end
end

-- -----------------------------------------------------------------------

if modifier_bucket_soldier_attack_fear == nil then
	modifier_bucket_soldier_attack_fear = class( {} )
end

function modifier_bucket_soldier_attack_fear:IsDebuff() return true end
function modifier_bucket_soldier_attack_fear:IsPurgable() return false end

function modifier_bucket_soldier_attack_fear:OnCreated( kv )
	if not IsServer() then return end

	-- бежать от солдата
	local vSoldierPos = self:GetCaster() and not self:GetCaster():IsNull() and self:GetCaster():GetAbsOrigin() or nil
	local vHeroPos = self:GetParent():GetAbsOrigin()

	if vSoldierPos then
		local vDir = vHeroPos - vSoldierPos
		vDir.z = 0
		local flLen = vDir:Length2D()
		if flLen > 10 then
			self.vTargetDir = vDir / flLen
		else
			self.vTargetDir = Vector( 1, 0, 0 )
		end
	else
		self.vTargetDir = Vector( 1, 0, 0 )
	end

	self:StartIntervalThink( 0.1 )
end

function modifier_bucket_soldier_attack_fear:OnIntervalThink()
	if not IsServer() then return end
	if not self.vTargetDir then return end
	local vDestination = self:GetParent():GetAbsOrigin() + self.vTargetDir * 400
	self:GetParent():MoveToPosition( vDestination )
end

function modifier_bucket_soldier_attack_fear:CheckState()
	return {
		[ MODIFIER_STATE_FEARED ]             = true,
		[ MODIFIER_STATE_COMMAND_RESTRICTED ] = true,
		[ MODIFIER_STATE_DISARMED ]           = true,
		[ MODIFIER_STATE_SILENCED ]           = true,
		[ MODIFIER_STATE_MUTED ]              = true,
		[ MODIFIER_STATE_NO_UNIT_COLLISION ]  = true,
	}
end
