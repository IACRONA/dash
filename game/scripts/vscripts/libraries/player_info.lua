
if PlayerInfo == nil then
	PlayerInfo = class({})
end
 
function PlayerInfo:InitPlayer(playerId, info)
	print("Platyer")
	DeepPrintTable(info)
	CustomNetTables:SetTableValue("rolls_player", tostring(playerId), {roll = info.roll, roll_used = 0}) 

	PlayerInfo:UpdatePlayerTable(playerId, info)
end

function PlayerInfo:UpdatePlayerTable(playerId, info)
	if not info then return end
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 

	if playerInfo and info.roll then 
		if playerInfo.roll ~= info.roll and self:GetRollPlayer(playerId) ~= info.roll then 
			local difference = info.roll - playerInfo.roll
			self:UpdateRollTable(playerId, difference, 0)
		end
	end

	for key, value in pairs(info) do
		if type(value) == "string" then
			local success, parsed = pcall(json.decode, value)
			print(parsed)
			if success then
				info[key] =  parsed
			end
		end
	end
	DeepPrintTable(info)
	CustomNetTables:SetTableValue("player_info", tostring(playerId), info) 
	DonateManager:CheckForChangeDonate(playerId)
end
 
function PlayerInfo:UpdateRollTable(playerId, roll, rollUsed)
	local rollTable = CustomNetTables:GetTableValue("rolls_player", tostring(playerId))

	local newRoll = math.max(self:GetRollPlayer(playerId) + roll, 0)
	local newRollUsed = math.max(self:GetRollUsedPlayer(playerId) + rollUsed, 0)

	CustomNetTables:SetTableValue("rolls_player", tostring(playerId), {roll = newRoll, roll_used = newRollUsed})
end

function PlayerInfo:GetRollPlayer(playerId)
	local table = CustomNetTables:GetTableValue("rolls_player", tostring(playerId))
	return table and table.roll or 0
end

function PlayerInfo:GetRollUsedPlayer(playerId)
	local table = CustomNetTables:GetTableValue("rolls_player", tostring(playerId))
	return table and table.roll_used or 0
end

 