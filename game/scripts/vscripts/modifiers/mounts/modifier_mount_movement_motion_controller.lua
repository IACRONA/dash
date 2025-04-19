modifier_mount_movement_motion_controller = class({})

----------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:CheckState()
	local state = 
	{
		[ MODIFIER_STATE_STUNNED ] = true,
	}
	return state
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:DeclareFunctions()
	local funcs = 
	{
		--MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

-----------------------------------------------------------------------
function modifier_mount_movement_motion_controller:GetOverrideAnimation( params )
	return self:GetAbility():GetAnimation_Movement()
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:GetModifierDisableTurning( params )
	return 1
end

----------------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:OnDeath( params )
	if IsServer() == false then
		return
	end

	local hAttacker = params.attacker
	local hVictim = params.unit
	if hAttacker ~= nil and hAttacker:IsNull() == false and hAttacker == self:GetParent() and self:GetHero() ~= nil and
		hVictim ~= nil and hVictim:IsNull() == false and hVictim:IsRealHero() == true then
		GameRules.Winter2022:GetTeamAnnouncer( self:GetHero():GetTeamNumber() ):OnMountKill( self:GetHero() )
	end
end

----------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:OnCreated( kv )
	if not IsServer() then return end

	self.flCreationTime = GameRules:GetDOTATime( false, true )

	local hAbility = self:GetAbility()

	-- Movement
	self.max_speed = hAbility:GetSpecialValueFor("max_speed")
	self.acceleration = hAbility:GetSpecialValueFor("acceleration")
	self.deceleration = hAbility:GetSpecialValueFor("deceleration")
	self.turn_rate_min = hAbility:GetSpecialValueFor( "turn_rate_min" )
	self.turn_rate_max = hAbility:GetSpecialValueFor( "turn_rate_max" )

	-- Impact
	self.impact_radius = hAbility:GetSpecialValueFor("impact_radius")
	self.impact_stun = hAbility:GetSpecialValueFor("impact_stun")
	self.base_damage = hAbility:GetSpecialValueFor("base_damage")
	self.damage_per_level = hAbility:GetSpecialValueFor("damage_per_level")
	self.knockback_distance = hAbility:GetSpecialValueFor("knockback_distance")
	self.knockback_duration = hAbility:GetSpecialValueFor("knockback_duration")

	-- Misc
	self.flCurrentSpeed = self.max_speed / 2.0
	self.flDespawnTime = 0.5
	self.nTreeDestroyRadius = 75
	self.bMaxSpeedNotified = false
	self.bCrashScheduled = false
	self.hCrashScheduledUnit = nil

	self.bHeroWasRiding = false

	if self:GetParent().flDesiredYaw == nil then
		self:GetParent().flDesiredYaw = self:GetParent():GetAnglesAsVector().y
	end

	if hAbility:GetAnimation_Movement() ~= nil then
		self:GetParent():StartGesture( hAbility:GetAnimation_Movement() )
	end

	if self:ApplyHorizontalMotionController() == false then 
		self:Destroy()
		print("Failed to apply motion controller")
		return
	end
	
	if hAbility.OnMovementStart ~= nil then
		hAbility:OnMovementStart()
	end

	self:StartIntervalThink( 0.02 )
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():RemoveHorizontalMotionController( self )
	
	local hAbility = self:GetAbility()
	if hAbility ~= nil then
		if hAbility.GetAnimation_Movement ~= nil and hAbility:GetAnimation_Movement() ~= nil then
			self:GetParent():RemoveGesture( hAbility:GetAnimation_Movement() )
		end
		if hAbility.OnMovementEnd ~= nil then
			hAbility:OnMovementEnd()
		end
	end
	-- always despawn mount when it stops moving
	if not self:GetParent():HasModifier("modifier_kill") and self.bDisableDespawn ~= true then
		self:GetParent():AddNewModifier( nil, nil, "modifier_kill", { duration = self.flDespawnTime } )
		print("mount killer - stop moving!")
	end
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:UpdateHorizontalMotion( me, dt )
	if not IsServer() or not self:GetParent() then return end

	if not self:GetHero() then
		self:Destroy()
		return
	end

	local bHeroIsRiding =  self:IsHeroRiding()
	-- print("riding: ", bHeroIsRiding)

	-- Calculate turning
	local curAngles = self:GetParent():GetAnglesAsVector()
	local flAngleDiff = bHeroIsRiding and AngleDiff( self:GetParent().flDesiredYaw, curAngles.y ) or 0

	local flTurnAmount = dt * ( self.turn_rate_min + self:GetSpeedMultiplier() * ( self.turn_rate_max - self.turn_rate_min ) )

	flTurnAmount = math.min( flTurnAmount, math.abs( flAngleDiff ) )

	if flAngleDiff < 0.0 then
		flTurnAmount = flTurnAmount * -1
	end

	if flAngleDiff ~= 0.0 then
		curAngles.y = curAngles.y + flTurnAmount
		me:SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
	end

	if not self.setHeroInitialPos and bHeroIsRiding then
		local startPos = self:GetParent():GetAbsOrigin()

		if self:GetAbility() ~= nil and self:GetAbility().GetRiderVerticalOffset ~= nil then
			startPos.z = startPos.z + self:GetAbility():GetRiderVerticalOffset()
		end
	
		self:GetHero():SetAbsOrigin( startPos )
		self:GetHero():SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )

		self.setHeroInitialPos = true
	end

	--set hero angles
	if bHeroIsRiding then
		self:GetHero():SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
	end

	local targetPos = self:GetParent().targetPos
	
	if bHeroIsRiding then
		local stopMount = false

		if not targetPos then
			stopMount = true
		else
			local isMountMovingToEndPos = true
			local currentDirectionToEndPos = (targetPos - self:GetParent():GetAbsOrigin()):Normalized()
			local currentDistanceToEndPos = (targetPos - self:GetParent():GetAbsOrigin()):Length2D()

			if not self.lastDirectionToEndPos then
				self.lastDirectionToEndPos = currentDirectionToEndPos
			end

			if currentDirectionToEndPos:Dot(self.lastDirectionToEndPos) < 0.25 then
				isMountMovingToEndPos = false
			end
			
			if currentDistanceToEndPos <= 50 or not isMountMovingToEndPos then
				stopMount = true
				self:GetParent().targetPos = nil
				self.lastDirectionToEndPos = nil
				self.forceCanMoving = false
			end
		end

		-- if not targetPos or ((targetPos - self:GetParent():GetAbsOrigin()):Length2D() <= 50) or (me:GetForwardVector():Dot(targetPos:Normalized()) < 0) then
		-- -- print("STOP!")
		-- --set hero angles
		-- 	self:GetHero():SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
		-- 	return
		-- end

		if stopMount then
			-- print("stop mount")
			return
		end
	end

	-- Acceleration
	local flMaxSpeed = self.max_speed
	if bHeroIsRiding then
		local flSpeedModifier = self:GetHero():GetIdealSpeed() / self:GetHero():GetBaseMoveSpeed()
		if flSpeedModifier < 1.0 then
			flMaxSpeed = flMaxSpeed * flSpeedModifier
		end
	end

	if flMaxSpeed <= 0 and self.max_speed > 0 then
		self:GetHero():RemoveModifierByName( "modifier_mounted" )
		self:Destroy()
		print("Max speed is zero")
		return
	end

	local flAcceleration = bHeroIsRiding and self.acceleration or -self.deceleration
	self.flCurrentSpeed = math.max( math.min( self.flCurrentSpeed + ( dt * flAcceleration ), flMaxSpeed ), 0 )

	if not bHeroIsRiding then
		self.flCurrentSpeed = 1000

		if not self.initialRunPosition then
			self.initialRunPosition = self:GetParent():GetAbsOrigin()

			self:GetParent():AddNewModifier(nil, nil, "modifier_kill", { duration = 5 })
		else
			if (self:GetParent():GetAbsOrigin() - self.initialRunPosition):Length2D() > 2500 then
				self:GetParent():AddEffects(EF_NODRAW)

				self:Destroy()
				return
			end
		end
	end

	-- Check to despawn mount
	if self.flCurrentSpeed <= 0 and not bHeroIsRiding then
		print("despawn hero")
		self:Destroy()
		return
	end

	-- Move
	local vNewPos = self:GetParent():GetOrigin() + self:GetParent():GetForwardVector() * ( dt * self.flCurrentSpeed )

	if self.lastGoodPosition and self.lastGoodPosition == vNewPos then
		return
	end

	local checkpointPos = GameRules.Dungeon:GetLatestValidPlayerCheckpointPos(self:GetHero())
	
	GridNav:DestroyTreesAroundPoint( vNewPos, self.nTreeDestroyRadius, true )

	local canContinueMoving = true

	if bHeroIsRiding then

		if not self.forceCanMoving then
			if not GridNav:CanFindPath( me:GetOrigin(), vNewPos ) then
				canContinueMoving = false
	
				if targetPos and GridNav:CanFindPath(GetClearSpaceForUnit(me, checkpointPos), targetPos) and 
					GridNav:FindPathLength(GetClearSpaceForUnit(me, me:GetAbsOrigin()), targetPos) < 1700 
				then
					self.forceCanMoving = true
					canContinueMoving = true
				end
			end
		end
	end

	-- local canContinueMoving = true

	-- if not GridNav:CanFindPath( me:GetOrigin(), vNewPos ) then

	-- 	-- if we are just crashing into trees, we can keep moving but will still slow down
	-- 	GridNav:DestroyTreesAroundPoint( vNewPos, self.nTreeDestroyRadius, true )

	-- 	if bHeroIsRiding then
	-- 		canContinueMoving = false
			
	-- 		if targetPos and GridNav:CanFindPath(GetClearSpaceForUnit(me, checkpointPos), targetPos) then
	-- 			canContinueMoving = true
	-- 		end
	-- 	end
	-- end

	local posToVerify = vNewPos

	if self.forceCanMoving then
		posToVerify = GetClearSpaceForUnit(me, vNewPos)
	end

	if not GridNav:CanFindPath(GetClearSpaceForUnit(me, checkpointPos), posToVerify) then
		canContinueMoving = false
		self.forceCanMoving = false
		print("brak pozycji!")
	end

	if bHeroIsRiding and not canContinueMoving then
		local backPos = me:GetAbsOrigin() - me:GetForwardVector() * 75
		
		vNewPos = GetClearSpaceForUnit(me, backPos)

		--clear the targeted position so the mount will stop
		self:GetParent().targetPos = nil

		-- if self.lastGroundHeight and (math.abs(GetGroundHeight(vNewPos, me) - self.lastGroundHeight) > 35) then			
		-- 	local backPos = me:GetAbsOrigin() - me:GetForwardVector() * 25

		-- 	vNewPos = GetClearSpaceForUnit(me, backPos)
		-- end
	end


	me:SetOrigin( vNewPos )

	-- Set Hero Position too. Set here instead of in modifier_mounted so that update order doesn't matter
	if bHeroIsRiding then
		local vHeroPosition = vNewPos
		if self:GetAbility() ~= nil and self:GetAbility().GetRiderVerticalOffset ~= nil then
			vHeroPosition.z = vHeroPosition.z + self:GetAbility():GetRiderVerticalOffset()
		end
	
		self:GetHero():SetAbsOrigin( vHeroPosition )
		self:GetHero():SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
	end

	-- Max Speed FX
	if self.flCurrentSpeed >= self.max_speed and not self.bMaxSpeedNotified and self.max_speed > 0 then
		self.bMaxSpeedNotified = true
	
		local hAbility = self:GetAbility()
		if hAbility ~= nil and hAbility.OnMaxSpeed ~= nil then
			hAbility:OnMaxSpeed()
		end
	end

	self.bHeroWasRiding = bHeroIsRiding

	self.lastGroundHeight = GetGroundHeight(vNewPos, me)
	self.lastGoodPosition = vNewPos
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self:Destroy()
end
--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:IsHeroRiding()
	local hHero = self:GetHero()
	if hHero ~= nil and hHero:IsNull() == false then

		return hHero:HasModifier("modifier_mounted") and hHero.hCurrentRidingMount and hHero.hCurrentRidingMount == self:GetParent()
	end

	return false
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:GetHero()
	return self:GetParent():GetOwnerEntity()
end

--------------------------------------------------------------------------------
function modifier_mount_movement_motion_controller:GetSpeedMultiplier()
	return 0.5 + 0.5 * (self.flCurrentSpeed / self.max_speed)
end