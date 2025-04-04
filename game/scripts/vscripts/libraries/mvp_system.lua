function CAddonWarsong:SortedMvpPlayers()
    local mvp_score = {}
    for iPlayerID=0, _G.MAX_PLAYER_COUNT do
        if PlayerResource:IsValidPlayerID(iPlayerID) then
            local player_info = {}
            player_info.player_id = iPlayerID
            player_info.kills = PlayerResource:GetKills(iPlayerID)
            player_info.flags_count = GameRules.AddonTemplate.player_flags_count[iPlayerID] or 0
            table.insert(mvp_score, player_info)
        end
    end

    if #mvp_score > 0 then
        if GetMapName() == "warsong" then
            table.sort( mvp_score, function(x,y) return y.flags_count < x.flags_count end )
        else
            table.sort( mvp_score, function(x,y) return y.kills < x.kills end )
        end
    end
    
    CustomNetTables:SetTableValue("mvp_score", "mvp_score", mvp_score)
end