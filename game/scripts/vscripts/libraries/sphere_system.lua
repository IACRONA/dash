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
    CAddonWarsong.sphere_count_number = CAddonWarsong.sphere_count_number + 1
    for i=0,24 do
        if PlayerResource:IsValidPlayer(i) and PlayerResource:GetSelectedHeroEntity(i) ~= nil then
            if CAddonWarsong.player_selected_sphere[i] == nil then
                CAddonWarsong.player_selected_sphere[i] = 0
            end
            local hero = PlayerResource:GetSelectedHeroEntity(i)
 
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), 'open_sphere_choose_players', {sphereList = self:GetSphereList(hero)})
        end
    end
end

function CAddonWarsong:SelectPlayerSphere(player_id, sphere_name)
    local hero = PlayerResource:GetSelectedHeroEntity(player_id)
    
    Timers:CreateTimer(0.1, function()
        if hero:IsAlive() then
            local modifier = hero:AddNewModifier(hero, nil, sphere_name, {})
            modifier:IncrementStackCount()
            return
        end
        return 0.1
    end)

    CAddonWarsong.player_selected_sphere[player_id] = CAddonWarsong.player_selected_sphere[player_id] + 1

    if CAddonWarsong.player_selected_sphere[player_id] < CAddonWarsong.sphere_count_number then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id), 'open_sphere_choose_players', {sphereList = self:GetSphereList(hero)})
    end
end

function CAddonWarsong:GetSphereList(hero)
    local passSpheres = {}

    for _,sphere in pairs(spheres) do
        local modifier = hero:FindModifierByName(sphere)
        if not modifier or modifier:GetStackCount() < MAX_SPHERE_LEVEL then 
               table.insert(passSpheres, {name = sphere, level = modifier and modifier:GetStackCount() or 0})
        end
    end
    local sphereList = {}
    for i=1,COUNT_SPHERE_CHOICE do
        local index = RandomInt(1, #passSpheres)
        local sphere = passSpheres[index]
        table.insert(sphereList, sphere)
        table.remove(passSpheres, index)
    end

    return sphereList
end

function CAddonWarsong:RerollPlayerSphere(event)
    if PlayerResource:IsValidPlayer(event.PlayerID) and PlayerResource:GetSelectedHeroEntity(event.PlayerID) ~= nil then
        PlayerInfo:UpdateRollTable(event.PlayerID, -1, 1)

        local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)   
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event.PlayerID), 'open_sphere_choose_players', {sphereList = self:GetSphereList(hero), isReroll = true})
    end 
end