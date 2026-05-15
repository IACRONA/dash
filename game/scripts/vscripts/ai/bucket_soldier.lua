local BUCKET_SOLDIER_STATE_IDLE				= 0
local BUCKET_SOLDIER_STATE_ATTACKING		= 1
local BUCKET_SOLDIER_STATE_LEASHED			= 2
local BUCKET_SOLDIER_STATE_SCREAM_ATTACK	= 3

_G.WINTER2022_BUCKET_SOLDIERS_MAX = 1
_G.WINTER2022_BUCKET_SOLDIERS_MAX_HOME = 0
_G.WINTER2022_BUCKET_SOLDIERS_INTERVAL = 10.0
_G.WINTER2022_BUCKET_SOLDIER_AGGRO_RANGE = 900
_G.WINTER2022_BUCKET_SOLDIER_LEASH_RANGE = 1100
_G.WINTER2022_BUCKET_SOLDIER_LEASHING_REACTIVATE_RANGE = 600	-- if we're leashing back to the well, start searching for aggro targets once we're this close to the well
_G.WINTER2022_BUCKET_SOLDIER_MAX_LEASH_TIME = 3.0
_G.WINTER2022_BUCKET_SOLDIER_MAINTAIN_RANGE = 300
_G.WINTER2022_BUCKET_SOLDIER_FOR_NEUTRALS = false
_G.WINTER2022_BUCKET_SOLDIERS_OUTER_BUCKET_BUFF_MULTIPLIER = 85 -- unused
_G.WINTER2022_BUCKET_SOLDIERS_HOME_BUCKET_BUFF_MULTIPLIER = 110 -- unused
_G.WINTER2022_BUCKET_SOLDIERS_OUTER_BUCKET_MODEL_SCALE_MULTIPLIER = 10
_G.WINTER2022_BUCKET_SOLDIERS_HOME_BUCKET_MODEL_SCALE_MULTIPLIER = 11
_G.WINTER2022_BUCKET_SOLDIERS_ROUND_ARMOR_BONUS = 3
_G.WINTER2022_BUCKET_SOLDIERS_ROUND_STATUS_RESIST_BASE = 20 -- If changing this value, also change on the creature (as DisableResistance) in npc_units_custom.txt
_G.WINTER2022_BUCKET_SOLDIERS_ROUND_STATUS_RESIST_BONUS = 10
_G.WINTER2022_BUCKET_SOLDIERS_INHERENTLY_BUFF_TIER_TWO = 0

if CBucketSoldier == nil then
	CBucketSoldier = class({})
end

function Spawn( entityKeyValues )
	if not IsServer() then return end
	if thisEntity == nil then return end

	thisEntity.AI = CBucketSoldier( thisEntity )
	local ent = thisEntity
	Timers:CreateTimer(0.3, function()
		if ent == nil or ent:IsNull() then return end
		local fThinkTime = ent.AI:BotThink()
		if fThinkTime and fThinkTime > 0 then
			return fThinkTime
		end
		return 0.3
	end)

	Timers:CreateTimer( FrameTime(), function()
		if thisEntity == nil or thisEntity:IsNull() then return end
		thisEntity:AddAbility( "bucket_soldier_fear" )
		local hFear = thisEntity:FindAbilityByName( "bucket_soldier_fear" )
		if hFear then
			hFear:SetLevel( 1 )
			thisEntity:AddNewModifier( thisEntity, hFear, "modifier_bucket_soldier_attack", {} )
		end
		thisEntity:AddAbility( "diretide_bucket_soldier_scream" )
		local hScream = thisEntity:FindAbilityByName( "diretide_bucket_soldier_scream" )
		if hScream then hScream:SetLevel( 1 ) end
		thisEntity.AI.hAbilityScream = hScream
	end )
end

function BucketSoldierThink()
	if IsServer() == false then
		return -1
	end

	local fThinkTime = thisEntity.AI:BotThink()
	if fThinkTime then
		return fThinkTime
	end

	return 0.3  -- Ð£Ð²ÐµÐ»Ð¸Ñ‡ÐµÐ½Ð¾ Ñ 0.1 Ð´Ð¾ 0.3 Ð´Ð»Ñ Ð¾Ð¿Ñ‚Ð¸Ð¼Ð¸Ð·Ð°Ñ†Ð¸Ð¸
end

function CBucketSoldier:constructor( me )
	self.me = me
	self.flNextPatrolTime = GameRules:GetGameTime() + 2.0
	self.flMaxLeashTime = nil
	self.nState = BUCKET_SOLDIER_STATE_IDLE
	self.hAbilityScream = nil
	self.hAttackTarget = nil
end

function CBucketSoldier:ChangeBotState( nNewState )
	if self.nState ~= nNewState then
		if nNewState == BUCKET_SOLDIER_STATE_IDLE then
			self.flNextPatrolTime = GameRules:GetGameTime() + 2.0
		elseif nNewState == BUCKET_SOLDIER_STATE_LEASHED then
			self:LeashToBucket()
		end
	end
	self.nState = nNewState
end

function CBucketSoldier:BotThink()
	if self.me == nil or self.me:IsNull() or ( not self.me:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.1
	end

	if not IsServer() then
		return
	end

	if self.vInitialSpawnPos == nil then
		if self.hBucket ~= nil then
			self.vInitialSpawnPos = self.hBucket:GetAbsOrigin()
		else
			self.vInitialSpawnPos = self.me:GetAbsOrigin()
		end
	end

	if self.nState == BUCKET_SOLDIER_STATE_IDLE then
		if self:ShouldLeash() == true then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_LEASHED )
			return 0.3
		end
		local hTarget = self:FindBestTarget()
		if hTarget ~= nil then
			self.hAttackTarget = hTarget
			self:ChangeBotState( BUCKET_SOLDIER_STATE_ATTACKING )
			return 0.3
		end
		if GameRules:GetGameTime() > self.flNextPatrolTime then
			local flWaitTime = self:PatrolBucket()
			self.flNextPatrolTime = GameRules:GetGameTime() + flWaitTime
		end

	elseif self.nState == BUCKET_SOLDIER_STATE_ATTACKING then
		if self:ShouldLeash() == true then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_LEASHED )
			return 0.3
		end
		if self.hAttackTarget ~= nil and self.hAttackTarget:IsNull() == false and self.hAttackTarget:IsRealHero() == false then
			self.hAttackTarget = self:FindBestTarget()
		end

		if self.hAttackTarget == nil or self.hAttackTarget:IsNull() == true or self.hAttackTarget:IsAlive() == false then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.3
		end

		self:AttackTarget( self.hAttackTarget )
		self:TryScream( self.hAttackTarget )
	elseif self.nState == BUCKET_SOLDIER_STATE_LEASHED then
		if GameRules:GetGameTime() > self.flMaxLeashTime then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.3
		end
		local flDist = ( self.vLeashDestination - self.me:GetAbsOrigin() ):Length2D()
		if flDist < 200 then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.3
		end
		flDist = ( self.vInitialSpawnPos - self.me:GetAbsOrigin() ):Length2D()
		if flDist < WINTER2022_BUCKET_SOLDIER_LEASHING_REACTIVATE_RANGE then
			local hTarget = self:FindBestTarget()
			if hTarget ~= nil then
				self.hAttackTarget = hTarget
				self:ChangeBotState( BUCKET_SOLDIER_STATE_ATTACKING )
				return 0.3
			end
		end
		ExecuteOrderFromTable({
			UnitIndex = self.me:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.vLeashDestination,
			Queue = false,
		})
	end

	return 0.3  -- Ð£Ð²ÐµÐ»Ð¸Ñ‡ÐµÐ½Ð¾ Ñ 0.1 Ð´Ð¾ 0.3 Ð´Ð»Ñ Ð¾Ð¿Ñ‚Ð¸Ð¼Ð¸Ð·Ð°Ñ†Ð¸Ð¸
end

function CBucketSoldier:LeashToBucket()
	self.vLeashDestination = self.vInitialSpawnPos + RandomVector( RandomInt( 50, WINTER2022_BUCKET_SOLDIER_MAINTAIN_RANGE ) )
	self.flMaxLeashTime = GameRules:GetGameTime() + WINTER2022_BUCKET_SOLDIER_MAX_LEASH_TIME
end

function CBucketSoldier:AttackTarget( hTarget )
	ExecuteOrderFromTable( {
		UnitIndex = self.me:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = hTarget:entindex(),
	} )
end

function CBucketSoldier:PatrolBucket()
	local vTargetPos = self.vInitialSpawnPos + RandomVector( RandomInt( 50, WINTER2022_BUCKET_SOLDIER_MAINTAIN_RANGE ) )
	local flDist = ( vTargetPos - self.me:GetAbsOrigin() ):Length2D()
	ExecuteOrderFromTable({
		UnitIndex = self.me:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = vTargetPos,
		Queue = false,
	})
	local fSleepTime = ( flDist / self.me:GetIdealSpeed() ) + RandomInt( 3.0, 10.0 )
	return fSleepTime
end

function CBucketSoldier:FindBestTarget()
	local fSearchRadius = WINTER2022_BUCKET_SOLDIER_AGGRO_RANGE
	local vSearchOrigin = self.me:GetAbsOrigin()
	if self.hBucket ~= nil and self.hBucket:IsNull() == false and self.hBucket:IsAlive() == true then
		vSearchOrigin = self.hBucket:GetAbsOrigin()
	end

	local Units = FindUnitsInRadius( self.me:GetTeamNumber(), vSearchOrigin, self.me, fSearchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
	local hBestNonHero = nil
	if #Units > 0 then
		for _,hUnit in pairs( Units ) do
			if hUnit ~= nil and hUnit:IsNull() == false and hUnit:GetTeam() ~= DOTA_TEAM_NEUTRALS and hUnit:IsAlive() and hUnit:IsInvulnerable() == false then
				if hUnit:IsRealHero() then
					return hUnit
				else
					if hBestNonHero == nil then
						hBestNonHero = hUnit
					end
				end
			end
		end
	end

	return hBestNonHero
end

-----------------------------------------------------------------------------------------

local SCREAM_COOLDOWN = 12.0
local SCREAM_RANGE = 800
local SCREAM_DAMAGE = 120
local SCREAM_FEAR_DURATION = 2.0

function CBucketSoldier:TryScream( hTarget )
	if not hTarget or hTarget:IsNull() or not hTarget:IsAlive() then return end
	local flNow = GameRules:GetGameTime()
	if self.flNextScreamTime and flNow < self.flNextScreamTime then return end
	local flDist = ( hTarget:GetAbsOrigin() - self.me:GetAbsOrigin() ):Length2D()
	if flDist > SCREAM_RANGE then return end

	self.flNextScreamTime = flNow + SCREAM_COOLDOWN
	EmitSoundOn( "Soldier.Scream", self.me )

	local vOrigin = self.me:GetAbsOrigin()
	local vDir = hTarget:GetAbsOrigin() - vOrigin
	vDir.z = 0
	local flLen = vDir:Length2D()
	if flLen < 1 then return end
	vDir = vDir / flLen

	local info = {
		EffectName      = "particles/hw_fx/golem_terror.vpcf",
		vSpawnOrigin    = vOrigin,
		fStartRadius    = 150,
		fEndRadius      = 250,
		vVelocity       = vDir * 1200,
		fDistance       = 800,
		Source          = self.me,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	local nProjectile = ProjectileManager:CreateLinearProjectile( info )

	local hMe = self.me
	Timers:CreateTimer( 0.8, function()
		local hHit = FindUnitsInRadius( hMe:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, 200,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _, u in ipairs( hHit ) do
			if u and not u:IsNull() and u:IsAlive() and not u:IsMagicImmune() then
				ApplyDamage({ victim = u, attacker = hMe, damage = SCREAM_DAMAGE, damage_type = DAMAGE_TYPE_MAGICAL })
				u:AddNewModifier( hMe, nil, "modifier_bucket_soldier_attack_fear", { duration = SCREAM_FEAR_DURATION } )
			end
		end
	end)
end

-----------------------------------------------------------------------------------------

function CBucketSoldier:ShouldLeash()
	local flDist = ( self.vInitialSpawnPos - self.me:GetAbsOrigin() ):Length2D()
	if flDist > WINTER2022_BUCKET_SOLDIER_LEASH_RANGE then
		return true
	end
	return false
end
