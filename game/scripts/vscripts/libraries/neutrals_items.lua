function CAddonWarsong:InitNeutralItems()
    Timers:CreateTimer(1, function()
            self:GiveNeutralsItemsForPlayers()
        return 1
    end)
end


function CAddonWarsong:GiveNeutralsItemsForPlayers()
    local nTime = GameRules:GetDOTATime(false, false)

    local nNextTier = (self.nLastTierDropped or 0) + 1
    local nTierTiming = NEUTRAL_ITEM_TIMINGS['TIER_' .. nNextTier]

    if nTierTiming and nTime >= nTierTiming then
        self.nLastTierDropped = nNextTier
        for _, entity in pairs( HeroList:GetAllHeroes() ) do
            if not entity:IsNull() and entity:IsRealHero() and not entity:HasModifier("modifier_monkey_king_fur_army_soldier") and not entity:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") and not entity:IsClone() and not entity:IsTempestDouble() then
                -- local neutral_item_name = "item_tier"..nNextTier.."_token"

                local item = entity:AddItemByName("item_madstone_bundle")
            end
        end
    end
end