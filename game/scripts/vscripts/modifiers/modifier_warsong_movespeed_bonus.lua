modifier_warsong_movespeed_bonus = class({})
function modifier_warsong_movespeed_bonus:IsPurgable() return false end
function modifier_warsong_movespeed_bonus:IsHidden() return true end
function modifier_warsong_movespeed_bonus:RemoveOnDeath() return false end
function modifier_warsong_movespeed_bonus:IsPurgeException() return false end
function modifier_warsong_movespeed_bonus:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
end

function modifier_warsong_movespeed_bonus:GetModifierMoveSpeedBonus_Constant()
    return (self:GetParent():HasModifier("modifier_item_flag_carrier") or self:GetParent():HasModifier("modifier_item_flag_carrier_both")) and FLAG_BONUS_SPEED or BONUS_SPEED
end

function modifier_warsong_movespeed_bonus:GetModifierMoveSpeed_Limit()
    if self:GetParent():HasModifier("modifier_spirit_breaker_charge_of_darkness") then return end
    if self:GetParent():HasModifier("modifier_spirit_breaker_bull_rush") then return end
    return (self:GetParent():HasModifier("modifier_item_flag_carrier") or self:GetParent():HasModifier("modifier_item_flag_carrier_both")) and FLAG_CARRIER_MAX_SPEED or MAX_SPEED
end