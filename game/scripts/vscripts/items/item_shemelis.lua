LinkLuaModifier("modifier_item_shemelis", "items/item_shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_passive", "items/item_shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_time_lapse", "items/item_shemelis", LUA_MODIFIER_MOTION_NONE)

item_shemelis = class({})

function item_shemelis:GetIntrinsicModifierName()
	return "modifier_item_shemelis_passive"
end

function item_shemelis:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster
	
	-- Rewind time to 2 seconds ago
	local time_lapse_distance = caster:GetAbsOrigin() - caster.position_at_time_lapse_start
	
	-- Store time lapse modifier
	caster:AddNewModifier(caster, self, "modifier_item_shemelis_time_lapse", {duration = 2})
	
	self:EndCooldown()
end

--------------------------------------------------------------------------------

modifier_item_shemelis_passive = class({})

function modifier_item_shemelis_passive:IsHidden()
	return true
end

function modifier_item_shemelis_passive:IsPurgable()
	return false
end

function modifier_item_shemelis_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_shemelis_passive:OnCreated()
	local parent = self:GetParent()
	local item = self:GetAbility()
	
	if IsServer() then
		self.position_history = {}
		self.velocity_history = {}
		self.time_index = 0
		
		-- Initialize history storage
		for i = 1, 120 do -- Store up to 120 ticks (4 seconds at 30 ticks/sec)
			self.position_history[i] = parent:GetAbsOrigin()
			self.velocity_history[i] = parent:GetForwardVector()
		end
		
		-- Update history every tick
		self:StartIntervalThink(0.016) -- ~60 ticks per second
	end
end

function modifier_item_shemelis_passive:OnIntervalThink()
	if not IsServer() then return end
	
	local parent = self:GetParent()
	
	-- Shift history
	for i = 120, 2, -1 do
		self.position_history[i] = self.position_history[i-1]
		self.velocity_history[i] = self.velocity_history[i-1]
	end
	
	-- Store current position
	self.position_history[1] = parent:GetAbsOrigin()
	self.velocity_history[1] = parent:GetForwardVector()
end

function modifier_item_shemelis_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_item_shemelis_passive:GetModifierEvasion()
	return 10
end

function modifier_item_shemelis_passive:GetModifierSpellAmplify_Percentage()
	return 8
end

function modifier_item_shemelis_passive:GetModifierBaseAttack_BonusDamage()
	return 20
end

function modifier_item_shemelis_passive:GetModifierAttackSpeedBonus_Constant()
	return 15
end

function modifier_item_shemelis_passive:OnTakeDamage(params)
	if not IsServer() then return end
	
	local parent = self:GetParent()
	if params.unit ~= parent then return end
	
	local damage = params.damage
	local damage_type = params.damage_type
	
	-- 5% vampirism from physical and magical damage
	if damage_type == DAMAGE_TYPE_PHYSICAL or damage_type == DAMAGE_TYPE_MAGICAL then
		local heal_amount = damage * 0.05
		parent:Heal(heal_amount, nil)
	end
	
	-- 5% spell reflect chance
	if RollPercentage(5) then
		-- Reflect spell back
		if params.inflictor then
			-- TODO: Implement spell reflection
		end
	end
end

--------------------------------------------------------------------------------

modifier_item_shemelis_time_lapse = class({})

function modifier_item_shemelis_time_lapse:IsHidden()
	return false
end

function modifier_item_shemelis_time_lapse:IsPurgable()
	return false
end

function modifier_item_shemelis_time_lapse:OnCreated()
	if not IsServer() then return end
	
	local parent = self:GetParent()
	local item = self:GetAbility()
	
	if item and item.position_history then
		-- Go back 2 seconds (120 ticks)
		local index = 120
		if index <= #item.position_history then
			parent:SetAbsOrigin(item.position_history[index])
		end
	end
end
