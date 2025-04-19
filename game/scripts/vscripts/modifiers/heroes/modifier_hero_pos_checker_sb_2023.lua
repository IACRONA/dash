
modifier_hero_pos_checker_sb_2023 = class({})

--------------------------------------------------------------------------------

function modifier_hero_pos_checker_sb_2023:IsHidden()
	return true
end

function modifier_hero_pos_checker_sb_2023:IsPurgable()
    return false
end

function modifier_hero_pos_checker_sb_2023:IsPermanent()
	return true
end

--------------------------------------------------------------------------------

function modifier_hero_pos_checker_sb_2023:OnCreated( kv )
	if IsServer() then
		self.lastGoodPosition = self:GetParent():GetAbsOrigin()
		self.playerPickTime = 0
		self.maxTimeToSetGoodPosition = 5

		self.lastGoodPositionTime = GameRules:GetGameTime()
		self.isBlocked = false

		--Unfortunately FindPathLength seems not to return always correct values (sometimes seems to short?), so there is 1800 max range
		self.maxPathLength = 1800

		self.zonesMaxPathLengthChecking = {
			ep_1 = {
				[4] = true,
				[6] = true,
				[7] = true,
			},

			ep_2 = {
				[7] = true,
				[8] = true,
				[9] = true,
			}
		}

		self.abilityPositionChangeModifier = {
			sniper_concussive_grenade = {
				modifier_name = "modifier_knockback",
			},
			
			mirana_leap = {
				modifier_name = "modifier_mirana_leap",
			},
			storm_spirit_ball_lightning = {
				modifier_name = "modifier_storm_spirit_ball_lightning",
			},

			zuus_heavenly_jump = {
				modifier_name = "modifier_zuus_heavenly_jump",
			},
			snapfire_firesnap_cookie = {
				modifier_name = "modifier_snapfire_firesnap_cookie_short_hop",
				modifier_need_notice_delay = 0.1
			},

			snapfire_gobble_up = {
				modifier_name = "modifier_snapfire_spit_creep_arcing_unit",
				modifier_need_notice_delay = 0.1,
				duration_property_name = "max_time_in_belly",
			},

			pudge_dismember = {
				modifier_name = "modifier_pudge_swallow_hide",
				modifier_need_notice_delay = 0.1,
			},

			marci_grapple = {
				modifier_name = "modifier_marci_grapple_victim_motion",
			},

			marci_companion_run = {
				modifier_name = "modifier_marci_lunge_arc",
				modifier_need_notice_delay = 0.1,
			},

			faceless_void_time_walk = {
				modifier_name = "modifier_faceless_void_time_walk",
			},

			dawnbreaker_converge = {
				modifier_name = "modifier_dawnbreaker_celestial_hammer_caster",1
			},

			ursa_earthshock = {
				modifier_name = "modifier_ursa_earthshock_move",
			},

			hoodwink_sharpshooter = {
				modifier_name = "modifier_hoodwink_sharpshooter_recoil",
				modifier_need_notice_delay = 0.1,
				modifier_max_waiting = 6.0,
			},

			enchantress_bunny_hop = {
				modifier_name = "modifier_enchantress_bunny_hop",
			},

			pangolier_swashbuckle = {
				modifier_name = "modifier_pangolier_swashbuckle",
				modifier_need_notice_delay = 0.1,
			},

			pangolier_shield_crash = {
				modifier_name = "modifier_pangolier_shield_crash_jump",
			},

			monkey_king_boundless_strike = {
				modifier_name = "modifier_monkey_king_boundless_strike_shard_movement",
			},

			crystal_maiden_crystal_clone = {
				modifier_name = "modifier_crystal_maiden_crystal_clone",
			},

			magnataur_skewer = {
				modifier_name = "modifier_magnataur_skewer_movement",
			},

			techies_suicide = {
				modifier_name = "modifier_techies_suicide_leap",
			},

			earthshaker_enchant_totem = {
				modifier_name = "modifier_earthshaker_enchant_totem_leap",
			},

			necrolyte_death_seeker = {
				modifier_name = "modifier_death_seeker_out_of_world",
			},

			rattletrap_hookshot = {
				modifier_name = "modifier_rattletrap_hookshot",
				timer_interval = 0.05
			},

			void_spirit_dissimilate = {
				modifier_name = "modifier_void_spirit_dissimilate_phase",
			},

			shredder_timber_chain = {
				modifier_name = "modifier_shredder_timber_chain",
				modifier_need_notice_delay = 0.1,
			},

			spirit_breaker_charge_of_darkness = {
				modifier_name = "modifier_spirit_breaker_charge_of_darkness",
				modifier_need_notice_delay = 0.1,
			},

			spirit_breaker_charge_of_darkness_creep = {
				modifier_name = "modifier_spirit_breaker_creep_charging_sb_2023",
				modifier_need_notice_delay = 0.1,
			},

			primal_beast_onslaught = {
				modifier_name = "modifier_primal_beast_onslaught_movement_adjustable",
				modifier_need_notice_delay = 0.1,
			},

			slark_pounce_sb_2023 = {
				modifier_name = "modifier_slark_pounce_sb_2023",
				modifier_need_notice_delay = 0.1,
			},

			riki_tricks_of_the_trade = {
				modifier_name = "modifier_riki_tricks_of_the_trade_phase",
				modifier_need_notice_delay = 0.1
			},

			sandking_burrowstrike = {
				modifier_name = "modifier_sandking_burrowstrike",
				modifier_need_notice_delay = 0.1
			},

			kez_grappling_claw = {
				modifier_name = "modifier_kez_grappling_claw_movement",
				modifier_need_notice_delay = 0.1
			},

			--enemy abilities used on heroes
			giant_burrower_explosion = {
				modifier_name = "modifier_knockback",
				modifier_need_notice_delay = 0.75,
			},

			--pos checker for enemy units:
			mars_gods_rebuke = {
				modifier_name = "modifier_knockback",
				modifier_need_notice_delay = 0.75,
				force_check_only = true
			},

			--pos checker for enemy units:
			void_spirit_resonant_pulse = {
				modifier_name = "modifier_knockback",
				modifier_need_notice_delay = 0.75,
			},

			drow_ranger_wave_of_silence = {
				modifier_name = "modifier_drowranger_wave_of_silence_knockback",
				modifier_need_notice_delay = 1,
				force_check_only = true
			},

			spirit_breaker_nether_strike = {
				modifier_name = "modifier_spirit_breaker_greater_bash",
				modifier_need_notice_delay = 0.5,
				force_check_only = true
			},

			spirit_breaker_greater_bash = {
				modifier_name = "modifier_spirit_breaker_greater_bash",
				modifier_need_notice_delay = 0.5,
				force_check_only = true
			},

			queenofpain_sonic_wave = {
				modifier_name = "modifier_queenofpain_sonic_wave_knockback",
				modifier_need_notice_delay = 1.5,
				force_check_only = true,
			},

			tusk_walrus_kick = {
				modifier_name = "modifier_tusk_walrus_kick_air_time",
				modifier_need_notice_delay = 0.1,
				force_check_only = true,
			},

			pudge_meat_hook_dark_moon = {
				modifier_name = "modifier_pudge_meat_hook_dark_moon",
				modifier_need_notice_delay = 0.1,
				force_check_only = true,
			},

			-- --items
			item_havoc_hammer = {
				modifier_name = "modifier_knockback",
				modifier_need_notice_delay = 0.75,
				blinks = true,
			},

			item_manta = {
				modifier_name = "modifier_manta_phase",
				modifier_need_notice_delay = 0.1,
				blinks = true,
			},

			item_hurricane_pike = {
				modifier_name = "modifier_item_hurricane_pike_active",
				modifier_need_notice_delay = 0.1,
				blinks = true,

				other_target_alternate_modifier = "modifier_item_hurricane_pike_active",
				other_enemy_target_alternate_modifier = "modifier_item_hurricane_pike_active_alternate",
				other_target_self_alternate_modifier = "modifier_item_hurricane_pike_active_alternate",
				both_targets_verify = true
			},

			item_force_staff = {
				modifier_name = "modifier_item_forcestaff_active",
				modifier_need_notice_delay = 0.1,
				blinks = true,
			},

			item_cyclone = {
				modifier_name = "modifier_eul_cyclone",
				modifier_need_notice_delay = 0.1,
			},

			item_wind_waker = {
				modifier_name = "modifier_wind_waker",
				modifier_need_notice_delay = 0.1,
				blinks = true,
			},

			item_pogo_stick = {
				modifier_name = "modifier_item_pogostick_active",
				blinks = true,
			},

			item_fallen_sky = {
				modifier_name = "modifier_item_fallen_sky_land",
				modifier_need_notice_delay = 0.1,
				blinks = true,
			},

			item_force_boots = {
				modifier_name = "modifier_force_boots_active",
				modifier_need_notice_delay = 0.1,
				blinks = true,
			},

			item_ogre_seal_totem = {
				modifier_name = "modifier_item_ogre_seal_totem_active",
				modifier_need_notice_delay = 0.1,
			}
		}

		--abilities + items without cast point or without modifier
		self.abilityBlinkChangePosition = {
			antimage_blink = 0.25,
			phantom_assassin_phantom_strike = 0.25,
			phantom_assassin_phantom_strike_aghs2024 = 0.25,
			queenofpain_blink = 0.25,
			meepo_poof = 0.25,
			templar_assassin_trap_teleport = 0.25,
			furion_teleportation = 0.25,
			void_spirit_astral_step = 0.25,
			mirana_leap = 0.5,
			lone_druid_spirit_bear = 0.25,
			puck_ethereal_jaunt = 0.25,
			puck_waning_rift = 0.25,
			vengefulspirit_nether_swap_sb2023 = 0.25,
			kez_echo_slash = 0.25,

			--for enemies
			tinker_warp_grenade = 0.5,
			ascension_flicker = 0.25,

			--items
			item_blink = 0.25,
			item_arcane_blink = 0.25,
			item_swift_blink = 0.25,
			item_overwhelming_blink = 0.25,
			item_corrupting_blade = 0.25,
			item_havoc_hammer = 0.5,
			item_manta = 0.25,
			item_hurricane_pike = 0.25,
			item_force_staff = 0.25,
			item_wind_waker = 0.25,
			item_pogo_stick = 0.25,
			item_fallen_sky = 0.25,
			item_force_boots = 0.25,
		}

		self.abilityForceCheckSelfPosition = {
			item_corrupting_blade = true,
			marci_companion_run = true,
			necrolyte_death_seeker = true,
			meepo_poof = true,
			spirit_breaker_charge_of_darkness = true,
			phantom_assassin_phantom_strike = true,
			phantom_assassin_phantom_strike_aghs2024 = true,
		}

		self.AbilityMaxAllowedRange = {
			mirana_leap = 1200, -- 3x leap with talent
			templar_assassin_trap_teleport = 1200,
			marci_companion_run = 1200,
			pangolier_shield_crash = 900, -- 3x horizontal distance (during ultimate)

			storm_spirit_ball_lightning = 1500,
			spirit_breaker_charge_of_darkness = 1500,
		}

		self.abilityOnlyOtherTargets = {
			snapfire_gobble_up = true,
			pudge_dismember = true,
		}

		self:StartIntervalThink(0.5)
	end
end

function modifier_hero_pos_checker_sb_2023:OnIntervalThink()
	if self:IsCurrentAbilityProcessedPos() then
		self.lastGoodPositionTime = GameRules:GetGameTime()
		return
	end

	local currentPos = self:GetParent():GetAbsOrigin()

	local isHeroMounted = self:GetParent():HasModifier("modifier_mounted")
	local isTooLong = self.lastGoodPositionTime and GameRules:GetGameTime() > self.lastGoodPositionTime + self.maxTimeToSetGoodPosition

	local canFindPath = GridNav:CanFindPath(currentPos, self.lastGoodPosition)
	local isPathToLastCheckpoint = self:IsPathToLastCheckPoint(self:GetParent(), currentPos)

	local isValidPosition = canFindPath or isPathToLastCheckpoint

	if isValidPosition and isHeroMounted then
		local pathLength = GridNav:FindPathLength(currentPos, self.lastGoodPosition)
		local isTooFar = (pathLength == -1 or pathLength > self.maxPathLength or (currentPos - self.lastGoodPosition):Length2D() > self.maxPathLength)

		isValidPosition = not isTooFar
	end

	if isValidPosition or isTooLong then
		if isValidPosition then
			self.lastGoodPosition = currentPos
		end

		if isTooLong and isPathToLastCheckpoint then
			self.lastGoodPosition = currentPos
		end

		self.lastGoodPositionTime = GameRules:GetGameTime()

		if GameRules.Dungeon.debugMode then
			local vPos = self.lastGoodPosition
			vPos.z = GetGroundHeight(currentPos, nil) + 25
			DebugDrawCircle( vPos, Vector( 0, 255, 0 ), 255, 75, false, 1.0 )
		end
	end
	
	if self:GetParent():IsRealHero() and isTooLong and (GameRules:GetGameTime() - self.playerPickTime) > 3.5 then
		local extraInfo = {
			text = "Position Checker Could Not Find Any Good Position! Please Use <font color='gold'>-unstuck</font> Command",
			error = true,
			duration = 3.5,
		}

		CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "player_extra_info", extraInfo )
	end
end

function modifier_hero_pos_checker_sb_2023:GetLastGoodPosition()
	return self.lastGoodPosition
end

function modifier_hero_pos_checker_sb_2023:SetCustomPositionCheckerForCreep(abilityIndex, checkLength, otherTargetEnemyModifier)
	local ability = EntIndexToHScript(abilityIndex)
	if not ability or ability:IsNull() then
		return
	end

	local abilityName = ability:GetAbilityName()
	local delay = self.abilityBlinkChangePosition[abilityName] or 1
	local channelTime = ability:GetChannelTime() or 0
	local castPoint = ability:GetCastPoint()
	local checkTime = castPoint + channelTime + delay

	local abilityToVerifyPos = {
		abilityIndex = abilityIndex,
		startPos = self:GetLastGoodPosition(),
		target = self:GetParent()
	}

	self.isBlocked = true

	if not self.abilityPositionChangeModifier[abilityName] or abilityName == "primal_beast_onslaught" then
		Timers:CreateTimer(checkTime, function ()
			self:VerifyPosAfterSpellCast(ability, abilityToVerifyPos["startPos"], self:GetParent(), checkLength)
			self.isBlocked = false
		end)
	else
		local modifierNoticeDelay = self.abilityPositionChangeModifier[abilityName]["modifier_need_notice_delay"] or 0
		local modifierToVerify = self.abilityPositionChangeModifier[abilityName]["modifier_name"] or ""

		if self.abilityPositionChangeModifier[abilityName]["other_target_alternate_modifier"] then
			modifierToVerify = self.abilityPositionChangeModifier[abilityName]["other_target_alternate_modifier"]
		end

		if otherTargetEnemyModifier and self.abilityPositionChangeModifier[abilityName]["other_enemy_target_alternate_modifier"] then
			modifierToVerify = self.abilityPositionChangeModifier[abilityName]["other_enemy_target_alternate_modifier"]
		end

		local customTimerInterval = self.abilityPositionChangeModifier[abilityName]["timer_interval"]

		local timerInterval = 0.1

		if customTimerInterval and tonumber(customTimerInterval) then
			timerInterval = tonumber(customTimerInterval)
		end

		abilityToVerifyPos["modifier_name"] = modifierToVerify
		abilityToVerifyPos["modifier_noticed"] = false
		abilityToVerifyPos["modifier_delay"] = modifierNoticeDelay
		abilityToVerifyPos["interval"] = timerInterval

		self:VerifyHeroPositionByModifier(abilityToVerifyPos, checkLength, false)
	end
end

function modifier_hero_pos_checker_sb_2023:VerifyCreepPositionByModifier(modifierToVerify, checkLength, delay, maxWaitingForModifier, forceVerifyPos)
	self.isBlocked = true

	local abilityToVerifyPos = {
		startPos = self:GetLastGoodPosition(),
		target = self:GetParent()
	}

	abilityToVerifyPos["modifier_name"] = modifierToVerify
	abilityToVerifyPos["modifier_noticed"] = false
	abilityToVerifyPos["modifier_delay"] = delay
	abilityToVerifyPos["interval"] = 0.1
	abilityToVerifyPos["modifier_max_waiting"] = 3.5

	if maxWaitingForModifier then
		abilityToVerifyPos["modifier_max_waiting"] = maxWaitingForModifier
	end

	if forceVerifyPos then
		abilityToVerifyPos["force_verify_pos"] = true
	end

	self:VerifyHeroPositionByModifier(abilityToVerifyPos, checkLength, true)
end

function modifier_hero_pos_checker_sb_2023:IsCurrentAbilityProcessedPos()
	return self.isBlocked
end

function modifier_hero_pos_checker_sb_2023:SetCurrentAblilityProcessedPos(isBlocked)
	self.isBlocked = isBlocked
end

function modifier_hero_pos_checker_sb_2023:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}

	return funcs
end

----------------------------------------
function modifier_hero_pos_checker_sb_2023:OnAbilityExecuted( params )
	if IsServer() then

		--Position Checker can be added for creeps, but should not verify their abilities!
		if not self:GetParent():IsRealHero() then
			return
		end

		if params.unit ~= self:GetParent() then
			return
		end

		if params.ability == nil or params.ability:IsNull() then
			return
		end

		local ability = params.ability
		local abilityName = params.ability:GetAbilityName()
		local target = params.target

		--spells stolen by amulet are not visible here (so need to overrite it here)
		if abilityName == "item_longclaws_amulet" then
			local longClawStolenSpell = ability:GetStolenAbilityHandler()
			if longClawStolenSpell then
				if longClawStolenSpell and not longClawStolenSpell:IsNull() then
					ability = longClawStolenSpell
					abilityName = longClawStolenSpell:GetAbilityName()
				end
			end
		end

		if self.abilityOnlyOtherTargets[abilityName] and params.target and self.abilityPositionChangeModifier[abilityName] then
			-- no need validation for enemies!
			if abilityName == "pudge_dismember" then
				if params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
					return
				end
			end

			local modifierToVerify = self.abilityPositionChangeModifier[abilityName]["modifier_name"]
			local durationProperty = self.abilityPositionChangeModifier[abilityName]["duration_property_name"]

			if modifierToVerify then
				local targetModifier = target:FindModifierByName("modifier_hero_pos_checker_sb_2023")

				if not targetModifier then
					targetModifier = target:AddNewModifier(target, nil, "modifier_hero_pos_checker_sb_2023", {})
				end
			
				if targetModifier then
					local maxDuration = 3.5

					if durationProperty then
						local duration = ability:GetSpecialValueFor(durationProperty)

						if duration and duration > 0 then
							maxDuration = duration + ability:GetCastPoint() + 0.2
						end
					end

					targetModifier:VerifyCreepPositionByModifier(modifierToVerify, true, 0.1, maxDuration, true)
				end
			end

			--this ability can be cast only on other targets, so end here!
			return
		end

		--force position checker only (for example enemy position is handled in their modifier)
		if self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["force_check_only"] then
			return
		end

		local isAbilityNeedPosChecker = self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["modifier_name"]
		local isBlinkNeedPoschecker = self.abilityBlinkChangePosition[abilityName] 

		if not isAbilityNeedPosChecker and not isBlinkNeedPoschecker then
			return
		end

		local isOtherUnitTarget = target and target:IsBaseNPC() and target ~= self:GetParent()

		--change spirit bear position
		if abilityName == "lone_druid_spirit_bear" and self:GetParent().spiritBearEntity then
			target = self:GetParent().spiritBearEntity
			isOtherUnitTarget = true
		end

		if isOtherUnitTarget and not self.abilityForceCheckSelfPosition[abilityName] then
			local targetModifier = target:FindModifierByName("modifier_hero_pos_checker_sb_2023")

			if not targetModifier then
				targetModifier = target:AddNewModifier(target, nil, "modifier_hero_pos_checker_sb_2023", {})
			end
		
			if targetModifier then
				local otherTargetEnemyModifier = self.abilityPositionChangeModifier[abilityName] and 
												self.abilityPositionChangeModifier[abilityName]["other_enemy_target_alternate_modifier"] and 
												target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()

				targetModifier:SetCustomPositionCheckerForCreep(ability:entindex(), true, otherTargetEnemyModifier)
			end

			--end here for other targets if hero position don't need verifcation.
			if self.abilityPositionChangeModifier[abilityName] and not self.abilityPositionChangeModifier[abilityName]["both_targets_verify"] then
				return
			end
		end

		self.isBlocked = true
		local modifierNoticeDelay = 0
		local modifierToVerify = ""
		local modifierMaxWaiting = 3.5
		local timerInterval = 0.1

		if self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["modifier_need_notice_delay"] then
			modifierNoticeDelay = self.abilityPositionChangeModifier[abilityName]["modifier_need_notice_delay"]
		end

		if self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["modifier_max_waiting"] then
			modifierMaxWaiting = self.abilityPositionChangeModifier[abilityName]["modifier_max_waiting"]
		end

		if self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["modifier_name"] then
			modifierToVerify = self.abilityPositionChangeModifier[abilityName]["modifier_name"]
		end

		if isOtherUnitTarget and self.abilityPositionChangeModifier[abilityName] and 
			self.abilityPositionChangeModifier[abilityName]["other_target_self_alternate_modifier"]
		then
			modifierToVerify = self.abilityPositionChangeModifier[abilityName]["other_target_self_alternate_modifier"]
		end

		if self.abilityPositionChangeModifier[abilityName] and self.abilityPositionChangeModifier[abilityName]["timer_interval"] then
			local customTimerInterval = self.abilityPositionChangeModifier[abilityName]["timer_interval"]

			if customTimerInterval and tonumber(customTimerInterval) then
				timerInterval = tonumber(customTimerInterval) or 0.1
			end
		end
		
		local abilityToVerifyPos = {
			abilityIndex = ability:entindex(),
			ability_name = abilityName,
			startPos = self.lastGoodPosition,
			modifier_name = modifierToVerify,
			modifier_noticed = false,
			modifier_delay = modifierNoticeDelay,
			modifier_max_waiting = modifierMaxWaiting,
			interval = timerInterval,
			target = self:GetParent(),
		}

		if isBlinkNeedPoschecker and modifierToVerify == "" then
			local delay = self.abilityBlinkChangePosition[abilityName] or 0.25
			local channelTime = ability:GetChannelTime() or 0
			local checkTime = channelTime + delay

			Timers:CreateTimer(checkTime, function ()
				self:VerifyPosAfterSpellCast(ability, abilityToVerifyPos["startPos"], self:GetParent(), true)
				self.isBlocked = false
			end)
		else
			self:StartAbilityPositionVerificationCheck(abilityToVerifyPos)
		end
	end
end

function modifier_hero_pos_checker_sb_2023:StartAbilityPositionVerificationCheck(abilityData)
	local startPos = abilityData["startPos"]
	if not startPos then
		self.isBlocked = false
		return
	end

	local abilityIndex = abilityData["abilityIndex"]
	if not abilityIndex then
		self.isBlocked = false
		return
	end

	local ability = EntIndexToHScript(abilityIndex)
	if not ability then
		self.isBlocked = false
		return
	end

	local target = abilityData["target"]

	if not target or not IsValidEntity(target) or not target:IsBaseNPC() then
		abilityData["target"] = self:GetParent()
	end

	self:VerifyHeroPositionByModifier(abilityData, true, false)
end

function modifier_hero_pos_checker_sb_2023:VerifyHeroPositionByModifier(abilityData, checkLength, ignoreAbility)
	if not abilityData["startPos"] or not abilityData["target"] then
		self.isBlocked = false
		return
	end

	local target = abilityData["target"]
	local startPos = abilityData["startPos"]

	local ability = nil

	if not ignoreAbility then
		local abilityIndex = abilityData["abilityIndex"]
		if not abilityIndex then
			self.isBlocked = false
			return
		end
	
		ability = EntIndexToHScript(abilityIndex)
		if not ability then
			self.isBlocked = false
			return
		end
	end

	local abilityCastPoint = 0

	if ability then
		abilityCastPoint = ability:GetCastPoint()
	end

	local maxWaitingTime = 3.5

	if abilityData["modifier_max_waiting"] then
		maxWaitingTime = abilityData["modifier_max_waiting"]
	end

	local maxTimeToNoticeModifier = GameRules:GetGameTime() + maxWaitingTime
	local modifierToVerify = abilityData["modifier_name"] or ""
	local modifierCheckDelay = abilityData["modifier_delay"] or 0
	local interval = abilityData["interval"] or -1

	if abilityCastPoint == 0 and modifierCheckDelay == 0 then
		modifierCheckDelay = 0.1
	end

	Timers:CreateTimer(0, function ()
		if not target or target:IsNull() or (target:IsCreature() and not target:IsAlive()) then
			self.isBlocked = false
			return nil
		end

		if not target:HasModifier(modifierToVerify) then
			if (modifierCheckDelay == 0 or abilityData["modifier_noticed"]) then
				self:VerifyPosAfterSpellCast(ability, startPos, target, checkLength)
				self.isBlocked = false
			
				return nil
			end
		elseif modifierCheckDelay > 0 and not abilityData["modifier_noticed"] then
			abilityData["modifier_noticed"] = true

			return modifierCheckDelay
		end

		if (GameRules:GetGameTime() > maxTimeToNoticeModifier) then
			local modifierDelayNotNoticed = modifierCheckDelay > 0 and not abilityData["modifier_noticed"]
			local modifierWithoutDelayNotNoticed = modifierCheckDelay == 0 and not target:HasModifier(modifierToVerify)

			if modifierDelayNotNoticed or modifierWithoutDelayNotNoticed then
				self.isBlocked = false

				if abilityData["force_verify_pos"] then
					self:VerifySelfCurrentPosition(true)
				end

				return nil
			end
		end

		return interval
	end)
end

function modifier_hero_pos_checker_sb_2023:VerifySelfCurrentPosition(checkLength)
	if not self.lastGoodPosition then
		return
	end

	self:VerifyPosAfterSpellCast(nil, self.lastGoodPosition, self:GetParent(), checkLength)
end

function modifier_hero_pos_checker_sb_2023:VerifyPosAfterSpellCast(ability, posBeforeCastSpell, target, checkLength)
	if not target or target:IsNull() then
		return
	end

	local currentPos = target:GetAbsOrigin()
	local pathLength = GridNav:FindPathLength(currentPos, posBeforeCastSpell)

	--Unfortunately FindPathLength seems not to return always correct values (sometimes seems to short?), so there is 1800 max range
	--Also location can be too far, but on some blocked position (e.g. cliffs) path length will be -1
	local isTooFar = false
	if checkLength and GameRules.Dungeon.GetTheBestHeroCurrentZone then
		local heroCurrentZone = GameRules.Dungeon:GetTheBestHeroCurrentZone(self:GetParent())

		if heroCurrentZone and self.zonesMaxPathLengthChecking[GetMapName()] and self.zonesMaxPathLengthChecking[GetMapName()][heroCurrentZone.nZoneID] then
			isTooFar = pathLength == -1 or pathLength > self.maxPathLength or (currentPos - posBeforeCastSpell):Length2D() > self.maxPathLength
		end
	end

	local isFreePathToDestination = GridNav:CanFindPath(posBeforeCastSpell, currentPos)
	
	if not isFreePathToDestination or isTooFar then
		if not target:IsCreature() then
			local newGoodPosition = self:FindBestPlaceToPutHero(posBeforeCastSpell, currentPos, target, isTooFar)
			
			if newGoodPosition and GridNav:CanFindPath(posBeforeCastSpell, newGoodPosition) then
				newGoodPosition = GetClearSpaceForUnit(target, newGoodPosition)
			else
				newGoodPosition = posBeforeCastSpell
			end

			target:SetAbsOrigin(newGoodPosition)
			self.lastGoodPosition = newGoodPosition

			if target:IsRealHero() and target == self:GetParent() and (currentPos - newGoodPosition):Length2D() > 1600 then
				CenterCameraOnUnit(target:GetPlayerOwnerID(), target)
			end

			GridNav:DestroyTreesAroundPoint( newGoodPosition, 250, false )
			
			local warningText = "Location Too Far"
			if not isFreePathToDestination then
				warningText = "Wrong Location"
			end

			local extraInfo = {
				text = warningText,
				sound = "Pos_Checker_Return",
				error = true,
			}

			if ability and not ability:IsNull() then
				extraInfo["ability_name"] = ability:GetAbilityName()
			end

			CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "player_extra_info", extraInfo )
		else
			FindClearSpaceForUnit(target, posBeforeCastSpell, true)
		end
	end
end

function modifier_hero_pos_checker_sb_2023:FindBestPlaceToPutHero(posBeforeCastSpell, currentPos, target, isTooFar)
	local endDistance = (currentPos - posBeforeCastSpell):Length2D()
	local realMaxDistance = math.min(self.maxPathLength, endDistance)

	if not isTooFar then
		local desiredPos = posBeforeCastSpell + (currentPos - posBeforeCastSpell):Normalized() * realMaxDistance
		desiredPos = GetClearSpaceForUnit(target, desiredPos)
	
		if GridNav:CanFindPath(posBeforeCastSpell, desiredPos) or self:IsPathToLastCheckPoint(target, desiredPos) then
			return desiredPos
		end
	end

	local counter = 0
	local maxAttempts = 100 --max range is 1800 (qop blink +ather lense + longclaw amulet: 100 x 25 = 2500)

	local firstMethodFailed = false
	local secondMethodFailed = true

	--PUSHING HERO BACKWARD: from current position to position before cast spell
	-- unit should stay as close as possible to the barrier
	--if blink item/ability was cast on the position where path length is ok but position is blocked (cliffs, water etc.)
	--then find the closest position that is traversable starting from current pos to the pos before cast spell 

	local direction = (posBeforeCastSpell - currentPos):Normalized()
	local newPos = currentPos + direction * 25
	newPos.z = GetGroundHeight(newPos, target)

	local distanceToStartPosition = (posBeforeCastSpell - currentPos):Length2D()

	while (not GridNav:CanFindPath(posBeforeCastSpell, newPos) or not self:IsPathToLastCheckPoint(target, newPos)) or 
		GridNav:FindPathLength(newPos, posBeforeCastSpell) > realMaxDistance or (newPos - posBeforeCastSpell):Length2D() > realMaxDistance
	do
		if counter > maxAttempts then
			firstMethodFailed = true
			break
		end

		newPos = newPos + direction * 25
		newPos.z = GetGroundHeight(newPos, target)

		--if distance between new position and currentpos (position where hero stopped his blink/ability) is greater than 
		--the initial distance to start position, it means we pushed hero back too much
		if (newPos - currentPos):Length2D() > distanceToStartPosition + 25 then
			firstMethodFailed = true
			break
		end

		counter = counter + 1
	end
	
	--can't find position by pushing hero back: try again from initial position and push forward!
	if firstMethodFailed then
		counter = 0
		local lastValidPosition = posBeforeCastSpell
		direction = (currentPos - posBeforeCastSpell):Normalized()
		newPos = posBeforeCastSpell + direction * 25
		newPos.z = GetGroundHeight(newPos, target)

		--PUSHING HERO FORWARD: from initial position (position before cast spell) to current position (hero end position)
		-- unit should stay as close as possible to the barrier or max spell/blink distance
		while GridNav:CanFindPath(posBeforeCastSpell, newPos) and GridNav:FindPathLength(newPos, posBeforeCastSpell) <= realMaxDistance and
			(newPos - posBeforeCastSpell):Length2D() <= realMaxDistance
		do
			secondMethodFailed = false

			if counter > maxAttempts then
				break
			end

			newPos = newPos + direction * 25
			newPos.z = GetGroundHeight(newPos, target)

			--if distance between new position and startPos (position where hero started his blink/ability) is greater than the end position, 
			--it means we pushed hero forward too much
			if (newPos - posBeforeCastSpell):Length2D() > endDistance + 25 then
				break
			end

			lastValidPosition = newPos
			counter = counter + 1
		end

		newPos = lastValidPosition
	end

	if not firstMethodFailed or not secondMethodFailed then
		return newPos
	end

	return posBeforeCastSpell
end

function modifier_hero_pos_checker_sb_2023:IsPathToLastCheckPoint(target, vPos)	
	local checkpointPos = GameRules.Dungeon:GetPlayerCurrentCheckpointPosition(target)

	if checkpointPos and GridNav:CanFindPath(vPos, GetClearSpaceForUnit(target, checkpointPos)) then
		return true
	end

	return false
end