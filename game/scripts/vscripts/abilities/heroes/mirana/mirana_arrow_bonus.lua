LinkLuaModifier('modifier_mirana_arrow_bonus', 'abilities/heroes/mirana/mirana_arrow_bonus', LUA_MODIFIER_MOTION_NONE)

mirana_arrow_bonus = class({})

 
function mirana_arrow_bonus:Spawn()
	if IsClient() then return end

	self:SetLevel(1)
end


function mirana_arrow_bonus:GetIntrinsicModifierName()
	return "modifier_mirana_arrow_bonus"
end

modifier_mirana_arrow_bonus = class({
	IsHidden 				= function(self) return true end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    } end,
})

function modifier_mirana_arrow_bonus:GetModifierTotalDamageOutgoing_Percentage(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local ability = event.inflictor

	if attacker == self:GetParent() and ability and event.inflictor:GetName() == "mirana_arrow" then 
  		if RollPercentage(ability:GetSpecialValueFor("chance_crit_3x")) then
	    	return 200
	    end

	    if RollPercentage(ability:GetSpecialValueFor("chance_crit_2x")) then
	    	return 100
	    end  
	end
end