CAddonWarsong.fate_count_number = 0
CAddonWarsong.player_selected_fate = {}
CAddonWarsong.InitHintsFates = false

function CAddonWarsong:GivePlayersFate()
    if not CAddonWarsong.InitHintsFates then
        CreateHints("warsong_hints_random_fates")
        CAddonWarsong.InitHintsFates = true
    end
    CAddonWarsong.fate_count_number = CAddonWarsong.fate_count_number + 1
    local validPlayerIDs = {}
    for player_id = 0, 24 do
        if PlayerResource:IsValidPlayerID(player_id) then
            local hero = PlayerResource:GetSelectedHeroEntity(player_id)
            if hero then
                table.insert(validPlayerIDs, player_id)
                if CAddonWarsong.player_selected_fate[player_id] == nil then
                    CAddonWarsong.player_selected_fate[player_id] = 0
                end
            end
        end
    end
    for _, player_id in pairs(validPlayerIDs) do
        local player = PlayerResource:GetPlayer(player_id)
        if IsValidEntity(player) then
            CustomGameEventManager:Send_ServerToPlayer(player, 'open_fates_choose_players', {})
        end
    end
end

local function TableCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

function CAddonWarsong:SelectPlayerFate(player_id, fate_name)
    local hero = PlayerResource:GetSelectedHeroEntity(player_id)
    if not hero then return end
    local current_fate_table = {}
    local current_fate = CustomNetTables:GetTableValue("fate_selected", tostring(player_id))
    if current_fate then
        current_fate_table = TableCopy(current_fate)
    end
    current_fate_table[fate_name] = (current_fate_table[fate_name] or 0) + 1
    Timers:CreateTimer(0.1, function()
        if hero:IsAlive() then
            hero:AddNewModifier(hero, nil, "modifier_warsong_" .. fate_name, {})
            return
        end
        return 0.1
    end)
    CAddonWarsong.player_selected_fate[player_id] = (CAddonWarsong.player_selected_fate[player_id] or 0) + 1
    if CAddonWarsong.player_selected_fate[player_id] < CAddonWarsong.fate_count_number then
        local player = PlayerResource:GetPlayer(player_id)
        if IsValidEntity(player) then
            CustomGameEventManager:Send_ServerToPlayer(player, 'open_fates_choose_players', {})
        end
    end
    CustomNetTables:SetTableValue("fate_selected", tostring(player_id), current_fate_table)
end
