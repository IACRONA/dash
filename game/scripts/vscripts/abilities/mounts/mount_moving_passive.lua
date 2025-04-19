mount_moving_passive = class({})

LinkLuaModifier( "modifier_mounted", "modifiers/mounts/modifier_mounted", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_mount_passive", "modifiers/mounts/modifier_mount_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_movement", "modifiers/mounts/modifier_mount_movement", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mount_invis_states", "modifiers/mounts/modifier_mount_invis_states", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mount_original_model_invisible", "modifiers/mounts/modifier_mount_original_model_invisible", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_clones_invulnerable", "modifiers/mounts/modifier_mount_clones_invulnerable", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_z_delta_visual", "modifiers/mounts/modifier_mount_z_delta_visual", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_z_delta_visual_small", "modifiers/mounts/modifier_mount_z_delta_visual_small", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_z_delta_visual_big", "modifiers/mounts/modifier_mount_z_delta_visual_big", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_z_delta_visual_very_big", "modifiers/mounts/modifier_mount_z_delta_visual_very_big", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mount_minus_z_delta_visual", "modifiers/mounts/modifier_mount_minus_z_delta_visual", LUA_MODIFIER_MOTION_NONE )

function mount_moving_passive:Precache( context )
	PrecacheUnitByNameAsync( "precache_npc_dota_hero_chaos_knight", function () end)
	PrecacheUnitByNameAsync( "precache_npc_dota_hero_keeper_of_the_light", function () end)

	--for mounts
	PrecacheResource( "model", "models/heroes/snapfire/snapfire.vmdl", context )
	PrecacheResource( "model", "models/heroes/batrider/batrider.vmdl", context )
	PrecacheResource( "model", "models/items/batrider/owl_rider_mount_v1/owl_rider_mount_v1.vmdl", context )
	PrecacheResource( "model", "models/items/snapfire/snapfire_whipper_snapper_mount/snapfire_whipper_snapper_mount.vmdl", context )
	PrecacheResource( "model", "models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl", context )
	PrecacheResource( "model", "models/items/courier/starladder_grillhound/starladder_grillhound.vmdl", context )
	PrecacheResource( "model", "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl", context )
	PrecacheResource( "model", "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl", context )
	PrecacheResource( "model", "models/courier/badger/courier_badger_flying.vmdl", context )

	PrecacheResource( "particle", "particles/hw_fx/mount_max_speed.vpcf", context )
	PrecacheResource( "particle", "particles/econ/courier/courier_snail/courier_snail_trail.vpcf", context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_international_2013/courier_international_2013.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/magic_cloud_mount_.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/cloud_mount_trail_.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/grillhound_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/grillhound_ambient_footprints.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/snapfire_crocodile_ambient_footprints.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/mount_summon_crocodile_snow.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/mount_summon_grillhoundsnow.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/mount_summon_smeevil_carpet_snow.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/mount_summon_owlsnow.vpcf", context )
	PrecacheResource( "particle", "particles/cosmetic_inventory/mounts/mount_summon_dragon_snow.vpcf", context )
end

function mount_moving_passive:GetIntrinsicModifierName()
	return "modifier_mount_passive"
end

function mount_moving_passive:GetMovementModifierName()
	return "modifier_mount_movement"
end

function mount_moving_passive:AddMountEffects(hUnit)
	if not hUnit then
		hUnit = self:GetCaster()
	end

	local modelName = self:GetCaster():GetModelName()

	local particleNames = {
		["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = "particles/cosmetic_inventory/mounts/mount_summon_grillhoundsnow.vpcf",
		["models/heroes/snapfire/snapfire.vmdl"] = "particles/cosmetic_inventory/mounts/mount_summon_crocodile_snow.vpcf",
		["models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl"] = "particles/cosmetic_inventory/mounts/mount_summon_smeevil_carpet_snow.vpcf",
		["models/heroes/batrider/batrider.vmdl"] = "particles/cosmetic_inventory/mounts/mount_summon_owlsnow.vpcf",
		["models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl"] = "particles/cosmetic_inventory/mounts/mount_summon_dragon_snow.vpcf",
	}

	local particleName = particleNames[modelName]

	if particleName then
		local nFXIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, hUnit )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, hUnit, PATTACH_ABSORIGIN_FOLLOW, nil, hUnit:GetOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 150, 150, 150 ) )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, hUnit, PATTACH_ABSORIGIN, nil, hUnit:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function mount_moving_passive:OnSummon(hUnit)
	if not self:GetCaster() then
		return
	end

	self:AddMountEffects(hUnit)

	local modelName = self:GetCaster():GetModelName()

	local sounds = {
		["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = "Hero_ChaosKnight.RealityRift.Cast",
		["models/heroes/snapfire/snapfire.vmdl"] = "Mount.Crocodile.Spawn",
		["models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl"] = "Mount.Carpet.Spawn",
		["models/heroes/batrider/batrider.vmdl"] = "Mount.Owl.Spawn",
		["models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl"] = "Mount.Dragon.Spawn",
		["models/courier/badger/courier_badger_flying.vmdl"] = "Mount.Cloud.Spawn",
	}
	
	if sounds[modelName] then
		self:GetCaster():EmitSoundParams(sounds[modelName], 0, 1.5, 0)
	else
		self:GetCaster():EmitSoundParams("Hero_KeeperOfTheLight.Spawn", 0, 3, 0)
	end
end

--------------------------------------------------------------------------------
function mount_moving_passive:OnDismount()
	if not self:GetCaster() then
		return
	end

	if self:GetCaster():GetOwnerEntity() then
		self:AddMountEffects(self:GetCaster():GetOwnerEntity())
	end

	local modelName = self:GetCaster():GetModelName()

	local sounds = {
		["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = {
			"Hero_ChaosKnight.Phantasm.Plus",
			"Hero_ChaosKnight.RealityRift",
		},

		["models/heroes/snapfire/snapfire.vmdl"] = {
			"Mount.Crocodile.Despawn",
		},

		["models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl"] = {"Mount.Carpet.Despawn"},
		["models/heroes/batrider/batrider.vmdl"] = {"Mount.Owl.Despawn"},
		["models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl"] = {"Mount.Dragon.Despawn"},
		["models/courier/badger/courier_badger_flying.vmdl"] = {"Mount.Cloud.Despawn"},
	}

	if sounds[modelName] then
		local sound1 = sounds[modelName][1]
		local sound2 = sounds[modelName][2]

		if sound1 then
			self:GetCaster():EmitSoundParams(sound1, 0, 1.5, 0)
		end

		if sound2 then
			self:GetCaster():EmitSoundParams(sound2, 0, 1.5, 0)
		end
	else
		self:GetCaster():EmitSoundParams("Hero_KeeperOfTheLight.Death", 0, 3, 0)
	end
end

function mount_moving_passive:OnMountIdle()
	local idleActivities = {
		["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = {

			--starts always with first one!
			{
				name = ACT_DOTA_IDLE,
				duration = 2,
				playback_rate = 0.35
			},

			{
				name = ACT_DOTA_IDLE_RARE,
				duration = 2,
				playback_rate = 0.35,
			}
		}
	}
	
	if self.runActivity then
		self:GetCaster():RemoveGesture(self.runActivity)
		self.runActivity = nil
	end

	--idle can be applied multiple times to change idle activity
	local previousIdleActivity = self.idleActivity
	
	if self.idleActivity then
		self:GetCaster():FadeGesture(self.idleActivity)
		self.idleActivity = nil
	end

	local mountIdleActivites = idleActivities[self:GetCaster():GetModelName()]

	if mountIdleActivites and #mountIdleActivites > 0 then
		local randomActivity = mountIdleActivites[RandomInt(1, #mountIdleActivites)]

		if not previousIdleActivity then
			randomActivity = mountIdleActivites[1]
		end
		
		local activityName = randomActivity["name"]
		local playbackRate = randomActivity["playback_rate"] or 1

		self:GetCaster():StartGestureWithFadeAndPlaybackRate(activityName, 0.5, 1.5, playbackRate)

		local duration = randomActivity["duration"] or 2

		if duration and duration > 0 then
			duration = duration + 2
			duration = math.floor((duration / playbackRate) * 100) / 100
		end

		self.idleActivity = activityName

		if duration > 0 then
			self.idleTimer = Timers:CreateTimer(duration, function ()
				if self and not self:IsNull() then
					self:OnMountIdle()
				end
			end)
		end
	end
end

function mount_moving_passive:OnMountMove()
	local runActivites = {
		["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = {
			ACT_DOTA_RUN,
		}
	}

	if self.idleTimer then
		Timers:RemoveTimer(self.idleTimer)
		self.idleTimer = nil
	end

	self:GetCaster():ClearActivityModifiers()
	self:GetCaster():AddActivityModifier("run")

	local mountRunActivities = runActivites[self:GetCaster():GetModelName()]

	if not mountRunActivities then
		return
	end
	
	if self.idleActivity then
		self:GetCaster():RemoveGesture(self.idleActivity)
		self.idleActivity = nil
	end

	local runActivity = ACT_DOTA_RUN

	if mountRunActivities and #mountRunActivities > 0 then
		runActivity = mountRunActivities[RandomInt(1, #mountRunActivities)]
	end

	self:GetCaster():StartGestureWithFadeAndPlaybackRate(runActivity, 0.1, 0.25, 1)

	self.runActivity = runActivity
end

--------------------------------------------------------------------------------
function mount_moving_passive:OnMovementStart()
end

--------------------------------------------------------------------------------
function mount_moving_passive:GetAnimation_Summon()
	return nil
end

--------------------------------------------------------------------------------
function mount_moving_passive:GetAnimation_Movement()
	return ACT_DOTA_RUN
end