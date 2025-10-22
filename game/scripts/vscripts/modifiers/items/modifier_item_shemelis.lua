modifier_item_shemelis = class({})

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] modifier_item_shemelis.lua START LOADING")
print("[MOD_SHEMELIS] ============================================")

print("[MOD_SHEMELIS] Defining GetTexture...")
function modifier_item_shemelis:GetTexture()
	print("[MOD_SHEMELIS] GetTexture() CALLED")
	return "shemelis"
end
print("[MOD_SHEMELIS] GetTexture DEFINED")

print("[MOD_SHEMELIS] Defining IsHidden...")
function modifier_item_shemelis:IsHidden()
	print("[MOD_SHEMELIS] IsHidden() CALLED")
	return true
end
print("[MOD_SHEMELIS] IsHidden DEFINED")

print("[MOD_SHEMELIS] Defining IsPurgable...")
function modifier_item_shemelis:IsPurgable()
	print("[MOD_SHEMELIS] IsPurgable() CALLED")
	return false
end
print("[MOD_SHEMELIS] IsPurgable DEFINED")

print("[MOD_SHEMELIS] Defining RemoveOnDeath...")
function modifier_item_shemelis:RemoveOnDeath()
	print("[MOD_SHEMELIS] RemoveOnDeath() CALLED")
	return false
end
print("[MOD_SHEMELIS] RemoveOnDeath DEFINED")

print("[MOD_SHEMELIS] Defining GetAttributes...")
function modifier_item_shemelis:GetAttributes()
	print("[MOD_SHEMELIS] GetAttributes() CALLED")
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
print("[MOD_SHEMELIS] GetAttributes DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining OnCreated...")

function modifier_item_shemelis:OnCreated(kv)
	print("[MOD_SHEMELIS] ============================================")
	print("[MOD_SHEMELIS] OnCreated() CALLED START")
	print("[MOD_SHEMELIS] ============================================")
	
	print("[MOD_SHEMELIS] Getting ability...")
	local ability = self:GetAbility()
	print("[MOD_SHEMELIS] Ability result: " .. tostring(ability))
	
	if not ability then
		print("[MOD_SHEMELIS] ERROR: Ability is nil - RETURNING")
		return
	end
	print("[MOD_SHEMELIS] Ability is valid!")
	
	print("[MOD_SHEMELIS] Caching special values (both client and server)...")
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage") or 0
	self.bonus_armor = ability:GetSpecialValueFor("bonus_armor") or 0
	self.evasion = ability:GetSpecialValueFor("evasion") or 0
	self.spell_amplify = ability:GetSpecialValueFor("spell_amplify") or 0
	self.crit_chance = ability:GetSpecialValueFor("crit_chance") or 0
	self.vampirism = ability:GetSpecialValueFor("vampirism") or 0
	self.spell_reflect_chance = ability:GetSpecialValueFor("spell_reflect_chance") or 0
	self.heal_boost = ability:GetSpecialValueFor("heal_boost") or 0
	self.mana_regen_boost = ability:GetSpecialValueFor("mana_regen_boost") or 0
	
	print("[MOD_SHEMELIS] Values cached: spell_amplify=" .. tostring(self.spell_amplify))
	
	if IsServer() then
		print("[MOD_SHEMELIS] Server side - initializing history...")
		local parent = self:GetParent()
		print("[MOD_SHEMELIS] Parent result: " .. tostring(parent))
		
		if parent then
			print("[MOD_SHEMELIS] Parent is valid - initializing history")
			self.history_max_frames = 20
			self.position_history = {}
			self.health_history = {}
			
			print("[MOD_SHEMELIS] Filling history arrays...")
			for i = 1, self.history_max_frames do
				self.position_history[i] = parent:GetAbsOrigin()
				self.health_history[i] = parent:GetHealth()
			end
			print("[MOD_SHEMELIS] History arrays filled successfully!")
			
			print("[MOD_SHEMELIS] Starting interval think...")
			self:StartIntervalThink(0.1)
			print("[MOD_SHEMELIS] Interval think started!")
		else
			print("[MOD_SHEMELIS] WARNING: Parent is nil - skipping history")
		end
	end
	
	print("[MOD_SHEMELIS] ============================================")
	print("[MOD_SHEMELIS] OnCreated() COMPLETED SUCCESSFULLY")
	print("[MOD_SHEMELIS] ============================================")
end

print("[MOD_SHEMELIS] OnCreated DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining OnDestroy...")

function modifier_item_shemelis:OnDestroy()
	print("[MOD_SHEMELIS] OnDestroy() CALLED")
	if IsServer() then
		print("[MOD_SHEMELIS] Clearing history...")
		self.position_history = nil
		self.health_history = nil
		print("[MOD_SHEMELIS] History cleared")
	end
end

print("[MOD_SHEMELIS] OnDestroy DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining OnIntervalThink...")

function modifier_item_shemelis:OnIntervalThink()
	if not IsServer() then return end
	
	local parent = self:GetParent()
	if not parent or not parent:IsAlive() then
		self:StartIntervalThink(-1)
		return
	end
	
	if not self.position_history or not self.health_history then return end
	if not self.history_max_frames then return end
	
	for i = self.history_max_frames, 2, -1 do
		self.position_history[i] = self.position_history[i-1]
		self.health_history[i] = self.health_history[i-1]
	end
	
	self.position_history[1] = parent:GetAbsOrigin()
	self.health_history[1] = parent:GetHealth()
end

print("[MOD_SHEMELIS] OnIntervalThink DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining DeclareFunctions...")

function modifier_item_shemelis:DeclareFunctions()
	print("[MOD_SHEMELIS] DeclareFunctions() CALLED")
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	print("[MOD_SHEMELIS] DeclareFunctions returning " .. tostring(#funcs) .. " functions")
	return funcs
end

print("[MOD_SHEMELIS] DeclareFunctions DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining property getters...")

function modifier_item_shemelis:GetModifierPreAttack_BonusDamage()
	if self.bonus_damage then return self.bonus_damage end
	local ability = self:GetAbility()
	if ability then return ability:GetSpecialValueFor("bonus_damage") or 20 end
	return 20
end

function modifier_item_shemelis:GetModifierPhysicalArmorBonus()
	if self.bonus_armor then return self.bonus_armor end
	local ability = self:GetAbility()
	if ability then return ability:GetSpecialValueFor("bonus_armor") or 0 end
	return 0
end

function modifier_item_shemelis:GetModifierEvasion_Constant()
	if self.evasion then return self.evasion end
	local ability = self:GetAbility()
	if ability then return ability:GetSpecialValueFor("evasion") or 10 end
	return 10
end

function modifier_item_shemelis:GetModifierSpellAmplify_Percentage()
	if self.spell_amplify then
		return self.spell_amplify
	end
	
	-- Fallback если не инициализировано
	local ability = self:GetAbility()
	if ability then
		return ability:GetSpecialValueFor("spell_amplify") or 8
	end
	
	return 8
end

function modifier_item_shemelis:GetModifierHPRegenAmplify_Percentage()
	if self.heal_boost then return self.heal_boost end
	local ability = self:GetAbility()
	if ability then return ability:GetSpecialValueFor("heal_boost") or 10 end
	return 10
end

function modifier_item_shemelis:GetModifierManaRegenTotal_Percentage()
	if self.mana_regen_boost then return self.mana_regen_boost end
	local ability = self:GetAbility()
	if ability then return ability:GetSpecialValueFor("mana_regen_boost") or 10 end
	return 10
end

function modifier_item_shemelis:GetModifierReflectSpell()
	if not IsServer() then return 0 end
	
	-- 5% шанс отразить заклинание
	if RollPseudoRandomPercentage(self.spell_reflect_chance or 5, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self:GetParent()) then
		return 1
	end
	
	return 0
end

print("[MOD_SHEMELIS] Property getters DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining GetModifierPreAttack_CriticalStrike...")

function modifier_item_shemelis:GetModifierPreAttack_CriticalStrike(params)
	if not IsServer() then return 0 end
	if not params then return 0 end
	
	local hTarget = params.target
	local hAttacker = params.attacker
	
	if not hTarget or not hAttacker then return 0 end
	if hAttacker:IsIllusion() then return 0 end
	if hTarget:IsBuilding() or hTarget:IsOther() then return 0 end
	if hAttacker ~= self:GetParent() then return 0 end
	if hAttacker:GetTeamNumber() == hTarget:GetTeamNumber() then return 0 end
	
	if RollPseudoRandomPercentage(self.crit_chance or 15, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, hAttacker) then
		return 200
	end
	
	return 0
end

print("[MOD_SHEMELIS] GetModifierPreAttack_CriticalStrike DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining OnAttackLanded...")

function modifier_item_shemelis:OnAttackLanded(params)
	if IsServer() then
		if self:GetParent() ~= params.attacker then return 0 end
		
		local hTarget = params.target
		local hAttacker = params.attacker
		
		if not hTarget or not hAttacker or not self:GetAbility() then return 0 end
		if hAttacker:IsIllusion() then return 0 end
		
		local damage = params.damage
		if damage and damage > 0 then
			local heal_amount = damage * (self.vampirism or 0) / 100
			if heal_amount > 0 then
				hAttacker:Heal(heal_amount, self:GetAbility())
				
				local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hAttacker)
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
	end
	
	return 0
end

print("[MOD_SHEMELIS] OnAttackLanded DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining OnTakeDamage...")

function modifier_item_shemelis:OnTakeDamage(params)
	if IsServer() then
		local Attacker = params.attacker
		local Target = params.unit
		local Ability = params.inflictor
		
		if Attacker ~= self:GetParent() or not Ability or not Target then return 0 end
		
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return 0 end
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then return 0 end
		
		local flDamage = params.damage
		if flDamage and flDamage > 0 then
			local flLifesteal = flDamage * (self.vampirism or 0) / 100
			if flLifesteal > 0 then
				Attacker:Heal(flLifesteal, self:GetAbility())
				
				local pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker)
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
	end
	
	return 0
end

print("[MOD_SHEMELIS] OnTakeDamage DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] Defining TimeRewind...")

function modifier_item_shemelis:TimeRewind()
	local parent = self:GetParent()
	if not parent or not parent:IsAlive() then return end
	
	if not self.position_history or not self.health_history then return end
	
	local rewind_index = self.history_max_frames
	
	if self.position_history[rewind_index] then
		-- Проиграть анимацию Time Lapse
		parent:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		
		-- Телепортация
		FindClearSpaceForUnit(parent, self.position_history[rewind_index], true)
		
		-- Восстановление здоровья
		if self.health_history[rewind_index] and self.health_history[rewind_index] > 0 then
			local current_health = parent:GetHealth()
			local old_health = self.health_history[rewind_index]
			
			if old_health > current_health then
				local heal_amount = old_health - current_health
				parent:Heal(heal_amount, self:GetAbility())
			end
		end
		
		-- Эффект Time Lapse
		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(effect, 0, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(effect)
		
		-- Звук Time Lapse (уже есть в item_shemelis.lua, но добавим для надежности)
		EmitSoundOn("Hero_Weaver.TimeLapse", parent)
	end
end

print("[MOD_SHEMELIS] TimeRewind DEFINED")

print("[MOD_SHEMELIS] ============================================")
print("[MOD_SHEMELIS] modifier_item_shemelis.lua LOADING COMPLETE")
print("[MOD_SHEMELIS] ============================================")

