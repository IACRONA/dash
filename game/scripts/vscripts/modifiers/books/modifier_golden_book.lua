modifier_golden_book = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsPurgeException 		= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})

function modifier_golden_book:OnStackCountChanged()
	if IsClient() then return end

	local parent = self:GetParent()
	local modifierMagical = parent:AddNewModifier(parent, nil, "modifier_spell_amp_magical", {})
	modifierMagical:SetStackCount(modifierMagical:GetStackCount() + self.magicalDamage)
	local modifierPure = parent:AddNewModifier(parent, nil, "modifier_spell_amp_pure", {})
	modifierPure:SetStackCount(modifierPure:GetStackCount() + self.pureDamage)
end

function modifier_golden_book:OnCreated()
	local bookStats = {}
	for _,book in pairs(CustomNetTables:GetTableValue("books_shop", "books")) do
		if book.modifier == self:GetName() then 
			bookStats = book.values
		end
	end

	self.magicalDamage = bookStats.bonus_magical_damage_pct
	self.pureDamage = bookStats.bonus_pure_damage_pct
end
