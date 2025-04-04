function CAddonWarsong:HeroSelectionUpdater()
    local same_heroes_selected = {}
    for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local hPlayer = PlayerResource:GetPlayer(i)
        if hPlayer and PlayerResource:HasSelectedHero(i) then
            local team = PlayerResource:GetTeam(i)
            local selected_hero = PlayerResource:GetSelectedHeroName(i)
            if same_heroes_selected[team] == nil then
                same_heroes_selected[team] = {}
                self.banned_heroes_same[team] = {}
            end
            same_heroes_selected[team][selected_hero] = 1
        end
    end
    for team, heroes_list in pairs(same_heroes_selected) do
        for hero_name, count in pairs(heroes_list) do
            self:DisableHeroForTeam(team, hero_name)
        end
    end
end

function CAddonWarsong:DisableHeroForTeam(team, hero_name)
    if self.banned_heroes_same[team][hero_name] ~= nil then
        return
    end
    self.banned_heroes_same[team][hero_name] = true
    for iPlayerID=0, _G.MAX_PLAYER_COUNT do
        if PlayerResource:IsValidPlayer(iPlayerID) then 
            if PlayerResource:GetTeam(iPlayerID) == team then
                GameRules:ClearPlayerHeroAvailability(iPlayerID)
                for i=1,148 do
                    local avial = true
                    for name,_ in pairs(self.banned_heroes_same[team]) do
                        if DOTAGameManager:GetHeroIDByName( name ) == i then
                            avial = false
                        end
                    end
                    if avial then
                        GameRules:AddHeroToPlayerAvailability(iPlayerID, i )
                    end
                end
            end
        end
    end
end