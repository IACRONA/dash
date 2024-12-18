LinkLuaModifier("modifier_fountain_aura_movespeed", "abilities/fountain_aura_movespeed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fountain_aura_movespeed_buff", "abilities/fountain_aura_movespeed", LUA_MODIFIER_MOTION_NONE)

fountain_aura_movespeed = class({})

function fountain_aura_movespeed:Spawn()
    if not IsServer() then return end
    if self and not self:IsNull() then
	   self:SetLevel(1)
    end
end

function fountain_aura_movespeed:GetIntrinsicModifierName()
	return "modifier_fountain_aura_movespeed"
end

modifier_fountain_aura_movespeed = class({})

function modifier_fountain_aura_movespeed:IsHidden() return true end

function modifier_fountain_aura_movespeed:IsAura()
    return true
end

function modifier_fountain_aura_movespeed:GetModifierAura()
    return "modifier_fountain_aura_movespeed_buff"
end

function modifier_fountain_aura_movespeed:GetAuraRadius()
    return FOUNTAIN_AURA_RADIUS
end

function modifier_fountain_aura_movespeed:GetAuraDuration()
    return FOUNTAIN_DELAY_MODIFIER
end

function modifier_fountain_aura_movespeed:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_fountain_aura_movespeed:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_fountain_aura_movespeed:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

modifier_fountain_aura_movespeed_buff = class({})

function modifier_fountain_aura_movespeed_buff:GetTexture() return "filler_ability" end

function modifier_fountain_aura_movespeed_buff:OnCreated()
    if not IsServer() then return end
    print("Пурдж")
    self:GetParent():Purge(false, true, false, true, true)
end

function modifier_fountain_aura_movespeed_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function modifier_fountain_aura_movespeed_buff:GetModifierMoveSpeedBonus_Constant()
	return FOUNTAIN_BONUS_MOVESPEED
end