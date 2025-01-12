require('donate/donate_items')

if DonateManager == nil then
	DonateManager = class({})
end

function DonateManager:InitHero(hero)
    local playerId = hero:GetPlayerOwnerID()
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 
    if not playerInfo then return end
    hero.donate = {
        aura = {}
    }

    self:AddHeroAura(hero, playerInfo.aura)
end

function DonateManager:CheckForChangeDonate(playerId)
	local playerInfo = CustomNetTables:GetTableValue("player_info", tostring(playerId)) 
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    
    if not hero then return end

    self:AddHeroAura(hero, playerInfo.aura)
end

function DonateManager:AddHeroAura(hero, auraInfo)
    local heroAura = hero.donate.aura
    for itemName, itemData in pairs(auraInfo) do
        if itemData.isActive and DONATE_ITEMS.aura[itemName] then
            if heroAura.modifier then 
                heroAura.modifier:Destroy()
                heroAura.modifier = nil
            end
            if heroAura.timer thenи 
                Timers:RemoveTimer(heroAura.timer) 
                heroAura.timer = nil
            end
            
            local modifier = DONATE_ITEMS.aura[itemName].modifier
            heroAura.timer = Timers:CreateTimer(0.1, function()
                if hero:IsAlive() then
                    heroAura.modifier = hero:AddNewModifier(hero, nil, modifier, {})
                    heroAura.timer = nil
                    return
                end
                return 0.1
            end)

        end
    end
end