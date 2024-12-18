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
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:SetContextThink( "BucketSoldierThink", BucketSoldierThink, 0.1 )
	thisEntity.AI = CBucketSoldier( thisEntity )
end

function BucketSoldierThink()
	if IsServer() == false then
		return -1
	end

	local fThinkTime = thisEntity.AI:BotThink()
	if fThinkTime then
		return fThinkTime
	end

	return 0.1
end

function CBucketSoldier:constructor( me )
	self.me = me
	self.flNextPatrolTime = GameRules:GetGameTime() + 2.0
	self.flMaxLeashTime = nil
	self.nState = BUCKET_SOLDIER_STATE_IDLE
	self.hAbilityScream = self.me:FindAbilityByName( "diretide_bucket_soldier_scream" )
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
			return 0.1
		end

		local hTarget = self:FindBestTarget()
		if hTarget ~= nil then
			self.hAttackTarget = hTarget
			self:ChangeBotState( BUCKET_SOLDIER_STATE_ATTACKING )
			return 0.1
		end

		if GameRules:GetGameTime() > self.flNextPatrolTime then
			local flWaitTime = self:PatrolBucket()
			self.flNextPatrolTime = GameRules:GetGameTime() + flWaitTime
		end

	elseif self.nState == BUCKET_SOLDIER_STATE_ATTACKING then
		if self:ShouldLeash() == true then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_LEASHED )
			return 0.1
		end
		if self.hAttackTarget ~= nil and self.hAttackTarget:IsNull() == false and self.hAttackTarget:IsRealHero() == false then
			self.hAttackTarget = self:FindBestTarget()
		end

		if self.hAttackTarget == nil or self.hAttackTarget:IsNull() == true or self.hAttackTarget:IsAlive() == false then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.1
		end

		self:AttackTarget( self.hAttackTarget )
		if self.hAbilityScream and self.hAbilityScream:IsFullyCastable() then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_SCREAM_ATTACK )
		end
	elseif self.nState == BUCKET_SOLDIER_STATE_LEASHED then
		if GameRules:GetGameTime() > self.flMaxLeashTime then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.1
		end
		local flDist = ( self.vLeashDestination - self.me:GetAbsOrigin() ):Length2D()
		if flDist < 200 then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
			return 0.1
		end
		flDist = ( self.vInitialSpawnPos - self.me:GetAbsOrigin() ):Length2D()
		if flDist < WINTER2022_BUCKET_SOLDIER_LEASHING_REACTIVATE_RANGE then
			local hTarget = self:FindBestTarget()
			if hTarget ~= nil then
				self.hAttackTarget = hTarget
				self:ChangeBotState( BUCKET_SOLDIER_STATE_ATTACKING )
				return 0.1
			end
		end
		ExecuteOrderFromTable({
			UnitIndex = self.me:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.vLeashDestination,
			Queue = false,
		})
	elseif self.nState == BUCKET_SOLDIER_STATE_SCREAM_ATTACK then
		if self:ShouldLeash() == true then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_LEASHED )
			return 0.1
		end
		if self.hAttackTarget == nil or self.hAttackTarget:IsNull() == true or self.hAttackTarget:IsAlive() == false then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
		end
		if self.hAbilityScream == nil then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_IDLE )
		end
		ExecuteOrderFromTable( {
			UnitIndex = self.me:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = self.hAbilityScream:entindex(),
			Position = self.hAttackTarget:GetAbsOrigin(),
		} )
		if not self.hAbilityScream:IsFullyCastable() then
			self:ChangeBotState( BUCKET_SOLDIER_STATE_ATTACKING )
		end
	end

	return 0.1
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

function CBucketSoldier:ShouldLeash()
	local flDist = ( self.vInitialSpawnPos - self.me:GetAbsOrigin() ):Length2D()
	if flDist > WINTER2022_BUCKET_SOLDIER_LEASH_RANGE then
		return true
	end
	return false
end
