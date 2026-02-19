if BossSystem == nil then
    _G.BossSystem = class({})
end

BossSystem.boss_names = {
    ["npc_boss_kunkka"] = true,
    ["npc_boss_tidehunter"] = true,
    -- ["npc_custom_boss_morphling"] = true -- Морфлинг имеет свой AI, его пока не трогаем, пользователь просил конкретно двух
}

function BossSystem:OnEntityKilled(killedUnit, killerEntity)
    if not killedUnit or not killerEntity then return end

    -- Работает только на карте Dash
    if GetMapName() ~= "dash" then return end
    
    local unitName = killedUnit:GetUnitName()
    
    -- Проверяем, является ли убитый юнит боссом из списка и нейтралом
    if self.boss_names[unitName] and killedUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
        -- Определяем команду убийцы
        local killerTeam = killerEntity:GetTeamNumber()
        
        -- Если убийца - крип или башня, ищем владельца (героя)
        if killerEntity:GetOwner() then
            killerTeam = killerEntity:GetOwner():GetTeamNumber()
        end

        -- Игнорируем убийства нейтралами или другими боссами
        if killerTeam == DOTA_TEAM_NEUTRALS then return end

        -- Запускаем таймер возрождения на линии
        -- Используем Timers из addon_game_mode
        Say(nil, "BossSystem: " .. unitName .. " killed! Respawn in 60s for team " .. killerTeam, false)
        
        Timers:CreateTimer(60, function()
            self:SpawnLaneBoss(unitName, killerTeam)
        end)
        
        -- Отправляем оповещение
        local gameEvent = {}
        gameEvent["player_id"] = killerEntity:GetPlayerOwnerID()
        gameEvent["teamnumber"] = -1
        gameEvent["message"] = "#Warsong_Boss_Captured" 
        FireGameEvent("dota_combat_event_message", gameEvent)
    end
end

function BossSystem:SpawnLaneBoss(unitName, team)
    Say(nil, "BossSystem: Spawning " .. unitName .. " for team " .. team, false)
    -- Выбираем случайную линию: TOP (1) или BOT (2)
    -- На карте warsong (если она симметрична) спавнеры обычно называются стандартно
    -- Если нет, используем позиции флагов как запасной вариант

    local lane = RandomInt(1, 2) == 1 and "top" or "bot"
    local spawnerName = ""
    
    if team == DOTA_TEAM_GOODGUYS then
        spawnerName = "npc_dota_spawner_good_" .. lane
    else
        spawnerName = "npc_dota_spawner_bad_" .. lane
    end
    
    local spawner = Entities:FindByName(nil, spawnerName)
    local spawnPos = Vector(0,0,0)
    
    if spawner then
        spawnPos = spawner:GetAbsOrigin()
    else
        -- Фоллбэк на базу/флаг/фонтан/точку старта
        if team == DOTA_TEAM_GOODGUYS then
            local flag = Entities:FindByName(nil, "flag_radiant") or Entities:FindByName(nil, "flag_both_radiant") or Entities:FindByClassname(nil, "ent_dota_fountain_good") or Entities:FindByClassname(nil, "info_player_start_goodguys")
            if flag then spawnPos = flag:GetAbsOrigin() end
        else
            local flag = Entities:FindByName(nil, "flag_dire") or Entities:FindByName(nil, "flag_both_dire") or Entities:FindByClassname(nil, "ent_dota_fountain_bad") or Entities:FindByClassname(nil, "info_player_start_badguys")
            if flag then spawnPos = flag:GetAbsOrigin() end
        end
    end
    
    if spawnPos == Vector(0,0,0) then
        print("[BossSystem] Error: Could not find spawn position for boss!")
        return
    end
    
    -- Создаем босса
    local boss = CreateUnitByName(unitName, spawnPos, true, nil, nil, team)
    
    if boss then
        -- boss:SetControllableByPlayer(-1, true) -- Убрано: босс должен быть автономным, как в Mobile Legends
        boss:SetUnitCanRespawn(false) -- Босс не должен респавниться после смерти на линии
        
        -- Добавляем модификатор, чтобы пометить что это "лейн босс"
        boss:AddNewModifier(boss, nil, "modifier_kill", {duration = -1})
        
        -- Устанавливаем цель (путь к трону) - это сделает AI скрипт, но мы можем задать начальный AttackMove
        local enemyBase = nil
        if team == DOTA_TEAM_GOODGUYS then
            enemyBase = Entities:FindByName(nil, "npc_dota_badguys_fort") or Entities:FindByName(nil, "npc_dota_badguys_fort_custom")
        else
            enemyBase = Entities:FindByName(nil, "npc_dota_goodguys_fort") or Entities:FindByName(nil, "npc_dota_goodguys_fort_custom")
        end

        
        if enemyBase then
            -- Используем ExecuteOrder, чтобы задать приказ "Атаковать в движение"
            -- AI скрипт должен будет подхватить это или не мешать
             ExecuteOrderFromTable({
                UnitIndex = boss:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = enemyBase:GetAbsOrigin(),
                Queue = false,
            })
            
            -- Сохраняем цель в handle юнита, чтобы AI мог ее использовать
            boss.lanePushTarget = enemyBase
        end
        
        -- Пытаемся найти вейпоинты для более точного пути (если есть)
        local pathCornerName = ""
        if team == DOTA_TEAM_GOODGUYS then
             pathCornerName = "lane_" .. lane .. "_pathcorner_goodguys_1"
        else
             pathCornerName = "lane_" .. lane .. "_pathcorner_badguys_1"
        end
        local pathCorner = Entities:FindByName(nil, pathCornerName)
        
        if pathCorner then
            boss:SetInitialGoalEntity(pathCorner)
        end
    end
end
