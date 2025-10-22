--------------------------------------------------------------------------------
-- Riki Invisibility Manager
-- Управляет сменой способностей при входе/выходе из невидимости
--------------------------------------------------------------------------------

riki_invisibility_manager = class({})
LinkLuaModifier("modifier_riki_invisibility_manager", "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_hidden_abilities", "abilities/heroes/riki/riki_invisibility_manager", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Инициализация
--------------------------------------------------------------------------------
function riki_invisibility_manager:GetIntrinsicModifierName()
    return "modifier_riki_invisibility_manager"
end

function riki_invisibility_manager:Spawn()
    if not IsServer() then return end
    self:SetLevel(1)
end

--------------------------------------------------------------------------------
-- Модификатор управления невидимостью
--------------------------------------------------------------------------------
modifier_riki_invisibility_manager = class({})

function modifier_riki_invisibility_manager:IsHidden()
    return true
end

function modifier_riki_invisibility_manager:IsPurgable()
    return false
end

function modifier_riki_invisibility_manager:RemoveOnDeath()
    return false
end

function modifier_riki_invisibility_manager:OnCreated()
    if not IsServer() then return end
    
    self.hero = self:GetParent()
    self.ability = self:GetAbility()
    
    -- Создаём скрытые способности заранее
    self:CreateHiddenAbilities()
    
    -- Флаг состояния
    self.is_in_stealth = false
    
    self:StartIntervalThink(0.1)
end

function modifier_riki_invisibility_manager:CreateHiddenAbilities()
    -- Добавляем все скрытые способности и сразу прячем их
    local hidden_abilities = {
        "riki_stun_strike",
        -- Здесь можно добавить остальные 3 способности для скрытого бара
    }
    
    for _, ability_name in ipairs(hidden_abilities) do
        local ability = self.hero:FindAbilityByName(ability_name)
        if not ability then
            ability = self.hero:AddAbility(ability_name)
            if ability then
                ability:SetHidden(true)
                ability:SetLevel(0)
            end
        end
    end
end

function modifier_riki_invisibility_manager:OnIntervalThink()
    if not IsServer() then return end
    
    local hero = self:GetParent()
    
    -- Проверяем, невидим ли герой
    local is_invisible = hero:IsInvisible()
    
    -- Если состояние изменилось
    if self.is_in_stealth ~= is_invisible then
        self.is_in_stealth = is_invisible
        
        if is_invisible then
            -- Входим в невидимость - меняем способности
            self:SwapToStealthAbilities()
            hero:AddNewModifier(hero, self:GetAbility(), "modifier_riki_hidden_abilities", {})
        else
            -- Выходим из невидимости - возвращаем обычные способности
            self:SwapToNormalAbilities()
            hero:RemoveModifierByName("modifier_riki_hidden_abilities")
        end
    end
end

function modifier_riki_invisibility_manager:SwapToStealthAbilities()
    local hero = self:GetParent()
    
    -- Получаем текущую первую способность (Smoke Screen)
    local smoke_ability = hero:FindAbilityByName("riki_smoke_screen")
    local stun_ability = hero:FindAbilityByName("riki_stun_strike")
    
    if smoke_ability and stun_ability then
        -- Синхронизируем уровень
        local current_level = smoke_ability:GetLevel()
        stun_ability:SetLevel(current_level)
        
        -- Меняем способности местами в UI
        hero:SwapAbilities(smoke_ability:GetAbilityName(), stun_ability:GetAbilityName(), false, true)
    end
end

function modifier_riki_invisibility_manager:SwapToNormalAbilities()
    local hero = self:GetParent()
    
    -- Возвращаем обычные способности
    local stun_ability = hero:FindAbilityByName("riki_stun_strike")
    local smoke_ability = hero:FindAbilityByName("riki_smoke_screen")
    
    if stun_ability and smoke_ability then
        -- Синхронизируем уровень обратно
        local current_level = stun_ability:GetLevel()
        smoke_ability:SetLevel(current_level)
        
        -- Меняем способности обратно
        hero:SwapAbilities(stun_ability:GetAbilityName(), smoke_ability:GetAbilityName(), false, true)
    end
end

--------------------------------------------------------------------------------
-- Модификатор для визуального отображения скрытых способностей
--------------------------------------------------------------------------------
modifier_riki_hidden_abilities = class({})

function modifier_riki_hidden_abilities:IsHidden()
    return false
end

function modifier_riki_hidden_abilities:IsPurgable()
    return false
end

function modifier_riki_hidden_abilities:GetTexture()
    return "riki_permanent_invisibility"
end

function modifier_riki_hidden_abilities:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_riki_hidden_abilities:OnTooltip()
    return 1
end

-- Обработка прокачки способностей
function modifier_riki_invisibility_manager:OnHeroLevelUp()
    if not IsServer() then return end
    
    -- Автоматическая синхронизация уровней при прокачке
    local hero = self:GetParent()
    local smoke_ability = hero:FindAbilityByName("riki_smoke_screen")
    local stun_ability = hero:FindAbilityByName("riki_stun_strike")
    
    if smoke_ability and stun_ability then
        -- Если прокачали smoke screen, синхронизируем со stun strike
        if smoke_ability:GetLevel() > stun_ability:GetLevel() then
            stun_ability:SetLevel(smoke_ability:GetLevel())
        end
    end
end

function modifier_riki_invisibility_manager:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_HERO_LEVEL_UP
    }
end

return riki_invisibility_manager
