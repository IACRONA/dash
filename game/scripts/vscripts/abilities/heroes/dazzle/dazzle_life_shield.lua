LinkLuaModifier('modifier_dazzle_life_shield', 'abilities/heroes/dazzle/dazzle_life_shield', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_dazzle_life_shield_movespeed', 'abilities/heroes/dazzle/dazzle_life_shield', LUA_MODIFIER_MOTION_NONE)

dazzle_life_shield = class({})
 
function dazzle_life_shield:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local heal = self:GetSpecialValueFor("heal")
	local modifiers = target:FindAllModifiers() 
	local index = #modifiers

	if not self.netTable then 
		self.netTable = CustomNetTables:GetTableValue("abilities_damage", "abilities") 
	end

	while index ~= 0 do 
		local modifier = modifiers[index]
		index = index - 1
		if modifier:IsDebuff() then 
			local ability = modifier:GetAbility()
			if ability:IsItem() then 
				index = 0
				modifier:Destroy()
			end
			local abilityInTable = self.netTable[ability:GetName()]

			if (abilityInTable and abilityInTable.dispell ~= "SPELL_DISPELLABLE_NO") then 
				index = 0
				modifier:Destroy()
			end
		end
	end
	target:AddNewModifier(caster, self, "modifier_dazzle_life_shield", {duration = self:GetSpecialValueFor("duration")})
	target:AddNewModifier(caster, self, "modifier_dazzle_life_shield_movespeed", {duration = self:GetSpecialValueFor("duration_movespeed")})
	target:Heal(heal, self)
    SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, target, heal, caster:GetPlayerOwner())

	EmitSoundOn("life_shield_cast", target)
end

modifier_dazzle_life_shield = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsBuff                  = function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
   		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
   		MODIFIER_EVENT_ON_TAKEDAMAGE,
   		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    } end,
})



function modifier_dazzle_life_shield:OnCreated(data)
	local ability = self:GetAbility()
	local parent = self:GetParent()
 
	self.damageReturn = ability:GetSpecialValueFor("damage_return")/100
	self.hpRegenAmp = ability:GetSpecialValueFor("heal_amp")

	if not IsServer() then return end
	local shieldHealth = ability:GetSpecialValueFor("shield_health")
	if data.isLightVersion then shieldHealth = shieldHealth/2 end
    self.pfx = ParticleManager:CreateParticle("particles/items_fx/immunity_sphere_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

	self:SetStackCount(shieldHealth)
end

function modifier_dazzle_life_shield:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
end

function modifier_dazzle_life_shield:GetModifierIncomingDamageConstant(event)
	if IsClient() then   return self:GetStackCount() end

	if not IsServer() then return end
	if event.inflictor and event.inflictor == self:GetAbility() then 
	  return
	end

	if self:GetStackCount() > event.damage then
	    self:SetStackCount(self:GetStackCount() - event.damage)
	    local i = event.damage
	    return -i
	else
	    local i = self:GetStackCount()
	    self:SetStackCount(0)
	    self:Destroy()
	    return -i
	end
end

function modifier_dazzle_life_shield:OnTakeDamage( params )
    if IsClient() then return end 

    if params.unit == self:GetParent() and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber()  and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
        local target = params.attacker

        if target == self:GetParent() then return end

        if target:IsBuilding() then return end

        ApplyDamage ( {
            victim = target,
            attacker = self:GetParent(),
            damage = params.original_damage * self.damageReturn,
            damage_type = params.damage_type ,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
        })
        EmitSoundOnClient("DOTA_Item.BladeMail.Damage", params.attacker:GetPlayerOwner())
    end
end

function modifier_dazzle_life_shield:GetModifierHPRegenAmplify_Percentage()  
	return self.hpRegenAmp
end

modifier_dazzle_life_shield_movespeed = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsBuff                  = function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
   		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    } end,
})

function modifier_dazzle_life_shield_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_movespeed_pct")
end