LinkLuaModifier('modifier_item_flag_carrier', 'items/item_flag.lua', LUA_MODIFIER_MOTION_NONE)

local EXCEPTION_MODIFIERS = {
	'modifier_winter_wyvern_arctic_burn_flight',
	'modifier_dazzle_shallow_grave',
	'modifier_storm_spirit_ball_lightning',
	'modifier_faceless_void_time_walk',
	'modifier_morphling_waveform',
	'modifier_phoenix_icarus_dive',
	'modifier_phoenix_sun',
	'modifier_void_spirit_dissimilate_phase',
	'modifier_void_spirit_astral_step_caster',
	'modifier_earth_spirit_rolling_boulder_caster',
	'modifier_pudge_swallow_hide',
	'modifier_dark_willow_shadow_realm_buff',
	'modifier_earthshaker_enchant_totem_leap',
	'modifier_monkey_king_bounce_leap',
	'modifier_monkey_king_bounce_perch',
	'modifier_magnataur_skewer_movement',
	'modifier_teleporting',
--	'modifier_obsidian_destroyer_astral_imprisonment_prison',
	'modifier_shredder_timber_chain',
--	'modifier_tusk_snowball_movement',
--	'modifier_tusk_snowball_movement_friendly',
	'modifier_sandking_burrowstrike',
	'modifier_black_king_bar_immune',
	'modifier_spectre_spectral_dagger_path_phased',
	'modifier_item_spider_legs_active',
	-- 'modifier_broodmother_spin_web_web',
	-- 'modifier_broodmother_spin_web_invisible_applier',
	'modifier_slark_pounce',
	'modifier_slark_shadow_dance',
	'modifier_oracle_false_promise',
	'modifier_wisp_relocate_return',
	'modifier_pangolier_gyroshell',
	'modifier_pangolier_swashbuckle_stunned',
	'modifier_swashbuckle_charge_counter',
	'modifier_brewmaster_primal_split',
	'modifier_item_giants_ring',
	'modifier_kunkka_x_marks_the_spot',
	'modifier_keeper_of_the_light_recall',
	'modifier_visage_silent_as_the_grave',
	'modifier_visage_summon_familiars_damage_charge',
	'modifier_techies_suicide_leap',
	'modifier_skeleton_king_reincarnation_scepter_active',
	'modifier_batrider_firefly',
	'modifier_snapfire_gobble_up_creep',
	'modifier_night_stalker_darkness',
	'modifier_wisp_tether_haste',
	'modifier_dragon_knight_dragon_form',
    'modifier_dragon_knight_black_dragon_tooltip',
    'modifier_item_ogre_seal_totem_active',
    'modifier_ui_custom_ability_jump',
}

local EXCEPTION_ABILITIES = {
	'weaver_time_lapse',
	'antimage_blink',
	'queenofpain_blink',
	'item_blink',
	'item_overwhelming_blink',
	'item_swift_blink',
	'item_arcane_blink',
	'puck_ethereal_jaunt',
	'item_force_staff',
	'item_wind_waker',
	'item_hurricane_pike',
	'puck_fallen_sky',
	'mirana_leap',
	'ember_spirit_activate_fire_remnant',
	'meepo_poof',
	'abyssal_underlord_portal_warp',
	'templar_assassin_trap_teleport',
	'spectre_reality',
	'phantom_lancer_doppelwalk',
	'item_force_boots',
	'item_fallen_sky',
	'item_book_of_shadows',
    'item_ogre_seal_totem',
    'naga_siren_song_of_the_siren',
    'rattletrap_hookshot',
}

local FlagReturnCountdown = class{
	constructor = function(self, hFlagItem)
		self.bNull = false
		self.hFlagItem = hFlagItem
		self.nTeam = hFlagItem:GetOwnerTeam()
		self.vPos = (hFlagItem:GetContainer() or hFlagItem):GetOrigin()
		self.nRadius = FLAG_RETURN_RADIUS
		self.nReturnDuration = FLAG_RETURN_DURATION
		self.nAutoReturnTimeout = FLAG_AUTO_RETURN_DURATION
		self.nSpawnTime = GameRules:GetGameTime()
		self.nLastThink = self.nSpawnTime

		self.nViewer1 = AddFOWViewer(DOTA_TEAM_GOODGUYS, self.vPos, self.nRadius + 32, 99999, false)
		self.nViewer2 = AddFOWViewer(DOTA_TEAM_BADGUYS, self.vPos, self.nRadius + 32, 99999, false)

		self:CreateTimerParticle()

		-- ОПТИМИЗАЦИЯ: Сохраняем ID таймера для очистки, увеличен интервал с FrameTime() до 0.1s
		self.timerID = Timers:CreateTimer(function()
			if self:IsNull() then
				self:Destroy()
				return
			end

			self:Think()

			return 0.1
		end)
	end,
	
	Destroy = function(self)
		if not self.bNull then
			RemoveFOWViewer(DOTA_TEAM_GOODGUYS, self.nViewer1)
			RemoveFOWViewer(DOTA_TEAM_BADGUYS, self.nViewer2)
			self:DestroyTimerParticle()
			-- ОПТИМИЗАЦИЯ: Очищаем таймер для предотвращения утечки памяти
			if self.timerID then
				Timers:RemoveTimer(self.timerID)
				self.timerID = nil
			end
			self.bNull = true
		end
	end,

	IsNull = function(self)
		return self.bNull or self.hFlagItem:IsNull()
	end,

    Think = function(self)
		local nTime = GameRules:GetGameTime()

		if nTime - self.nSpawnTime >= self.nAutoReturnTimeout then
			self:RestoreFlag()
			return
		end

		local heroesAround = FindUnitsInRadius(
			self.nTeam,
			self.vPos, 
			nil,
			self.nRadius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false
		)

		if #heroesAround > 0 then
			local nEnemiesArouns = #FindUnitsInRadius(
				self.nTeam,
				self.vPos,
				nil,
				self.nRadius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false
			)

			if self.nRingStartTime == nil then
				self.nRingStartTime = nTime
			end

			if self.nTimerParticle ~= nil then
				if nEnemiesArouns == 0 then
					ParticleManager:SetParticleControl(self.nTimerParticle, 1, Vector(self.nRadius, 1/self.nReturnDuration, 0))
				else
					ParticleManager:SetParticleControl(self.nTimerParticle, 1, Vector(self.nRadius, 0, 0))
				end
			end

			if nEnemiesArouns == 0 then
				local nReturnTime = nTime - self.nRingStartTime
				if nReturnTime >= self.nReturnDuration then
					self:RestoreFlag()
					return
				end
			else
				self.nRingStartTime = self.nRingStartTime + nTime - self.nLastThink
			end
		elseif self.nRingStartTime then
			self.nRingStartTime = nil
			self:CreateTimerParticle()
		end

		self.nLastThink = nTime
    end,

	RestoreFlag = function(self)
		local heroesAround = FindUnitsInRadius(
			self.nTeam,
			self.vPos, 
			nil,
			self.nRadius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false
		)

		for _, hero in ipairs(heroesAround) do
			Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
		end

		UTIL_Remove(self.hFlagItem:GetContainer())
		UTIL_Remove(self.hFlagItem)

		GameRules.AddonTemplate:RespawnFlagForTeam(self.nTeam)

		GameRules.AddonTemplate:PlaySoundForTeam('Flag.Return.Good', self.nTeam)
		GameRules.AddonTemplate:PlaySoundForTeam('Flag.Return.Bad', GetOppositeTeam(self.nTeam))

		self:Destroy()
	end,

	DestroyTimerParticle = function(self)
		if self.nTimerParticle then
			ParticleManager:DestroyParticle(self.nTimerParticle, true)
			ParticleManager:ReleaseParticleIndex(self.nTimerParticle)
			self.nTimerParticle = nil
		end
	end,
	
	CreateTimerParticle = function(self)
		self:DestroyTimerParticle()

		self.nTimerParticle = ParticleManager:CreateParticle('particles/djalal/custom_timer.vpcf', PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.nTimerParticle, 0, self.vPos)
		ParticleManager:SetParticleControl(self.nTimerParticle, 1, Vector(self.nRadius, 0, 0))
		ParticleManager:SetParticleFoWProperties(self.nTimerParticle, 0, 0, self.nRadius)
	end,
}

local function CanCarryFlag(nTeam, hUnit)
	if nTeam == hUnit:GetTeam() then
		return false
	end
	if hUnit:GetUnitName() == "npc_dota_hero_broodmother" then
		if hUnit:HasModifier("modifier_broodmother_spin_web_web") or 
		   hUnit:HasModifier("modifier_broodmother_spin_web_invisible_applier") then
			return false
		end
	end
	
	for _, sMod in pairs(EXCEPTION_MODIFIERS) do
		if hUnit:HasModifier(sMod) then
			return false
		end
	end
	
	if not hUnit:IsRealHero() then
		return false
	end
	return true
end

local function DropFlag(nTeam, vPos)
	local hFlag = GameRules.AddonTemplate:RespawnFlagForTeam(nTeam, vPos)
	hFlag.hReturnCountdown = FlagReturnCountdown(hFlag)
end

item_flag = class({
	GetOwnerTeam = function(self)
		if self:GetName() == 'item_flag_dire' then
			return DOTA_TEAM_BADGUYS
		end
		return DOTA_TEAM_GOODGUYS
	end,

	OnSpellStart = function(self)
		if self.bUsed then
			return
		end
		self.bUsed = true

		local caster = self:GetCaster()
		local nTeam = DOTA_TEAM_GOODGUYS
		local nOpponentTeam = DOTA_TEAM_BADGUYS
		
        if self:GetAbilityName() == 'item_flag_dire' then
			nTeam = DOTA_TEAM_BADGUYS
			nOpponentTeam = DOTA_TEAM_GOODGUYS
		end

		local vFlagOrigin = self:GetOrigin()
		if self:GetContainer() then
			vFlagOrigin = self:GetContainer():GetOrigin()
		end

		if CanCarryFlag(nTeam, caster) then
			caster:AddNewModifier(caster, self, 'modifier_item_flag_carrier', {})
			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Stolen.Bad', nTeam)
			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Stolen.Good', nOpponentTeam)

			if self.hReturnCountdown then
				self.hReturnCountdown:Destroy()
			end
		else
			local hFlag = GameRules.AddonTemplate:RespawnFlagForTeam(nTeam, vFlagOrigin)

			local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID())
        	if player then
            	CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_cant_pickup_flag"})
        	end

			if self.hReturnCountdown then
				self.hReturnCountdown.hFlagItem = hFlag
				hFlag.hReturnCountdown = self.hReturnCountdown
			end
		end

		UTIL_Remove(self:GetContainer())
		UTIL_Remove(self)
    end
})

modifier_item_flag_carrier = class({
    IsDebuff = function(self) return false end,
    IsPurgable = function(self) return false end,
	IsPurgeException = function(self) return false end,
	GetPriority = function(self) return MODIFIER_PRIORITY_SUPER_ULTRA end,
	GetTexture = function(self)
		return 'item_dimensional_doorway'
	end,
	GetEffectName = function(self) 
		return 'particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_ambient.vpcf'
	end,
    DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	} end,
	GetModifierProvidesFOWVision = function(self)
		return 1
	end,
	CheckState = function(self)
		return {
			[MODIFIER_STATE_INVISIBLE] = false,
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = false,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		}
	end,
    OnCreated = function(self, keys)
		if IsClient() then return end

		local hAbility = self:GetAbility()
		if not hAbility then
			return
		end
		
		self.carrier = self:GetParent()
		self.nOwnerTeam = self.carrier:GetOpposingTeamNumber()
		self.caster_absorigin = self:GetParent():GetAbsOrigin()

        self.time_return_flag = FLAG_RETURN_DURATION * 60

		self.nOpponentTeam = DOTA_TEAM_BADGUYS
		if self.nOwnerTeam == DOTA_TEAM_BADGUYS then
			self.nOpponentTeam = DOTA_TEAM_GOODGUYS
		end
		
		self.hIcon = GameRules.AddonTemplate.flagIconUnits[self.nOwnerTeam]
		SetIconVisibe(GameRules.AddonTemplate.flagIconpointUnits[self.nOwnerTeam], true)

		self:StartIntervalThink(FrameTime())

		self.vTargetPlace = GameRules.AddonTemplate.flagPositions[DOTA_TEAM_GOODGUYS]
		if self.carrier:GetTeam() == DOTA_TEAM_BADGUYS then
			self.vTargetPlace = GameRules.AddonTemplate.flagPositions[DOTA_TEAM_BADGUYS]
		end

		-- create flag visual
		self.nParticle = ParticleManager:CreateParticle("particles/head_flag.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.carrier)
		local vAttachOrigin = self.carrier:GetAttachmentOrigin(self.carrier:ScriptLookupAttachment('attach_hitloc'))
		ParticleManager:SetParticleControlEnt(self.nParticle, 0, self.carrier, PATTACH_POINT_FOLLOW, 'attach_hitloc', vAttachOrigin, false)
		ParticleManager:SetParticleControl(self.nParticle, 1, Vector(FLAG_PICKUP_SCALE * GetFlagScale(self.nOwnerTeam), math.pi, 0))
		ParticleManager:SetParticleControl(self.nParticle, 2, vAttachOrigin)
		ParticleManager:SetParticleControl(self.nParticle, 7, Vector(tonumber(GetMaterial(hAbility) or 0), 0, 0))

		local FxSparkEntry = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.carrier)
		ParticleManager:SetParticleControlEnt(FxSparkEntry, 0, self.carrier, PATTACH_POINT_FOLLOW, 'attach_hitloc', vAttachOrigin, false)
		
		ParticleManager:ReleaseParticleIndex(FxSparkEntry)
		-- create prop with flag model for flag visual
		
		if hAbility then
			local sModel = hAbility:GetAbilityKeyValues().Model
			if sModel then
				self.hModelProp = SpawnEntityFromTableSynchronous('prop_dynamic', {
					model = sModel,
				})
				if self.hModelProp then
					self.hModelProp:AddEffects(EF_NODRAW)
					ParticleManager:SetParticleControlEnt(self.nParticle, 3, self.hModelProp, PATTACH_ABSORIGIN, nil, Vector(0,0,0), false)
				end
			end
		end
    end,
	OnDestroy = function(self)
		if not IsServer() then
			return
		end

		-- remove flag visual
		if self.nParticle then
			ParticleManager:DestroyParticle(self.nParticle, true)
			ParticleManager:ReleaseParticleIndex(self.nParticle)
			
			local FxSparkEnd = ParticleManager:CreateParticle("particles/ui/ui_game_start_hero_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.carrier)
			local vAttachOrigin = self.carrier:GetAttachmentOrigin(self.carrier:ScriptLookupAttachment('attach_hitloc'))
			ParticleManager:SetParticleControlEnt(FxSparkEnd, 0, self.carrier, PATTACH_POINT_FOLLOW, 'attach_hitloc', vAttachOrigin, false)
			ParticleManager:SetParticleControl(FxSparkEnd, 1, vAttachOrigin)
			ParticleManager:ReleaseParticleIndex(FxSparkEnd)
		end

		-- remove prop with flag model
		if self.hModelProp and (not self.hModelProp:IsNull()) then
			self.hModelProp:Destroy()
			self.hModelProp = nil
		end

		if self.speed_break then
			DropFlag(self.nOwnerTeam, self.caster_absorigin)
			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Drop.Good', self.nOwnerTeam)
			GameRules.AddonTemplate:PlaySoundForTeamAndPlayerSpecial(self.carrier:GetPlayerOwnerID(), 'Flag.Drop.Self', 'Flag.Drop.Bad')
			return
		end

		if self.bDelivered then
			local nTeam = self.carrier:GetTeam()
            
			DoWithAllPlayers(function(player, hero)
				if not hero then return end
				if hero:GetTeamNumber() == nTeam then
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
				end
			end)
			GameRules.AddonTemplate:IncrementFlags(nTeam)
			GameRules.AddonTemplate:RespawnFlagForTeam(self.nOwnerTeam, nil, nil, true)
			GameRules.AddonTemplate:IncrementCurrencyPlayer(self.carrier:GetPlayerOwner())

            if GameRules.AddonTemplate.player_flags_count[self.carrier:GetPlayerOwnerID()] == nil then
                GameRules.AddonTemplate.player_flags_count[self.carrier:GetPlayerOwnerID()] = 1
            else
                GameRules.AddonTemplate.player_flags_count[self.carrier:GetPlayerOwnerID()] = GameRules.AddonTemplate.player_flags_count[self.carrier:GetPlayerOwnerID()] + 1
            end

			local vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.carrier)
			ParticleManager:DestroyParticle(vfx, false)
			ParticleManager:ReleaseParticleIndex(vfx) -- ФИКС УТЕЧКИ: Освобождение индекса частицы

			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Deliver.Bad', self.nOwnerTeam)
			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Deliver.Good', nTeam)
        elseif self.time_return_flag <= 0 then
            GameRules.AddonTemplate:RespawnFlagForTeam(self.nOwnerTeam, nil, nil, true)
        else
			DropFlag(self.nOwnerTeam, self.carrier:GetOrigin())

			GameRules.AddonTemplate:PlaySoundForTeam('Flag.Drop.Good', self.nOwnerTeam)
			GameRules.AddonTemplate:PlaySoundForTeamAndPlayerSpecial(self.carrier:GetPlayerOwnerID(), 'Flag.Drop.Self', 'Flag.Drop.Bad')
		end
	end,
    OnIntervalThink = function(self)
		local vCarrierPos = self.carrier:GetAbsOrigin()
		local flDistance = (self.vTargetPlace - vCarrierPos):Length2D()

		if (self.caster_absorigin - self:GetParent():GetAbsOrigin()):Length2D() >= 500 then
			self.speed_break = true
			self:Destroy()
			return
		end

        self.time_return_flag = self.time_return_flag - FrameTime()
        if self.time_return_flag <= 0 then
            self:Destroy()
            return
        end

		self.caster_absorigin = self:GetParent():GetAbsOrigin()

		if flDistance < 250 then
			self.bDelivered = true
			self:Destroy()
		else
			AddFOWViewer(self.nOwnerTeam, vCarrierPos, 600, 0.1, true)

			if self.hIcon then
				self.hIcon:SetAbsOrigin(vCarrierPos)
			end
		end
    end,
	OnAbilityStart = function(self, event)
		if not IsServer() then return end

		if self:GetParent() == event.unit then
			local hAbility = event.ability

			print('dropped by '..hAbility:GetAbilityName())

			if in_array(hAbility:GetAbilityName(), EXCEPTION_ABILITIES) then
				self:Destroy()
			end
		end
	end,
	OnModifierAdded = function(self, event)
		if not IsServer() then return end

		if self:GetParent() == event.unit then
			local szModifierName = event.added_buff:GetName()
			if in_array(szModifierName, EXCEPTION_MODIFIERS) then
				self:Destroy()
			end
		end
	end,
})

item_flag_radiant = item_flag
item_flag_dire = item_flag

function _G.HasFlag(hUnit)
	return hUnit:HasModifier('modifier_item_flag_carrier') or hUnit:HasModifier('modifier_item_flag_carrier_both')
end