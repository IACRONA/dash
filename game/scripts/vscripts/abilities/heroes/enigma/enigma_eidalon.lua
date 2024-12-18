LinkLuaModifier('modifier_enigma_eidalon_eat', 'abilities/heroes/enigma/enigma_eidalon', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_on_death', 'modifiers/generic/modifier_on_death', LUA_MODIFIER_MOTION_NONE)

enigma_eidalon = class({})

function enigma_eidalon:OnSpellStart()
	local caster = self:GetCaster()

	self.target = self:GetCursorTarget()
	self.soundName = "edolon_cast"
	EmitSoundOn(self.soundName, caster)
	self.animationTimer = Timers:CreateTimer(self:GetChannelTime()-0.5, function()
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end)
end

function enigma_eidalon:OnChannelFinish(interrupted)
	local caster = self:GetCaster()

	if self.animationTimer then  
		if interrupted then caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2) end
		Timers:RemoveTimer(self.animationTimer) 
	end 
	if interrupted then return StopSoundOn(self.soundName, caster) end

	if caster.eidalon and IsValidEntity(caster.eidalon) and caster.eidalon:IsAlive() then caster.eidalon:Kill(self, nil) end
	caster.eidalon = CreateUnitByName("npc_dota_eidolon_custom", caster:GetAbsOrigin() + RandomVector(50), true, caster, caster, caster:GetTeamNumber())
	caster.eidalon:SetOwner(caster)
	caster.eidalon:SetControllableByPlayer(caster:GetPlayerID(), true)

 	caster.eidalon:SetBaseDamageMin(self:GetSpecialValueFor("min_damage"))	
	caster.eidalon:SetBaseDamageMax(self:GetSpecialValueFor("max_damage"))	

	Timers:CreateTimer(0.1, function()
		ExecuteOrderFromTable({
			UnitIndex = caster.eidalon:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET ,
			TargetIndex = caster:entindex()
		})
	end)
 
	local modifierDeath = caster.eidalon:AddNewModifier(caster.eidalon, nil, "modifier_on_death", {})
	modifierDeath.CallbackOnDeath = function()
		if caster:HasModifier("modifier_item_aghanims_shard") then caster:SwapAbilities("enigma_eidalon_eat", "enigma_eidalon", false, true) end
	end

	if caster:HasModifier("modifier_item_aghanims_shard") then 
		if not caster:HasAbility("enigma_eidalon_eat") then caster:AddAbility("enigma_eidalon_eat"):SetLevel(1) end

		caster:SwapAbilities("enigma_eidalon", "enigma_eidalon_eat", false, true)
	end
end


enigma_eidalon_eat = class({})

function enigma_eidalon_eat:OnSpellStart()
	local caster = self:GetCaster()

	if caster.eidalon and IsValidEntity(caster.eidalon) and caster.eidalon:IsAlive() then
		caster:AddNewModifier(caster, self, "modifier_enigma_eidalon_eat", {duration = self:GetSpecialValueFor("duration")})
		 EmitSoundOn("edolon_die", caster)
		caster.eidalon:Kill(self, caster)
	end
end

modifier_enigma_eidalon_eat = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    } end,
})

function modifier_enigma_eidalon_eat:OnCreated()
	self.reduceDamage = self:GetAbility():GetSpecialValueFor("reduce_damage")
	self.damage = 0
end

function modifier_enigma_eidalon_eat:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	if self.damage == 0 then return end
	parent:Heal(self.damage, self:GetAbility())
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, self.damage, nil)
end

function modifier_enigma_eidalon_eat:GetModifierIncomingDamage_Percentage(event)

	self.damage = self.damage + (event.damage * (self.reduceDamage/100))
	return -self.reduceDamage
end
