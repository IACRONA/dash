modifier_custom_wear = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_EVENT_ON_MODEL_CHANGED
    } end,
})

function modifier_custom_wear:OnModelChanged()
	local parent = self:GetParent()
	local canHideItems = parent.baseModel ~= parent:GetModelName()

	for _,item in ipairs(parent.wearItems) do
		if canHideItems then 
			item:AddEffects(EF_NODRAW)
		else
			item:RemoveEffects(EF_NODRAW)
		end
 	end
end