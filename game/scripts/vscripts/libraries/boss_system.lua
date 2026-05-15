-- ============================================================================
-- Система «линейного» респавна боссов.
--
-- Когда Host Pirate (npc_boss_kunkka) или Kraken (npc_boss_tidehunter) умирают,
-- через 60 секунд (+ выравнивание на ближайший тик волны крипов = 30 сек) они
-- возрождаются на случайной боковой линии (top/bot) на точке спавна крипов
-- команды убийцы. Возрождённый босс идёт атак-мувом к вражескому трону вместе
-- с ближайшей волной крипов, атакует башни, казармы и трон как обычный крип.
--
-- При респавне на линии на босса вешается modifier_lane_boss_debuff, который
-- снижает на 15% HP, броню, скорость атаки и весь исходящий урон (включая
-- урон абилок). Смерть «линейного» босса снова запускает цикл.
-- ============================================================================

require("settings/game_settings")

if BossSystem == nil then
	_G.BossSystem = class({})
end

BossSystem.boss_names = {
	["npc_boss_kunkka"]     = true, -- Host Pirate
	["npc_boss_tidehunter"] = true, -- Kraken
}

-- Цикл появления крипов по линиям (в секундах). Стандартное значение Dota 2.
BossSystem.creep_wave_interval = 30

-- Дефолтная задержка респавна после смерти, если карта не задала свою.
-- На картах, у которых выставлен глобал BOSS_LANE_RESPAWN_DELAY (см.
-- settings/game_settings.lua, блок Dash), используется именно он.
BossSystem.respawn_delay = 60

local function get_respawn_delay()
	return tonumber(BOSS_LANE_RESPAWN_DELAY) or BossSystem.respawn_delay
end

-- ---------------------------------------------------------------------------
-- Вход: вызывается из CAddonWarsong:OnEntityKilled в libraries/events.lua
-- ---------------------------------------------------------------------------
function BossSystem:OnEntityKilled(killedUnit, killerEntity)
	if not killedUnit or killedUnit:IsNull() then return end
	local unitName = killedUnit:GetUnitName()
	if not BossSystem.boss_names[unitName] then return end

	local deadTeam = killedUnit:GetTeamNumber()
	local respawnTeam = nil

	if deadTeam == DOTA_TEAM_NEUTRALS then
		-- Убили оригинального «домашнего» босса — определяем команду убийцы.
		if not killerEntity or killerEntity:IsNull() then return end

		local killerTeam = killerEntity:GetTeamNumber()
		if killerEntity.GetOwner and killerEntity:GetOwner() and not killerEntity:GetOwner():IsNull() then
			killerTeam = killerEntity:GetOwner():GetTeamNumber()
		end

		if killerTeam ~= DOTA_TEAM_GOODGUYS and killerTeam ~= DOTA_TEAM_BADGUYS then
			return
		end
		respawnTeam = killerTeam

		-- Запоминаем домашнюю точку и вектор поворота оригинального босса,
		-- чтобы после смерти линейного босса OnDeath мог возродить его дома.
		BossSystem.home_positions = BossSystem.home_positions or {}
		BossSystem.home_positions[unitName] = {
			pos = killedUnit.respoint,
			fw  = killedUnit.fw,
		}
	elseif deadTeam == DOTA_TEAM_GOODGUYS or deadTeam == DOTA_TEAM_BADGUYS then
		-- Умер линейный босс — стандартный OnDeath возродит его дома.
		-- Цикл линейного пуша НЕ повторяется.
		return
	else
		return
	end

	-- Уведомление вражеской команде: «Босс повержен и присоединится к врагам!»
	local enemyTeam = (respawnTeam == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
	BossSystem:SendLaneNotification(unitName, enemyTeam)

	BossSystem:ScheduleLaneRespawn(unitName, respawnTeam)
end

-- ---------------------------------------------------------------------------
-- Отправляем уведомление игрокам указанной команды о том, что босс был
-- повержен и присоединится к врагам.
-- ---------------------------------------------------------------------------
function BossSystem:SendLaneNotification(unitName, enemyTeam)
	for i = 0, PlayerResource:GetPlayerCount() - 1 do
		if PlayerResource:IsValidPlayerID(i) then
			local team = PlayerResource:GetTeam(i)
			local player = PlayerResource:GetPlayer(i)
			if player and team == enemyTeam then
				CustomGameEventManager:Send_ServerToPlayer(player, "boss_lane_notification", {
					boss_name = unitName,
				})
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Планирование респавна — выравниваем на ближайшую волну крипов.
-- ---------------------------------------------------------------------------
function BossSystem:ScheduleLaneRespawn(unitName, team)
	local now = GameRules:GetDOTATime(false, false)
	local respawnDelay = get_respawn_delay()
	local earliest = now + respawnDelay
	local cycle = BossSystem.creep_wave_interval

	-- Ближайший момент ≥ earliest, кратный cycle от 0-й отметки игрового времени.
	-- Если earliest уже попал ровно на тик, оставляем этот тик.
	local laneTick = math.ceil(earliest / cycle) * cycle
	local delay = laneTick - now
	if delay < respawnDelay then
		delay = delay + cycle
	end

	Timers:CreateTimer(delay, function()
		BossSystem:SpawnLaneBoss(unitName, team)
	end)
end

-- ---------------------------------------------------------------------------
-- Жёстко заданные пути по линиям. Координаты получены через `setpos` из игры
-- (см. переписку — пользователь дал точки лично, чтобы не зависеть от того,
-- как именно названы спавнеры/path-corner'ы в каждой кастомной карте).
--
-- Для каждой команды есть набор «линий» (right/left), у каждой:
--   spawn      — точка появления босса.
--   waypoints  — упорядоченная цепочка точек по линии, последняя — у врат
--                вражеского ancient'а.
--
-- Босс получает очередь ATTACK_MOVE по всем waypoints (Queue=true), что
-- заставляет движок вести его строго по линии и автоматически возобновлять
-- движение после боя со следующего waypoint.
-- ---------------------------------------------------------------------------
-- Конвенция: смотрим на карту сверху (как на миникарте), Dire вверху,
-- Radiant внизу. "left" = визуально левая половина карты = отрицательный X
-- (западная сторона). "right" = положительный X (восточная сторона).
-- Маркировка одинаковая для обеих команд.
local LANE_PATHS = {
	-- Dire (badguys) пушит к Radiant ancient (-1048, -5997).
	[DOTA_TEAM_BADGUYS] = {
		left = {
			spawn = Vector(-1499.30, 3466.46, 1353.98),
			waypoints = {
				Vector(-1532.56,  3645.72, 1366.32),
				Vector(-7450.31,   102.38, 1543.21),
				Vector(-6150.94, -4865.51, 1315.92),
				Vector(-1590.55, -4565.92, 1387.78),
				Vector(-1048.35, -5997.47, 1495.65),
			},
		},
		right = {
			spawn = Vector(2124.19, 3466.46, 1412.93),
			waypoints = {
				Vector( 2473.98,  3523.72, 1371.17),
				Vector( 7374.77,    20.31, 1502.25),
				Vector( 4893.54, -5838.15, 1369.59),
				Vector( 1171.69, -5015.30, 1421.05),
				Vector(-1048.35, -5997.47, 1495.65),
			},
		},
	},
	-- Radiant (goodguys) пушит к Dire ancient (908, 4427).
	[DOTA_TEAM_GOODGUYS] = {
		left = {
			spawn = Vector(-896.00, -4502.57, 1413.36),
			waypoints = {
				Vector(-1590.55, -4565.92, 1387.78),
				Vector(-6150.94, -4865.51, 1315.92),
				Vector(-7450.31,   102.38, 1543.21),
				Vector(-1532.56,  3645.72, 1366.32),
				Vector(  908.47,  4427.03, 1502.92),
			},
		},
		right = {
			spawn = Vector(796.71, -5152.75, 1439.31),
			waypoints = {
				Vector( 1171.69, -5015.30, 1421.05),
				Vector( 4893.54, -5838.15, 1369.59),
				Vector( 7374.77,    20.31, 1502.25),
				Vector( 2473.98,  3523.72, 1371.17),
				Vector(  908.47,  4427.03, 1502.92),
			},
		},
	},
}

-- ---------------------------------------------------------------------------
-- Сканер path_corner'ов в карте.
--
-- Стандартная Dota-конвенция: лайновые крипы ходят по entity класса
-- "path_corner" с именами вроде "lane_top_pathcorner_goodguys_1",
-- "lane_top_pathcorner_goodguys_2" и т.д. Мы выгребаем ВСЕ path_corner,
-- группируем по команде (по подстроке goodguys/badguys в имени) и линии
-- (по подстроке top/bot/mid), сортируем по числу в конце имени и получаем
-- готовые цепочки waypoints — те самые, по которым ходят крипы.
--
-- Результат кешируется на сессию.
-- ---------------------------------------------------------------------------
function BossSystem:ScanPathCorners()
	if BossSystem._cached_lane_paths ~= nil then
		return BossSystem._cached_lane_paths
	end

	local result = {
		[DOTA_TEAM_GOODGUYS] = {},
		[DOTA_TEAM_BADGUYS]  = {},
	}
	local groups = {} -- key = "team|lane" -> list of {idx, pos, name}

	local all = Entities:FindAllByClassname("path_corner") or {}
	for _, e in pairs(all) do
		if e and not e:IsNull() then
			local name = e:GetName() or ""
			if name ~= "" then
				local team = nil
				if name:find("goodguys") then team = DOTA_TEAM_GOODGUYS
				elseif name:find("badguys") then team = DOTA_TEAM_BADGUYS end

				local lane = "unknown"
				if name:find("top") then lane = "top"
				elseif name:find("bot") then lane = "bot"
				elseif name:find("mid") then lane = "mid" end

				if team then
					local idx = tonumber(name:match("(%d+)$")) or 0
					local key = tostring(team) .. "|" .. lane
					groups[key] = groups[key] or {}
					table.insert(groups[key], { idx = idx, pos = e:GetAbsOrigin(), name = name })
				end
			end
		end
	end

	for key, list in pairs(groups) do
		table.sort(list, function(a, b) return a.idx < b.idx end)
		local positions = {}
		for _, item in ipairs(list) do
			table.insert(positions, item.pos)
		end
		local team_str, lane_str = key:match("(%-?%d+)|(.+)")
		local team = tonumber(team_str)
		if team and result[team] then
			result[team][lane_str] = positions
		end
	end

	BossSystem._cached_lane_paths = result
	return result
end

-- ---------------------------------------------------------------------------
-- Интерполяция: если между двумя соседними waypoints расстояние больше
-- max_gap, вставляем промежуточные точки по прямой так, чтобы шаг ≤ max_gap.
-- Это не даёт движку «срезать» через мид: каждый ATTACK_MOVE-хоп ≤ 800 unit.
-- ---------------------------------------------------------------------------
local INTERPOLATION_MAX_GAP = 800

local function interpolate_waypoints(waypoints)
	if #waypoints < 2 then return waypoints end
	local result = {}
	for i = 1, #waypoints do
		table.insert(result, waypoints[i])
		if i < #waypoints then
			local a = waypoints[i]
			local b = waypoints[i + 1]
			local dist = (b - a):Length2D()
			if dist > INTERPOLATION_MAX_GAP then
				local steps = math.ceil(dist / INTERPOLATION_MAX_GAP)
				for s = 1, steps - 1 do
					local t = s / steps
					local mid = Vector(
						a.x + (b.x - a.x) * t,
						a.y + (b.y - a.y) * t,
						a.z + (b.z - a.z) * t
					)
					table.insert(result, mid)
				end
			end
		end
	end
	return result
end

-- ---------------------------------------------------------------------------
-- Возвращает { spawn, waypoints, name, source } для случайной БОКОВОЙ линии
-- команды. Используем хардкод LANE_PATHS + интерполяцию между точками.
-- ---------------------------------------------------------------------------
function BossSystem:GetSpawnPath(team)
	local teamPaths = LANE_PATHS[team]
	if not teamPaths then return nil end
	local laneNames = {}
	for k, _ in pairs(teamPaths) do table.insert(laneNames, k) end
	if #laneNames == 0 then return nil end
	local lane = laneNames[RandomInt(1, #laneNames)]
	local lanePath = teamPaths[lane]

	-- Строим полный маршрут: spawn → waypoints, с интерполяцией.
	local raw = { lanePath.spawn }
	for _, w in ipairs(lanePath.waypoints) do table.insert(raw, w) end
	local dense = interpolate_waypoints(raw)

	return {
		spawn = lanePath.spawn,
		waypoints = dense,
		name = lane,
		source = "hardcoded+interpolated",
	}
end

-- Расстояние, на котором waypoint считается «пройденным».
local WAYPOINT_REACH_RADIUS = 700
-- Если за это число тиков (по 1 сек) босс не сдвинулся и не атакует — пере-выдаём очередь.
local STUCK_TICKS_BEFORE_REISSUE = 2
-- Сколько unit за тик считается «движется».
local STUCK_MOVEMENT_THRESHOLD = 80

-- ---------------------------------------------------------------------------
-- Каст способностей в бою. Повторяет логику из ai_boss.lua, но без
-- RetreatHome и без спама ордеров на невалидные цели.
-- ---------------------------------------------------------------------------
function BossSystem:TryCastAbilities(boss, target)
	if not target or target:IsNull() or not target:IsAlive() then return end
	for i = 0, boss:GetAbilityCount() - 1 do
		local ability = boss:GetAbilityByIndex(i)
		if ability and not ability:IsNull() and not ability:IsPassive() and ability:IsFullyCastable() then
			local behavior = ability:GetBehavior()
			local orderTable = { UnitIndex = boss:entindex() }

			if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
				-- Проверяем, может ли способность целиться в этот тип юнита.
				local targetType = ability:GetAbilityTargetType()
				if targetType ~= 0 and bit.band(targetType, DOTA_UNIT_TARGET_HERO) == 0 and bit.band(targetType, DOTA_UNIT_TARGET_BASIC) == 0 then
					goto continue
				end
				orderTable.OrderType = DOTA_UNIT_ORDER_CAST_TARGET
				orderTable.TargetIndex = target:entindex()
			elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
				orderTable.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
			elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
				orderTable.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
				orderTable.Position = target:GetAbsOrigin()
			end

			if orderTable.OrderType then
				orderTable.AbilityIndex = ability:entindex()
				ExecuteOrderFromTable(orderTable)
				return -- одна способность за тик
			end
			::continue::
		end
	end
end

-- ---------------------------------------------------------------------------
-- Выдать очередь ATTACK_MOVE на все ещё не пройденные waypoints.
-- Первый ордер идёт без Queue (сбрасывает зависший order), остальные — с Queue=true.
-- ---------------------------------------------------------------------------
function BossSystem:IssueLaneQueue(boss)
	local wps = boss.lane_waypoints
	local idx = boss.lane_waypoint_index or 1
	if not wps or idx > #wps then return end

	local first = true
	for i = idx, #wps do
		ExecuteOrderFromTable({
			UnitIndex = boss:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position  = wps[i],
			Queue     = not first,
		})
		first = false
	end
end

-- ---------------------------------------------------------------------------
-- Каждую секунду: продвигаем индекс waypoint'а, проверяем застревание.
-- Логируем позицию, текущий waypoint-индекс и состояние босса.
-- ---------------------------------------------------------------------------
function BossSystem:UpdateLaneProgress(boss)
	local wps = boss.lane_waypoints
	local idx = boss.lane_waypoint_index or 1
	if not wps or idx > #wps then return end

	local pos = boss:GetAbsOrigin()
	local attackTarget = boss:GetAttackTarget()

	-- Авто-продвижение: пропускаем waypoint'ы, которые уже рядом / позади.
	while idx <= #wps and (wps[idx] - pos):Length2D() < WAYPOINT_REACH_RADIUS do
		idx = idx + 1
	end
	boss.lane_waypoint_index = idx
	if idx > #wps then return end

	-- Если босс реально дерётся — кастуем способности и не трогаем движение.
	if attackTarget ~= nil then
		boss._lane_last_pos = pos
		boss._lane_stuck_ticks = 0
		BossSystem:TryCastAbilities(boss, attackTarget)
		return
	end

	-- Детект «застрял».
	local lastPos = boss._lane_last_pos
	boss._lane_last_pos = pos
	if lastPos and (pos - lastPos):Length2D() < STUCK_MOVEMENT_THRESHOLD then
		boss._lane_stuck_ticks = (boss._lane_stuck_ticks or 0) + 1
	else
		boss._lane_stuck_ticks = 0
	end

	if (boss._lane_stuck_ticks or 0) >= STUCK_TICKS_BEFORE_REISSUE then
		BossSystem:IssueLaneQueue(boss)
		boss._lane_stuck_ticks = 0
	end
end

-- ---------------------------------------------------------------------------
-- Реген вне боя: если никого нет в радиусе агро — реген x10, иначе обычный.
-- ---------------------------------------------------------------------------
local BOSS_REGEN_INTERVAL   = 1.0
local BOSS_REGEN_MULTIPLIER = 10
local BOSS_AGRO_RADIUS      = 800

function BossSystem:StartRegenThink(boss)
	boss:SetContextThink("BossSystem_RegenThink", function()
		if not boss or boss:IsNull() or not boss:IsAlive() then return nil end
		if GameRules:IsGamePaused() then return BOSS_REGEN_INTERVAL end

		local inCombat = boss:GetAttackTarget() ~= nil
		if not inCombat then
			local enemies = FindUnitsInRadius(
				boss:GetTeamNumber(),
				boss:GetAbsOrigin(),
				nil,
				BOSS_AGRO_RADIUS,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
				FIND_CLOSEST,
				false
			)
			inCombat = #enemies > 0
		end

		local baseRegen = boss:GetBaseHealthRegen()
		local extraRegen = inCombat and 0 or (baseRegen * (BOSS_REGEN_MULTIPLIER - 1))
		if extraRegen > 0 then
			local newHp = math.min(boss:GetHealth() + extraRegen * BOSS_REGEN_INTERVAL, boss:GetMaxHealth())
			boss:SetHealth(newHp)
		end

		return BOSS_REGEN_INTERVAL
	end, BOSS_REGEN_INTERVAL)
end

-- ---------------------------------------------------------------------------
-- Непосредственный спавн линейного босса.
-- ---------------------------------------------------------------------------
function BossSystem:SpawnLaneBoss(unitName, team)
	local lanePath = BossSystem:GetSpawnPath(team)
	if not lanePath then return end

	-- Нормализуем спавн по высоте земли.
	local spawnPos = GetGroundPosition(Vector(lanePath.spawn.x, lanePath.spawn.y, 0), nil)

	local boss = CreateUnitByName(unitName, spawnPos, true, nil, nil, team)
	if not boss or boss:IsNull() then return end

	-- Это линейный босс: после смерти OnDeath возродит его дома штатно.
	boss:SetUnitCanRespawn(false)
	boss.is_lane_boss = true

	-- Подставляем домашнюю точку и вектор, чтобы OnDeath (ability_boss)
	-- возродил босса именно дома, а не на точке лейна.
	local home = BossSystem.home_positions and BossSystem.home_positions[unitName]
	if home then
		boss.respoint = home.pos
		boss.fw = home.fw
	end

	-- ВАЖНО: отключаем стандартный AI босса (ai_boss.lua / BossThink).
	-- Он каждые 0.25 сек выдаёт RetreatHome() → ордер на respoint (0,0),
	-- что перебивает нашу ATTACK_MOVE очередь и гонит босса в центр карты.
	-- Делаем это дважды: сразу и через 0.1 сек — на случай если Spawn() в
	-- ai_boss.lua зарегистрирует BossThink ПОСЛЕ нашего вызова.
	boss:SetContextThink("BossThink", nil, -1)
	Timers:CreateTimer(0.1, function()
		if boss and not boss:IsNull() then
			boss:SetContextThink("BossThink", nil, -1)
		end
	end)
	boss.lane_waypoints = lanePath.waypoints
	boss.lane_waypoint_index = 1
	boss._lane_last_pos = spawnPos
	boss._lane_stuck_ticks = 0

	-- Дебафф (% берётся из BOSS_LANE_DEBUFF_PERCENT в game_settings.lua).
	boss:AddNewModifier(boss, nil, "modifier_lane_boss_debuff", { duration = -1 })
	boss:SetHealth(boss:GetMaxHealth())

	-- Сразу выдаём очередь по всем waypoints.
	BossSystem:IssueLaneQueue(boss)

	-- Реген вне боя.
	BossSystem:StartRegenThink(boss)

	-- Periodic think: каждую секунду продвигаем индекс / чиним застревания.
	boss:SetContextThink("BossSystem_LanePushThink", function()
		if not boss or boss:IsNull() or not boss:IsAlive() then return nil end
		if GameRules:IsGamePaused() then return 1 end
		BossSystem:UpdateLaneProgress(boss)
		return 1
	end, 1)
end
