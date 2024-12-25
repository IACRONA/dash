modifier_for_middle_towers_for_unvulbure = modifier_for_middle_towers_for_unvulbure or {}
function modifier_for_middle_towers_for_unvulbure:IsHidden() return true end
function modifier_for_middle_towers_for_unvulbure:OnCreated()
    if self:GetParent():HasModifier("modifier_invulnerable") then self:Destroy() end
end
function modifier_for_middle_towers_for_unvulbure:IsPurgable() return false end
function modifier_for_middle_towers_for_unvulbure:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true, 
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
end
function modifier_for_middle_towers_for_unvulbure:DeclareFunctions() return {MODIFIER_PROPERTY_AVOID_DAMAGE} end
function modifier_for_middle_towers_for_unvulbure:GetModifierAvoidDamage( params ) return 1 end
function modifier_for_middle_towers_for_unvulbure:CanParentBeAutoAttacked() return false end