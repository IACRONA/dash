LinkLuaModifier('modifier_sphere_shield_physic_buff', 'modifiers/spheres/modifier_sphere_shield_physic', LUA_MODIFIER_MOTION_NONE)

modifier_sphere_shield_physic = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    } end,
})
 
function modifier_sphere_shield_physic:OnCreated(event)
	local parent = self:GetParent()
 	
 	if IsClient() then return end
    self.modif = parent:AddNewModifier(parent, nil, "modifier_sphere_shield_physic_buff", {})
end

function modifier_sphere_shield_physic:OnStackCountChanged()
	local stack = self:GetStackCount()

	self.modif:SetStackCount(SPHERE_SHIELD_PHYSIC * stack)
	self.modif.maxShield = SPHERE_SHIELD_PHYSIC * stack
end

modifier_sphere_shield_physic_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    } end,
})
 
function modifier_sphere_shield_physic_buff:OnCreated(event)
	local parent = self:GetParent()

	self.maxShield = SPHERE_SHIELD_PHYSIC  


	if not IsServer() then return end
	self:SetStackCount(SPHERE_SHIELD_PHYSIC * parent:FindModifierByName("modifier_sphere_shield_physic"):GetStackCount())
 end

function modifier_sphere_shield_physic_buff:GetModifierIncomingPhysicalDamageConstant(params)
	if IsClient() then 
	  if params.report_max then 
	    return self.maxShield 
	  else 
	    return self:GetStackCount()
	  end 
	end
end

function modifier_sphere_shield_physic_buff:GetModifierIncomingDamageConstant(params)
	if not IsServer() then return end
	if self.timerDamage then
	     Timers:RemoveTimer(self.timerDamage) 
	     self.timerDamage = nil
	end
	local parent = self:GetParent()
	self.timerDamage = Timers:CreateTimer(SPHERE_SHIELD_PHYSIC_COOLDOWN, function()
		local stackCount = parent:FindModifierByName("modifier_sphere_shield_physic"):GetStackCount()
		self.maxShield = SPHERE_SHIELD_PHYSIC * stackCount
		self:SetStackCount(self.maxShield) 
		self.timerDamage = nil
	end)
	if self:GetStackCount() == 0 then return end
	if params.damage_type == DAMAGE_TYPE_PHYSICAL then 
		if self:GetStackCount() > params.damage then
		    self:SetStackCount(self:GetStackCount() - params.damage)
		    local i = params.damage
		    return -i
		else
		    local i = self:GetStackCount()
		    return -i
		end
	end
end

