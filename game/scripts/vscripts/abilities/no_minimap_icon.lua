LinkLuaModifier("modifier_no_minimap_icon", "abilities/no_minimap_icon", LUA_MODIFIER_MOTION_NONE)

no_minimap_icon = class({})

function no_minimap_icon:GetIntrinsicModifierName()
    return "modifier_no_minimap_icon"
end

modifier_no_minimap_icon = class({})

function modifier_no_minimap_icon:IsHidden()
    return true
end

function modifier_no_minimap_icon:CheckState()
    return {
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
end