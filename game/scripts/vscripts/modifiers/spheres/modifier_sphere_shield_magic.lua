LinkLuaModifier('modifier_sphere_shield_magic_buff', 'modifiers/spheres/modifier_sphere_shield_magic', LUA_MODIFIER_MOTION_NONE)

modifier_sphere_shield_magic = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    } end,
})
 
function modifier_sphere_shield_magic:OnCreated(event)
	local parent = self:GetParent()
 	
 	if IsClient() then return end
    self.modif = parent:AddNewModifier(parent, nil, "modifier_sphere_shield_magic_buff", {})
end

function modifier_sphere_shield_magic:OnStackCountChanged()
	local stack = self:GetStackCount()

	self.modif:SetStackCount(SPHERE_SHIELD_MAGICAL * stack)
	self.modif.maxShield = SPHERE_SHIELD_MAGICAL * stack
end

modifier_sphere_shield_magic_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    } end,
})
 
function modifier_sphere_shield_magic_buff:OnCreated(event)
	local parent = self:GetParent()

	self.maxShield = SPHERE_SHIELD_MAGICAL  


	if not IsServer() then return end
	self:SetStackCount(SPHERE_SHIELD_MAGICAL * parent:FindModifierByName("modifier_sphere_shield_magic"):GetStackCount())
 end

function modifier_sphere_shield_magic_buff:GetModifierIncomingSpellDamageConstant(params)
	if IsClient() then 
	  if params.report_max then 
	    return self.maxShield 
	  else 
	    return self:GetStackCount()
	  end 
	end
end



function modifier_sphere_shield_magic_buff:GetModifierIncomingDamageConstant(params)
	if not IsServer() then return end
	if self.timerDamage then
	     Timers:RemoveTimer(self.timerDamage) 
	     self.timerDamage = nil
	end
	local parent = self:GetParent()
	self.timerDamage = Timers:CreateTimer(SPHERE_SHIELD_MAGICAL_COOLDOWN, function()
		local stackCount = parent:FindModifierByName("modifier_sphere_shield_magic"):GetStackCount()
		self.maxShield = SPHERE_SHIELD_MAGICAL * stackCount
		self:SetStackCount(self.maxShield) 
		self.timerDamage = nil
	end)
	if self:GetStackCount() == 0 then return end
	if params.damage_type == DAMAGE_TYPE_MAGICAL then 
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

