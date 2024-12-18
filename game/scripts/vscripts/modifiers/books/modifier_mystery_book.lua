modifier_mystery_book = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsPurgeException 		= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    } end,
})

function modifier_mystery_book:OnStackCountChanged()
	if IsClient() then return end
	
	local parent = self:GetParent()
	parent:CalculateStatBonus(false)
end

function modifier_mystery_book:OnCreated()
	local bookStats = {}
	for _,book in pairs(CustomNetTables:GetTableValue("books_shop", "books")) do
		if book.modifier == self:GetName() then 
			bookStats = book.values
		end
	end

	self.bonusSpellAmp = bookStats.bonus_spell_amp
end

function modifier_mystery_book:GetModifierSpellAmplify_Percentage()
	return self.bonusSpellAmp * self:GetStackCount()
end
 