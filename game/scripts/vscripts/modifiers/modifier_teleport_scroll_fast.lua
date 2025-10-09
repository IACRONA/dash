require("settings/game_settings")

modifier_teleport_scroll_fast = class{}
function modifier_teleport_scroll_fast:IsHidden() return true end
function modifier_teleport_scroll_fast:IsPurgable() return false end
function modifier_teleport_scroll_fast:RemoveOnDeath() return false end
function modifier_teleport_scroll_fast:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_teleport_scroll_fast:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_teleport_scroll_fast:GetModifierOverrideAbilitySpecial(data)
    -- if data.ability:GetAbilityName() == "item_tp_scroll_custom" and data.ability_special_value == "AbilityCooldown" then
    --     return 1
    -- end
end

function modifier_teleport_scroll_fast:GetModifierOverrideAbilitySpecialValue(data)
    -- if data.ability:GetAbilityName() == "item_tp_scroll_custom" and data.ability_special_value == "AbilityCooldown" then
    --     return TELEPORT_COOLDOWN
    -- end
end