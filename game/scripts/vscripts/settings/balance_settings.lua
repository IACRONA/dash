if GetMapName() == "portal_duo" then
    --Разница между килами последнекей и первой командой
    --Я разделил на тиры, чтобы было удобнее, первый тир самый попущенный
    LAST_KILL_DIFFERENCE_TIER_1 = 20
    LAST_KILL_DIFFERENCE_TIER_2 = 18
    LAST_KILL_DIFFERENCE_TIER_3 = 15

    
    --Разница между килами предпоследней и первой командой
    PRE_LAST_KILL_DIFFERENCE_TIER_1 = 18
    PRE_LAST_KILL_DIFFERENCE_TIER_2 = 15
    PRE_LAST_KILL_DIFFERENCE_TIER_3 = 12
    

    --Разница между килами первой и второй командой
    FIRST_KILL_DIFFERENCE_TIER_1 = 20
    FIRST_KILL_DIFFERENCE_TIER_2 = 16
    FIRST_KILL_DIFFERENCE_TIER_3 = 12

    LAST_COMMAND_GOLD_TICK = {
        [1] = 400,
        [2] = 300,
        [3] = 200
    }

    PRE_LAST_COMMAND_GOLD_TICK = {                  
        [1] = 350,
        [2] = 250,
        [3] = 150
    }
    
    LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 30,
            rare = 100,
            epic = 220,
        },
        [2] = {
            common = 30,
            rare = 85,
        },
        [3] = {
            common = 25,
        },
    }
    
    
    PRE_LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 30,
            rare = 80,
            epic = 220,
        },
        [2] = {
            common = 30,
            rare = 80,
        },
        [3] = {
            common = 25,
        },
    }

    --Уменьшение урона по послденей команде [1] - это какой тир нужен
    LAST_MODIFIER_BALANCE = {
        [1] = {
            incoming = -10,
        },
    }

    --Уменьшение урона по предпоследней команде [1] - это какой тир нужен
    RE_LAST_MODIFIER_BALANCE = {}
    
    --Уменьшение урона по первой команде [1] - это какой тир нужен
    FIRST_MODIFIER_CURSED_LEADER = {
        [1] = {
            incoming = 12,
            outgoing = -10,
        },
        [2] = {
            incoming = 10,
            outgoing = -10,
        },
        [3] = {
            incoming = 8,
            outgoing = -5,
        },
    }

    --Лимит бонусов на серийные убийств а 
    SERIAL_KILL_LIMIT = {
        tripple = {rare = 3},
        rampage = {rare = 2}
    }

    --Кулдаун на серийцные убийства
    SERIAL_KILL_TIMER = {
        tripple = {rare = 120},
    }

    --Убийства лидера последееий и иногда предпоследний командой кулдаун
    KILL_LEADER_REWARD_TIME = 240

    BOOK_REROLL_COUNT  = 3
    BOOK_COMMON_COOLDOWN = 65
    BOOK_RARE_START = 480
    BOOK_RARE_COOLDOWN = 85
    BOOK_EPIC_COOLDOWN = 333
    BOOK_COMMON_LIMIT = 30
    BOOK_RARE_LIMIT = 25
    BOOK_EPIC_LIMIT = 8
end

if GetMapName() == "portal_trio" then
    --Разница между килами последнекей и первой командой
    --Я разделил на тиры, чтобы было удобнее, первый тир самый попущенный
    LAST_KILL_DIFFERENCE_TIER_1 = 20
    LAST_KILL_DIFFERENCE_TIER_2 = 18
    LAST_KILL_DIFFERENCE_TIER_3 = 15

    
    --Разница между килами предпоследней и первой командой
    PRE_LAST_KILL_DIFFERENCE_TIER_1 = 20
    PRE_LAST_KILL_DIFFERENCE_TIER_2 = 18
    PRE_LAST_KILL_DIFFERENCE_TIER_3 = 15
    

    --Разница между килами первой и второй командой
    FIRST_KILL_DIFFERENCE_TIER_1 = 18
    FIRST_KILL_DIFFERENCE_TIER_2 = 15
    FIRST_KILL_DIFFERENCE_TIER_3 = 12

    LAST_COMMAND_GOLD_TICK = {
        [1] = 400,
        [2] = 300,
        [3] = 200
    }

    PRE_LAST_COMMAND_GOLD_TICK = {                  
        [1] = 350,
        [2] = 250,
        [3] = 200
    }
    
    LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 40,
            rare = 80,
            epic = 240,    
        },
        [2] = {
            common = 30,
            rare = 80,
        },
        [3] = {
            common = 25,
        },
    }
    
    
    PRE_LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 35,
            rare = 90,
            epic = 240,
        },
        [2] = {
            common = 35,
            rare = 90,
        },
        [3] = {
            common = 25,
        },
    }

    --Уменьшение урона по послденей команде [1] - это какой тир нужен
    LAST_MODIFIER_BALANCE = {
        [1] = {
            incoming = -10,
        },
    }

    --Уменьшение урона по предпоследней команде [1] - это какой тир нужен
    PRE_LAST_MODIFIER_BALANCE = {
        [1] = {
            incoming = -5,
        },
    }
    
    --Уменьшение урона по первой команде [1] - это какой тир нужен
    FIRST_MODIFIER_CURSED_LEADER = {
        [1] = {
            incoming = 12,
            outgoing = -12,
        },
        [2] = {
            incoming = 12,
            outgoing = -12,
        },
        [3] = {
            incoming = 12,
            outgoing = -12,
        },
    }

    --Лимит бонусов на серийные убийств а 
    SERIAL_KILL_LIMIT = {
        tripple = {rare = 3},
        rampage = {rare = 2}
    }

    --Кулдаун на серийцные убийства
    SERIAL_KILL_TIMER = {
        tripple = {rare = 120},
    }

    --Убийства лидера последееий и иногда предпоследний командой кулдаун
    KILL_LEADER_REWARD_TIME = 240

    BOOK_REROLL_COUNT  = 3
    BOOK_COMMON_COOLDOWN = 65
    BOOK_RARE_START = 480
    BOOK_RARE_COOLDOWN = 85
    BOOK_EPIC_COOLDOWN = 333
    BOOK_COMMON_LIMIT = 30
    BOOK_RARE_LIMIT = 25
    BOOK_EPIC_LIMIT = 8
end

if GetMapName() == "warsong" then
    FLAGS_DIFFERENCE_TIER_1 = 5
    FLAGS_DIFFERENCE_TIER_2 = 3
    
    LAST_COMMAND_GOLD_TICK = {
        [1] = 300,
        [2] = 200,
    }

    LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 35,
            rare = 80,
            epic = 200
        },
        [2] = {
            common = 35,
            rare = 85,
        },
    }
 
    LAST_MODIFIER_BALANCE = {
        [1] = {
            incoming = -15,
            outgoing = 15,
        },
        [2] = {
            incoming = -12,
        },
 
    }

    --Лимит бонусов на серийные убийств а 
    SERIAL_KILL_LIMIT = {
        tripple = {rare = 3},
        rampage = {rare = 2}
    }

    --Кулдаун на серийцные убийства
    SERIAL_KILL_TIMER = {
        tripple = {rare = 120},
    }
    BOOK_REROLL_COUNT  = 1
    BOOK_COMMON_COOLDOWN = 65
    BOOK_RARE_START = 480
    BOOK_RARE_COOLDOWN = 90
    BOOK_EPIC_COOLDOWN = 333
    BOOK_COMMON_LIMIT = 30
    BOOK_RARE_LIMIT = 25
    BOOK_EPIC_LIMIT = 8
end

if GetMapName() == "dash" then
    KILLS_DIFFERENCE_TIER_1 = 2
    KILLS_DIFFERENCE_TIER_2 = 1

    
    GOLD_DIFFERENCE_TIER_1 = 25
    GOLD_DIFFERENCE_TIER_2 = 15

    LAST_COMMAND_GOLD_TICK = {
        [1] = 400,
        [2] = 200,
    }

    LAST_BOOK_COOLDOWN = {
        [1] = {
            common = 120,
            rare = 250,
        },
    }
 
    LAST_MODIFIER_BALANCE = {
        [1] = {
            incoming = -10,
        },
    }
    BOOK_REROLL_COUNT  = 0
    BOOK_COMMON_COOLDOWN = 90
    BOOK_RARE_START = 600
    BOOK_RARE_COOLDOWN = 110
    BOOK_EPIC_COOLDOWN = 480
    BOOK_COMMON_LIMIT = 30
    BOOK_RARE_LIMIT = 15
    BOOK_EPIC_LIMIT = 7
end