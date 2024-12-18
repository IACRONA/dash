modifier_spell_radius = class({
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
 
function modifier_spell_radius:OnCreated( params )
	self.netTable = CustomNetTables:GetTableValue("abilities_radius", "abilities") 

	self.abilities = {}
end

function modifier_spell_radius:GetModifierOverrideAbilitySpecial( params )
	local ability = params.ability
	if self:GetParent() == nil or ability == nil or ability:IsItem() then return 0 end
	local name = ability:GetName()
	local isChangeAbility = self.abilities[name]

	if isChangeAbility == nil then 
		local abilityInTable = self.netTable[name]

		if not abilityInTable then return 0 end
		self.abilities[name] = abilityInTable
		return 1
	elseif isChangeAbility then
		return 1
	else 
		return 0
	end
 end

function modifier_spell_radius:GetModifierOverrideAbilitySpecialValue( params )
	local ability = params.ability
	local abilityName = ability:GetName()
	local specialValue = params.ability_special_value
	local canChangeValues = self.abilities[abilityName][specialValue]

	local specialLevel = params.ability_special_level
	local baseValue = ability:GetLevelSpecialValueNoOverride( specialValue, specialLevel )

	return canChangeValues and baseValue + self:GetStackCount()  or baseValue
end
 
 