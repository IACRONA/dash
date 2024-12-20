-- Время оглушения всех игроков на карте после спавна морфа (задержка до спавна морфа) в секундах
SPAWN_MORPHLING_STUN_DELAY = 5 -- СКОЛЬКО СТОИТ МОРФ
SPAWN_MORPHLING_STUN_DELAY_HERO = 4 -- СКОЛЬКО СТОИТ ГЕРОЙ

-- Время спавна босса морфа (через сколько секунд после начала игры)
SPAWN_MORPHLING_TIME_TOOLTIP = RandomInt(380, 410) -- Случайное время спавна ОТ СТАРТА ИГРЫ (от 300 до 400 секунд) ЭТО ПЕРВЫЙ СПАВН
-- Повторное время спавна босса морфа
SPAWN_MORPHLING_TIME_TOOLTIP_DOUBLE = RandomInt(700, 960) -- Случайное время спавна ОТ СТАРТА ИГРЫ (от 600 до 800 секунд) ЭТО ВТОРОЙ СПАВН

SPAWN_MORPHLING_TIME = GAME_TIME_CLOCK - SPAWN_MORPHLING_TIME_TOOLTIP -- Не трогать
SPAWN_MORPHLING_TIME_DOUBLE = GAME_TIME_CLOCK - SPAWN_MORPHLING_TIME_TOOLTIP_DOUBLE -- Не трогать

-- Время жизни морфлинга в секундах
MORPHLING_LIFE_TIME = 60

-- Статы морфлинга
BASE_MORPH_MAX_HEALTH = 16000
BASE_MORPH_MAX_MANA = 12310
BASE_MORPH_MIN_DAMAGE = 650
BASE_MORPH_MAX_DAMAGE = 1250
BASE_MORPH_MAGICAL_RESISTANCE = 25
BASE_MORPH_PHYSICAL_ARMOR = 35
BASE_MORPH_MOVESPEED = 400

-- Сколько очков добавляет убийство морфа
MORPH_REWARD_MAX_KILLS = 10

-- СКОЛЬКО ОЧКОВ ЗАБИРАЕТ МОРФ УБИВАЯ ГЕРОЯ
MORPH_KILL_HERO_STEAL_POINT = 1

-- Ограничение снятия очков за игрока
MORPH_KILL_HERO_STEAL_POINT_MAX = 4

-- Время после которого все стоят афк как морф уходит
MORPH_OUT_TIME_STUN = 4

-- НАСТРОЙКИ УРОНА СПОСОБНОСТЕЙ В ФАЙЛЕ scripts/npc/npc_abilities_custom.txt
-- morphling_boss_wave
-- morphling_boss_crystalnova
-- morphling_boss_frostbite
-- morphling_boss_blast
-- morphling_boss_finger

--Скорость атаки в файле scripts/npc/npc_units_custom.txt
-- в юните npc_custom_boss_morphling и там BaseAttackSpeed


-- Также надо будет если что изменять оповещалки в файлах resource/addon_english и resource/addon_russian