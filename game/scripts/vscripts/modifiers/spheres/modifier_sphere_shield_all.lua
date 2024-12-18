LinkLuaModifier('modifier_sphere_shield_all_buff', 'modifiers/spheres/modifier_sphere_shield_all', LUA_MODIFIER_MOTION_NONE)

modifier_sphere_shield_all = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    } end,
})
 
function modifier_sphere_shield_all:OnCreated(event)
	local parent = self:GetParent()
 	
 	if IsClient() then return end
    self.modif = parent:AddNewModifier(parent, nil, "modifier_sphere_shield_all_buff", {})
end

function modifier_sphere_shield_all:OnStackCountChanged()
	local stack = self:GetStackCount()

	self.modif:SetStackCount(SPHERE_SHIELD_ALL * stack)
	self.modif.maxShield = SPHERE_SHIELD_ALL * stack
end

modifier_sphere_shield_all_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    } end,
})
 
function modifier_sphere_shield_all_buff:OnCreated(event)
	local parent = self:GetParent()

	self.maxShield = SPHERE_SHIELD_ALL  


	if not IsServer() then return end
	self:SetStackCount(SPHERE_SHIELD_ALL * parent:FindModifierByName("modifier_sphere_shield_all"):GetStackCount())
 end

function modifier_sphere_shield_all_buff:GetModifierIncomingDamageConstant(params)
	if IsClient() then 
	  if params.report_max then 
	    return self.maxShield 
	  else 
	    return self:GetStackCount()
	  end 
	end
	if not IsServer() then return end
	if self.timerDamage then
	     Timers:RemoveTimer(self.timerDamage) 
	     self.timerDamage = nil
	end
	local parent = self:GetParent()
	self.timerDamage = Timers:CreateTimer(SPHERE_SHIELD_ALL_COOLDOWN, function()
		local stackCount = parent:FindModifierByName("modifier_sphere_shield_all"):GetStackCount()
		self.maxShield = SPHERE_SHIELD_ALL * stackCount
		self:SetStackCount(self.maxShield) 
		self.timerDamage = nil
	end)
	if self:GetStackCount() == 0 then return end

	if self:GetStackCount() > params.damage then
	    self:SetStackCount(self:GetStackCount() - params.damage)
	    local i = params.damage
	    return -i
	else
	    local i = self:GetStackCount()
	    return -i
	end
end

