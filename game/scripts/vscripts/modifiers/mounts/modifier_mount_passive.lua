modifier_mount_passive = class({})

----------------------------------------------------------------------------------
function modifier_mount_passive:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mount_passive:IsPurgable()
	return false
end

----------------------------------------------------------------------------------
function modifier_mount_passive:OnCreated( kv )
	self.currentMovementSpeed = self:GetParent():GetBaseMoveSpeed()
	
	if IsServer() then
		self.heroAttached = false
		self.blockUseClones = true
		self.mountInvis = false
		self.mountInvisImmune = false

		self.movementSpeedBonus = 0
		
		self.wearables = {}
		self.particles = {}
		self.unitsAnglesCorrection = {}

		self.particlesAttached = false
		self.cosmeticsAdded = false
		self.particleStrength = 0

		--this is base model:
		self:GetParent():SetModel("models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl")
		self:GetParent():SetOriginalModel("models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl")

		self.mountData = {
			["models/props_gameplay/donkey.vmdl"] = {
				bone = "spine1",
				angles = {x = 0, y = 0, z = 0},
				update_pos = {
					base =  Vector(0, 0, -15),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						}
					}
				}
			},

			["models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl"] = {
				bone = "spine1",
				model_scale = 2.5,
				render_colors = Vector(205,133,63),
				attachment_z_offset = -66,

				--currently used only for clones in Siltbreaker
				angles = {x = 0, y = 0, z = 0},
				update_pos = {
					base =  Vector(0, 0, -15),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						}
					}
				}
			},

			["models/courier/badger/courier_badger_flying.vmdl"] = {
				model_scale = 0.25,
				hide_mount = true,
				use_z_delta = true,

				particles = {
					{
						name = "particles/cosmetic_inventory/mounts/magic_cloud_mount_.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
					},

					{
						name = "particles/cosmetic_inventory/mounts/cloud_mount_trail_.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
					},
				}
			},

			["models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl"] = {
				bone = "spine1",
				model_scale = 2.5,
				use_z_delta = true,

				--currently used only for clones in Siltbreaker
				update_pos = {
					base =  Vector(0, 0, -15),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						}
					}
				},

				particles = {
					{
						name = "particles/econ/courier/courier_trail_international_2013/courier_international_2013.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
	
						only_supporter_level = 2
					}
				}
			},

			["models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl"] = {
				bone = "spine1",
				model_scale = 1.25,

				custom_spawn_gesture = ACT_DOTA_TELEPORT_END,

				--currently used only for clones in Siltbreaker
				update_pos = {
					base =  Vector(0, 0, -15),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						}
					}
				},
			},

			["models/courier/snowleopard/snowleopard_courier.vmdl"] = {
				bone = "spine1",
				angles = {x = 180, y = 0, z = 0},
				base_angles_negative = {x = true, y = false, z = false},
				update_pos = {
					base =  Vector(0, 0, -20),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						}
					}
				}
			},

			["models/items/courier/starladder_grillhound/starladder_grillhound.vmdl"] = {
				model_scale = 2.65,
				bone = "root",
				angles = {x = 0, y = 0, z = 0},
				base_angles_negative = {x = false, y = false, z = false},
				update_pos = {
					base =  Vector(0, 0, -20),

					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -35),
						},

						npc_dota_hero_disruptor = {
							["models/heroes/disruptor/disruptor.vmdl"] = Vector(0, 0, -40)
						},

						npc_dota_hero_batrider = {
							["models/heroes/batrider/batrider.vmdl"] = Vector(20, 0, -90)
						},

						npc_dota_hero_gyrocopter = {
							["models/heroes/gyro/gyro.vmdl"] = Vector(0, 0, -50),
						},
						
						npc_dota_hero_snapfire = {
							["models/heroes/snapfire/snapfire.vmdl"] = Vector(0, 0, -40),
						},

						npc_dota_hero_luna = {
							["models/heroes/luna/luna.vmdl"] = Vector(-10, 0, -35),
						},

						npc_dota_hero_slark = {
							["models/heroes/slark/slark.vmdl"] = Vector(0, 0, 0),
						},

						npc_dota_hero_weaver = {
							["models/heroes/weaver/weaver.vmdl"] = Vector(0, 0, 0),
						},

						npc_dota_hero_winter_wyvern = {
							["models/heroes/winterwyvern/winterwyvern.vmdl"] = Vector(0, 0, 0),
						},
					}
				},

				particles = {
					{
						name = "particles/cosmetic_inventory/mounts/grillhound_ambient.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
						control_points = {
							{
								cp = 0,
								attach_name = "attach_eye_l",
								attach_type = PATTACH_POINT_FOLLOW,
							},

							{
								cp = 1,
								attach_name = "attach_eye_r",
								attach_type = PATTACH_POINT_FOLLOW,
							},

							{
								cp = 2,
								attach_name = "attach_tail",
								attach_type = PATTACH_POINT_FOLLOW,
							},

							{
								cp = 13,
								vector = Vector(15,0,0),
								particle_strength = true
							}
						}
					},

					{
						name = "particles/cosmetic_inventory/mounts/grillhound_ambient_footprints.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
						control_points = {
							{
								cp = 1,
								vector = Vector(0,1,0)
							},
							{
								cp = 5,
								vector = Vector(1,0,0)
							}
						},

						only_supporter_level = 2,
					}
				}
			},

			["models/heroes/snapfire/snapfire.vmdl"] = {
				bone = "spine_2",
				angles = {x = 0, y = -90, z = 0},
				base_angles_negative = {x = false, y = false, z = false},
				update_pos = {
					base =  Vector(-20, 0, 0),
				},

				need_z_angle_fixer = true,
				hide_mount = true,
				mount_cosmetics = {
					"models/items/snapfire/snapfire_whipper_snapper_mount/snapfire_whipper_snapper_mount.vmdl",
				},

				particles = {
					{
						name = "particles/cosmetic_inventory/mounts/snapfire_crocodile_ambient_footprints.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW,
						control_points = {
							{
								cp = 1,
								vector = Vector(0,1,0)
							},
							{
								cp = 5,
								vector = Vector(1,0,0)
							}
						},

						only_supporter_level = 2,
					}
				}
			},

			["models/heroes/batrider/batrider.vmdl"] = {
				bone = "spine1",
				model_scale = 1.25,
				angles = {x = 0, y = 0, z = 0},
				base_angles_negative = {x = false, y = false, z = false},
				update_pos = {
					base =  Vector(0, 0, -30),
					heroes = {
						npc_dota_hero_gyrocopter = {
							["models/heroes/gyro/gyro.vmdl"] = Vector(0, 0, -110),
						},
					}
				},

				need_z_angle_fixer = false,
				hide_mount = true,
				mount_cosmetics = {
					"models/items/batrider/owl_rider_mount_v1/owl_rider_mount_v1.vmdl",
				}
			},

			["models/heroes/keeper_of_the_light/keeper_of_the_light.vmdl"] = {
				bone = "root",
				model_scale = 1.6,
				angles = {x = 0, y = 0, z = 0},
				base_angles_negative = {x = false, y = false, z = false},
				update_pos = {
					base =  Vector(0, 0, -20),
					heroes = {
						npc_dota_hero_mirana = {
							["models/heroes/mirana/mirana.vmdl"] = Vector(0, 0, -40),
						},

						npc_dota_hero_disruptor = {
							["models/heroes/disruptor/disruptor.vmdl"] = Vector(0, 0, -40)
						},

						npc_dota_hero_batrider = {
							["models/heroes/batrider/batrider.vmdl"] = Vector(20, 0, -90)
						},

						npc_dota_hero_gyrocopter = {
							["models/heroes/gyro/gyro.vmdl"] = Vector(0, 0, -50),
						},

						npc_dota_hero_snapfire = {
							["models/heroes/snapfire/snapfire.vmdl"] = Vector(0, 0, -40),
						},

						npc_dota_hero_luna = {
							["models/heroes/luna/luna.vmdl"] = Vector(0, 0, -40),
						},

						npc_dota_hero_slark = {
							["models/heroes/slark/slark.vmdl"] = Vector(0, 0, 0),
						},

						npc_dota_hero_weaver = {
							["models/heroes/weaver/weaver.vmdl"] = Vector(0, 0, 0),
						},

						npc_dota_hero_winter_wyvern = {
							["models/heroes/winterwyvern/winterwyvern.vmdl"] = Vector(0, 0, 0),
						},

						npc_dota_hero_crystal_maiden = {
							["models/heroes/crystal_maiden_persona/crystal_maiden_persona.vmdl"] = Vector(0,0,0)
						},

						npc_dota_hero_keeper_of_the_light = {
							["models/heroes/keeper_of_the_light/keeper_of_the_light.vmdl"] = Vector(0,0,-50)
						}
					}
				},

				need_z_angle_fixer = false,
				hide_mount = true,
				mount_cosmetics = {
					"models/items/keeper_of_the_light/gladys_the_lightbearing_mule_new/gladys_the_lightbearing_mule_new.vmdl",
				}
			},

			["models/items/snapfire/snapfire_snailfire_mount/snapfire_snailfire_mount.vmdl"] = {
				bone = "spine_2",
				angles = {x = 0, y = -90, z = 0},
				base_angles_negative = {x = false, y = false, z = false},
				update_pos = {
					base =  Vector(-35, 0, 0),
				},

				need_z_angle_fixer = true,
				particles = "particles/econ/courier/courier_snail/courier_snail_trail.vpcf"
			}
		}

		self.heroNeedClone = {
			npc_dota_hero_mirana = {
				["models/heroes/mirana/mirana.vmdl"] = {
					model_scale = 1.1,
					mount_child_count = 2
				},
	
				["models/heroes/mirana_persona/mirana_persona_base.vmdl"] = {
					model_scale = 1.1,
					mount_child_count = 1
				},
			},

			npc_dota_hero_disruptor = {
				["models/heroes/disruptor/disruptor.vmdl"] = {
					model_scale = 0.95,
					mount_child_count = 1,
				}
			},

			npc_dota_hero_gyrocopter = {
				["models/heroes/gyro/gyro.vmdl"] = {
					model_scale = 1,
					only_child_count = 5,
				}
			},

			npc_dota_hero_keeper_of_the_light = {
				["models/heroes/keeper_of_the_light/keeper_of_the_light.vmdl"] = {
					model_scale = 1,
					mount_child_count = 1,
				}
			},

			npc_dota_hero_batrider = {
				["models/heroes/batrider/batrider.vmdl"] = {
					model_scale = 1.1,
					mount_child_count = 1,
				}
			},

			npc_dota_hero_snapfire = {
				["models/heroes/snapfire/snapfire.vmdl"] = {
					model_scale = 0.75,
					mount_child_count = 2,
				}
			},

			npc_dota_hero_luna = {
				["models/heroes/luna/luna.vmdl"] = {
					model_scale = 0.9,
					mount_child_count = 1,
				}
			}
		}
	
		self:UpdateMountScale()
		self:AddMountCosmeticItems(true)
		self:AddMountParticleEffects(0)
		self:SetMountRenderColors()

		if self:MustHideMount() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_original_model_invisible", {})
		end

		self:GetParent():ClearActivityModifiers()
		self:GetParent():AddActivityModifier("loadout")

		if self:GetParent():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
			local dragonMaterials = {
				"default","1","2","3"
			}

			self:GetParent():SetMaterialGroup(dragonMaterials[RandomInt(1, #dragonMaterials)])
			self:GetParent():SetIdleAcquire(true)

			if not self.nextDragonSpawn then
				self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + self:GetParent():GetAbsOrigin() * 25)
				self.nextDragonSpawn = true
			end
		end

		local spawnGesture = self:GetCustomSpawnGesture()

		if spawnGesture then
			local playbackRate = 1

			if self:GetParent():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
				playbackRate = 0.75
			end

			self:GetParent():StartGestureWithPlaybackRate(spawnGesture, playbackRate)
		end

		self:StartIntervalThink(0.25)
	end
end

--there is a problem with this combo on enemies: MODIFIER_STATE_OUT_OF_GAME + MODIFIER_STATE_INVISIBLE + MODIFIER_PROPERTY_INVISIBILITY_LEVEL (1)
--after applying this combo unit is total invis (there is no invisibility effect as shadow blade)
function modifier_mount_passive:OnIntervalThink()
	if not self.hPlayer then
		return
	end

	if self.mountInvis then
		if self.hPlayer and self.hPlayer:CanBeSeenByAnyOpposingTeam() then
			self.canBeInvisble = false
		else
			self.canBeInvisble = true
		end
	else
		self.canBeInvisible = true
	end

	if self.hPlayer:HasModifier("modifier_mounted") and self.movementSpeedBonus then
		local currentHeroSpeed = self.hPlayer:GetIdealSpeed() or 0
		self.currentMovementSpeed = currentHeroSpeed + self.movementSpeedBonus
	end
end

function modifier_mount_passive:RestartModifier()
	if IsServer() then
		self.currentMountAttempt = 0
		self.heroAttached = false
		self.mountInvis = false
		self.mountInvisImmune = false
		self.currentMovementSpeed = self:GetParent():GetBaseMoveSpeed()

		self:GetParent().mountExpired = false

		if not self:MustHideMount() then
			self:GetParent():RemoveModifierByName("modifier_mount_original_model_invisible")
		else
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_original_model_invisible", {})
		end

		--seems particles need to be re-attached on grillhound mount
		self:AddMountParticleEffects(self.particleStrength)

		if not self.cosmeticsAdded then
			self:AddMountCosmeticItems(true)
		end

		self:ShowCosmeticItemsVisibility()
		self:RemoveHeroClone()

		if self:UseZDelta() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_z_delta_visual", {})
		else
			self:GetParent():RemoveModifierByName("modifier_mount_z_delta_visual")
		end

		if self:UseMinusZDelta() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_minus_z_delta_visual", {})
		else
			self:GetParent():RemoveModifierByName("modifier_mount_minus_z_delta_visual")
		end

		self:GetParent():ClearActivityModifiers()
		self:GetParent():AddActivityModifier("loadout")

		if self:GetParent():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
			local dragonMaterials = {
				"default","1","2","3"
			}

			self:GetParent():SetMaterialGroup(dragonMaterials[RandomInt(1, #dragonMaterials)])
			self:GetParent():SetIdleAcquire(true)

			if not self.nextDragonSpawn then
				self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 25)
				self.nextDragonSpawn = true
			end
		end

		local spawnGesture = self:GetCustomSpawnGesture()

		if spawnGesture then
			local playbackRate = 1

			if self:GetParent():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
				playbackRate = 0.75
			end

			self:GetParent():StartGestureWithPlaybackRate(spawnGesture, playbackRate)
		end

		self:StartIntervalThink(0.25)
	end
end

----------------------------------------------------------------------------------
function modifier_mount_passive:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

		--mounts currently have unit collision cause heroes are motion controlled (no collision)
		-- [MODIFIER_STATE_NO_UNIT_COLLISION ] = true,

		if IsServer() then
			state[MODIFIER_STATE_INVISIBLE] = self.canBeInvisble and self.mountInvis
			state[MODIFIER_STATE_TRUESIGHT_IMMUNE ] = self.mountInvisImmune
			
		end

	return state
end
---------------------------------------------------------------

function modifier_mount_passive:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
	return funcs
end

function modifier_mount_passive:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_mount_passive:GetModifierMoveSpeedOverride()
	if self.currentMovementSpeed then
		return self.currentMovementSpeed
	end

	return 450
end

function modifier_mount_passive:OnStateChanged(params)
	if IsServer() then
		if not self.hPlayer or not self.hPlayer:HasModifier("modifier_mounted") then
			return
		end

		if self.hPlayer == params.unit then
			if self.hPlayer:_HasAppliedState_SB2023(MODIFIER_STATE_INVISIBLE) then
				self.mountInvis = true

				if self.hPlayer:_HasAppliedState_SB2023(MODIFIER_STATE_TRUESIGHT_IMMUNE) then
					self.mountInvisImmune = true
				else
					self.mountInvisImmune = false
				end

				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_invis_states", {})
			else
				self.mountInvis = false
				self.mountInvisImmune = false
				self:GetParent():RemoveModifierByName("modifier_mount_invis_states")
			end
		end
	end
end

function modifier_mount_passive:UpdateMountModel(heroOwner)
	if not heroOwner then
		return
	end

	local cosmeticModifier = heroOwner:FindModifierByName("modifier_cosmetic_inventory_sb2023")
	if cosmeticModifier then
		local customMountModel = cosmeticModifier:GetHeroMountModel()

		if customMountModel and customMountModel ~= self:GetParent():GetModelName() then
			self:GetParent():SetModel(customMountModel)
			self:GetParent():SetOriginalModel(customMountModel)
			self:UpdateMountScale()

			if self:MustHideMount() then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_original_model_invisible", {})
			else
				self:GetParent():RemoveModifierByName("modifier_mount_original_model_invisible")
			end

			self:RemoveHeroClone()

			local hideCosmetics = true
			if self.hPlayer and self.hPlayer:HasModifier("modifier_mounted") then
				local mountModifier = self.hPlayer:FindModifierByName("modifier_mounted")
				if mountModifier then
					mountModifier:ForceRefresh()
				end
				
				hideCosmetics = false
			end

			self:AddMountCosmeticItems(hideCosmetics)
			self:SetMountRenderColors()
			
			local particleStrength = 0

			if cosmeticModifier.GetHeroMountParticleStrength then
				particleStrength = cosmeticModifier:GetHeroMountParticleStrength()
			end
			
			if particleStrength then
				self:AddMountParticleEffects(particleStrength)
				self.particleStrength = particleStrength
			end

			if self:UseZDelta() then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_z_delta_visual", {})
			else
				self:GetParent():RemoveModifierByName("modifier_mount_z_delta_visual")
			end

			if self:UseMinusZDelta() then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_minus_z_delta_visual", {})
			else
				self:GetParent():RemoveModifierByName("modifier_mount_minus_z_delta_visual")
			end
		end
	end
end

function modifier_mount_passive:UpdateMountScale()
	local modelScale = self:GetMountModelScale()

	if modelScale then
		self:GetParent():SetModelScale(modelScale)
	end
end

function modifier_mount_passive:GetMountModelScale()
	local mountModel = self:GetParent():GetModelName()

	if self.mountData[mountModel] and self.mountData[mountModel]["model_scale"] then
		return self.mountData[mountModel]["model_scale"]
	end

	return 1
end

function modifier_mount_passive:GetMountAttachmentBone()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["bone"] then
		return self.mountData[self:GetParent():GetModelName()]["bone"]
	end

	return nil
end

function modifier_mount_passive:UpdateHeroLocalAngles(unit)
	if not unit or unit:IsNull() then
		return
	end

	if not self.hPlayer then
		return
	end

	local modelName = self:GetParent():GetModelName()
	local heroName = self.hPlayer:GetUnitName()
	local heroModelName = self.hPlayer:GetModelName()

	if self.mountData[modelName] and self.mountData[modelName]["angles"] then
		local angles = unit:GetLocalAngles()

		local anglesCorrection = self.mountData[modelName]["angles"]
		local updatePosData =  self.mountData[modelName]["update_pos"]

		local x = 0
		local y = 0
		local z = 0

		for angleType, angleChange in pairs(anglesCorrection) do
			local baseAngle = angles[angleType]

			if baseAngle then
				local baseAnglesNegative = self.mountData[modelName]["base_angles_negative"]
				if baseAnglesNegative and baseAnglesNegative[angleType] then
					baseAngle = baseAngle * -1
				end

				if angleType == "x" then
					x = angleChange + baseAngle
				end

				if angleType == "y" then
					y = angleChange + baseAngle
				end

				if angleType == "z" then
					z = angleChange + baseAngle
				end
			end
		end
		
		unit:SetLocalAngles(x, y, z)

		self.unitsAnglesCorrection[unit:entindex()] = unit:GetLocalAngles()

		if updatePosData and updatePosData["base"] then
			local updatePos = updatePosData["base"]

			if updatePosData["heroes"] and updatePosData["heroes"][heroName] and updatePosData["heroes"][heroName][heroModelName] then
				updatePos = updatePosData["heroes"][heroName][heroModelName]
			end
			
			local deltapos = RotatePosition( Vector(0,0,0), unit:GetLocalAngles(), updatePos )
			local pos = unit:GetLocalOrigin() + deltapos
	
			unit:SetLocalOrigin(pos)
		end
	end
end

function modifier_mount_passive:MountHero(hPlayer)
	self.hPlayer = hPlayer
	self.heroAttached = true

	self.mountInvis = hPlayer:IsInvisible()
	self.mountInvisImmune = hPlayer:_HasAppliedState_SB2023(MODIFIER_STATE_TRUESIGHT_IMMUNE)

	self:ShowCosmeticItemsVisibility()

	if self.mountInvis then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mount_invis_states", {})
	end

	--set mount movement if available
	if self:GetAbility().GetMovementModifierName then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), self:GetAbility():GetMovementModifierName(), {
			hero_ride_activity = ACT_DOTA_RUN
		} )
	end

	self.hPlayer:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_mounted", {} )
	
	local currentHeroSpeed = self.hPlayer:GetIdealSpeed() or 0

	local summonAbility = self.hPlayer:FindAbilityByName("summon_mount")
	if summonAbility then
		self.movementSpeedBonus = summonAbility:GetSpecialValueFor("ms_speed_bonus")
		self.currentMovementSpeed = currentHeroSpeed + self.movementSpeedBonus
	end

	local playerCosmeticInventoryModifier = self.hPlayer:FindModifierByName("modifier_cosmetic_inventory_sb2023")
	if playerCosmeticInventoryModifier then
		local cosmeticMountModel = playerCosmeticInventoryModifier:GetHeroMountModel()

		if cosmeticMountModel and cosmeticMountModel ~= self:GetParent():GetModelName() then
			self:UpdateMountModel(hPlayer)
		end
	end

	if not self.blockUseClones and self:UseHeroClone() then
		self:AttachCloneToMount()
	end

	if self:GetAbility() and self:GetAbility().OnSummon then
		self:GetAbility():OnSummon(hPlayer)
	end
end

function modifier_mount_passive:AttachCloneToMount()
	self.hPlayer:AddEffects(EF_NODRAW)
	local teamNumber = self.hPlayer:GetTeamNumber()

	local clone = CreateUnitByName("npc_dota_dummy_container", self.hPlayer:GetAbsOrigin(), false, nil, nil, teamNumber)

	if clone then
		self.clonedHero = clone
		clone:SetOwner(self.hPlayer)
		self:GetParent().clonedHero = clone
		
		clone:SetModel(self.hPlayer:GetModelName())
		clone:SetOriginalModel(self.hPlayer:GetModelName())

		local modelScale = self:GetHeroCloneModelScale() or 1
		clone:SetModelScale(modelScale)
		clone:StartGesture(ACT_DOTA_IDLE)

		clone:AddNewModifier(clone, nil, "modifier_mount_clones_invulnerable", {})

		local mountChildCount = self:GetMountChildCount()
		local childOnlyCount = self:GetChildOnlyCount()

		if mountChildCount or childOnlyCount then
			local cosmeticModel = self.hPlayer:FirstMoveChild()

			local counter = 1
			while cosmeticModel ~= nil do
				if cosmeticModel:GetClassname() == "dota_item_wearable" and cosmeticModel:GetModelName() ~= "" then

					--copy everything except mount or only selected item
					--items are counted backwards (comparing to cosmetic items in hero preview in DOTA)
					if (mountChildCount and counter ~= mountChildCount) or (childOnlyCount and counter == childOnlyCount) then
						local hWearable = Entities:CreateByClassname( "wearable_item" )
						if hWearable ~= nil then
							hWearable:SetModel(cosmeticModel:GetModelName())
							hWearable:SetTeam(clone:GetTeamNumber())
							hWearable:SetOwner(clone)
							hWearable:SetParent(clone, nil)
							hWearable:FollowEntity(clone, true)
						end
					end

					counter = counter + 1
				end
				
				cosmeticModel = cosmeticModel:NextMovePeer()
			end
		end

		local boneAttachment = self:GetMountAttachmentBone()

		if boneAttachment then
			clone:FollowEntityMerge(self:GetParent(), boneAttachment)

			self:UpdateHeroLocalAngles(clone)
		else
			clone:FollowEntity(self:GetParent(), false)
		end
	end
end

function modifier_mount_passive:AttachHeroToMount()
	if not self.hPlayer then
		return
	end

	local mount = self:GetParent()
	local boneAttachment = self:GetMountAttachmentBone()
	local boneAttachmentForHero = boneAttachment

	if self:NeedZAngleFixer() then
		local zAngleFixer = CreateUnitByName("npc_dota_dummy_container_z_angle_fixer", self.hPlayer:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)

		if zAngleFixer then
			mount = zAngleFixer

			zAngleFixer:AddEffects(EF_NODRAW)
			zAngleFixer:AddNewModifier(zAngleFixer, nil, "modifier_mount_clones_invulnerable", {})

			self:GetParent().zAngleFixer = zAngleFixer
	
			if boneAttachment then
				zAngleFixer:FollowEntityMerge(self:GetParent(), boneAttachment)
		
				self:UpdateHeroLocalAngles(zAngleFixer)

				boneAttachmentForHero = "root"
			else
				zAngleFixer:FollowEntity(self:GetParent(), false)
			end
		end
	end

	if boneAttachment then
		self.hPlayer:FollowEntityMerge(mount, boneAttachmentForHero)

		self:UpdateHeroLocalAngles(self.hPlayer)
	else
		self.hPlayer:FollowEntity(mount, false)
	end

	if self:UseHeroClone() then
		self.hPlayer:AddEffects(EF_NODRAW)

		local clone = CreateUnitByName("npc_dota_dummy_container", self.hPlayer:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)

		if clone then
			self.clonedHero = clone
			self:GetParent().clonedHero = clone
			
			clone:SetModel(self.hPlayer:GetModelName())
			clone:SetOriginalModel(self.hPlayer:GetModelName())

			local modelScale = self:GetHeroCloneModelScale() or 1
			clone:SetModelScale(modelScale)
			clone:StartGesture(ACT_DOTA_IDLE)

			clone:AddNewModifier(clone, nil, "modifier_mount_clones_invulnerable", {})

			local mountChildCount = self:GetMountChildCount()
			local childOnlyCount = self:GetChildOnlyCount()

			if mountChildCount or childOnlyCount then
				local cosmeticModel = self.hPlayer:FirstMoveChild()

				local counter = 1
				while cosmeticModel ~= nil do
					if cosmeticModel:GetClassname() == "dota_item_wearable" and cosmeticModel:GetModelName() ~= "" then

						--copy everything except mount or only selected item
						--items are counted backwards (comparing to cosmetic items in hero preview in DOTA)
						if (mountChildCount and counter ~= mountChildCount) or (childOnlyCount and counter == childOnlyCount) then
							local hWearable = Entities:CreateByClassname( "wearable_item" )
							if hWearable ~= nil then
								hWearable:SetModel(cosmeticModel:GetModelName())
								hWearable:SetTeam(clone:GetTeamNumber())
								hWearable:SetOwner(clone)
								hWearable:SetParent(clone, nil)
								hWearable:FollowEntity(clone, true)
							end
						end

						counter = counter + 1
					end
					
					cosmeticModel = cosmeticModel:NextMovePeer()
				end
			end

			if boneAttachment then
				clone:FollowEntityMerge(self:GetParent(), boneAttachment)

				self:UpdateHeroLocalAngles(clone)
			else
				clone:FollowEntity(self:GetParent(), false)
			end
		end
	end
end

function modifier_mount_passive:UseHeroClone()
	if not self.hPlayer then
		return false
	end


	if self.heroNeedClone[self.hPlayer:GetUnitName()] then
		return true
	end

	return false
end

function modifier_mount_passive:NeedZAngleFixer()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["need_z_angle_fixer"] then
		return true
	end

	return false
end

function modifier_mount_passive:MustHideMount()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["hide_mount"] then
		return true
	end

	return false
end

function modifier_mount_passive:AddMountCosmeticItems(forceHide)
	--first remove cosmetics if exist
	self:RemoveCosmeticItems()

	if not self.mountData[self:GetParent():GetModelName()] or not self.mountData[self:GetParent():GetModelName()]["mount_cosmetics"] then
		return
	end

	local cosmeticItems = self.mountData[self:GetParent():GetModelName()]["mount_cosmetics"]

	for _, modelName in pairs(cosmeticItems) do
		local hWearable = CreateUnitByName( 
			"npc_dota_dummy_wearable", 
			self:GetParent():GetAbsOrigin(), 
			true, 
			self:GetParent(),
			self:GetParent(),
			self:GetParent():GetTeamNumber() 
		)

		if hWearable ~= nil then
			hWearable:SetModel(modelName)
			hWearable:SetOriginalModel(modelName)
			hWearable:SetTeam(self:GetParent():GetTeamNumber())
			hWearable:SetOwner(self:GetParent())
			hWearable:FollowEntity(self:GetParent(), true)

			if forceHide then
				hWearable:AddEffects(EF_NODRAW)
			end

			if not self.hPlayer then
				self.hPlayer = self:GetParent():GetOwnerEntity()
			end

			hWearable.hPlayer = self.hPlayer
			hWearable.isMount = true

			self.wearables[hWearable:entindex()] = hWearable
		end
	end

	self.cosmeticsAdded = true
end

function modifier_mount_passive:RemoveCosmeticItems()
	for entindex, wearable in pairs(self.wearables) do
		if wearable and not wearable:IsNull() then
			wearable:AddEffects(EF_NODRAW)
			wearable:SetUnitCanRespawn(false)
			wearable:ForceKill(false)
		end

		self.wearables[entindex] = nil
	end

	self.cosmeticsAdded = false
end

function modifier_mount_passive:HideCosmeticItemsVisibility()
	for _, wearable in pairs(self.wearables) do
		if wearable and not wearable:IsNull() then
			wearable:AddEffects(EF_NODRAW)
		end
	end
end

function modifier_mount_passive:ShowCosmeticItemsVisibility()
	for _, wearable in pairs(self.wearables) do
		if wearable and not wearable:IsNull() then
			wearable:RemoveEffects(EF_NODRAW)
		end
	end
end


function modifier_mount_passive:RemoveParticleEffects()
	for nFxIndex, _ in pairs(self.particles) do
		ParticleManager:DestroyParticle(nFxIndex, true)

		self.particles[nFxIndex] = nil
	end

	self.particlesAttached = false
end

function modifier_mount_passive:AddMountParticleEffects(particleStrength)
	--first destroy existing particles if exist
	self:RemoveParticleEffects()

	if not self.mountData[self:GetParent():GetModelName()] or not self.mountData[self:GetParent():GetModelName()]["particles"] then
		return
	end

	local particles = self.mountData[self:GetParent():GetModelName()]["particles"]

	for _, particleData in pairs(particles) do
		local canApplyParticles = true
		
		local particleName = particleData["name"]
		local attachType = particleData["attach_type"] or PATTACH_ABSORIGIN_FOLLOW
		local onlySupporterLevel = particleData["only_supporter_level"]
		
		if not self.hPlayer then
			self.hPlayer = self:GetParent():GetOwnerEntity()
		end

		if onlySupporterLevel and self.hPlayer then
			canApplyParticles = false
			local playerID = self.hPlayer:GetPlayerOwnerID()

			if GameRules.Dungeon._vPlayerStats[playerID] and GameRules.Dungeon._vPlayerStats[playerID]["supporter_level"] then
				local supporterLevel = GameRules.Dungeon._vPlayerStats[playerID]["supporter_level"] or 0

				if supporterLevel and supporterLevel >= onlySupporterLevel then
					canApplyParticles = true
				end
			end
		end

		if canApplyParticles then
			local nFxIndex = ParticleManager:CreateParticle(particleName, attachType, self:GetParent())
			self.particles[nFxIndex] = true
	
			if particleData["control_points"] then
	
				for _, cpData in pairs(particleData["control_points"]) do
					local cp = cpData["cp"]
					local attachName = cpData["attach_name"]
					local cpAttachType = cpData["attach_type"]
					local cpVector = cpData["vector"]
	
					if cp then
						if attachName then
							ParticleManager:SetParticleControlEnt( nFxIndex, cp, self:GetParent(), cpAttachType, attachName, Vector(0,0,0), true )
						elseif cpVector then
							if cpData["particle_strength"] and particleStrength then
								cpVector = Vector(particleStrength, particleStrength, particleStrength)
							end
	
							ParticleManager:SetParticleControl( nFxIndex, cp, cpVector )
						end
					end
				end
			end
		end
	end

	self.particlesAttached = true
end

function modifier_mount_passive:GetHeroCloneModelScale()
	if not self.hPlayer then
		return false
	end

	local heroName = self.hPlayer:GetUnitName()
	local heroModelName = self.hPlayer:GetModelName()

	if self.heroNeedClone[heroName] and self.heroNeedClone[heroName][heroModelName] and self.heroNeedClone[heroName][heroModelName]["model_scale"] then
		return self.heroNeedClone[heroName][heroModelName]["model_scale"]
	end

	return 1
end

function modifier_mount_passive:GetMountChildCount()
	if not self.hPlayer then
		return false
	end

	local heroName = self.hPlayer:GetUnitName()
	local heroModelName = self.hPlayer:GetModelName()

	if self.heroNeedClone[heroName] and self.heroNeedClone[heroName][heroModelName] and self.heroNeedClone[heroName][heroModelName]["mount_child_count"] then
		return self.heroNeedClone[heroName][heroModelName]["mount_child_count"]
	end

	return nil
end

function modifier_mount_passive:GetChildOnlyCount()
	if not self.hPlayer then
		return false
	end

	local heroName = self.hPlayer:GetUnitName()
	local heroModelName = self.hPlayer:GetModelName()

	if self.heroNeedClone[heroName] and self.heroNeedClone[heroName][heroModelName] and self.heroNeedClone[heroName][heroModelName]["only_child_count"] then
		return self.heroNeedClone[heroName][heroModelName]["only_child_count"]
	end

	return nil
end

function modifier_mount_passive:SetMountRenderColors()
	if not self.mountData[self:GetParent():GetModelName()] or not self.mountData[self:GetParent():GetModelName()]["render_colors"] then
		self:GetParent():SetRenderColor(255, 255, 255)
		return
	end

	local renderColors = self.mountData[self:GetParent():GetModelName()]["render_colors"]

	self:GetParent():SetRenderColor(renderColors.x, renderColors.y, renderColors.z)
end

function modifier_mount_passive:RemoveHeroClone()
	--removeClone if available
	if self.clonedHero and not self.clonedHero:IsNull() then
		self.clonedHero:ForceKill(false)
		UTIL_Remove(self.clonedHero)

		self.clonedHero = nil
		self:GetParent().clonedHero = nil
	end
end

function modifier_mount_passive:GetMountOffset()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["attachment_z_offset"] then
		return self.mountData[self:GetParent():GetModelName()]["attachment_z_offset"]
	end

	return 0
end

function modifier_mount_passive:UseZDelta()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["use_z_delta"] then
		return true
	end

	return false
end

function modifier_mount_passive:UseMinusZDelta()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["use_minus_z_delta"] then
		return true
	end

	return false
end

function modifier_mount_passive:GetCustomSpawnGesture()
	if self.mountData[self:GetParent():GetModelName()] and self.mountData[self:GetParent():GetModelName()]["custom_spawn_gesture"] then
		return self.mountData[self:GetParent():GetModelName()]["custom_spawn_gesture"]
	end

	return ACT_DOTA_SPAWN
end