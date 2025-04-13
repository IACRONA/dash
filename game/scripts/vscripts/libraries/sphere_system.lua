CAddonWarsong.sphere_count_number = 0
CAddonWarsong.player_selected_sphere = {}
local spheres = {
    "modifier_sphere_armor",
    "modifier_sphere_cooldown",
    "modifier_sphere_decrase_mr",
    "modifier_sphere_heal",
    "modifier_sphere_magic_resistance",
    "modifier_sphere_miss",
    "modifier_sphere_movespeed",
    "modifier_sphere_radiance",
    "modifier_sphere_shield_physic",
    "modifier_sphere_shield_magic",
    "modifier_sphere_shield_all",
}

function CAddonWarsong:GivePlayersSphere()
    self.sphere_count_number = self.sphere_count_number + 1

    for playerID = 0, 24 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                if not self.player_selected_sphere[playerID] then
                    self.player_selected_sphere[playerID] = 0
                end

                local player = PlayerResource:GetPlayer(playerID)
                if IsValidEntity(player) then
                    CustomGameEventManager:Send_ServerToPlayer(player, "open_sphere_choose_players", { sphereList = self:GetSphereList(hero) })
                end
            end
        end
    end
end

function CAddonWarsong:SelectPlayerSphere(playerID, sphere_name)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then return end

    Timers:CreateTimer(0.1, function()
        if hero:IsAlive() then
            local modifier = hero:AddNewModifier(hero, nil, sphere_name, {})
            if modifier then
                modifier:IncrementStackCount()
            end
            return
        end
        return 0.1
    end)
    self.player_selected_sphere[playerID] = (self.player_selected_sphere[playerID] or 0) + 1

    local player = PlayerResource:GetPlayer(playerID)
    if self.player_selected_sphere[playerID] < self.sphere_count_number then
        if IsValidEntity(player) then
            CustomGameEventManager:Send_ServerToPlayer(player, "open_sphere_choose_players", { sphereList = self:GetSphereList(hero) })
        end
    end
end

function CAddonWarsong:GetSphereList(hero)
    local passSpheres = {}
    
    for _, sphere in ipairs(spheres) do
        local modifier = hero:FindModifierByName(sphere)
        if not modifier or modifier:GetStackCount() < MAX_SPHERE_LEVEL then 
            table.insert(passSpheres, { name = sphere, level = modifier and modifier:GetStackCount() or 0 })
        end
    end

    local tempSpheres = {}
    for i, sphereData in ipairs(passSpheres) do
        tempSpheres[i] = sphereData
    end

    local sphereList = {}
    for i = 1, COUNT_SPHERE_CHOICE do
        if #tempSpheres > 0 then
            local index = RandomInt(1, #tempSpheres)
            table.insert(sphereList, tempSpheres[index])
            table.remove(tempSpheres, index)
        end
    end

    return sphereList
end

function CAddonWarsong:RerollPlayerSphere(event)
    local playerID = event.PlayerID
    if PlayerResource:IsValidPlayerID(playerID) then
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero then
            PlayerInfo:UpdateRollTable(playerID, -1, 1)
            local player = PlayerResource:GetPlayer(playerID)
            if IsValidEntity(player) then
                CustomGameEventManager:Send_ServerToPlayer(player, "open_sphere_choose_players", {
                    sphereList = self:GetSphereList(hero),
                    isReroll = true
                })
            end
        end
    end 
end
