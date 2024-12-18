require("modifiers/generic/filter_special_values")

modifier_spell_amp_magical = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsPurgeException 		= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
   		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    } end,
})

function modifier_spell_amp_magical:OnCreated( params )
	self.netTable = CustomNetTables:GetTableValue("abilities_damage", "abilities") 
	self.abilities = {}
end

function modifier_spell_amp_magical:GetModifierOverrideAbilitySpecial( params )
	local ability = params.ability
	if self:GetParent() == nil or ability == nil or ability:IsItem() then return 0 end
	local name = ability:GetName()
	local isChangeAbility = self.abilities[name]

	if isChangeAbility == nil then 
		local abilityInTable = self.netTable[name]
		if not abilityInTable then return 0 end
		local isMagicalDamage = abilityInTable.damage == "DAMAGE_TYPE_MAGICAL"
		self.abilities[name] = isMagicalDamage
		return isMagicalDamage and 1 or 0
	elseif isChangeAbility then
		return 1
	else 
		return 0
	end
 end

function modifier_spell_amp_magical:GetModifierOverrideAbilitySpecialValue( params )
	local ability = params.ability
	local specialValue = params.ability_special_value
	local specialLevel = params.ability_special_level
	local baseValue = ability:GetLevelSpecialValueNoOverride( specialValue, specialLevel )

 	local multiple = (self:GetStackCount()/100 + 1)

	return IsDamageSpecialValue(specialValue) and baseValue * multiple or baseValue
end
 