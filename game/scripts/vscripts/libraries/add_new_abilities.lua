CAddonWarsong.player_abilities_info = {}
CAddonWarsong.abilityHeroMap = {}
CAddonWarsong.InitHintsAbilities = false

local npc_heroes_list_kv = LoadKeyValues("scripts/npc/npc_heroes.txt")
for hero_name, data in pairs(npc_heroes_list_kv) do
    if data and type(data) == "table" then
        for ab = 1, 8 do
            local ability = data["Ability" ..ab]
            if ability ~= nil and ability ~= "" and ability ~= "generic_hidden" and not ability:find("special_bonus") then
                CAddonWarsong.abilityHeroMap[ability] = hero_name
    
            end
        end
    end
end

function CAddonWarsong:ChangeNewAbilities(is_ultimate)
    self.count_ulti_abilities = (self.count_ulti_abilities or 0) + 1
    if self.count_ulti_abilities > MAX_COUNT_ULTI_ABILITIES then
        return
    end
    if not CAddonWarsong.InitHintsAbilities then
        CreateHints("warsong_hints_random_spells")
        CAddonWarsong.InitHintsAbilities = true
    end
    for _, entity in pairs( HeroList:GetAllHeroes() ) do
        if not entity:IsNull() and entity:IsRealHero() and not entity:HasModifier("modifier_monkey_king_fur_army_soldier") and not entity:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") and not entity:IsClone() and not entity:IsTempestDouble() then
            self:HeroAddNewAbility(entity, is_ultimate)
        end
    end
end

function CAddonWarsong:HeroAddNewAbility(entity, is_ultimate, player_id, is_reroll)
    if entity ~= nil and HEROES_SELECT_SPELL_DISABLED[entity:GetUnitName()] and not is_ultimate then
        return
    end

    if entity ~= nil and HEROES_SELECT_ULTIMATE_DISABLED[entity:GetUnitName()] and is_ultimate then
        return
    end

    if entity == nil then
        entity = PlayerResource:GetSelectedHeroEntity(player_id)
        is_ultimate = is_ultimate == 1
    end
    if is_reroll then
        PlayerInfo:UpdateRollTable(player_id, -1, 1)
    end

    if CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()] == nil then
        CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()] = {}
    end

    local abilities_list = RANDOM_ABILITIES_LIST_WG

    if is_ultimate then
        if self.PlayersUltimateAbilities[entity:GetPlayerOwnerID()] ~= nil then
            self:RemoveModifierFromAbility(self.PlayersUltimateAbilities[entity:GetPlayerOwnerID()])
            entity:RemoveAbilityByHandle(self.PlayersUltimateAbilities[entity:GetPlayerOwnerID()])
            self.PlayersUltimateAbilities[entity:GetPlayerOwnerID()] = nil
            CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()].ultimate = nil
        end
        abilities_list = RANDOM_ULTIMATES_WG
    else
        if self.PlayersDefaultAbilities[entity:GetPlayerOwnerID()] ~= nil then
            self:RemoveModifierFromAbility(self.PlayersDefaultAbilities[entity:GetPlayerOwnerID()])
            entity:RemoveAbilityByHandle(self.PlayersDefaultAbilities[entity:GetPlayerOwnerID()])
            self.PlayersDefaultAbilities[entity:GetPlayerOwnerID()] = nil
            CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()].basic = nil
        end
    end
    CustomNetTables:SetTableValue("abilities_list", tostring(entity:GetPlayerOwnerID()), CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()])
    local random_abilities = self:GetNewAbilityPlayer(entity, abilities_list)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(entity:GetPlayerOwnerID()), "spell_select_open_panel", {spell_list = random_abilities, is_ultimate = is_ultimate, is_reroll = not (not is_reroll)})
end
function CAddonWarsong:PrecacheHero(ability_name)
    local hero_name = CAddonWarsong.abilityHeroMap[ability_name]

    if hero_name and not self.precached[hero_name] then

        PrecacheUnitByNameAsync("npc_precache_"..hero_name, function()
            self.precached[hero_name] = true
        end)
    end
end
function CAddonWarsong:SelectAbilityToHero(player_id, ability_name, is_ultimate)
    local entity = PlayerResource:GetSelectedHeroEntity(player_id)
    local random_ability = ability_name
    if random_ability then
        local sHeroOwnerName = CAddonWarsong.abilityHeroMap[ability_name]
        if sHeroOwnerName and not table.contains(self.pendingPrecache, sHeroOwnerName) and not self.precached[sHeroOwnerName] then
            table.insert(self.pendingPrecache, sHeroOwnerName)   
        end
        local new_ability = entity:AddAbility(random_ability)
        if CAddonWarsong.player_abilities_info[player_id] == nil then
            CAddonWarsong.player_abilities_info[player_id] = {}
        end
        if is_ultimate then
            CAddonWarsong.player_abilities_info[player_id].ultimate = ability_name
        else
            CAddonWarsong.player_abilities_info[player_id].basic = ability_name
        end
        CustomNetTables:SetTableValue("abilities_list", tostring(entity:GetPlayerOwnerID()), CAddonWarsong.player_abilities_info[entity:GetPlayerOwnerID()])
        if new_ability then
            self:PrecacheHero(new_ability)
            if string.find(random_ability, "invoker") then
                if entity:GetLevel() >= 30 then
                    new_ability:SetLevel(3)
                elseif entity:GetLevel() >= 15 then
                    new_ability:SetLevel(2)
                else
                    new_ability:SetLevel(1)
                end
            else
                new_ability:SetLevel(new_ability:GetMaxLevel())
            end
            new_ability:EndCooldown()
            if is_ultimate == 1 then
                self.PlayersUltimateAbilities[entity:GetPlayerOwnerID()] = new_ability
            else
                self.PlayersDefaultAbilities[entity:GetPlayerOwnerID()] = new_ability
            end
            --EmitAnnouncerSoundForPlayer("Flag.NewAbility", entity:GetPlayerOwnerID())
        else
            GameRules:SendCustomMessage("Напишите админу, Способность сломана - "..random_ability, 0, 0)
        end
    end
end

function CAddonWarsong:RunAbilitySoundPrecache()
    Timers:CreateTimer(1, function()
        local sHeroName
        if self.pendingPrecache and #self.pendingPrecache > 0 then
            sHeroName = self.pendingPrecache[#self.pendingPrecache]
            table.remove(self.pendingPrecache, #self.pendingPrecache)
        end
        if not sHeroName then return 5 end
        print("npc_precache_"..sHeroName)
        PrecacheUnitByNameAsync("npc_precache_"..sHeroName, function()
            self.precached[sHeroName] = true
            self:RunAbilitySoundPrecache()
        end)
    end)
end

function CAddonWarsong:GetNewAbilityPlayer(hero, list)
    local abilities = {}
    local count = 3
    local shuffled = table.shuffle(list)
    for _, ability_name in pairs(shuffled) do
        if not hero:HasAbility(ability_name) then
            count = count - 1
            table.insert(abilities, ability_name)
        end
        if count <= 0 then
            break
        end
    end
    return abilities
end

function CAddonWarsong:RemoveModifierFromAbility(ability)
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsValidEntity(hero) then
            local modifiers = hero:FindAllModifiers()
            for _, modifier in pairs(modifiers) do
                if modifier and modifier:GetAbility() == ability then
                    modifier:Destroy()
                end
            end
        end
    end
    for _, thinker in pairs(Entities:FindAllByClassname("npc_dota_thinker")) do
        if IsValidEntity(thinker) then
            local modifiers = thinker:FindAllModifiers()
            for _, modifier in pairs(modifiers) do
                if modifier and modifier:GetAbility() == ability then
                    thinker:Destroy()
                end
            end
        end
    end
end
