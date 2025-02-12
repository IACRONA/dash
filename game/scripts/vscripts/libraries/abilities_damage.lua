function InitDamageAbilities()
    local abilitiesDamage = {}
    local abilitiesRadius = {}
    local parseAbilities = function(file)
        if file then 
            for abilityName,value in pairs(file) do
                if type(value) == "table"  then 
                    if value.AbilityUnitDamageType or value.SpellDispellableType then 
                        abilitiesDamage[abilityName] = {}
                    end
                    if value.AbilityUnitDamageType then 
                        abilitiesDamage[abilityName].damage = value.AbilityUnitDamageType
                    end

                    if value.SpellDispellableType then 
                        abilitiesDamage[abilityName].dispell = value.SpellDispellableType
                    end
                    local values = value.AbilityValues

                    if values then 
                        local dataRadiusValues = {}
                        local hasIncrementRadius = false
                        for valueName,valueInfo in pairs(values) do
                            if type(valueInfo) == "table"  then 
                                if valueInfo.affected_by_aoe_increase == 1 then 
                                    hasIncrementRadius = true
                                    dataRadiusValues[valueName] = true
                                end
                            end
                        end

                        if hasIncrementRadius then 
                            abilitiesRadius[abilityName] = dataRadiusValues
                        end
                    end
 
                end
            end
        end
    end

    for hero,v in pairs(LoadKeyValues("scripts/npc/npc_heroes.txt")) do
        local heroAbilities = LoadKeyValues("scripts/npc/heroes/".. hero.. ".txt")
        parseAbilities(heroAbilities)
    end

    local crystalFile = LoadKeyValues("scripts/npc/heroes/crystal_maiden_abilities.kv")
    parseAbilities(crystalFile)

    local dazzleFile = LoadKeyValues("scripts/npc/heroes/dazzle_abilities.kv")
    parseAbilities(dazzleFile)

    local enigmaFile = LoadKeyValues("scripts/npc/heroes/enigma_abilities.kv")
    parseAbilities(enigmaFile)

    local axeFile = LoadKeyValues("scripts/npc/heroes/axe_abilities.kv")
    parseAbilities(axeFile)

    local miranaFile = LoadKeyValues("scripts/npc/heroes/mirana_abilities.kv")
    parseAbilities(miranaFile)

    local linaFile = LoadKeyValues("scripts/npc/heroes/lina_abilities.kv")
    parseAbilities(linaFile)
 
    local abilityFile = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    parseAbilities(abilityFile)

    CustomNetTables:SetTableValue("abilities_damage", "abilities", abilitiesDamage)
    CustomNetTables:SetTableValue("abilities_radius", "abilities", abilitiesRadius)
end

InitDamageAbilities()