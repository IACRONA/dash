LinkLuaModifier('modifier_cursed_knight_curse_of_blood', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_cooldown', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_ally_curse', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_generic', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)


cursed_knight_curse_of_blood = cursed_knight_curse_of_blood or {}
function cursed_knight_curse_of_blood:GetIntrinsicModifierName()
    return "modifier_cursed_knight_curse_of_blood_generic"
end
function cursed_knight_curse_of_blood:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
    local duration = ability:GetSpecialValueFor("duration_before")
    local pure_dmg = ability:GetSpecialValueFor("pure_damage")
    local FacetID = caster:GetHeroFacetID()
    if FacetID == 3 then pure_dmg = pure_dmg*1.03 end
    if not target:TriggerSpellAbsorb( self ) then 
        ApplyDamage({victim = target, attacker = caster,damage = pure_dmg, damage_type = DAMAGE_TYPE_PURE , damage_flags = DOTA_DAMAGE_FLAG_NONE,self})
        EmitSoundOn("curse_of_blood", self:GetCaster() )
        target:AddNewModifier(caster, ability, "modifier_cursed_knight_curse_of_blood", {duration = duration})
    end
end

modifier_cursed_knight_curse_of_blood_generic = modifier_cursed_knight_curse_of_blood_generic or {}
function modifier_cursed_knight_curse_of_blood_generic:IsHidden() return true end
function modifier_cursed_knight_curse_of_blood_generic:IsPurgable() return false end
function modifier_cursed_knight_curse_of_blood_generic:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,MODIFIER_EVENT_ON_ATTACK_LANDED  }
end
function modifier_cursed_knight_curse_of_blood_generic:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() then
        self.mortal_critical_strike = false
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self:GetParent() then
            if target:HasModifier("modifier_cursed_knight_curse_of_blood_ally_curse") or target:HasModifier("modifier_cursed_knight_curse_of_blood") then  
                self.mortal_critical_strike = true
                Timers:CreateTimer(self:GetParent():GetAttackSpeed(true), function()                    
					self.mortal_critical_strike = false
				end)  
                return self:GetAbility():GetSpecialValueFor("damage_krit_after")* self:GetAbility():GetCaster():GetAttackDamage()
            end
		end
	end
    return 0
end

function modifier_cursed_knight_curse_of_blood_generic:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target
		local damage = keys.damage
		-- Only apply on attacks of the caster
		if attacker == self.caster then            
			-- If this attack was not a crit, do nothing
			if not self.mortal_critical_strike then
				return nil
			end
            EmitSoundOn("Hero_SkeletonKing.CriticalStrike", attacker)
			-- Remove crit mark
			self.mortal_critical_strike = false
		end
	end
end

modifier_cursed_knight_curse_of_blood = modifier_cursed_knight_curse_of_blood or {}

function modifier_cursed_knight_curse_of_blood:IsHidden() return false end
function modifier_cursed_knight_curse_of_blood:IsPurgable() return true end

function modifier_cursed_knight_curse_of_blood:OnCreated(kkd)
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_cursed_knight_curse_of_blood:OnIntervalThink(sss)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local perid_mag_damage = ability:GetSpecialValueFor("mag_periodic_damage")
    local stack = self:GetStackCount()
    local critx = ability:GetSpecialValueFor("damage_krit_after")
    local dmg = 0
    local value_stack = ability:GetSpecialValueFor("value_of_hits")
    if stack >= value_stack then dmg = critx* perid_mag_damage else dmg = perid_mag_damage end
    -- SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, parent, dmg, nil)
    local FacetID = caster:GetHeroFacetID()
    if FacetID == 3 then dmg = dmg*1.03 end
    ApplyDamage({victim = parent, attacker = ability:GetCaster(),damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_DAMAGE_FLAG_NONE, ability})
end

function modifier_cursed_knight_curse_of_blood:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED }

end
function modifier_cursed_knight_curse_of_blood:OnAttackLanded(event)
    if not IsServer() then return end
    local target = event.target
    local parent = self:GetParent()
    if target ~= parent then return end
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local attacker = event.attacker
    if caster ~= attacker then return end
    local curse_cooldown = ability:GetSpecialValueFor("curse_cooldown")
    local IsCooldown = caster:HasModifier("modifier_cursed_knight_curse_of_blood_cooldown")
    local value_stack = ability:GetSpecialValueFor("value_of_hits")
    if self:GetStackCount() ~= value_stack then 
        self:IncrementStackCount()
    end
    if self:GetStackCount() == value_stack and not IsCooldown then 
        self:MagicEmployed()
        caster:AddNewModifier(caster, ability, "modifier_cursed_knight_curse_of_blood_cooldown", {duration = curse_cooldown})
    end
end
function modifier_cursed_knight_curse_of_blood:MagicEmployed()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local silence_duration = ability:GetSpecialValueFor("silence_duration")
    local team_ally = parent:GetTeam()
    local point = parent:GetOrigin()
    local radius_curse = ability:GetSpecialValueFor("radius_curse")
    local curse_duration_ally = ability:GetSpecialValueFor("curse_duration_ally")
    local allies = FindUnitsInRadius(team_ally, point, nil,radius_curse, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC , DOTA_UNIT_TARGET_FLAG_NONE , FIND_ANY_ORDER , false)
    for _, ally in pairs(allies) do
        ally:AddNewModifier(caster, ability, "modifier_cursed_knight_curse_of_blood_ally_curse", {duration = curse_duration_ally})
        ally:AddNewModifier(caster, ability, "modifier_silence", {duration = silence_duration})
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally )
	    ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_cursed_knight_curse_of_blood_ally_curse = modifier_cursed_knight_curse_of_blood_ally_curse or {}
function modifier_cursed_knight_curse_of_blood_ally_curse:RemoveOnDeath() return true end
function modifier_cursed_knight_curse_of_blood_ally_curse:IsHidden() return false end
function modifier_cursed_knight_curse_of_blood_ally_curse:IsPurgable() return true end
function modifier_cursed_knight_curse_of_blood_ally_curse:GetTexture() return "cursed_knight/curse_of_blood_curse2" end
function modifier_cursed_knight_curse_of_blood_ally_curse:OnCreated(kkd) self:StartIntervalThink(1) end
function modifier_cursed_knight_curse_of_blood_ally_curse:OnIntervalThink(sss)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local damage_mag_periodic_ally = ability:GetSpecialValueFor("damage_mag_periodic_ally")
    caster:Heal(damage_mag_periodic_ally, ability)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, parent, damage_mag_periodic_ally, nil)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, damage_mag_periodic_ally, nil)
    local FacetID = caster:GetHeroFacetID()
    if FacetID == 3 then damage_mag_periodic_ally = damage_mag_periodic_ally*1.03 end
    ApplyDamage({victim = parent, attacker = caster,damage = damage_mag_periodic_ally, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = ability})
end
function modifier_cursed_knight_curse_of_blood_ally_curse:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_noxious_plague_projectile_trail_fluid.vpcf"
end

function modifier_cursed_knight_curse_of_blood_ally_curse:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW 
end
modifier_cursed_knight_curse_of_blood_cooldown = modifier_cursed_knight_curse_of_blood_cooldown or {}
function modifier_cursed_knight_curse_of_blood_cooldown:IsHidden() return false end
function modifier_cursed_knight_curse_of_blood_cooldown:IsPurgable() return false end
function modifier_cursed_knight_curse_of_blood_cooldown:IsDebuff() return false end