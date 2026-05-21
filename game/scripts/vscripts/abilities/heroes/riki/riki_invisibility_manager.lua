riki_invisibility_manager = class({})
LinkLuaModifier("modifier_riki_invisibility_manager", "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_break_invis",          "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_invis_particle",       "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)

local SWAP_PAIRS = {
    { normal = "riki_smoke_screen",        stealth = "riki_sleeping_dart" },
    { normal = "riki_blink_strike",        stealth = "riki_stun_strike"   },
    { normal = "riki_tricks_of_the_trade", stealth = "riki_venous_strike" },
    { normal = "riki_backstab",            stealth = "riki_second_life"   },
}

function riki_invisibility_manager:GetIntrinsicModifierName()
    return "modifier_riki_invisibility_manager"
end

function riki_invisibility_manager:Spawn()
    if not IsServer() then return end
    self:SetLevel(1)
end

--------------------------------------------------------------------------------

modifier_riki_invisibility_manager = class({})

function modifier_riki_invisibility_manager:IsHidden() return true end
function modifier_riki_invisibility_manager:IsPurgable() return false end
function modifier_riki_invisibility_manager:RemoveOnDeath() return false end

function modifier_riki_invisibility_manager:OnCreated()
    if not IsServer() then return end

    self.is_in_stealth = false

    Timers:CreateTimer(0.1, function()
        if not IsValidEntity(self:GetParent()) then return end
        local hero = self:GetParent()
        for _, pair in ipairs(SWAP_PAIRS) do
            local stealth = hero:FindAbilityByName(pair.stealth)
            if stealth then stealth:SetHidden(true) end
            local normal = hero:FindAbilityByName(pair.normal)
            if normal then normal:SetHidden(false) end
        end
        self:SyncAbilityLevels(hero)
        self:StartIntervalThink(0.2)
    end)

    self.learn_listener = ListenToGameEvent("dota_player_learned_ability", function(event)
        if not IsValidEntity(self:GetParent()) then return end
        local hero = self:GetParent()
        if hero:GetPlayerOwnerID() ~= event.PlayerID then return end
        self:SyncAbilityLevels(hero)
    end, nil)
end

function modifier_riki_invisibility_manager:OnDestroy()
    if not IsServer() then return end
    if self.learn_listener then
        StopListeningToGameEvent(self.learn_listener)
        self.learn_listener = nil
    end
end

function modifier_riki_invisibility_manager:OnIntervalThink()
    if not IsServer() then return end

    local hero = self:GetParent()
    local is_invisible = hero:IsInvisible()

    if self.is_in_stealth == is_invisible then return end
    self.is_in_stealth = is_invisible

    if is_invisible then
        self:SwapToStealth(hero)
    else
        self:SwapToNormal(hero)
    end
end

function modifier_riki_invisibility_manager:DeclareFunctions()
    return {}
end

function modifier_riki_invisibility_manager:SyncAbilityLevels(hero)
    for _, pair in ipairs(SWAP_PAIRS) do
        local normal = hero:FindAbilityByName(pair.normal)
        local stealth = hero:FindAbilityByName(pair.stealth)
        if normal and stealth then
            local nlvl = normal:GetLevel()
            local slvl = stealth:GetLevel()
            if nlvl > slvl then
                stealth:SetLevel(nlvl)
            elseif slvl > nlvl then
                normal:SetLevel(slvl)
            end
        end
    end
end

function modifier_riki_invisibility_manager:SwapToStealth(hero)
    for _, pair in ipairs(SWAP_PAIRS) do
        hero:SwapAbilities(pair.normal, pair.stealth, false, true)
    end
    hero:AddNewModifier(hero, self:GetAbility(), "modifier_riki_invis_particle", {})
    if hero.wearItems then
        for _, item in ipairs(hero.wearItems) do
            if item and not item:IsNull() then
                item:AddEffects(EF_NODRAW)
            end
        end
    end
end

function modifier_riki_invisibility_manager:SwapToNormal(hero)
    for _, pair in ipairs(SWAP_PAIRS) do
        hero:SwapAbilities(pair.stealth, pair.normal, false, true)
    end
    hero:RemoveModifierByName("modifier_riki_invis_particle")
    if hero.wearItems then
        for _, item in ipairs(hero.wearItems) do
            if item and not item:IsNull() then
                item:RemoveEffects(EF_NODRAW)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Invis particle: висит пока Рики в инвизе
--------------------------------------------------------------------------------

modifier_riki_invis_particle = class({})

function modifier_riki_invis_particle:IsHidden() return true end
function modifier_riki_invis_particle:IsPurgable() return false end
function modifier_riki_invis_particle:RemoveOnDeath() return true end

function modifier_riki_invis_particle:OnCreated()
    if not IsClient() then return end
    local parent = self:GetParent()
    self.fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_riki/riki_ambient_invis.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        parent
    )
    ParticleManager:SetParticleControlEnt(self.fx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)
end

function modifier_riki_invis_particle:OnDestroy()
    if not IsClient() then return end
    if self.fx then
        ParticleManager:DestroyParticle(self.fx, false)
        ParticleManager:ReleaseParticleIndex(self.fx)
        self.fx = nil
    end
end

function modifier_riki_invis_particle:DeclareFunctions() return {} end

--------------------------------------------------------------------------------
-- Break invis: форсирует выход из инвиза на N секунд (используется для 2/3 скиллов)
--------------------------------------------------------------------------------

modifier_riki_break_invis = class({})

function modifier_riki_break_invis:IsHidden() return true end
function modifier_riki_break_invis:IsPurgable() return false end
function modifier_riki_break_invis:RemoveOnDeath() return true end

function modifier_riki_break_invis:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end

function modifier_riki_break_invis:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_riki_break_invis:DeclareFunctions() return {} end

return riki_invisibility_manager
