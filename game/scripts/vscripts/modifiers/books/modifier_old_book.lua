modifier_old_book = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsPurgeException 		= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    } end,
})

function modifier_old_book:OnStackCountChanged()
	if IsClient() then return end
	
	local parent = self:GetParent()
	parent:CalculateStatBonus(false)
end

function modifier_old_book:OnCreated()
	local bookStats = {}
	for _,book in pairs(CustomNetTables:GetTableValue("books_shop", "books")) do
		if book.modifier == self:GetName() then 
			bookStats = book.values
		end
	end

	self.bonusStats = bookStats.bonus_all_stats
end

function modifier_old_book:GetModifierBonusStats_Strength()
	return self.bonusStats * self:GetStackCount()
end

function modifier_old_book:GetModifierBonusStats_Agility()
	return self.bonusStats * self:GetStackCount()
end

function modifier_old_book:GetModifierBonusStats_Intellect()
	return self.bonusStats * self:GetStackCount()
end