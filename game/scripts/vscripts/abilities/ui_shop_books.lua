LinkLuaModifier('modifier_ui_shop_books_aura', 'abilities/ui_shop_books', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_ui_shop_books', 'abilities/ui_shop_books', LUA_MODIFIER_MOTION_NONE)
 
ui_shop_books = class({})

function ui_shop_books:GetIntrinsicModifierName()
	return "modifier_ui_shop_books_aura"
end

modifier_ui_shop_books_aura = class({
	IsHidden 				= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetModifierAura 		= function(self) return "modifier_ui_shop_books" end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("radius") end,
	GetAuraDuration 		= function(self) return 0.05 end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO end,
	DeclareFunctions 		= function(self) return 
		{
			MODIFIER_EVENT_ON_ORDER,
		}
	end,
    CheckState      		= function(self) return 
    	{
    		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
    		[MODIFIER_STATE_OUT_OF_GAME  ] = true,
    	} 
	end,
})

function modifier_ui_shop_books_aura:OnOrder(kv)
	if(not IsServer()) then
		return
	end
	local parent = self:GetParent()

	local unit = kv.unit
	if unit.shopTimer and kv.target ~= parent then

	    local orderArray = { DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	      DOTA_UNIT_ORDER_MOVE_TO_TARGET,
	      DOTA_UNIT_ORDER_ATTACK_MOVE,
	      DOTA_UNIT_ORDER_ATTACK_TARGET,
	      DOTA_UNIT_ORDER_STOP,
	      DOTA_UNIT_ORDER_HOLD_POSITION,
	    }
	        for _,order in ipairs(orderArray) do
	        	if kv.order_type == order then 
	        		Timers:RemoveTimer(unit.shopTimer)
	        		unit.shopTimer = nil
	        	end
	        end
	end

	if(kv.target ~= parent) then
		return
	end


	if(kv.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET
	or kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET) then
 		Timers:CreateTimer(0.03, function()
		unit:Stop()
		    Timers:CreateTimer(0.03, function()
		    	ExecuteOrderFromTable({
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, 
					Position = kv.target:GetAbsOrigin(),
					Queue = false,
				})
		    	if unit:IsRealHero() then 
		    		if unit.shopTimer then Timers:RemoveTimer(unit.shopTimer) end
			    	unit.shopTimer = Timers:CreateTimer(0.01, function()
				    	local difference = (parent:GetAbsOrigin() - unit:GetAbsOrigin())
		      			local distance = difference:Length()

		      			if distance < self:GetAbility():GetSpecialValueFor("radius") then
		      				CustomGameEventManager:Send_ServerToPlayer(unit:GetPlayerOwner(), 'show_books_shop',  {}) 
		      				return
		      			end
		      			return 0.25      			
			    	end)
		    	end
			end)
		end)  
	end
end 
 
modifier_ui_shop_books = class({
	IsHidden 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
})
 

function modifier_ui_shop_books:OnDestroy()
	if IsClient() then return end

	CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), 'hide_books_shop',  {})
end

 