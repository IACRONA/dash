-- Дебафф для босса, возрождённого на боковой линии. Уменьшает на одинаковый
-- процент: максимум HP, физ. броню, скорость атаки и весь исходящий урон
-- (и от автоатак, и от способностей). Процент берётся из game_settings:
-- BOSS_LANE_DEBUFF_PERCENT (по умолчанию 15).
require("settings/game_settings")

modifier_lane_boss_debuff = class({})

function modifier_lane_boss_debuff:IsHidden() return false end
function modifier_lane_boss_debuff:IsPurgable() return false end
function modifier_lane_boss_debuff:IsPurgableException() return false end
function modifier_lane_boss_debuff:IsDebuff() return false end
function modifier_lane_boss_debuff:RemoveOnDeath() return true end
function modifier_lane_boss_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_lane_boss_debuff:OnCreated(kv)
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	-- Берём актуальное значение из game_settings, фолбэк = 15%.
	local pct = tonumber(BOSS_LANE_DEBUFF_PERCENT) or 15
	self.reduction_pct = pct
	local reduction = pct / 100

	-- Считаем абсолютные значения один раз на основе базовых статов,
	-- чтобы потом выдавать их как фиксированные бонусы в геттерах.
	local baseHp    = parent:GetBaseMaxHealth()
	local baseArmor = parent:GetPhysicalArmorBaseValue()

	self.hp_bonus    = -math.floor(baseHp * reduction)
	self.armor_bonus = -(baseArmor * reduction)

	-- Фиксируем текущее здоровье на новом максимуме, чтобы босс появлялся
	-- на линии с «полным» пулом, а не с переполнением через прошлый максимум.
	parent:SetHealth(math.max(1, baseHp + self.hp_bonus))
end

function modifier_lane_boss_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_lane_boss_debuff:GetModifierHealthBonus()
	return self.hp_bonus or 0
end

function modifier_lane_boss_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_bonus or 0
end

function modifier_lane_boss_debuff:GetModifierAttackSpeedBonus_Constant()
	-- -N BAT даёт примерно -N% к скорости атаки.
	return -(self.reduction_pct or 15)
end

function modifier_lane_boss_debuff:GetModifierTotalDamageOutgoing_Percentage()
	-- Применяется к физическому, магическому и чистому урону от любых источников
	-- (автоатаки + способности) — покрывает требование про урон абилок.
	return -(self.reduction_pct or 15)
end
