special_bonus_riki_second_life_unlock = class({})
LinkLuaModifier("modifier_special_bonus_riki_second_life", "abilities/heroes/riki/special_bonus_riki_second_life_unlock", LUA_MODIFIER_MOTION_NONE)

function special_bonus_riki_second_life_unlock:GetIntrinsicModifierName()
    return "modifier_special_bonus_riki_second_life"
end

modifier_special_bonus_riki_second_life = class({})

function modifier_special_bonus_riki_second_life:IsHidden() return true end
function modifier_special_bonus_riki_second_life:IsPurgable() return false end
function modifier_special_bonus_riki_second_life:RemoveOnDeath() return false end

function modifier_special_bonus_riki_second_life:OnCreated()
    if not IsServer() then return end
    local hero = self:GetParent()
    local ability = hero:FindAbilityByName("riki_second_life")
    if ability and ability:GetLevel() < 1 then
        ability:SetLevel(1)
    end
end

return special_bonus_riki_second_life_unlock
