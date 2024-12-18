LinkLuaModifier('modifier_lina_fiery_soul_custom', 'abilities/heroes/lina/lina_fiery_soul_custom', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_lina_fiery_soul_custom_buff', 'abilities/heroes/lina/lina_fiery_soul_custom', LUA_MODIFIER_MOTION_NONE)
 
lina_fiery_soul_custom = class({})

function lina_fiery_soul_custom:GetIntrinsicModifierName()
	return "modifier_lina_fiery_soul_custom"
end

modifier_lina_fiery_soul_custom = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    } end,
})
 
function modifier_lina_fiery_soul_custom:GetModifierTotalDamageOutgoing_Percentage(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local ability = event.inflictor

	if attacker == self:GetParent() and event.inflictor and (event.inflictor:GetName() == "lina_dragon_slave" or event.inflictor:GetName() == "lina_light_strike_array") then 
	    if RollPercentage(ability:GetSpecialValueFor("crit_2x") + (parent.bonusLinaCrit or 0)) then
	    	local pyrablast = parent:FindAbilityByName("lina_pyrablast")
			if pyrablast then 
				pyrablast:ProcPyromanic()
			end

	    	return 100
	    end  
	end
end

function modifier_lina_fiery_soul_custom:OnAbilityExecuted(event)
	if IsClient() then return end 

	local unit = event.unit
    local parent = self:GetParent()

    if unit ~= parent then return end

    if event.ability:IsItem() then return  end
 
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local maxStack = ability:GetSpecialValueFor("max_stack")
	local modifier = parent:AddNewModifier(parent, ability, "modifier_lina_fiery_soul_custom_buff", {duration = ability:GetSpecialValueFor("duration")})

	modifier:SetStackCount(math.min(modifier:GetStackCount() + 1, maxStack))
end

           


modifier_lina_fiery_soul_custom_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,    }
	end,
})

function modifier_lina_fiery_soul_custom_buff:OnStackCountChanged()
	self:GetParent().bonusLinaCrit = self:GetStackCount() * self.bonusCrist
end


function modifier_lina_fiery_soul_custom_buff:OnCreated()
	self.bonusCrist = self:GetAbility():GetSpecialValueFor("bonus_crit")
	self:GetParent().bonusLinaCrit = 0
end

function modifier_lina_fiery_soul_custom_buff:OnDestroy()
	self:GetParent().bonusLinaCrit = 0
end

function modifier_lina_fiery_soul_custom:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") * self:GetStackCount()
end

function modifier_lina_fiery_soul_custom:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_move_speed_pct") * self:GetStackCount()
end
