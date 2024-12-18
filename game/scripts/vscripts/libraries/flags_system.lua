function CAddonWarsong:RespawnFlagForTeam(nTeam, vPos, options, soldier)
	print('Respawning flag for team #' .. nTeam)
	local vSpawnPos = self.flagPositions[nTeam]

	if GetMapName() == "warsong" and soldier ~= nil then
		if nTeam == DOTA_TEAM_GOODGUYS then
			self:SpawnSoldierRadiant()
		end
		if nTeam == DOTA_TEAM_BADGUYS then
			self:SpawnSoldierDire()
		end
	end

	if vPos ~= nil then
		vSpawnPos = vPos
	end

	local vDestination = vSpawnPos

	if options ~= nil then
		if options.start_point ~= nil then
			vSpawnPos = options.start_point
		end
	end

	local hItem = CreateItem(self.flagItemNames[nTeam], nil, nil)
	local hDrop
	if options then
		hDrop = CreateItemOnPositionForLaunch(vSpawnPos, hItem)
		hItem:LaunchLootInitialHeight(false, 0, 50, 0.25, vDestination)
	else
		hDrop = CreateItemOnPositionSync(vDestination, hItem)
	end
	hDrop:SetForwardVector(Vector(0,-1,0))
	hDrop:SetModelScale(GetFlagScale(nTeam))
	SetMaterial(hDrop, hItem)

	local hIcon = self.flagIconUnits[nTeam]
	if hIcon then
		hIcon:SetAbsOrigin(vDestination)
	end

	hIcon = self.flagIconpointUnits[nTeam]
	if hIcon then
		SetIconVisibe(hIcon, vPos)
	end

	return hItem
end

function CAddonWarsong:RespawnFlagBoth(vPos, options)
	local vSpawnPos = self.FlagPositionBoth

	if vPos ~= nil then
		vSpawnPos = vPos
	end

	local vDestination = vSpawnPos

	if options ~= nil then
		if options.start_point ~= nil then
			vSpawnPos = options.start_point
		end
	end

	local hItem = CreateItem("item_flag_both", nil, nil)
	local hDrop
	if options then
		hDrop = CreateItemOnPositionForLaunch(vSpawnPos, hItem)
		hItem:LaunchLootInitialHeight(false, 0, 50, 0.25, vDestination)
	else
		hDrop = CreateItemOnPositionSync(vDestination, hItem)
	end
	hDrop:SetForwardVector(Vector(0,-1,0))
	hDrop:SetModelScale(GetFlagScale(nTeam))

	local hIcon = self.flagIconUnits[DOTA_TEAM_BADGUYS]
	if hIcon then
		hIcon:SetAbsOrigin(vDestination)
	end

	local hIcon = self.flagIconUnits[DOTA_TEAM_GOODGUYS]
	if hIcon then
		hIcon:SetAbsOrigin(vDestination)
	end

	hIcon = self.flagIconpointUnits[nTeam]
	if hIcon then
		SetIconVisibe(hIcon, vPos)
	end

	return hItem
end

function CAddonWarsong:IncrementFlags(nTeam)
	self.nCapturedFlagsCount[nTeam] = self.nCapturedFlagsCount[nTeam] + 1
	self:RemindClients_FlagsRemaining()
	self:DifferenceFlags()
end

function CAddonWarsong:RemindClients_FlagsRemaining()
	CustomGameEventManager:Send_ServerToAllClients('update_flags_count', {
		radiant = self.nWinConditionGoal - self.nCapturedFlagsCount[DOTA_TEAM_GOODGUYS],
		dire = self.nWinConditionGoal - self.nCapturedFlagsCount[DOTA_TEAM_BADGUYS]
	})
	print('another shot fired')
end


function CAddonWarsong:DifferenceFlags()
	local flagRadiant = self.nCapturedFlagsCount[DOTA_TEAM_GOODGUYS]
	local flagDire = self.nCapturedFlagsCount[DOTA_TEAM_BADGUYS]
	
	local leader = flagRadiant > flagDire and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	local loser = leader == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS

	local difference = self.nCapturedFlagsCount[leader] - self.nCapturedFlagsCount[loser]
	local dataLoser = {place = "last"}
	local dataLeader = {place = "first", tier = 0}

	if difference >= FLAGS_DIFFERENCE_TIER_1 then 
		if not self.wasRewardFlagsTier1 or not self.wasRewardFlagsTier1[loser] then
			self.wasRewardFlagsTier1 = {
				[leader] = false,
				[loser] = true,
			}

			DoWithAllPlayers(function(player, hero)
				if not hero then return end
				if hero:GetTeamNumber() == loser then
					Upgrades:QueueSelection(hero, UPGRADE_RARITY_EPIC)

					for i = 1, 3 do
						Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
					end
				end
			end)
		end
		dataLoser.tier = 1
	elseif difference >= FLAGS_DIFFERENCE_TIER_2 then
		dataLoser.tier = 2
	else
		dataLoser.tier = 0
	end

	self.teamBalanceTier[loser] = dataLoser
	self.teamBalanceTier[leader] = dataLeader


	DoWithAllPlayers(function(player, hero)
		if not hero then return end
		if not hero.balanceModifier then return end
		local team = hero:GetTeamNumber()

		local tier = self.teamBalanceTier[team].tier
		local place = self.teamBalanceTier[team].place

		if place == "last" and LAST_MODIFIER_BALANCE[tier]then
			local incomingDamage = LAST_MODIFIER_BALANCE[tier].incoming
			local outgoingDamage = LAST_MODIFIER_BALANCE[tier].outgoing
			if incomingDamage or outgoingDamage then
				hero.balanceModifier:SetStackCount(1) 
				hero.balanceModifier.incomingDamage = incomingDamage or 0
				hero.balanceModifier.outgoingDamage = outgoingDamage or 0
			end
 		else
 			hero.balanceModifier:SetStackCount(0) 
			hero.balanceModifier.incomingDamage = 0	
			hero.balanceModifier.outgoingDamage = 0
		end
	end)
	DeepPrintTable(self.teamBalanceTier)
 end

 
function CAddonWarsong:PlaySoundForTeam(sSound, nTeam)
	EmitAnnouncerSoundForTeam(sSound, nTeam)
end

function CAddonWarsong:PlaySoundForTeamAndPlayerSpecial(nPlayer, sPlayerSound, sTeamSound)
	local nTeam = PlayerResource:GetTeam(nPlayer)
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(i) and PlayerResource:GetTeam(i) == nTeam then
			EmitAnnouncerSoundForPlayer(i == nPlayer and sPlayerSound or sTeamSound, i)
		end
	end
end

function _G.HasFlag(hUnit)
	return hUnit:HasModifier('modifier_item_flag_carrier') or hUnit:HasModifier('modifier_item_flag_carrier_both')
end
 