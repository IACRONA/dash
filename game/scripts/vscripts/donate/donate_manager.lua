require('donate/donate_items')

if DonateManager == nil then
	DonateManager = class({})
end

function DonateManager:Init()
    CustomNetTables:SetTableValue("server_info", "music", DONATE_ITEMS.music) 
end
 
function DonateManager:InitHero(hero)
    hero.donate = {
        aura = {},
        titul = "",
        pet = {},
    }

    local playerId = hero:GetPlayerOwnerID()
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 
    if not playerInfo then return end
 
    self:AddHeroAura(hero, playerInfo.aura)
    self:AddHeroPet(hero, playerInfo.pet)
end

function DonateManager:CheckForChangeDonate(playerId)
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    
    if not hero then return end

    self:AddHeroAura(hero, playerInfo.aura)
    self:TryChangeTitul(hero, playerInfo.titul)
    self:AddHeroPet(hero, playerInfo.pet)
end

function DonateManager:AddHeroAura(hero, auraInfo)
    local heroAura = hero.donate.aura

    for itemName, itemData in pairs(auraInfo) do
        if itemData.isActive and DONATE_ITEMS.aura[itemName] then
            if heroAura.itemName == itemName then return end
            if heroAura.modifier then 
                heroAura.modifier:Destroy()
                heroAura.modifier = nil
            end
            if heroAura.timer then
                Timers:RemoveTimer(heroAura.timer) 
                heroAura.timer = nil
            end
              
            local modifier = DONATE_ITEMS.aura[itemName].modifier
            heroAura.timer = Timers:CreateTimer(0.1, function()
                if hero:IsAlive() then
                    heroAura.modifier = hero:AddNewModifier(hero, nil, modifier, {})
                    heroAura.timer = nil
                    heroAura.itemName = itemName
                    return
                end
                return 0.1
            end)
            return
        end
    end

    if heroAura.modifier then heroAura.modifier:Destroy() end
    if heroAura.timer then Timers:RemoveTimer(heroAura.timer) end
    hero.donate.aura = {}
end

function DonateManager:TryChangeTitul(hero, titulInfo)
    local particleLeader = hero:Attribute_GetIntValue( "particleID", -1 )

    if particleLeader == -1 then return end

    for itemName, itemData in pairs(titulInfo) do
        if itemData.isActive and DONATE_ITEMS.titul[itemName] then
            local titul = DONATE_ITEMS.titul[itemName].particle

            if hero.donate.titul == titul then return end
            ParticleManager:DestroyParticle( particleLeader, true )
            ParticleManager:ReleaseParticleIndex(particleLeader)

            CAddonWarsong:AddLeaderParticle(hero)
            return
        end
    end

    if hero.donate.titul == DEFAULT_LEADER_PARTICLE then return end
    ParticleManager:DestroyParticle( particleLeader, true )
    ParticleManager:ReleaseParticleIndex(particleLeader)

    CAddonWarsong:AddLeaderParticle(hero)
end
  
function DonateManager:GetCurrentTitulParticle(playerId)
    local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 

    if  not (playerInfo and playerInfo.titul) then return nil end

    for itemName, itemData in pairs(playerInfo.titul) do
        if itemData.isActive and DONATE_ITEMS.titul[itemName] then
            local titul = DONATE_ITEMS.titul[itemName].particle
            hero.donate.titul = titul
            return titul
        end
    end

    return nil
end

function DonateManager:GetCurrentTeleportationEffect(hero)
    local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(hero:GetPlayerOwnerID())) 

    if not playerInfo then return nil end

    for itemName, itemData in pairs(playerInfo.teleportation_effect) do
        if itemData.isActive and DONATE_ITEMS.teleportation_effect[itemName] then
            return {particleStart = DONATE_ITEMS.teleportation_effect[itemName].particleStart, particleEnd = DONATE_ITEMS.teleportation_effect[itemName].particleEnd}
        end
    end

    return nil
end

function DonateManager:AddHeroPet(hero, petInfo)
    local heroPet = hero.donate.pet

    for itemName, itemData in pairs(petInfo) do
        if itemData.isActive and DONATE_ITEMS.pet[itemName] then    
            if heroPet.itemName == itemName then return end

            local item = DONATE_ITEMS.pet[itemName]
            local model = item.model

            if not heroPet.unit then 
                local pet = CreateUnitByName(
                    "npc_cosmetic_pet",
                    hero:GetAbsOrigin() + RandomVector(300), true,
                    hero, hero, hero:GetTeam()
                )
                heroPet.unit = pet
                heroPet.itemName = itemName

                pet:SetForwardVector(hero:GetForwardVector())
                local pet_modifier = pet:AddNewModifier(hero, nil, "modifier_donate_pet", {})
            end
            heroPet.unit:SetModel(model)
            heroPet.unit:SetOriginalModel(model)
       
            return
        end
    end

    if heroPet.unit then UTIL_Remove(heroPet.unit) end
    hero.donate.pet = {}
end

