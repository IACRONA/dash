modifier_mount_movement = class({})

----------------------------------------------------------------------------------
function modifier_mount_movement:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_movement:IsPurgable()
	return false
end

----------------------------------------------------------------------------------
function modifier_mount_movement:OnCreated( kv )
	if not IsServer() then return end

	self.flCreationTime = GameRules:GetDOTATime( false, true )
	self.blockUseClones = true

	local hAbility = self:GetAbility()

	self.idleActivity = true
	self.heroIdleActivity = ACT_DOTA_IDLE
	self.heroRideActivity = ACT_DOTA_CAPTURE

	self.heroBaseMount = {
		npc_dota_hero_batrider = true,
		npc_dota_hero_mirana = true,
		npc_dota_hero_keeper_of_the_light = true,
		npc_dota_hero_snapfire = true,
		npc_dota_hero_luna = true,
		npc_dota_hero_gyrocopter = true,
		npc_dota_hero_disruptor = true,
		npc_dota_hero_abaddon = true,
		npc_dota_hero_chaos_knight = true,
	}

	if not self.blockUseClones and self:GetHero(false) then
		if self.heroBaseMount[self:GetHero(false):GetUnitName()] then
			self.heroRideActivity = ACT_DOTA_RUN
		end
	end

	if self:GetHero(false):GetUnitName() == "npc_dota_hero_vengefulspirit" then
		self.heroRideActivity = ACT_DOTA_IDLE
	end

	-- Movement
	self.max_speed = 600
	self.flCurrentSpeed = self.max_speed / 2.0
	self.bMaxSpeedNotified = false
	
	self.bHeroWasRiding = false
	self.startActivityRemoved = false

	if hAbility.OnMovementStart ~= nil then
		hAbility:OnMovementStart()
	end

	self.killMountDelay = 0.5

	self:GetCaster():AddActivityModifier("run")
	self:StartIntervalThink( 0.1 )
end

function modifier_mount_movement:RestartModifier()
	if IsServer() then
		self.mountRunning = false
		self.bWasHeroRiding = false
		self.idleActivity = true
		self.startActivityRemoved = false

		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():ClearActivityModifiers()
		self:GetCaster():AddActivityModifier("run")

		self:GetParent():RemoveGesture(ACT_DOTA_RUN)

		if self.nMaxSpeedFx then
			ParticleManager:DestroyParticle(self.nMaxSpeedFx, false)
			
			self.nMaxSpeedFx = nil
		end
		
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_mount_movement:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}

	return funcs
end

function modifier_mount_movement:GetModifierDisableTurning()
	if IsServer() then
		if self.mountRunning then
			return 1
		end
	end

	return 0
end

function modifier_mount_movement:OnUnitMoved(params)
	if IsServer() then
		if params.unit ~= self:GetParent() then
			return
		end

		if not self.startActivityRemoved then
			self:GetParent():RemoveGesture(ACT_DOTA_SPAWN)
			self:GetParent():RemoveGesture(ACT_DOTA_LOADOUT)
			self.startActivityRemoved = true
		end

		local movementSound = "Hero_ChaosKnight.Footstep"
		local step = 0.5

		if self:GetParent():GetModelName() == "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl" then
			movementSound = "Mount.Carpet.Move"
			step = 3.0
		end

		if self:GetParent():GetModelName() == "models/heroes/batrider/batrider.vmdl" then
			movementSound = "Mount.Owl.Move"
			step = 1.0
		end

		if self:GetParent():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
			movementSound = "Mount.Dragon.Move"
			step = 1.5
		end

		if self:GetParent():GetModelName() == "models/courier/badger/courier_badger_flying.vmdl" then
			movementSound = "Mount.Cloud.Move"
			step = 0.33
		end

		if self.lastSoundEmit and GameRules:GetGameTime() < self.lastSoundEmit + step then
			return
		end

		self:GetCaster():EmitSoundParams(movementSound, 0, 5, 0)

		self.lastSoundEmit = GameRules:GetGameTime()
	end
end

function modifier_mount_movement:OnIntervalThink()
	if self.mountRunning then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():AddEffects(EF_NODRAW)

		self:GetParent():ForceKill(true)

		self:StartIntervalThink(-1)
		return
	end

	if self:GetHero(false) then
		local hero = self:GetHero(false)
		local queueUnitTarget = hero.queueCastTargetUnit
		local queueAbility = hero.queueCastTargetAbility
		local minDistance = hero.queueCastTargetDistance

		if queueAbility and hero:HasAbility(queueAbility:GetAbilityName()) and queueUnitTarget and not queueUnitTarget:IsNull() and minDistance then
			local distance = (queueUnitTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()

			if distance <= minDistance then

				if queueUnitTarget:GetUnitName() == "npc_dota_unit_twin_gate" then
					hero:RemoveModifierByName("modifier_mounted")
				end

				ExecuteOrderFromTable_SB2023({
					UnitIndex = hero:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = queueUnitTarget:entindex(),
					AbilityIndex = queueAbility:entindex(),
					Queue = false,
				})

				hero.queueCastTargetUnit = nil
				hero.queueCastTargetAbility = nil

				local afterShockAbility = hero:FindAbilityByName("earthshaker_aftershock")
				if afterShockAbility then
					local esModifier = hero:FindModifierByName("modifier_earthshaker_aftershock")
					if esModifier then
						hero.AfterShockDeactivated = true
						esModifier:Destroy()
					end
				end
			end
		end

		local attackTarget = hero.attackTarget

		if attackTarget and not attackTarget:IsNull() and attackTarget:IsAlive() then
			local distance = (attackTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()

			local attackRange = hero:Script_GetAttackRange()

			if attackRange and distance and distance <= attackRange then
				hero:RemoveModifierByName("modifier_mounted")
				hero.attackTarget = nil
			end
		end

		local castWardPos = hero.queueCastWardPosition
		local wardItemName = hero.queueCastWardItem
		local castWardDistance = hero.queueCastPositionDistance

		if wardItemName and hero:HasItemInInventory(wardItemName) and castWardPos and castWardDistance then
			local item = hero:FindItemInInventory(wardItemName)

			if item then
				local distance = (castWardPos - hero:GetAbsOrigin()):Length2D()

				if distance <= castWardDistance then
					hero:SetCursorPosition(castWardPos)
					item:OnSpellStart()

					self:GetParent():Stop()

					hero.queueCastWardPosition = nil
					hero.queueCastWardItem = nil
				end
			end
		end
	end

	if self:IsHeroRiding() then
		if not self.bWasHeroRiding then
			self.bWasHeroRiding = true
		end

		if not self:GetParent():IsMoving() then
			if not self.idleActivity then
				self:GetHero(true):Hold()
				self:GetHero(true):FadeGesture(self.heroRideActivity)
				self:GetHero(true):StartGestureWithFadeAndPlaybackRate(self.heroIdleActivity, 0.4, 0.4, 1)
	
				self.idleActivity = true

				if self:GetParent():GetModelName() == "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl" then
					self:GetParent():StopSound("Mount.Carpet.Move")
					self.lastSoundEmit = 0
				end
			end
		else
			if self.idleActivity then
				self:GetHero(true):FadeGesture(self.heroIdleActivity)
				self:GetHero(true):StartGestureWithFadeAndPlaybackRate(self.heroRideActivity, 0.4, 0.4, 1)
				
				self.idleActivity = false
			end
		end

	elseif self.bWasHeroRiding or self:GetParent().mountExpired then
		self:MakeDismountRun()
	end
end

function modifier_mount_movement:MakeDismountRun()
	if not self.mountRunning then
		self.mountRunning = true

		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
			print("Failed to apply motion controller")
			return
		end
	
		self:GetParent():RemoveGesture(ACT_DOTA_SPAWN)
		self:GetParent():RemoveGesture(ACT_DOTA_LOADOUT)
		self:GetParent():StartGesture(ACT_DOTA_RUN)
	
		if self:GetHero(false) then
			self:GetHero(false):FadeGesture(self.heroRideActivity)
			self:GetHero(false):FadeGesture(self.heroIdleActivity)
		end
		
		self:StartIntervalThink(self.killMountDelay)
	end
end

--------------------------------------------------------------------------------
function modifier_mount_movement:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():AddEffects(EF_NODRAW)

	local passiveModifier = self:GetParent():FindModifierByName("modifier_mount_passive")
	if passiveModifier then
		if passiveModifier.RemoveParticleEffects then
			passiveModifier:RemoveParticleEffects()
		end

		if passiveModifier.HideCosmeticItemsVisibility then
			passiveModifier:HideCosmeticItemsVisibility()
		end
	end

	self:GetParent():ForceKill(true)

	if self.nMaxSpeedFx then
		ParticleManager:DestroyParticle(self.nMaxSpeedFx, false)

		self.nMaxSpeedFx = nil
	end
end

--------------------------------------------------------------------------------
function modifier_mount_movement:UpdateHorizontalMotion( me, dt )
	if not IsServer() or not self:GetParent() then return end

	if not self:GetHero(false) then
		self:Destroy()
		return
	end

	local bHeroIsRiding = self:IsHeroRiding()

	if not bHeroIsRiding then
		self.flCurrentSpeed = 1000

		if not self.initialRunPosition then
			self.initialRunPosition = self:GetParent():GetAbsOrigin()
		else
			if (self:GetParent():GetAbsOrigin() - self.initialRunPosition):Length2D() > 2500 then
				self:GetParent():AddEffects(EF_NODRAW)

				self:Destroy()
				return
			end
		end
	end

	-- Move
	local vNewPos = self:GetParent():GetOrigin() + self:GetParent():GetForwardVector() * ( dt * self.flCurrentSpeed )

	--check if free mount can trigger not activated checkpoits
	local buildings = Entities:FindAllByNameWithin("*checkpoint*", vNewPos, 1000)

	for _, hBuilding in pairs(buildings) do
		if hBuilding:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS and GameRules.Dungeon:IsCheckpoint(hBuilding) then
			local canMountActivateCheckpoint = false

			if self:GetHero(false) then
				local heroPos = self:GetHero(false):GetAbsOrigin()
				local checkpointDistance = GridNav:FindPathLength(heroPos, GetClearSpaceForUnit(self:GetHero(false), hBuilding:GetAbsOrigin()))
	
				if checkpointDistance >= 0 and checkpointDistance < 1700 then
					canMountActivateCheckpoint = true
				end
			end
	
			if not canMountActivateCheckpoint then
				self:Destroy()
				return
			end
		end	
	end

	me:SetOrigin( vNewPos )

	-- Max Speed FX
	if self.flCurrentSpeed >= self.max_speed and not self.bMaxSpeedNotified and self.max_speed > 0 then
		self.bMaxSpeedNotified = true

		self:OnMaxSpeed()
	end
end

function modifier_mount_movement:OnMaxSpeed()
	self.nMaxSpeedFx = ParticleManager:CreateParticle( "particles/hw_fx/mount_max_speed.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( self.nMaxSpeedFx, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
end

--------------------------------------------------------------------------------
function modifier_mount_movement:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
end
--------------------------------------------------------------------------------
function modifier_mount_movement:IsHeroRiding()
	local hHero = self:GetHero(false)
	if hHero ~= nil and hHero:IsNull() == false then
		return hHero:HasModifier("modifier_mounted") and hHero.hCurrentRidingMount and hHero.hCurrentRidingMount == self:GetParent()
	end

	return false
end

--------------------------------------------------------------------------------
function modifier_mount_movement:GetHero(useCloneIfAvailable)
	if useCloneIfAvailable and self:GetParent().clonedHero and not self:GetParent().clonedHero:IsNull() then
		return self:GetParent().clonedHero
	end

	local hHero = self:GetParent():GetOwnerEntity()

	if not hHero then
		hHero = self:GetParent().hHeroOwner
	end

	return hHero
end

--------------------------------------------------------------------------------
function modifier_mount_movement:GetSpeedMultiplier()
	return 0.5 + 0.5 * (self.flCurrentSpeed / self.max_speed)
end