if CAddonWarsong == nil then
	_G.CAddonWarsong = class({})
end
_G.MAX_PLAYER_COUNT = 12

require('moasq1')
require('get_keys')
Precache = require "precache"
require('libraries/declarations')
require('libraries/timers')
require('libraries/table')
require('libraries/utility_functions')
require('extensions/base_npc')
require('extensions/table')
require ("libraries/player_info")
require ("server/http")
require ("server/server_manager")
require('donate/donate_manager')
require('libraries/neutrals_items')
require('libraries/portals_system')
require('libraries/add_new_abilities')
require('libraries/fate_system') 
require('libraries/sphere_system')
require('libraries/mvp_system')
require('libraries/spawner_system')
require('libraries/events')
require('libraries/wear_manager')
require('libraries/flags_system')
require('libraries/selection_same')
require('libraries/abilities_damage')
require('libraries/upgrades')
require('settings/heroes_items_list')
require('settings/morph_settings')
require('settings/abilities_give_list')
TEST_ACTIVATED = false

require('settings/books_settings')
 
function Activate()
	GameRules.AddonTemplate = CAddonWarsong()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonWarsong:FilterFunction(name)
	local f = require('filters/' .. name)
	return function(self, t)
		return f(t, self)
	end
end


HeroExpTable = {0}
expTable = {
    240,
    400,
    520,
    600,
    680,
    760,
    800,
    900,
    1000,
    1100,
    1200,
    1300,
    1400,
    1500,
    1600,
    1700,
    1800,
    1900,
    2000,
    2200,
    2400,
    2600,
    2800,
    3000,
    4000,
    5000,
    6000,
    7000,
    7500,
}

for i=2,#expTable + 1 do 
	HeroExpTable[i] = HeroExpTable[i-1] + expTable[i-1]
end

function CAddonWarsong:InitGameMode()
	-- ОПТИМИЗАЦИЯ FPS: Кешируем имя карты чтобы не вызывать GetMapName() многократно
	local mapName = GetMapName()
	self.mapName = mapName
	
	-- Устанавливаем GAME_TIME_CLOCK для карт
	print("[INIT] mapName =", mapName)
	print("[INIT] GAME_TIME_CLOCK before =", GAME_TIME_CLOCK)
	
	if mapName == "warsong" then
		GAME_TIME_CLOCK = 1000
		print("[INIT] Set GAME_TIME_CLOCK = 1000 for warsong")
	elseif mapName == "portal_duo" then
		GAME_TIME_CLOCK = 1200
		print("[INIT] Set GAME_TIME_CLOCK = 1200 for portal_duo")
	elseif mapName == "portal_trio" then
		GAME_TIME_CLOCK = 1200
		print("[INIT] Set GAME_TIME_CLOCK = 1200 for portal_trio")
	end
	
	print("[INIT] GAME_TIME_CLOCK after =", GAME_TIME_CLOCK)
	
	GameRules:SetPreGameTime(3)
	GameRules:SetStrategyTime(5)
	GameRules:SetShowcaseTime(0)
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(DAY_NIGHT_CYCL)
	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_tp_scroll_custom")
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath(false)
	 
    GameRules:GetGameModeEntity():SetPlayerHeroAvailabilityFiltered(true)

	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true ) 
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( HeroExpTable )

	if mapName == "warsong" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:GetGameModeEntity():SetPauseEnabled(IsInToolsMode())
		GameRules:GetGameModeEntity():SetCameraDistanceOverride(1200)
		SendToServerConsole( "r_farz 8000" )
	elseif mapName == "portal_duo" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 2 )
		GameRules:GetGameModeEntity():SetPauseEnabled(IsInToolsMode())
	elseif mapName == "portal_trio" then 
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3 )
	 	GameRules:GetGameModeEntity():SetPauseEnabled(IsInToolsMode())	
	elseif mapName == "dash" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	end
 
	self.bMatchStarted = false


	self.nWinConditionGoal = CONDITION_FLAG_COUNT_WIN

	self.PlayersDefaultAbilities = {}
	self.PlayersUltimateAbilities = {}
    self.PlayersRerollAbilities = {}

    self.player_flags_count = {}
	self.nCapturedFlagsCount = {}

	if mapName == "warsong" then
		self.nCapturedFlagsCount = {
			[DOTA_TEAM_GOODGUYS] = 0,
			[DOTA_TEAM_BADGUYS] = 0,
		}
	end
 
    self.nMorphKillsCount = {}
	self.nMorphKillsCount[DOTA_TEAM_GOODGUYS] = 0
	self.nMorphKillsCount[DOTA_TEAM_BADGUYS] = 0
	self.nMorphKillsCount[DOTA_TEAM_CUSTOM_1] = 0
	self.nMorphKillsCount[DOTA_TEAM_CUSTOM_2] = 0
	self.nMorphKillsCount[DOTA_TEAM_CUSTOM_3] = 0
	self.nMorphKillsCount[DOTA_TEAM_CUSTOM_4] = 0

    self.soldiers_units = {}
	
	-- ВАЖНО: Повторно устанавливаем GAME_TIME_CLOCK здесь, т.к. game_settings.lua может перезаписать значение
	if mapName == "warsong" then
		GAME_TIME_CLOCK = 1000
	elseif mapName == "portal_duo" then
		GAME_TIME_CLOCK = 1200
	elseif mapName == "portal_trio" then
		GAME_TIME_CLOCK = 1200
	end
	
	self.game_timer = GAME_TIME_CLOCK
	print("[TIMER INIT] Final GAME_TIME_CLOCK for " .. mapName .. " = " .. GAME_TIME_CLOCK)

	self.killLeaderRewardTimer = {}
	self.killStreak = {}
	self.killStreakLimits = {}
	self.teamBalanceTier = {}
	CAddonWarsong.votes_kills = {}
	CAddonWarsong.votes_draft = {}

	local hGME = GameRules:GetGameModeEntity()
	
	hGME:SetThink("OnThink", self, "GlobalThink", 1)

    self.pendingPrecache = {}
    self.precached = {}
    self:RunAbilitySoundPrecache()
 
    Timers:CreateTimer(0, function()
    	local gameState = GameRules:State_Get()
    	
    	-- DEBUG: Выводим состояние каждый тик для диагностики
    	if not self._timer_debug_count then
        self._timer_debug_count = 0
    	end
    	self._timer_debug_count = self._timer_debug_count + 1
    	
    	if self._timer_debug_count % 100 == 0 then
        print("[TIMER LOOP] Timer loop active. Tick count: " .. self._timer_debug_count .. " Game state: " .. gameState)
    	end
    	
    	if gameState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            if mapName ~= "dota" and mapName ~="dash" then
                self:GameTimeClock()
            else
                -- DEBUG: Таймер не запускается
                print("[TIMER DEBUG] Timer condition failed. mapName =", mapName)
            end
        else
            -- DEBUG: Игра еще не началась
            if not self._timer_state_logged then
                print("[TIMER DEBUG] Waiting for game to start. Current state:", gameState)
                print("[TIMER DEBUG] DOTA_GAMERULES_STATE_GAME_IN_PROGRESS =", DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)
                self._timer_state_logged = true
            end
        end
        -- Таймер обновляется каждую секунду для плавного отображения
        return 1
    end)
	
	hGME:SetFreeCourierModeEnabled(true)
	hGME:SetUseTurboCouriers(true)
	hGME:SetDraftingBanningTimeOverride(BAN_TIME)

	if mapName == "dash" then
		hGME:SetBountyRuneSpawnInterval(99999)
		hGME:SetPowerRuneSpawnInterval(RUNE_INTERVAL)
		GameRules:SetNextRuneSpawnTime(RUNE_INTERVAL)
        hGME:SetFountainPercentageHealthRegen(FOUNTAIN_MAX_HEALTH_REGEN_PCT)
		hGME:SetFountainPercentageManaRegen(FOUNTAIN_MAX_MANA_REGEN_PCT)
		GameRules:SetStartingGold(START_GOLD)
		GameRules:SetUseUniversalShopMode(true)
		-- GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)
		hGME:SetLoseGoldOnDeath(false)
        hGME:SetCanSellAnywhere(true)
    else
		hGME:SetBountyRuneSpawnInterval(99999)
		hGME:SetPowerRuneSpawnInterval(RUNE_INTERVAL)
		GameRules:SetNextRuneSpawnTime(RUNE_INTERVAL)
		hGME:SetFixedRespawnTime(RESPAWN_TIME)
		hGME:SetFountainPercentageHealthRegen(FOUNTAIN_MAX_HEALTH_REGEN_PCT)
		hGME:SetFountainPercentageManaRegen(FOUNTAIN_MAX_MANA_REGEN_PCT)
		GameRules:SetStartingGold(START_GOLD)
		GameRules:SetUseUniversalShopMode(true)
		hGME:SetLoseGoldOnDeath(false)
        hGME:SetCanSellAnywhere(true)
	end

    if TEST_ACTIVATED then
		GameRules:SetCustomGameSetupAutoLaunchDelay(1)
		GameRules:SetCustomGameSetupTimeout(1)
    end

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonWarsong, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonWarsong, "OnNPCSpawned"), self)
	ListenToGameEvent("dota_team_kill_credit", Dynamic_Wrap( self, 'OnTeamKillCredit' ), self )
    ListenToGameEvent("entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
	ListenToGameEvent("dota_buyback", Dynamic_Wrap( self, 'OnBuyback' ), self )
	ListenToGameEvent("player_disconnect", Dynamic_Wrap( self, 'OnPlayerDisconnect' ), self )
	ListenToGameEvent("player_connect_full", Dynamic_Wrap( self, 'OnPlayerConnect' ), self )
	ListenToGameEvent("dota_inventory_item_added", Dynamic_Wrap( self, 'OnPlayerItemAdded' ), self )
	-- ListenToGameEvent("dota_item_used", Dynamic_Wrap( self, 'OnItemUsed' ), self )
	if IsInToolsMode() then
		ListenToGameEvent("player_chat", Dynamic_Wrap( self, 'OnPlayerChat' ), self )
	end

    CustomGameEventManager:RegisterListener('select_kills_event', function(_, event)
        self.nWinConditionGoal = self.nWinConditionGoal + HOW_MUCH_KILLS_ADD
        CustomGameEventManager:Send_ServerToAllClients('update_kills_duo', {
            kills = self.nWinConditionGoal
        })
	end)
	CustomGameEventManager:RegisterListener('high_five', function(_, event)
		self:HighFive(event)
	end)
	CustomGameEventManager:RegisterListener('summon_mount', function (_, event)
		self:SummonMount(event)
	end)
    CustomGameEventManager:RegisterListener('ability_select_to_hero', function(_, event)
        self:SelectAbilityToHero(event.PlayerID, event.spell_name, event.is_ultimate)
	end)

    CustomGameEventManager:RegisterListener('player_fate_selected', function(_, event)
        self:SelectPlayerFate(event.PlayerID, event.fate_name)
	end)
 
    CustomGameEventManager:RegisterListener('player_sphere_selected', function(_, event)
        self:SelectPlayerSphere(event.PlayerID, event.sphere_name)
	end)

    CustomGameEventManager:RegisterListener('swap_abilities_to_select', function(_, event)
        self:HeroAddNewAbility(nil, event.is_ultimate, event.PlayerID, true)
	end)

    CustomGameEventManager:RegisterListener('reroll_spheres', function(_, event)
        self:RerollPlayerSphere(event)
	end)

 

	 

	CustomGameEventManager:RegisterListener('Request_RemainingFlags', function(_, event)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event.PlayerID), 'update_flags_count', {
			radiant = self.nWinConditionGoal - (self.nCapturedFlagsCount[DOTA_TEAM_GOODGUYS] or 0),
			dire = self.nWinConditionGoal - (self.nCapturedFlagsCount[DOTA_TEAM_BADGUYS] or 0)
		})
	end)

    CustomGameEventManager:RegisterListener('buy_book', function(_, event)
        self:BuyBook(event)
	end)

    if IsInToolsMode() then
        hGME:SetDraftingBanningTimeOverride(0)
        --GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_pudge")
    end

	hGME:SetExecuteOrderFilter(self:FilterFunction('order'), self)
	self:RegisterPortals()
end
 

function CAddonWarsong:ModifyGoldFilter(data)
	if data.reason_const == DOTA_ModifyGold_HeroKill then
		local hero = PlayerResource:GetSelectedHeroEntity(data.player_id_const)
		if hero then
			local teamTable = self.teamBalanceTier[hero:GetTeamNumber()]

			if teamTable.place == "first" and teamTable.tier ~= 0 then
				data.gold = data.gold / 2 
			end
		end
	end

	return true
end
 

-- Игровой think 0.5 sec and 1 sec start
function CAddonWarsong:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self.mapName ~= "dash" then
			self:GetWinPlayers()
		end
	end
	-- ОПТИМИЗАЦИЯ FPS: Увеличен интервал с 2s до 5s (проверка победы)
	return 5
end

function CAddonWarsong:OnStartGame()
	self:InitNeutralItems()

	if self.mapName == "portal_duo" or self.mapName == "portal_trio" then
		Timers:CreateTimer(1, function()
			self:UpdateLeaderPortalDuo()
			return 1
		end)
	end
end

function CAddonWarsong:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		for iPlayerID=0, _G.MAX_PLAYER_COUNT do
            for i=1,148 do
                if DOTAGameManager:GetHeroNameByID( i ) ~= nil then
                    GameRules:AddHeroToPlayerAvailability(iPlayerID, i )
                end
            end 	
        end

        self.banned_heroes_same = {}
        Timers:CreateTimer(0.1, function()
            local nNewState = GameRules:State_Get()
            if nNewState ~= DOTA_GAMERULES_STATE_HERO_SELECTION then
                return
            end
            self:HeroSelectionUpdater()
            -- ОПТИМИЗАЦИЯ FPS: Увеличен интервал с 1.0s до 2.0s (проверка запрета одинаковых героев)
            return 2.0
        end)
		self.flagPositions = {}
		self.flagItemNames = {}
		self.flagIconUnits = {}
		self.flagIconpointUnits = {}
		self.FlagPositionBoth = {}
		self:ChangeKills()
		if self.mapName == "dash" then
			self.item_flag_both_position = Entities:FindByName(nil, 'flag_both')
			if self.item_flag_both_position == nil then
				print('cant find both flag')
				return
			end
			self.item_flag_both_radiant_position = Entities:FindByName(nil, 'flag_both_radiant')
			if self.item_flag_both_radiant_position == nil then
				print('cant find both radiant flag')
				return
			end
			self.item_flag_both_dire_position = Entities:FindByName(nil, 'flag_both_dire')
			if self.item_flag_both_dire_position == nil then
				print('cant find both dire flag')
				return
			end
			self.FlagPositionBoth = self.item_flag_both_position:GetAbsOrigin()
			self.flagPositions[DOTA_TEAM_GOODGUYS] = self.item_flag_both_radiant_position:GetAbsOrigin()
			self.flagPositions[DOTA_TEAM_BADGUYS] = self.item_flag_both_dire_position:GetAbsOrigin()
			self:RespawnFlagBoth()
		else
			self.radiant_flag_position = Entities:FindByName(nil, 'flag_radiant')
			if self.radiant_flag_position == nil then
				print('cant find radiant flag')
				return
			end
			self.dire_flag_position = Entities:FindByName(nil, 'flag_dire')
			if self.dire_flag_position == nil then
				print('cant find radiant flag')
				return
			end
			self.all_vision_point = Entities:FindByName(nil, 'middle_vision_point')
			if self.all_vision_point ~= nil then
				local vVisionPos = self.all_vision_point:GetAbsOrigin()
				AddFOWViewer(DOTA_TEAM_GOODGUYS, vVisionPos, 1800, 9999.0, false)
				AddFOWViewer(DOTA_TEAM_BADGUYS, vVisionPos, 1800, 9999.0, false)
			end
			self.flagItemNames[DOTA_TEAM_GOODGUYS] = 'item_flag_radiant'
			self.flagPositions[DOTA_TEAM_GOODGUYS] = self.radiant_flag_position:GetAbsOrigin()
			self.flagItemNames[DOTA_TEAM_BADGUYS] = 'item_flag_dire'
			self.flagPositions[DOTA_TEAM_BADGUYS] = self.dire_flag_position:GetAbsOrigin()
			AddFOWViewer(DOTA_TEAM_GOODGUYS, self.flagPositions[DOTA_TEAM_GOODGUYS], 1000, 9999.0, true)
			AddFOWViewer(DOTA_TEAM_GOODGUYS, self.flagPositions[DOTA_TEAM_BADGUYS], 1000, 9999.0, true)
			AddFOWViewer(DOTA_TEAM_BADGUYS, self.flagPositions[DOTA_TEAM_GOODGUYS], 1000, 9999.0, true)
			AddFOWViewer(DOTA_TEAM_BADGUYS, self.flagPositions[DOTA_TEAM_BADGUYS], 1000, 9999.0, true)
			self.flagIconpointUnits[DOTA_TEAM_GOODGUYS] = CreateMinimapIcon(
				'npc_dota_warsong_minimap_flagpoint',
				DOTA_TEAM_GOODGUYS,
				self.radiant_flag_position:GetAbsOrigin()
			)
			self.flagIconpointUnits[DOTA_TEAM_BADGUYS] = CreateMinimapIcon(
				'npc_dota_warsong_minimap_flagpoint',
				DOTA_TEAM_BADGUYS,
				self.dire_flag_position:GetAbsOrigin()
			)
			self.flagIconUnits[DOTA_TEAM_GOODGUYS] = CreateMinimapIcon(
				'npc_dota_warsong_minimap_flag_radiant',
				DOTA_TEAM_GOODGUYS,
				self.radiant_flag_position:GetAbsOrigin()
			)
			self.flagIconUnits[DOTA_TEAM_BADGUYS] = CreateMinimapIcon(
				'npc_dota_warsong_minimap_flag_dire',
				DOTA_TEAM_BADGUYS,
				self.dire_flag_position:GetAbsOrigin()
			)
			self:RespawnFlagForTeam(DOTA_TEAM_GOODGUYS, nil, nil, true)
			self:RespawnFlagForTeam(DOTA_TEAM_BADGUYS, nil, nil, true)
		end
	elseif nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then 
		-- PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_1)
		local mapName = self.mapName
		-- function addBot(team)
		-- 	local used_hero_name = "npc_dota_hero_luna"
		-- 	local maxPlayers = 4
		-- 	local teamCount = maxPlayers - PlayerResource:GetPlayerCountForTeam(team)
		
		-- 	while teamCount > 0 do
		-- 		Tutorial:AddBot(used_hero_name, "", "", team == DOTA_TEAM_GOODGUYS)
		-- 		teamCount = maxPlayers - PlayerResource:GetPlayerCountForTeam(team)
		-- 	end
		-- end
		-- addBot(DOTA_TEAM_BADGUYS)
		-- addBot(DOTA_TEAM_GOODGUYS)
		ServerManager:Init()
		if mapName == "warsong" or mapName == "dash" then
			if PlayerResource:GetPlayerCount() ~= 10 then  
				local team = 2
				for i=0, _G.MAX_PLAYER_COUNT do 
					if PlayerResource:IsValidPlayer(i) then 
						if i%2 == 0 then 
							team = RandomInt(2,3)
						end
						PlayerResource:SetCustomTeamAssignment(i, team)
						team = team == 3 and 2 or 3
					end
				end
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			local hPlayer = PlayerResource:GetPlayer(i)
			if hPlayer and not PlayerResource:HasSelectedHero(i) then
				hPlayer:MakeRandomHeroSelection()
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local mapName = self.mapName
		DonateManager:Init()
		CustomGameEventManager:Send_ServerToAllClients('update_flags_count', {
			radiant = self.nWinConditionGoal,
			dire = self.nWinConditionGoal
		})
		CustomGameEventManager:Send_ServerToAllClients('update_kills_duo', {
			kills = self.nWinConditionGoal
		})
		if mapName == "portal_duo" then
			local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2, DOTA_TEAM_CUSTOM_3, DOTA_TEAM_CUSTOM_4}
			for _,team in ipairs(teams) do
				local sentry = CreateUnitByName("npc_dummy_unit", Entities:FindByName(nil, "point_sentry"):GetAbsOrigin(), true, nil, nil, team)
				sentry:AddNewModifier(sentry, nil, "modifier_true_sight_portal_aura", {})
			end
		elseif mapName == "portal_trio" then
			local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2}
			for _,team in ipairs(teams) do
				local sentry = CreateUnitByName("npc_dummy_unit", Entities:FindByName(nil, "point_sentry"):GetAbsOrigin(), true, nil, nil, team)
				sentry:AddNewModifier(sentry, nil, "modifier_true_sight_portal_aura", {})
			end
        end
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local mapName = self.mapName
		
		-- Устанавливаем game_timer перед началом игры
		if mapName == "warsong" then
			self.game_timer = 1000
		elseif mapName == "portal_duo" then
			self.game_timer = 1200
		elseif mapName == "portal_trio" then
			self.game_timer = 1200
		end
		print("[GAME START] Set game_timer = " .. self.game_timer .. " for " .. mapName)
		
		self:OnStartGame()

		self:DayNightCycle()

        if mapName == "warsong" then
            CreateHints("warsong_hints_start_game")
            Timers:CreateTimer(45, function()
                CreateHints("warsong_hints_capture_flag")
            end)
        elseif mapName == "portal_duo" then
            CreateHints("warsong_hints_start_game")
        elseif mapName == "portal_trio" then
            CreateHints("warsong_hints_start_game")
        elseif mapName == "dash" then
            CreateHints("warsong_hints_dash_start")
            Timers:CreateTimer(120, function()
                CreateHints("warsong_hints_dash_gameplay")
            end)
            Timers:CreateTimer(720, function()
                CreateHints("warsong_hints_dash_gameplay")
            end)
            Timers:CreateTimer(1440, function()
                CreateHints("warsong_hints_dash_gameplay")
            end)
        end
		self.bMatchStarted = true
		CustomGameEventManager:Send_ServerToAllClients('update_kills_duo', {
			kills = self.nWinConditionGoal
		})
        if mapName == "portal_duo" or mapName == "portal_trio" then
            CustomGameEventManager:Send_ServerToAllClients('select_kill_on_start_game', {})
        end
		Timers:CreateTimer(NEW_ABILITY_COOLDOWN, function()
			self:ChangeNewAbilities()
			return NEW_ABILITY_COOLDOWN
		end)
        Timers:CreateTimer(NEW_PASSIVE_SPELLS_COOLDOWN, function()
            if CAddonWarsong.fate_count_number >= MAX_COUNT_CHOOSE_PASSIVE_SPELL_IN_GAME then return end
			self:GivePlayersFate()
			return NEW_PASSIVE_SPELLS_COOLDOWN
		end)
        Timers:CreateTimer(NEW_SPHERES, function()
        	if CAddonWarsong.sphere_count_number >= MAX_SPHERE_COUNT then return end
			self:GivePlayersSphere()
			return NEW_SPHERES
		end)
		Timers:CreateTimer(NEW_ULTIMATE_COOLDOWN, function()
			self:ChangeNewAbilities(true)
			return NEW_ULTIMATE_COOLDOWN
		end)
		if mapName == "dash" then
			Timers:CreateTimer(TIME_FOR_AMP_TOWERS_AND_CREEPS, function()
				if self.mapName ~= "dash" then return end
				self:AMP_TOWERS_AND_CREEPS()
				return TIME_FOR_AMP_TOWERS_AND_CREEPS
			end)
		end
		self:GiveBooks()
		if mapName ~= "dota" then
			-- ОПТИМИЗАЦИЯ FPS: Объединил циклы золота и опыта в один, интервал 5s вместо отдельных
			Timers:CreateTimer(5, function()
				for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
					local hHero = PlayerResource:GetSelectedHeroEntity(i)

					if hHero then
						-- Начисление золота (умножено на 5, т.к. было GRANT_INTERVAL/2 ~= 10s, теперь 5s)
						local team = hHero:GetTeamNumber()
						local bonusGold = 0
						if self.teamBalanceTier[team] and self.teamBalanceTier[team].tier ~= 0 then
							local place = self.teamBalanceTier[team].place
							if place == "last" then
								bonusGold = LAST_COMMAND_GOLD_TICK[self.teamBalanceTier[team].tier]
							elseif place == "prelast" then
								bonusGold = PRE_LAST_COMMAND_GOLD_TICK[self.teamBalanceTier[team].tier]
							end
						end
						hHero:ModifyGold((GRANT_GOLD + bonusGold) / 2 * 5 / (GRANT_INTERVAL / 2), true, DOTA_ModifyGold_Unspecified)

						-- Начисление опыта
						if not hHero:HasModifier("modifier_freeze_time_start") then
							local expForNextLevel = expTable[hHero:GetLevel()]
							if expForNextLevel then
								local exp = PERCENT_OF_LEVEL_MINUTE / 60 * 5
								hHero:AddExperience(math.ceil(expForNextLevel * (exp / 100)), 0, false, true)
							end
						end
					end
				end
				return 5
			end)

			if mapName == "dash" then
				self:GiveTowersModifiersUNVUIL()
				-- ОПТИМИЗАЦИЯ FPS: Увеличен интервал с 3s до 8s для баланса команд
				Timers:CreateTimer(8, function()
					local goldTeam = {
						[DOTA_TEAM_GOODGUYS] = 0,
						[DOTA_TEAM_BADGUYS] = 0,
					}

					local radiantScore = self.nCapturedFlagsCount[DOTA_TEAM_GOODGUYS] or 0
					local direScore = self.nCapturedFlagsCount[DOTA_TEAM_BADGUYS] or 0

					local leader = radiantScore > direScore and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
					local loser = leader == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
					local dataLoser = {place = "last"}
					local dataLeader = {place = "first", tier = 0}

					local differenceKill = (self.nCapturedFlagsCount[leader] or 0) - (self.nCapturedFlagsCount[loser] or 0)
					
					-- ОПТИМИЗАЦИЯ FPS: Прямой цикл вместо DoWithAllPlayers
					for playerId = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
						if PlayerResource:IsValidPlayerID(playerId) then
							local hero = PlayerResource:GetSelectedHeroEntity(playerId)
							if hero then
								local goldHero = PlayerResource:GetNetWorth(playerId)
								local team = hero:GetTeamNumber()
								if team == DOTA_TEAM_GOODGUYS then
									goldTeam[DOTA_TEAM_GOODGUYS] = goldTeam[DOTA_TEAM_GOODGUYS] + goldHero
								elseif team == DOTA_TEAM_BADGUYS then
									goldTeam[DOTA_TEAM_BADGUYS] = goldTeam[DOTA_TEAM_BADGUYS] + goldHero
								end
							end
						end
					end

					local differenceGold = goldTeam[loser] > 0 and ((goldTeam[leader] - goldTeam[loser]) / goldTeam[loser]) * 100 or 0

					if differenceKill >= KILLS_DIFFERENCE_TIER_1 and differenceGold >= GOLD_DIFFERENCE_TIER_1 then
						dataLoser.tier = 1
					elseif differenceKill >= KILLS_DIFFERENCE_TIER_2 and differenceGold >= GOLD_DIFFERENCE_TIER_2 then
						dataLoser.tier = 2
 					else
						dataLoser.tier = 0
					end

					self.teamBalanceTier[loser] = dataLoser
					self.teamBalanceTier[leader] = dataLeader

					-- ОПТИМИЗАЦИЯ FPS: Отключены все проверки modifier_balance
					-- DoWithAllPlayers(function(player, hero)
					-- 	if not hero then return end
					-- 	if not hero.balanceModifier then return end
					-- 	local team = hero:GetTeamNumber()

					-- 	local tier = self.teamBalanceTier[team].tier
					-- 	local place = self.teamBalanceTier[team].place

					-- 	if place == "last" and LAST_MODIFIER_BALANCE[tier] then
					-- 		local incomingDamage = LAST_MODIFIER_BALANCE[tier].incoming
					-- 		local outgoingDamage = LAST_MODIFIER_BALANCE[tier].outgoing
					-- 		if incomingDamage or outgoingDamage then
					-- 			hero.balanceModifier:SetStackCount(1)
					-- 			hero.balanceModifier.incomingDamage = incomingDamage or 0
					-- 			hero.balanceModifier.outgoingDamage = outgoingDamage or 0
					-- 		end
					-- 	 else
					-- 		 hero.balanceModifier:SetStackCount(0)
					-- 		hero.balanceModifier.incomingDamage = 0
					-- 		hero.balanceModifier.outgoingDamage = 0
					-- 	end
					-- end)

					-- ОПТИМИЗАЦИЯ FPS: Увеличен интервал с 3s до 8s для баланса команд
					return 8
				end)
			end
		end
	end
end


function CAddonWarsong:OnBuyback(data)
	local playerId  = data.player_id
	PlayerResource:SetCustomBuybackCooldown(playerId, BUYBACK_COOLDOWN)
end
 


function CAddonWarsong:GiveBooks()
	self.bookTicks = {
		common = {},
		rare = {},
		epic = {},
	}
	self.bookReserve = {}
	self.activeBookPlayers = {} -- ОПТИМИЗАЦИЯ: Кеш активных игроков
	
	local initPlayerBooks = function(playerId)
        self.bookTicks.common[playerId] = {tick = 0, count = 0}
        self.bookTicks.rare[playerId] = {tick = 0, count = 0}
        self.bookTicks.epic[playerId] = {tick = 0, count = 0}
        self.bookReserve[playerId] = {common = 0, rare = 0, epic = 0}
    end
	
	DoWithAllPlayers(function(player, hero, playerId)
        initPlayerBooks(playerId)
        self.activeBookPlayers[playerId] = true -- Добавляем в кеш
    end)
	
	Timers:CreateTimer(2, function()
		-- ОПТИМИЗАЦИЯ FPS: Кешированный список активных игроков вместо проверки всех 24 слотов
		for playerId, _ in pairs(self.activeBookPlayers) do
			local hero = PlayerResource:GetSelectedHeroEntity(playerId)
			local player = PlayerResource:GetPlayer(playerId)
			
			-- Проверяем валидность (игрок мог выйти)
			if not hero or not player or not PlayerResource:IsValidPlayerID(playerId) then 
				self.activeBookPlayers[playerId] = nil -- Удаляем из кеша
				goto continue 
			end
			
			if self.bookTicks.common[playerId] == nil then
				initPlayerBooks(playerId)
				goto continue
			end

			-- ОПТИМИЗАЦИЯ: Увеличен интервал с 2s до 5s
			self.bookTicks.common[playerId].tick = self.bookTicks.common[playerId].tick + 5
			self.bookTicks.rare[playerId].tick = self.bookTicks.rare[playerId].tick + 5
			self.bookTicks.epic[playerId].tick = self.bookTicks.epic[playerId].tick + 5

			-- ОПТИМИЗАЦИЯ FPS: Отключен дебаг-принт для снижения нагрузки на консоль
			-- print("[GiveBooks] Tick update for player", playerId, "- common tick:", self.bookTicks.common[playerId].tick)

			-- ОПТИМИЗАЦИЯ FPS: Кеш времён книг для команды
			local team = hero:GetTeamNumber()
			local commonTime = BOOK_COMMON_COOLDOWN
			local rareTime = BOOK_RARE_COOLDOWN
			local epicTime = BOOK_EPIC_COOLDOWN

			-- Проверка баланса (простое чтение из таблицы, быстро)
			local teamBalance = self.teamBalanceTier[team]
			if teamBalance and teamBalance.tier ~= 0 then
				local tier = teamBalance.tier
				local bookTimes = teamBalance.place == "last" and LAST_BOOK_COOLDOWN 
					or teamBalance.place == "prelast" and PRE_LAST_BOOK_COOLDOWN
				
				if bookTimes and bookTimes[tier] then
					commonTime = bookTimes[tier].common or commonTime
					rareTime = bookTimes[tier].rare or rareTime
					epicTime = bookTimes[tier].epic or epicTime
				end
			end

			if self.bookTicks.common[playerId].count < BOOK_COMMON_LIMIT and self.bookTicks.common[playerId].tick >= commonTime then
                self.bookTicks.common[playerId].tick = 0
                if self.bookTicks.common[playerId].disconnected then
                    self.bookReserve[playerId].common = self.bookReserve[playerId].common + 1
                else
                    self.bookTicks.common[playerId].count = self.bookTicks.common[playerId].count + 1
                    -- ОПТИМИЗАЦИЯ FPS: Отключен дебаг-принт
                    -- print("[GiveBooks] Giving COMMON book to player", playerId, "count:", self.bookTicks.common[playerId].count)
                    Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
                    EmitSoundClient("sphere_choice", player)
                end
			elseif self.bookTicks.common[playerId].count >= BOOK_COMMON_LIMIT then
				-- print("Лимит на книги COMMON")
            end

			if GameRules:GetDOTATime(false, false) >= BOOK_RARE_START and self.bookTicks.rare[playerId].count < BOOK_RARE_LIMIT and self.bookTicks.rare[playerId].tick >= rareTime then
                self.bookTicks.rare[playerId].tick = 0
                if self.bookTicks.rare[playerId].disconnected then
                    self.bookReserve[playerId].rare = self.bookReserve[playerId].rare + 1
                else
                    self.bookTicks.rare[playerId].count = self.bookTicks.rare[playerId].count + 1
                    -- ОПТИМИЗАЦИЯ FPS: Отключен дебаг-принт
                    -- print("[GiveBooks] Giving RARE book to player", playerId, "count:", self.bookTicks.rare[playerId].count)
                    Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
                    EmitSoundClient("sphere_choice", player)
                end
            end

			if self.bookTicks.epic[playerId].count < BOOK_EPIC_LIMIT and self.bookTicks.epic[playerId].tick >= epicTime then
                self.bookTicks.epic[playerId].tick = 0
                if self.bookTicks.epic[playerId].disconnected then
                    self.bookReserve[playerId].epic = self.bookReserve[playerId].epic + 1
                else
                    self.bookTicks.epic[playerId].count = self.bookTicks.epic[playerId].count + 1
                    -- ОПТИМИЗАЦИЯ FPS: Отключен дебаг-принт
                    -- print("[GiveBooks] Giving EPIC book to player", playerId, "count:", self.bookTicks.epic[playerId].count)
                    Upgrades:QueueSelection(hero, UPGRADE_RARITY_EPIC)
                    EmitSoundClient("sphere_choice", player)
                end
            end
			
			::continue::
		end

		-- ОПТИМИЗАЦИЯ: Увеличен интервал с 2s до 5s
		return 5
	end)
end

function CAddonWarsong:DayNightCycle()
	GameRules:SetTimeOfDay(0.25)

	Timers:CreateTimer(150, function()
		local isDay = GameRules:GetDOTATime(false, false)%299 <= 150  

		GameRules:SetTimeOfDay(isDay and 0.25 or 0.75)
		return 150
	end)
end

function CAddonWarsong:OnNPCSpawned(event)
	local hUnit = EntIndexToHScript(event.entindex)
	if hUnit == nil then return end
	
	-- ОПТИМИЗАЦИЯ FPS: Ранний выход для ненужных юнитов (здания, вышки и т.д.)
	local isHero = hUnit:IsRealHero()
	local isCreep = hUnit:IsCreep()
	local isIllusion = hUnit:IsIllusion()
	local hasSummonUpgrades = hUnit:GetOwner() and not hUnit:GetOwner():IsNull()
	
	-- Обрабатываем только героев, крипов, иллюзий и саммонов
	if not isHero and not isCreep and not isIllusion and not hasSummonUpgrades then
		return
	end
	
    if hUnit and hUnit.items_activated == nil then
        hUnit.items_activated = true
        CAddonWarsong:SetEquipItemPlayer(hUnit)
    end

	if isHero then
		Timers:CreateTimer(0.03, function()
			if  not hUnit:IsClone()
				and not hUnit:IsTempestDouble()
				and hUnit.bFirstSpawned == nil
			then
				hUnit.bFirstSpawned = true
				hUnit.spawnPoint = hUnit:GetAbsOrigin()
				self:WearHero(hUnit)
				if self.nCapturedFlagsCount[hUnit:GetTeamNumber()] == nil then
					self.nCapturedFlagsCount[hUnit:GetTeamNumber()] = 0
				end
		
				if self.teamBalanceTier[hUnit:GetTeamNumber()] == nil then
					self:InitTeamBalanceTier(hUnit:GetTeamNumber())
				end



				if hUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
					hUnit:AddNewModifier(hUnit, nil, "modifier_skeleton_king_sound_set", {})
				end
				local mountsAbility = hUnit:AddAbility("summon_mount")
				if mountsAbility then
					mountsAbility:SetLevel(1)
					--cosmetic abilities should be set in indexes 200+ to save hotkeys on server!
					mountsAbility:SetAbilityIndex(201)
				end
				-- local particleLeader = ParticleManager:CreateParticle("particles/overhead_particle/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, hUnit )
				-- ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, hUnit, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", hUnit:GetAbsOrigin(), true )
			if self.mapName ~= "dota" then
				for i=1,HERO_STARTING_LEVEL-1 do
					hUnit:HeroLevelUp(false)
				end
			hUnit.upgrades = {}

			Upgrades:LoadUpgradesData(hUnit:GetUnitName())

				-- ОПТИМИЗАЦИЯ FPS: Отключены модификаторы для повышения производительности
				-- hUnit:AddNewModifier(hUnit, nil, 'modifier_warsong_movespeed_bonus', nil)
				-- hUnit:AddNewModifier(hUnit, nil, 'modifier_balance', nil)
				hUnit:AddNewModifier(hUnit, nil, 'modifier_cursed_leader', nil)
				if self.mapName == "dash" then
					hUnit:AddNewModifier(hUnit, nil, "modifier_head_boss", {})
				end

				-- ОПТИМИЗАЦИЯ FPS: Отключен бесполезный модификатор
				-- hUnit:AddNewModifier(hUnit, nil, 'modifier_teleport_scroll_fast', nil)
				hUnit:AddNewModifier(hUnit, nil, 'modifier_ability_upgrades_controller', nil)

				hUnit:AddNewModifier(hUnit, nil, 'modifier_warsong_movespeed_bonus_resistance_bonus', {phys = PHYSICAL_RESISTANCE_PERCENTAGE, magical = MAGICAL_RESISTANCE_PERCENTAGE, time = RESISTANCE_TIME_ACTIVATED})
				if hUnit:HasAbility('nevermore_necromastery') then
					hUnit:AddNewModifier(hUnit, nil, 'modifier_nevermore_souls', {})
				end

				-- ОПТИМИЗАЦИЯ: Отключена способность прыжка для улучшения FPS
				-- local ui_custom_ability_jump = hUnit:AddAbility('ui_custom_ability_jump')
				-- if ui_custom_ability_jump then
				-- 	ui_custom_ability_jump:SetLevel(1)
				-- end

				-- hUnit:AddItemByName("item_tp_scroll_custom")

				if self.mapName ~= "dash" then
					if hUnit:GetUnitName() ~= 'npc_dota_base_mount' then
						hUnit:AddNewModifier(hUnit, nil, "modifier_freeze_time_start", {duration = START_GAME_FREEZE_TIME})
					end
				end
				DonateManager:InitHero(hUnit)
			end
		end
		end)
	end
 
	-- Применяем AMP модификатор к крипам при спавне (оптимизация вместо таймера)
	if self.mapName == "dash" and self.AMP_Init and isCreep then
		hUnit:AddNewModifier(hUnit, nil, "modifier_dash_amp", {lvl = self.amp_bonus_level, type = "creep"})
	end

	local owner = hUnit:GetOwner()

	if owner and not owner:IsNull() then
		local is_tempest_double = hUnit.IsTempestDouble and hUnit:IsTempestDouble()
		local is_meepo_clone = hUnit.IsClone and hUnit:IsClone()

		if hUnit:IsIllusion() or is_tempest_double or is_meepo_clone then
			Upgrades:ProcessClone(hUnit, PlayerResource:GetSelectedHeroEntity(hUnit:GetPlayerOwnerID()))
		else
			Upgrades:ApplySummonUpgrades(hUnit, hUnit:GetUnitName(), owner)
		end
	end
end
-- выдаем неуязвимость центральным башням
function CAddonWarsong:GiveTowersModifiersUNVUIL()
    local all_buildings = Entities:FindAllByClassname("npc_dota_tower")
    for _, tower in pairs(all_buildings) do
        local tower_name = tower:GetUnitName()
        if tower_name == "npc_dota_goodguys_tower4" or tower_name == "npc_dota_badguys_tower4" then
            tower:AddNewModifier(tower, nil, "modifier_for_middle_towers_for_unvulbure", {})
        end
    end
end

function CAddonWarsong:OnPlayerDisconnect(event) 
	local playerId = event.PlayerID

	if self.bookTicks.common[playerId] then
        self.bookTicks.common[playerId].disconnected = true
        self.bookTicks.rare[playerId].disconnected = true
        self.bookTicks.epic[playerId].disconnected = true
    end
	ServerManager:SendServerPlayerRoll(playerId)
end

function CAddonWarsong:OnPlayerConnect(event) 
	Timers:CreateTimer(1.5, function() 
		local playerId = event.PlayerID
		if self.bookTicks and self.bookTicks.common[playerId] then
			self.bookTicks.common[playerId].disconnected = false
			self.bookTicks.rare[playerId].disconnected = false
			self.bookTicks.epic[playerId].disconnected = false
			 -- Выдаем книги из резерва
			local hero = PlayerResource:GetSelectedHeroEntity(playerId)
			if hero and self.bookReserve[playerId] then
				 for i = 1, self.bookReserve[playerId].common do
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
				 end
				 for i = 1, self.bookReserve[playerId].rare do
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
				 end
				 for i = 1, self.bookReserve[playerId].epic do
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_EPIC)
				 end
				 self.bookReserve[playerId] = {common = 0, rare = 0, epic = 0} -- Очищаем резерв
			end
		end
	end)
end

-- function CAddonWarsong:OnItemUsed(event)
-- 	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
-- 	if not hero then return end

-- 	local item = EntIndexToHScript(event.itemEntIndex)
-- 	if not item then return end

-- 	-- Проверяем что это TP scroll
-- 	if item:GetAbilityName() == "item_tpscroll" then
-- 		-- Восстанавливаем TP scroll через небольшую задержку
-- 		Timers:CreateTimer(0.1, function()
-- 			-- Проверяем есть ли TP scroll в специальном слоте
-- 			local tpSlot = hero:FindItemInInventory("item_tpscroll")
-- 			if not tpSlot then
-- 				-- Если нет, создаём новый
-- 				hero:AddItemByName("item_tpscroll")
-- 			end
-- 		end)
-- 	end
-- end

CAddonWarsong.amp_bonus_level = 0
CAddonWarsong.AMP_Init = false
-- Кеш для башен и фонтанов (оптимизация)
CAddonWarsong.cached_towers = nil
CAddonWarsong.cached_fountains = nil

function CAddonWarsong:AMP_TOWERS_AND_CREEPS()
	self.amp_bonus_level = self.amp_bonus_level + 1
	self.AMP_Init = true

	-- Кешируем башни и фонтаны при первом вызове
	if not self.cached_towers then
		self.cached_towers = Entities:FindAllByClassname("npc_dota_tower")
	end
	if not self.cached_fountains then
		self.cached_fountains = Entities:FindAllByClassname("ent_dota_fountain")
	end

	-- Используем кешированные объекты
	for _, tower in pairs(self.cached_towers) do
		if tower and not tower:IsNull() then
			if tower:HasModifier("modifier_dash_amp") then
				tower:RemoveModifierByName("modifier_dash_amp")
			end
			tower:AddNewModifier(tower, nil, "modifier_dash_amp", {lvl = self.amp_bonus_level})
		end
	end

	for _, fountain in pairs(self.cached_fountains) do
		if fountain and not fountain:IsNull() then
			if fountain:HasModifier("modifier_dash_amp") then
				fountain:RemoveModifierByName("modifier_dash_amp")
			end
			fountain:AddNewModifier(fountain, nil, "modifier_dash_amp", {lvl = self.amp_bonus_level, type = "fountain"})
		end
	end
end

-- УДАЛЕН таймер UpdateCreepsAMP - теперь модификаторы применяются при спавне крипа в OnNPCSpawned
-- Дай пять механика
function CAddonWarsong:HighFive(params)
    if params.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(params.PlayerID)
    local hero = PlayerResource:GetSelectedHeroEntity(params.PlayerID)
    local selected_index = params.selected_index
	local hero_selected = EntIndexToHScript(selected_index)
	if hero_selected ~= hero then
		hero_selected:AddNewModifier(hero_selected, nil, "modifier_high_five", {duration = 10})
		return 
	end
    if hero then
        hero:AddNewModifier(hero, nil, "modifier_high_five", {duration = 10})
    end
end
function CAddonWarsong:SummonMount(params)
	if params.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(params.PlayerID)
    local hero = PlayerResource:GetSelectedHeroEntity(params.PlayerID)
	local selected_index = params.selected_index
	local hero_selected = EntIndexToHScript(selected_index)
	local SummonMountAbility
	if hero_selected ~= hero then
		SummonMountAbility = hero_selected:FindAbilityByName('summon_mount')
		if SummonMountAbility then
			ExecuteOrderFromTable({
				UnitIndex = hero_selected:GetEntityIndex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = SummonMountAbility:GetEntityIndex()
			})
		end
		return 
	end
	if hero then
        SummonMountAbility = hero:FindAbilityByName('summon_mount')
		if SummonMountAbility then
			ExecuteOrderFromTable({
				UnitIndex = hero:GetEntityIndex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = SummonMountAbility:GetEntityIndex()
			})
		end
    end
end


function CAddonWarsong:SetWinner(teamWinner) 
	ServerManager:OnEndGame(function()
		GameRules:SetGameWinner(teamWinner)
	end)
end

