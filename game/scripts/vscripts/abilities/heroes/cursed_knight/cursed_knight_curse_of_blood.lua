LinkLuaModifier('modifier_cursed_knight_curse_of_blood', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_cooldown', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_ally_curse', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_cursed_knight_curse_of_blood_generic', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_blood', LUA_MODIFIER_MOTION_NONE)


cursed_knight_curse_of_blood = cursed_knight_curse_of_blood or {}
function cursed_knight_curse_of_blood:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange()
end
function cursed_knight_curse_of_blood:GetIntrinsicModifierName()
    return "modifier_cursed_knight_curse_of_blood_generic"
end
function cursed_knight_curse_of_blood:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget() 
    local modifier_generic = self:GetCaster():FindModifierByName("modifier_cursed_knight_curse_of_blood_generic")
    if modifier_generic then
        if target:HasModifier("modifier_cursed_knight_curse_of_blood") and target:FindModifierByName("modifier_cursed_knight_curse_of_blood"):GetStackCount() >= 3 and not caster:HasModifier("modifier_cursed_knight_curse_of_blood_cooldown") then
            modifier_generic.target = target
            modifier_generic.crit = true
            Timers:CreateTimer(caster:GetAttackSpeed(true)*0.7, function()
                modifier_generic.crit = false
            end)
        end
        modifier_generic.IsAbilityModifier = true
        Timers:CreateTimer(caster:GetAttackSpeed(true)*0.7, function()
            modifier_generic.IsAbilityModifier = false
        end)
    end
    -- Выполнение атаки
    if not target:TriggerSpellAbsorb(self) then 
        caster:MoveToTargetToAttack(target)
    end
    self:EndCooldown()
end

modifier_cursed_knight_curse_of_blood_generic = modifier_cursed_knight_curse_of_blood_generic or {}
function modifier_cursed_knight_curse_of_blood_generic:IsHidden() return true end
function modifier_cursed_knight_curse_of_blood_generic:IsPurgable() return false end
function modifier_cursed_knight_curse_of_blood_generic:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_cursed_knight_curse_of_blood_generic:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() then
        local crit = self.crit
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self:GetParent() then
            local ability = self:GetAbility()
            local damage_krit_after = ability:GetSpecialValueFor("damage_krit_after")
            if not crit or self.target ~= target then
				return
			end
            if crit then  
                Timers:CreateTimer(attacker:GetAttackSpeed(true), function()                    
					self.crit = false
				end)  
                -- if target:HasModifier("modifier_cursed_knight_curse_of_blood") or target:HasModifier("modifier_cursed_knight_curse_of_blood_ally_curse") then
                return attacker:GetAttackDamage()*damage_krit_after
                -- end
                -- return 100
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
        local ability = self:GetAbility()
        local duration = ability:GetSpecialValueFor("duration_before")
        local dmg = ability:GetSpecialValueFor("pure_damage")
		if attacker == ability:GetCaster() then   
            if self.IsAbilityModifier   then
                if self.crit and self.target == target then
                    EmitSoundOn("Hero_SkeletonKing.CriticalStrike", attacker)
                    self.target = nil
                    self.crit = false
                end
                ApplyDamage({victim = target, attacker = attacker,damage = dmg, damage_type = DAMAGE_TYPE_PURE , damage_flags = DOTA_DAMAGE_FLAG_NONE, ability})
                target:AddNewModifier(attacker, ability, "modifier_cursed_knight_curse_of_blood", {duration = duration})
                EmitSoundOn("curse_of_blood", attacker)
                ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
            end
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
function modifier_cursed_knight_curse_of_blood:GetEffectName()
	return "particles/shadow_demon_demonic_purge.vpcf"
end

function modifier_cursed_knight_curse_of_blood:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW 
end
function modifier_cursed_knight_curse_of_blood:OnRefresh(kkd)
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local value_stack = ability:GetSpecialValueFor("value_of_hits")
    local curse_cooldown = ability:GetSpecialValueFor("curse_cooldown")
    local IsCooldown = caster:HasModifier("modifier_cursed_knight_curse_of_blood_cooldown")
    if self:GetStackCount() ~= value_stack then 
        self:IncrementStackCount()
    end
    if self:GetStackCount() == value_stack and not IsCooldown then 
        self:MagicEmployed()
        caster:AddNewModifier(caster, ability, "modifier_cursed_knight_curse_of_blood_cooldown", {duration = curse_cooldown})
    end
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


function modifier_cursed_knight_curse_of_blood:MagicEmployed()
    if not IsServer() then return end
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
	return "particles/shadow_demon_demonic_purge.vpcf"
end

function modifier_cursed_knight_curse_of_blood_ally_curse:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW 
end
modifier_cursed_knight_curse_of_blood_cooldown = modifier_cursed_knight_curse_of_blood_cooldown or {}
function modifier_cursed_knight_curse_of_blood_cooldown:IsHidden() return false end
function modifier_cursed_knight_curse_of_blood_cooldown:IsPurgable() return false end
function modifier_cursed_knight_curse_of_blood_cooldown:IsDebuff() return false end