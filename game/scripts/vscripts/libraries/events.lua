DEFAULT_LEADER_PARTICLE = "particles/overhead_particle/leader_overhead.vpcf"

function CAddonWarsong:OnEntityKilled( params )
	local killedUnit = EntIndexToHScript( params.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = nil
	if params.entindex_attacker then
		hero = EntIndexToHScript( params.entindex_attacker )
	end
	if killedUnit:IsRealHero() then
        if killedUnit:IsReincarnating() == true then
            if killedUnit:HasModifier("modifier_warsong_fate_immortal") then
                return killedUnit:SetTimeUntilRespawn( 1 )
            end
            return killedUnit:SetTimeUntilRespawn( 5 )
        else
            local multiple_decrease_respawn = 1
            if killedUnit.one_punchman_die then
                multiple_decrease_respawn = SETTINGS_ONE_PUNCHMAN_RESPAWN_FAST_MULTIPLE
            end
            if GetMapName() == "dash" or GetMapName() == "portal_duo" or GetMapName() == "portal_trio" then
                local level = killedUnit:GetLevel()
                local respawn_time_dash = RESPAWN_TIME
                for _, time_info in pairs(DASH_RESPAWN_TIME_LEVEL) do
                    if level <= time_info[1] then
                        respawn_time_dash = time_info[2]
                        break
                    end
                end
                killedUnit:SetTimeUntilRespawn( respawn_time_dash / multiple_decrease_respawn )
            else
                killedUnit:SetTimeUntilRespawn( RESPAWN_TIME / multiple_decrease_respawn )
            end
			if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
				EmitSoundOn("cursed_knight_dead", killedUnit)
			end

			if not killedUnit:IsClone() and not killedUnit:IsTempestDouble() and hero then 
				local mapName = GetMapName()
				if mapName == "warsong_duo" or mapName == "portal_duo" or mapName == "portal_trio" or mapName == "dash" then 
					local teamNumber  = hero:GetTeamNumber()
					local isOverthrow = mapName == "portal_duo" or mapName == "portal_trio"

					self.nCapturedFlagsCount[teamNumber] = GetTeamHeroKills(teamNumber)
				
					if isOverthrow then
						self:RewardKillLeader(hero:GetPlayerOwnerID(), killedUnit:GetPlayerOwnerID())
					end
			
					self:OnTeamKillChange()
					if GetMapName() == "portal_duo" or GetMapName() == "portal_trio" then
						self:UpdateLeaderPortalDuo()
					end
				end
			end
        end
	end
    if killedUnit:GetUnitName() == "npc_dota_badguys_fort_custom" or killedUnit:GetUnitName() == "npc_dota_goodguys_fort_custom" then
		local isDireFort = killedUnit:GetUnitName() == "npc_dota_badguys_fort_custom"

		CAddonWarsong:SortedMvpPlayers()
		CAddonWarsong:SetWinner(isDireFort and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS) 
    end
	if killedUnit:IsBuilding() then
		local mid_destroy_dire = true
    	local mid_destroy_radiant = true
		for _, tower_list in pairs({tower_to_kills_for_radiant, tower_to_kills_for_dire}) do
			for k, v in pairs(tower_list) do
				if killedUnit:GetUnitName() == k then
					tower_list[k] = v - 1
				end
			end 
		end
		for k, v in pairs(tower_to_kills_for_radiant) do
			if v ~= 0 then
				mid_destroy_dire = false
				break
			end
		end
		for k, v in pairs(tower_to_kills_for_dire) do
			if v ~= 0 then
				mid_destroy_radiant = false
				break
			end
		end
		if mid_destroy_dire or mid_destroy_radiant then
			local all_buildings = Entities:FindAllByClassname("npc_dota_tower")
			for _, tower in pairs(all_buildings) do
				local tower_name = tower:GetUnitName()
				if mid_destroy_dire and tower_name == "npc_dota_badguys_tower4" then
					tower:RemoveModifierByName("modifier_for_middle_towers_for_unvulbure")
				elseif mid_destroy_radiant and tower_name == "npc_dota_goodguys_tower4" then
					tower:RemoveModifierByName("modifier_for_middle_towers_for_unvulbure")
				end
			end
		end
	end
end


function CAddonWarsong:ChangeKills()
	if GetMapName() == "warsong" then return end
    if GetMapName() == "dash" then return end
	local final_kills_count = CONDITION_FLAG_COUNT_WIN
	self.nWinConditionGoal = final_kills_count
end

function CAddonWarsong:AddLeaderParticle(entity)
	local titul = DEFAULT_LEADER_PARTICLE
	
	if not entity:IsRealHero() or entity:IsTempestDouble() then 
		titul = DonateManager:GetCurrentTitulParticle(entity:GetPlayerOwnerID()) or DEFAULT_LEADER_PARTICLE
	else 
		titul = DonateManager:GetCurrentTitulParticle(entity:GetPlayerOwnerID()) or DEFAULT_LEADER_PARTICLE
		entity.donate.titul = titul
	end


	local particleLeader = ParticleManager:CreateParticle(titul, PATTACH_OVERHEAD_FOLLOW, entity )
	ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
	entity:Attribute_SetIntValue( "particleID", particleLeader )
end

function CAddonWarsong:UpdateLeaderPortalDuo()
    local sortedTeams = {}
    for team, kills in pairs( self.nCapturedFlagsCount ) do
        table.insert( sortedTeams, { teamID = team, teamScore = kills } )
    end
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
	local leader = sortedTeams[1].teamID
	local allHeroes = HeroList:GetAllHeroes()
	for _,entity in pairs( allHeroes ) do
		if not entity:IsNull() then
			if entity:GetTeamNumber() == leader and (sortedTeams[1] and sortedTeams[1].teamScore or 0) ~=  (sortedTeams[2] and sortedTeams[2].teamScore or 0) then
				if entity:IsAlive() == true then
					local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
					if existingParticle == -1 then
						self:AddLeaderParticle(entity)
					end
				else
					local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
					if particleLeader ~= -1 then
						ParticleManager:DestroyParticle( particleLeader, true )
						entity:DeleteAttribute( "particleID" )
					end
				end
			else
				local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
				if particleLeader ~= -1 then
					ParticleManager:DestroyParticle( particleLeader, true )
					entity:DeleteAttribute( "particleID" )
				end
			end
		end
	end
end

-- Обновление времени до конца игры
function CAddonWarsong:GameTimeClock()
	if GAME_TIME_CLOCK > 0 then
		GAME_TIME_CLOCK = GAME_TIME_CLOCK - 1
	end
    if GetMapName() == "portal_duo" then
        if GAME_TIME_CLOCK == SPAWN_MORPHLING_TIME then
            self:SpawnMorphling()
        elseif GAME_TIME_CLOCK == SPAWN_MORPHLING_TIME_DOUBLE then
            self:SpawnMorphling()
        end
    end

	local t =  math.floor(GAME_TIME_CLOCK)
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
    {
        timer_minute_10 = m10,
        timer_minute_01 = m01,
        timer_second_10 = s10,
        timer_second_01 = s01,
    }
    CustomGameEventManager:Send_ServerToAllClients( "GameTimer", broadcast_gametimer )
    CustomGameEventManager:Send_ServerToAllClients( "GameTimer_2", broadcast_gametimer )
    if GAME_TIME_CLOCK <= 0 then
    	local sortedTeams = {}

		for team, kills in pairs( self.nCapturedFlagsCount ) do
			table.insert( sortedTeams, { teamID = team, teamScore = kills } )
		end
		table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
		CAddonWarsong:SetWinner( sortedTeams[1].teamID )
        self:SortedMvpPlayers()
    end
end
 

function CAddonWarsong:OnTeamKillCredit( event )
	if event.killer_userid ~= -1 then
		self:RecordKillStreak(event.killer_userid)

		if GetMapName() == "warsong" then 
			if not self.wasFirstBlood then 
				self.wasFirstBlood = true
				Upgrades:QueueSelection(PlayerResource:GetSelectedHeroEntity(event.killer_userid), UPGRADE_RARITY_RARE)
				DoWithAllPlayers(function(player, hero, playerId)
					if not hero then return end
					if playerId ~= event.killer_userid then
						Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
					end
				end)
			end
		end	
	end
	
	if GetMapName() == "dash" then 
		if not self.wasFirstBlood then 
			self.wasFirstBlood = true
			DoWithAllPlayers(function(player, hero, playerId)
				if not hero then return end
				Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
			end)
		end
	end
 
 

	if GetMapName() == "warsong_duo" or GetMapName() == "portal_duo" or GetMapName() == "portal_trio" then
		local isOverthrow = GetMapName() == "portal_duo" or GetMapName() == "portal_trio"

		if isOverthrow then
			if not self.wasFirstBlood then 
				self.wasFirstBlood = true
				Upgrades:QueueSelection(PlayerResource:GetSelectedHeroEntity(event.killer_userid), UPGRADE_RARITY_RARE)
			end
		end		
		 
 
	end
end

function CAddonWarsong:OnTeamKillChange()
	local sortedScore = {}

	for team,score in pairs(self.nCapturedFlagsCount) do
		table.insert(sortedScore, {team = team, score = score})
	end

    table.sort(sortedScore, function(a, b)
        return a.score > b.score
    end)
 
    local maxScore = sortedScore[1].score

	for i,value in ipairs(sortedScore) do
    	if i == #sortedScore then
			self:DifferenceScore(value.team, maxScore, value.score, "last") 
		elseif #sortedScore - 1 ~= 1 and i == #sortedScore - 1  then
			self:DifferenceScore(value.team, maxScore, value.score, "prelast")
		elseif i == 1 then
			self:DifferenceScoreFirstPlace(value.team, sortedScore[2].score, value.score)
		else
			self.teamBalanceTier[value.team] = {place = "other", tier = 0}
		end
    end

	DoWithAllPlayers(function(player, hero)
		if not hero then return end
		if not hero.balanceModifier then return end
		local team = hero:GetTeamNumber()

		local tier = self.teamBalanceTier[team].tier
		local place = self.teamBalanceTier[team].place

		if place == "last" and LAST_MODIFIER_BALANCE[tier] then
			local incomingDamage = LAST_MODIFIER_BALANCE[tier].incoming
			local outgoingDamage = LAST_MODIFIER_BALANCE[tier].outgoing
			if incomingDamage or outgoingDamage then
				hero.balanceModifier:SetStackCount(1) 
				hero.balanceModifier.incomingDamage = incomingDamage or 0
				hero.balanceModifier.outgoingDamage = outgoingDamage or 0
			end
		elseif place == "prelast" and PRE_LAST_MODIFIER_BALANCE[tier] then
			local stackCount = PRE_LAST_MODIFIER_BALANCE[tier]
			local incomingDamage = PRE_LAST_MODIFIER_BALANCE[tier].incoming
			local outgoingDamage = PRE_LAST_MODIFIER_BALANCE[tier].outgoing
			if incomingDamage or outgoingDamage then
				hero.balanceModifier:SetStackCount(1) 
				hero.balanceModifier.incomingDamage = incomingDamage or 0
				hero.balanceModifier.outgoingDamage = outgoingDamage or 0
			end
 		elseif place == "first" and tier > 0 and FIRST_MODIFIER_CURSED_LEADER[tier] then
			local incomingDamage = FIRST_MODIFIER_CURSED_LEADER[tier].incoming
			local outgoingDamage = FIRST_MODIFIER_CURSED_LEADER[tier].outgoing
			if incomingDamage or outgoingDamage then
				hero.cursedLeaderModifier:SetStackCount(1) 
				hero.cursedLeaderModifier.incomingDamage = incomingDamage
				hero.cursedLeaderModifier.outgoingDamage = outgoingDamage
			end
		else
			hero.cursedLeaderModifier:SetStackCount(0)
			hero.cursedLeaderModifier.incomingDamage = 0
			hero.cursedLeaderModifier.outgoingDamage = 0
			hero.balanceModifier:SetStackCount(0) 
			hero.balanceModifier.incomingDamage = 0
			hero.balanceModifier.outgoingDamage = 0
		end
	end)
 end


function CAddonWarsong:DifferenceScore(team, maxScore, teamScore, place)
    if place ~= "last" and place ~= "prelast" then return end
	  
	local difference = maxScore - teamScore
	local data = {place = place}

	if difference >= (place == "last" and LAST_KILL_DIFFERENCE_TIER_1 or PRE_LAST_KILL_DIFFERENCE_TIER_1) then 
		data.tier = 1
	elseif difference >= (place == "last" and LAST_KILL_DIFFERENCE_TIER_2 or PRE_LAST_KILL_DIFFERENCE_TIER_2) then
		data.tier = 2
	elseif difference >= (place == "last" and LAST_KILL_DIFFERENCE_TIER_3 or PRE_LAST_KILL_DIFFERENCE_TIER_3) then
		data.tier = 3
	else 
		data.tier = 0
	end

	self.teamBalanceTier[team] = data
 end

function CAddonWarsong:DifferenceScoreFirstPlace(team, secondScore, teamScore)
	local difference = teamScore - secondScore
	local data = {place = "first"}

	if difference >= FIRST_KILL_DIFFERENCE_TIER_1 then
		data.tier = 1
	elseif difference >= FIRST_KILL_DIFFERENCE_TIER_2 then
		data.tier = 2
	elseif difference >= FIRST_KILL_DIFFERENCE_TIER_3 then
		data.tier = 3
	else
		data.tier = 0
	end

	self.teamBalanceTier[team] = data
end

function CAddonWarsong:RecordKillStreak(killer_userid)
	local hero = PlayerResource:GetSelectedHeroEntity(killer_userid)
	if not hero then return end
	if not self.killStreak[killer_userid] then 
		self.killStreak[killer_userid] = {count = 0, timer = nil}
		self.killStreakLimits[killer_userid] = {triple = {rare = 0, timer = nil}, rampage = {rare = {giveCount = 2, count = 0}}}
	end
	local heroStreak = self.killStreak[killer_userid]
	heroStreak.count = heroStreak.count + 1

	local isActiveMap = GetMapName() == "portal_duo" or GetMapName() == "portal_trio" or GetMapName() == "warsong"

	if heroStreak.count == 3 then 
		local tripleStreak = self.killStreakLimits[killer_userid].triple		
		if not tripleStreak.timer then 
			tripleStreak.rare = tripleStreak.rare + 1
			if isActiveMap then
				if SERIAL_KILL_LIMIT.tripple.rare >= tripleStreak.rare then
						Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
						tripleStreak.timer = Timers:CreateTimer(SERIAL_KILL_TIMER.tripple.rare, function()
							tripleStreak.timer = nil
						end)
				end
			elseif GetMapName() == "dash" then
				for i = 1, 2 do
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
				end
			end
		end
	end

	if heroStreak.count == 5 then 
		local rampageStreak = self.killStreakLimits[killer_userid].rampage		
		rampageStreak.rare.count = rampageStreak.rare.count + 1
		if isActiveMap then
			if SERIAL_KILL_LIMIT.rampage.rare >= rampageStreak.rare.count then
				for i = 1, rampageStreak.rare.giveCount do
						Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
				end
			end
		else 
			Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
		end
	end

	if heroStreak.timer then 
		Timers:RemoveTimer(heroStreak.timer)
	end

	heroStreak.timer = Timers:CreateTimer(20, function()
		heroStreak.count = 0
		heroStreak.timer = nil
	end)
end

function CAddonWarsong:InitTeamBalanceTier(team)
	self.teamBalanceTier[team] = {place = "other", tier = 0}
end

function CAddonWarsong:RewardKillLeader(killer_userid, victim_userid)
	local hero = PlayerResource:GetSelectedHeroEntity(killer_userid)
 
	if not hero then return end
	local teamKiller = hero:GetTeamNumber()
	local teamVictim = PlayerResource:GetSelectedHeroEntity(victim_userid):GetTeamNumber()
	if not self.teamBalanceTier[teamKiller] or not self.teamBalanceTier[teamVictim] then return end
	local placeKiller = self.teamBalanceTier[teamKiller].place
	local placeVictim = self.teamBalanceTier[teamVictim].place
	local isTrueKillerTeam = GetMapName() == "portal_duo" and (placeKiller == "last" or placeKiller == "prelast") or (placeKiller == "last")
	if placeVictim == "first" and isTrueKillerTeam then
		if not self.killLeaderRewardTimer[teamKiller] then
			DoWithAllPlayers(function(player, hero)
				if not hero then return end
				if hero:GetTeamNumber() == teamKiller then
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
				end
			end)
			self.killLeaderRewardTimer[teamKiller] = true
			Timers:CreateTimer(KILL_LEADER_REWARD_TIME, function()
				self.killLeaderRewardTimer[teamKiller] = false
			end)
		end
	end
end

function CAddonWarsong:BalanceTimerGetBook(hero)
	local tick = 0
	local time = 60

	Timers:CreateTimer(1, function()
		tick = tick + 1
		if tick >= time then
			tick = 0
			Upgrades:QueueSelection(hero, UPGRADE_RARITY_COMMON)
		end
		return 1
	end)
end

function CAddonWarsong:SetEquipItemPlayer(hUnit)
    if HEROES_ITEMS_MODELS_CREATE[hUnit:GetUnitName()] then
        for _, model_name in pairs(HEROES_ITEMS_MODELS_CREATE[hUnit:GetUnitName()]) do
            local model = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model_name})
			model:FollowEntity(hUnit, true)
        end
    end
end

-- Проверка кто победил по очкам
function CAddonWarsong:GetWinPlayers()
    for team, score in pairs(self.nCapturedFlagsCount) do
        if score >= self.nWinConditionGoal then
			LogPanorama("Погнала сортировка бим бим чикибамбони")
            self:SortedMvpPlayers()
			LogPanorama("Сортировка выполнена тудым сюдым")
            CAddonWarsong:SetWinner(team)
			LogPanorama("Победа")
        end
    end
end
function CAddonWarsong:BuyBook(data)
    local book = BOOKS_SHOP[tonumber(data.itemIndex)]
    local hero = PlayerResource:GetSelectedHeroEntity(data.playerId)

    if not book or not hero then return end
    local player = PlayerResource:GetPlayer(data.playerId)

    local type = data.type
    local mapName = GetMapName()
    local resources = book.resources[mapName]
    if not resources then return end
    local function SuccessBuyBook()
        local bookName = ""
        if book.rarity == UPGRADE_RARITY_COMMON then
            bookName = "<font color='#808080'>обычную</font>"
        elseif book.rarity == UPGRADE_RARITY_RARE then
            bookName = "<font color='#3399ff'>редкую</font>"
        elseif book.rarity == UPGRADE_RARITY_EPIC then
            bookName = "<font color='#cc99ff'>эпическую</font>"
        end

        if mapName == "warsong" then
            -- Уведомление для всей команды через SendCustomMessageToTeam
            local message = "<font color='#00CED1'>" .. data.playerName .. "</font>".. " Обменял Флаги на " .. bookName .. " книгу улучшений для вашей команды."
			GameRules:SendCustomMessageToTeam(message,hero:GetTeam(),0,0)
            DoWithAllPlayers(function(player, HHhero, playerId)
                if PlayerResource:GetTeam(playerId) == HHhero:GetTeam() then
                    EmitSoundOnEntityForPlayer("buy_book", HHhero, playerId)
        			Upgrades:QueueSelection(HHhero, book.rarity)
                end
            end) 
			return 
        elseif mapName == "portal_duo" or mapName == "portal_trio" then
            -- Уведомление только для покупателя через SendCustomMessageToTeam
            local message = "<font color='#00CED1'>" .. data.playerName .. "</font>".. " Купил " .. bookName .. " книгу улучшений для вашей команды."
            GameRules:SendCustomMessageToTeam(message,hero:GetTeam(),0,0)
			DoWithAllPlayers(function(player, HHhero, playerId)
                if PlayerResource:GetTeam(playerId) == HHhero:GetTeam() then
                    EmitSoundOnEntityForPlayer("buy_book", HHhero, playerId)
        			Upgrades:QueueSelection(HHhero, book.rarity)
                end
            end)
			return 
		elseif mapName == "dash" then
			-- local message = "<font color='#00CED1'>" .. data.playerName .. "</font>".. " Купил " .. bookName .. " книгу улучшений для вашей команды."
			-- GameRules:SendCustomMessageToTeam(message,hero:GetTeam(),0,0)
			EmitSoundOnEntityForPlayer("buy_book", hero, data.playerId)
			Upgrades:QueueSelection(hero, book.rarity)
			return
		end
    end
    if type == "gold" then
        local cost = resources.gold

        if hero:GetGold() >= cost then
            hero:SpendGold(cost, DOTA_ModifyGold_PurchaseItem)
            SuccessBuyBook()
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message = "#dota_hud_error_not_enough_gold"})
        end
    elseif type == "flags" or type == "heads" then
        local cost = resources[type]

        if self:GetCurrencyPlayer(player) >= cost then
            self:SpendCurrencyPlayer(player, cost)
            SuccessBuyBook()
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message = "#error_not_enough_" .. type})
        end
    elseif type == "both" then
        local costGold = resources.gold

        if hero:GetGold() >= costGold then
            local typeCurrency = resources.flags and "flags" or "heads"
            local costFlags = resources.flags or resources.heads

            if self:GetCurrencyPlayer(player) >= (costFlags or 0) then
                hero:SpendGold(costGold, DOTA_ModifyGold_PurchaseItem)
                self:SpendCurrencyPlayer(player, costFlags)
                SuccessBuyBook()
            else
                CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message = "#error_not_enough_" .. typeCurrency})
            end
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message = "#dota_hud_error_not_enough_gold"})
        end
    end
end

-- function CAddonWarsong:BuyBook(data)
-- 	local book = BOOKS_SHOP[tonumber(data.itemIndex)]
--     local hero = PlayerResource:GetSelectedHeroEntity(data.playerId)

-- 	if (not book or not hero) then return end
-- 	local player = PlayerResource:GetPlayer(data.playerId)

-- 	local type = data.type
-- 	local mapName = GetMapName()
-- 	local resources = book.resources[mapName]
-- 	if not resources then return end
	
-- 	local function SuccessBuyBook() 
-- 		EmitSoundOnEntityForPlayer( "buy_book", hero, data.playerId )
--  		Upgrades:QueueSelection(hero, book.rarity)
--  	end

-- 	if type == "gold" then 
-- 		local cost = resources.gold

-- 		if hero:GetGold() >= cost then 
-- 			hero:SpendGold(cost, DOTA_ModifyGold_PurchaseItem)
-- 			SuccessBuyBook()
-- 		else 
-- 			CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#dota_hud_error_not_enough_gold"})
-- 		end
-- 	elseif type == "flags" or type == "heads" then 
-- 		local cost =  resources[type]

-- 		if self:GetCurrencyPlayer(player) >= cost then
-- 			self:SpendCurrencyPlayer(player, cost)
-- 			SuccessBuyBook()
-- 		else 
-- 			CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_not_enough_".. type})
-- 		end
-- 	elseif type == "both" then 
-- 		local costGold = resources.gold

-- 		if hero:GetGold() >= costGold then 
-- 			local typeCurrency = resources.flags and "flags" or "heads"
-- 			local costFlags = resources.flags or resources.heads
			 
-- 			if self:GetCurrencyPlayer(player) >= (costFlags or 0) then
-- 				hero:SpendGold(costGold, DOTA_ModifyGold_PurchaseItem)
-- 				self:SpendCurrencyPlayer(player, costFlags)
-- 				SuccessBuyBook()
-- 			else 
-- 				CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#error_not_enough_".. typeCurrency})
-- 			end
-- 		else 
-- 			CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="#dota_hud_error_not_enough_gold"})
-- 		end	
-- 	end
-- end
 


function CAddonWarsong:IncrementCurrencyPlayer(nPlayer)
	local playerId = tostring(nPlayer:GetPlayerID())
	local currencyFromTable = CustomNetTables:GetTableValue("custom_currency", playerId)
	local currentCurrency = currencyFromTable and currencyFromTable.counter or 0

	if GetMapName() == "dash" then
		local hero = PlayerResource:GetSelectedHeroEntity(nPlayer:GetPlayerID())
		local modifier = hero:FindModifierByName("modifier_head_boss")
		modifier:IncrementStackCount()
		CustomGameEventManager:Send_ServerToPlayer(nPlayer, "boss_head_notification", {})
	end

	CustomNetTables:SetTableValue("custom_currency", playerId, {counter = currentCurrency + 1})
end

function CAddonWarsong:GetCurrencyPlayer(nPlayer)
	local playerId = tostring(nPlayer:GetPlayerID())
	local currencyFromTable = CustomNetTables:GetTableValue("custom_currency", playerId)
	
	return currencyFromTable and currencyFromTable.counter or 0
end

function CAddonWarsong:SpendCurrencyPlayer(nPlayer, value)
	local playerId = tostring(nPlayer:GetPlayerID())
 	local currentCurrency = self:GetCurrencyPlayer(nPlayer)	

	if GetMapName() == "dash" then
		local hero = PlayerResource:GetSelectedHeroEntity(nPlayer:GetPlayerID())
		local modifier = hero:FindModifierByName("modifier_head_boss")
		modifier:DecrementStackCount()
	end

	CustomNetTables:SetTableValue("custom_currency", playerId, {counter = math.max(currentCurrency - value, 0)})
end


function CAddonWarsong:OnPlayerChat(event)
	if IsClient() then return end
	local playerId = event.playerid
 	local command = string.lower(event.text)
	local player = PlayerResource:GetPlayer(playerId)
end

function CAddonWarsong:OnPlayerItemAdded(event)
	local itemName = event.itemname
	DoWithAllPlayers(function(player, hero, playerId) 
		if not hero then return end
		if hero:GetUnitName() == "npc_dota_hero_skeleton_king" then
			if itemName == "item_ultimate_scepter" then
				if not hero.IsAghanim then
					EmitSoundOn("cursed_knight_get_aghanim", hero)
					hero.IsAghanim = true
				else
					local rnd = RandomInt(1, 100)
					if rnd <= 20 then
						EmitSoundOn("cursed_knight_get_aghanim", hero)
					end
				end
			end
		end
	end)
end