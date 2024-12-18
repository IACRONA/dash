LinkLuaModifier('modifier_ability_boss', 'abilities/ability_boss', LUA_MODIFIER_MOTION_NONE)

ability_boss = class({})

function ability_boss:Spawn()
	if IsClient() then return end 
	local caster = self:GetOwner() 	 
	if caster.respoint ~= nil then return nil end
	caster.respoint = caster:GetOrigin()  
	caster.fw = caster:GetForwardVector()
end

function ability_boss:GetIntrinsicModifierName()
	return "modifier_ability_boss"
end

modifier_ability_boss = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_EVENT_ON_DEATH,
    } end,
})

function modifier_ability_boss:OnStackCountChanged()
	if IsServer() then self:GetParent():CalculateGenericBonuses() end
end

function modifier_ability_boss:OnCreated()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	self.minutes = ability:GetSpecialValueFor("minutes")
	self.stats = ability:GetSpecialValueFor("stats")

	self.damage = 0
	self.health = parent:GetMaxHealth() * (self.stats/100)
	self.armor = parent:GetPhysicalArmorBaseValue() * (self.stats/100)
	self:OnIntervalThink()
	self:StartIntervalThink(1)
end

function modifier_ability_boss:OnIntervalThink()
	if IsClient() then return end
	local time = GameRules:GetDOTATime(false, false)
	local stack = (math.floor(time/60) / self.minutes)
	
	if self:GetStackCount() ~= stack then self:SetStackCount(stack) end
end

function modifier_ability_boss:GetModifierExtraHealthBonus()
	return self.health * self:GetStackCount()
end

function modifier_ability_boss:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end
 

function modifier_ability_boss:GetModifierPreAttack_BonusDamage()
	if self.damage == 0 then
		self.damage = self:GetParent():GetDamageMax() * (self.stats/100)
	end
 
	return self.damage * self:GetStackCount()
end
 
function modifier_ability_boss:OnDeath(event)
	local unit = event.unit

	if unit ~= self:GetParent() then return end
	local attacker = event.attacker
	local countDead = (unit.counter or 0) + 1
	local respawnTime = self:GetAbility():GetSpecialValueFor("respawn_time")
	local deathTimes = self:GetAbility():GetSpecialValueFor("death_times")
	local radiusReward = self:GetAbility():GetSpecialValueFor("radius_reward")

 	local unitName = unit:GetUnitName()
 	local respawnPoint = unit.respoint
 	local teamNumber = unit:GetTeamNumber()
 	local forwadVector = unit.fw

	local allies = FindUnitsInRadius( 
		unit:GetTeamNumber(),	 
		unit:GetAbsOrigin(),		 
		nil,	 
		radiusReward,	 
		DOTA_UNIT_TARGET_TEAM_ENEMY,	 
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	 
		FIND_CLOSEST,	 
		false
	) 

	for _,ally in ipairs(allies) do
		if ally:IsRealHero() then GameRules.AddonTemplate:IncrementCurrencyPlayer(ally:GetPlayerOwner()) end
	end	
	EmitGlobalSound("Roshan.Death")
	EmitGlobalSound("boss_killed")
	if countDead < deathTimes  then 
		Timers:CreateTimer(respawnTime, function()
			local newUnit = CreateUnitByName(unitName, respawnPoint, true, nil, nil, teamNumber)
			newUnit.counter = countDead
	        newUnit:SetForwardVector(forwadVector)
			newUnit.respoint = respawnPoint
			newUnit.fw = forwadVector
		end)
	end
end