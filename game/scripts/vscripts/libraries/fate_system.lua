CAddonWarsong.fate_count_number = 0
CAddonWarsong.player_selected_fate = {}
CAddonWarsong.InitHintsFates = false

function CAddonWarsong:GivePlayersFate()
    if not CAddonWarsong.InitHintsFates then
        CreateHints("warsong_hints_random_fates")
        CAddonWarsong.InitHintsFates = true
    end
    CAddonWarsong.fate_count_number = CAddonWarsong.fate_count_number + 1
    for i=0,24 do
        if PlayerResource:IsValidPlayer(i) and PlayerResource:GetSelectedHeroEntity(i) ~= nil then
            if CAddonWarsong.player_selected_fate[i] == nil then
                CAddonWarsong.player_selected_fate[i] = 0
            end
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), 'open_fates_choose_players', {})
        end
    end
end

function CAddonWarsong:SelectPlayerFate(player_id, fate_name)
    local hero = PlayerResource:GetSelectedHeroEntity(player_id)
    local current_fate_table = {}
    local current_fate = CustomNetTables:GetTableValue("fate_selected", tostring(player_id))
    
    if current_fate ~= nil then
        for ff_n, count in pairs(current_fate) do
            current_fate_table[ff_n] = count
        end
    end

    if current_fate_table[fate_name] == nil then
        current_fate_table[fate_name] = 1
    else
        current_fate_table[fate_name] = current_fate_table[fate_name] + 1
    end

    Timers:CreateTimer(0.1, function()
        if hero:IsAlive() then
            hero:AddNewModifier(hero, nil, "modifier_warsong_"..fate_name, {})
            return
        end
        return 0.1
    end)

    CAddonWarsong.player_selected_fate[player_id] = CAddonWarsong.player_selected_fate[player_id] + 1

    if CAddonWarsong.player_selected_fate[player_id] < CAddonWarsong.fate_count_number then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id), 'open_fates_choose_players', {})
    end

    CustomNetTables:SetTableValue("fate_selected", tostring(player_id), current_fate_table)
end