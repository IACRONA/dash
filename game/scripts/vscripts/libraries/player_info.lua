
if PlayerInfo == nil then
	PlayerInfo = class({})
end
 
function PlayerInfo:Init() 
	CustomGameEventManager:RegisterListener('player_change_keybinds', function(_, event)
		PlayerInfo:OnPlayerChangeKeybinds(event)
	end)
end

function PlayerInfo:InitPlayer(playerId, info)
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

			if success then
				info[key] =  parsed
			end
		end
	end

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

-- Белый список ключей, которые клиент имеет право прислать в keybinds.
local ALLOWED_KEYBIND_KEYS = {
	cast_ability_7 = true,
	cast_ability_8 = true,
}
local KEYBIND_MAX_VALUE_LEN = 16
local KEYBIND_CHANGE_COOLDOWN = 1.0

PlayerInfo._last_keybind_change = PlayerInfo._last_keybind_change or {}

function PlayerInfo:OnPlayerChangeKeybinds(data)
	local playerId = data.PlayerID

	if not PlayerResource:IsValidPlayer(playerId) then return end

	-- Rate-limit: не чаще одного изменения в секунду на игрока.
	local now = GameRules:GetGameTime()
	local last = self._last_keybind_change[playerId] or 0
	if now - last < KEYBIND_CHANGE_COOLDOWN then return end
	self._last_keybind_change[playerId] = now

	local raw = data.keybinds
	if type(raw) ~= "table" then return end

	-- Фильтруем по белому списку ключей и валидируем значения.
	local clean = {}
	for k, v in pairs(raw) do
		if ALLOWED_KEYBIND_KEYS[k] and type(v) == "string" and #v > 0 and #v <= KEYBIND_MAX_VALUE_LEN then
			clean[k] = v
		end
	end

	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId))
	if not playerInfo then return end

	playerInfo.keybinds = clean

	CustomNetTables:SetTableValue("player_info", tostring(playerId), playerInfo)
end

 
PlayerInfo:Init() 