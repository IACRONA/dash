if  summon_mount == nil then
	summon_mount = class({})
end

LinkLuaModifier( "modifier_summon_mount", "modifiers/mounts/modifier_summon_mount", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "mount_hero_ms_bonus", "modifiers/mounts/mount_hero_ms_bonus", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function summon_mount:Precache( context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_earth/courier_trail_earth.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/trails/mount_snail_trail.vpcf", context )
	PrecacheResource( "particle", "articles/cosmetic_inventory/mounts/grillhound_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/grillhound_ambient_footprints.vpcf", context )
end

function summon_mount:GetIntrinsicModifierName()
	return "modifier_summon_mount"
end

function summon_mount:IsHiddenAbilityCastable()
	return true
end

--------------------------------------------------------------------------------

function summon_mount:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function summon_mount:IsRefreshable()
	return false
end

function summon_mount:IsCosmetic(hEntity)
	return true
end

--------------------------------------------------------------------------------

function summon_mount:IsStealable()
	return false
end

function summon_mount:GetCastAnimation()
	if self.heroMounted or self:GetCaster():HasModifier("modifier_mounted") then
		return -1
	end

	return ACT_DOTA_GENERIC_CHANNEL_1
end

--------------------------------------------------------------------------------

summon_mount.forbiddenModifiers = {
	modifier_storm_spirit_ball_lightning = "storm_spirit_ball_lightning"
}

function summon_mount:OnChannelThink(flInterval)
	if IsServer() then
		if self.forceInterrupt then
			self.forceInterrupt = false
			self:EndChannel(true)
			
			StopSoundOn("Mount.Channeling.Start", self:GetCaster())
		end
	end
end

function summon_mount:OnSpellStart()
	if IsServer() then
		--Channeling can't be interrupted in OnSpellStart, only in OnChannelThink
		if self.heroMounted or self:GetCaster():HasModifier("modifier_mounted") then
			self.forceInterrupt = true
			return
		end
		self:GetCaster():EmitSound("Mount.Channeling.Start")
	end
end

function summon_mount:DismountHero()
	self.heroMounted = false

	local hCaster = self:GetCaster()
	if not hCaster then
		return
	end

	hCaster:RemoveModifierByName("modifier_mounted")
	hCaster:RemoveModifierByName("modifier_phased")
	hCaster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	if self.mount then
		self.mount.mountExpired = true
		self.mount:RemoveModifierByName("modifier_phased")

		local movementModifier = self.mount:FindModifierByName("modifier_mount_movement")
		if movementModifier then
			movementModifier:MakeDismountRun()
		end
	end
 
	--check current position
	local positionChecker = self:GetCaster():FindModifierByName("modifier_hero_pos_checker_sb_2023")
	if positionChecker then
		positionChecker:VerifySelfCurrentPosition(true)
	end

	self:GetCaster():RemoveModifierByName("mount_hero_ms_bonus")
end

function summon_mount:CreateMount()
	local hCaster = self:GetCaster()
	local initPos = hCaster:GetAbsOrigin() + RandomVector(100)
	
	local mount = CreateUnitByName( "npc_dota_base_mount", initPos, true, hCaster, hCaster, hCaster:GetTeamNumber() )
	
	if mount then
		self.mount = mount
		-- Не добавляем эффект EF_NODRAW, чтобы конь всегда был виден
		-- self.mount:AddEffects(EF_NODRAW)
		self.mount:SetOwner(self:GetCaster())
		
		local vPos = self:GetValidPositionForMount()
		if not vPos then
			vPos = self:GetCaster():GetAbsOrigin()
		end

		self.mount:SetAbsOrigin(vPos)
		self.mount:SetForwardVector(self:GetCaster():GetForwardVector())

		FindClearSpaceForUnit(self.mount, vPos, true)

		-- Постоянный phased модификатор для коня
		self.mount:AddNewModifier(self.mount, nil, "modifier_phased", {duration = -1})

		local passiveAbility = self.mount:FindAbilityByName("mount_moving_passive")
		if passiveAbility then
			passiveAbility:SetLevel(1)
		end
							
		self:GetCaster():_SetPlayerMount_SB2023(self.mount)

		local mountModifier = self.mount:FindModifierByName("modifier_mount_passive")
		if mountModifier then
			mountModifier:UpdateMountModel(self:GetCaster())
		end
	end
end

function summon_mount:OnChannelFinish(bInterrupted)
	if IsServer() then
		if self:GetCaster():HasModifier('modifier_freeze_time_start') then return end
		if bInterrupted then
			self:DismountHero()
			StopSoundOn("Mount.Channeling.Start", self:GetCaster())
		else
			self:EndCooldown()

			if not self.mount or self.mount:IsNull() then
				self:CreateMount()
			end

			if self.mount then
				local vPos = self:GetValidPositionForMount()
				if not vPos then
					vPos = self:GetCaster():GetAbsOrigin()
				end
				
				if not self.mount:IsAlive() then
					self:GetCaster():_RespawnPlayerMount_SB2023(vPos)
				end

				self.mount:SetAbsOrigin(vPos)
				local heroDirection = self:GetCaster():GetForwardVector()
				heroDirection.z = 0

				self.mount:SetForwardVector(heroDirection)

				self.heroMounted = true
				self.mount.mountExpired = false
				self.mount.isUnequipped = false
				
				-- Убираем эффект невидимости, если он был
				self.mount:RemoveEffects(EF_NODRAW)


				--uncomment for dynamic tests
				-- local passiveModifier = self.mount:FindModifierByName("modifier_mount_passive")

				-- if passiveModifier then
				-- 	passiveModifier:RemoveParticleEffects()
				-- 	passiveModifier:RemoveCosmeticItems()
				-- end
	
				-- self.mount:RemoveAbility("mount_moving_passive")
				-- local ability = self.mount:AddAbility("mount_moving_passive")
				-- ability:SetLevel(1)
				-- ability:RefreshIntrinsicModifier()
	
				--restart passive modifier
				local passiveModifier = self.mount:FindModifierByName("modifier_mount_passive")
				if passiveModifier and passiveModifier.RestartModifier then
					passiveModifier:RestartModifier()
					passiveModifier:MountHero(self:GetCaster())
				end
	
				--restart mount movement modifier if exist
				local moveModifier = self.mount:FindModifierByName("modifier_mount_movement")
				if moveModifier and moveModifier.RestartModifier then
					moveModifier:RestartModifier()
				end

				-- Постоянный phased модификатор для проходимости сквозь героя
				self.mount:AddNewModifier(self.mount, nil, "modifier_phased", {duration = -1})
				self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_phased", {duration = -1})
			end
		end
	end
end

function summon_mount:GetValidPositionForMount()
	local casterPos = self:GetCaster():GetAbsOrigin()	
	GridNav:DestroyTreesAroundPoint( casterPos, 200, false )

	return casterPos
end