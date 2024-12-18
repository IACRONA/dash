modifier_sphere_spell_radius = class({
 	IsHidden 				= function(self) return true end,
 	IsPurgable 				= function(self) return false end,
 	IsBuff                  = function(self) return true end,
 	RemoveOnDeath 			= function(self) return false end,
})

function modifier_sphere_spell_radius:OnStackCountChanged()
 	if IsClient() then return end

	local stack = self:GetStackCount()

	self.modifier:SetStackCount(SPHERE_SPELL_RADIUS * stack)	 
end


function modifier_sphere_spell_radius:OnCreated()
 	if IsClient() then return end

 	self.modifier = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_spell_radius", {}) 
end

 