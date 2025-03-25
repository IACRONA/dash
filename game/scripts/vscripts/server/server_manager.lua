if ServerManager == nil then
	ServerManager = class({})
end

function ServerManager:Init()
	ServerManager.playersId = {}

	DoWithAllPlayers(function(_,_,playerId)
		local steamId = PlayerResource:GetSteamAccountID(playerId)
		ServerManager.playersId[tostring(steamId)] = playerId
		HTTP("POST", "/player/".. steamId, nil, {success = function(data)
			PlayerInfo:InitPlayer(playerId, data)
		end})
	end)

  	Timers:CreateTimer(2, function()
 		HTTP("POST", "/store/store_info", nil, {success = function(data)
			CustomNetTables:SetTableValue("server_info", "store", data)
		end})
 	end)

	CustomGameEventManager:RegisterListener('buy_item', Dynamic_Wrap(self, 'BuyItem'))
	CustomGameEventManager:RegisterListener('equip_shop_item', Dynamic_Wrap(self, 'EquipShopItem'))
end


function ServerManager:BuyItem(data)
	local playerId = data.playerId
	local steamId = PlayerResource:GetSteamAccountID(playerId)
	local player = PlayerResource:GetPlayer(playerId)

	HTTP("POST", "/store/buy_item", {id = steamId, item_name = data.item, type = data.type}, {success = function(data)
		PlayerInfo:UpdatePlayerTable(playerId, data.user)
		end,
		error = function(data)
			CustomGameEventManager:Send_ServerToPlayer(player, "store_error", {error = data.error})
		end,
		finnaly = function()
			CustomGameEventManager:Send_ServerToPlayer(player, "store_request_finally", {})
		end,
	})
end

function ServerManager:SendServerPlayerRoll(playerId)
	local steamId = PlayerResource:GetSteamAccountID(playerId)
	local rollUsed = PlayerInfo:GetRollUsedPlayer(playerId)
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId))

	if not playerInfo then return end

	local newRoll = (playerInfo.roll or 0) - rollUsed
	HTTP("POST", "/player", {id = steamId, roll = newRoll}, {
		success = function(data)
			PlayerInfo:UpdateRollTable(playerId, 0, -rollUsed)
			PlayerInfo:UpdatePlayerTable(playerId, data)
		end,
	})
end

function ServerManager:OnEndGame(callback)
	if self._game_end == true then return end
	self._game_end = true

	local playersReady = {}
	local matchSent = false
	local checkPlayers = function(data)
		local canEnd = matchSent
		LogPanorama(playersReady)

		DoWithAllPlayers(function(_,_,id)
			if not playersReady[id] then canEnd = false end
		end)

		if canEnd then 
 			if data then 
				local newData = {}

				for steamId, value in pairs(data) do
					local playerIdSteam = ServerManager.playersId[tostring(steamId)]

					if playerIdSteam ~= nil then 
						newData[playerIdSteam] = value
					end
				end

				CustomNetTables:SetTableValue("server_info", "get_raiting", newData)
			end

			callback()
		 end
	end

	DoWithAllPlayers(function(player,_,playerId)
		local team = PlayerResource:GetTeam(playerId)
		if GameRules.AddonTemplate.nCapturedFlagsCount[team] == nil then
			GameRules.AddonTemplate.nCapturedFlagsCount[team] = 0
		end
	end)

	local sortedTeams = {}
	for team, kills in pairs( GameRules.AddonTemplate.nCapturedFlagsCount ) do
		table.insert( sortedTeams, { teamID = team, teamScore = kills } )
	end
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	local teamPlaces = {}
	for i, data in pairs(sortedTeams) do
		teamPlaces[data.teamID] = i
	end

	local places = {}

	DoWithAllPlayers(function(player,_,playerId)
		local steamId = PlayerResource:GetSteamAccountID(playerId)
		LogPanorama(playersReady)

		LogPanorama(steamId)

		if not player or steamId == -1 or steamId == 0 then
			playersReady[playerId] = true
			checkPlayers()
			return
		end
		LogPanorama(playersReady)

		local rollUsed = PlayerInfo:GetRollUsedPlayer(playerId)
		local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId))

		if not playerInfo then
			playersReady[playerId] = true
			return checkPlayers()
		end

		local newRoll = (playerInfo.roll or 0) - rollUsed
		LogPanorama("sendRequest to ".. steamId)

		HTTP("POST", "/player", {id = steamId, roll = newRoll, isEndGame = true}, {
			finnaly = function()
				playersReady[playerId] = true
				checkPlayers()
 			end,
		})

		if not PlayerResource:IsFakeClient(playerId) then
			local place = teamPlaces[PlayerResource:GetTeam(playerId)]
			if places[tostring(place)] == nil then
				places[tostring(place)] = {tostring(steamId)}
			else
				table.insert(places[tostring(place)], tostring(steamId))
			end
		end
	end)

	-- if not GameRules:IsCheatMode() or not IsDedicatedServer() then
	if true then
		HTTP("POST", "/match/result", {places = places, map_name = GetMapName()}, {
			finnaly = function(data)
				matchSent = true
				checkPlayers(data)
			end,
		})
	else
		matchSent = true
		checkPlayers()
	end

	Timers:CreateTimer(10, function()
		callback()
	end)
end

function ServerManager:EquipShopItem(data)
	local playerId = data.playerId
	local steamId = PlayerResource:GetSteamAccountID(playerId)
	local player = PlayerResource:GetPlayer(playerId)

	HTTP("POST", "/equip_item", {id = steamId, item_name = data.item, type = data.type}, {
		success = function(data)
			PlayerInfo:UpdatePlayerTable(playerId, data)
		end,
		error = function(data)
			CustomGameEventManager:Send_ServerToPlayer(player, "store_error", {error = data.error})
		end,
		finnaly = function()
			CustomGameEventManager:Send_ServerToPlayer(player, "store_request_finally", {})
		end,
	})
end




function ServerManager:GetHeroUpgradeData(callback)
	HTTP("POST", "/upgrades/talents", {}, {
		success = function(data)
			if callback then callback(data) end
		end,
		error = function(data)
			if callback then callback(data) end
		end,
		finnaly = function()
			if callback then callback(nil) end
		end
	})
end