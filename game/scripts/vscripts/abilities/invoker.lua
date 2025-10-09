LinkLuaModifier( "modifier_invoker_alacrity_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )

invoker_alacrity_custom = class({})

function invoker_alacrity_custom:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local target = self:GetCursorTarget()
    target:AddNewModifier( self:GetCaster(), self, "modifier_invoker_alacrity_custom", { duration = duration } )
    target:EmitSound("Hero_Invoker.Alacrity")
end

modifier_invoker_alacrity_custom = class({})

function modifier_invoker_alacrity_custom:OnCreated( kv )

    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_alacrity.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_invoker_alacrity_custom:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_invoker_alacrity_custom:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_invoker_alacrity_custom:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_invoker_alacrity_custom:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_alacrity_buff.vpcf"
end

function modifier_invoker_alacrity_custom:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_invoker_emp_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )

invoker_emp_custom = class({})

function invoker_emp_custom:GetAOERadius()
    return self:GetSpecialValueFor( "area_of_effect" )
end

function invoker_emp_custom:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("delay")
    local thinker = CreateModifierThinker( self:GetCaster(), self, "modifier_invoker_emp_custom", { duration = delay }, point, self:GetCaster():GetTeamNumber(), false )
    thinker:EmitSound("Hero_Invoker.EMP.Cast")
end

modifier_invoker_emp_custom = class({})

function modifier_invoker_emp_custom:IsHidden()
    return true
end

function modifier_invoker_emp_custom:IsPurgable()
    return false
end

function modifier_invoker_emp_custom:OnCreated( kv )
    if not IsServer() then return end
    self.area_of_effect = self:GetAbility():GetSpecialValueFor("area_of_effect")
    self.mana_burned = self:GetAbility():GetSpecialValueFor("mana_burned")
    self.damage_per_mana_pct = self:GetAbility():GetSpecialValueFor("damage_per_mana_pct") / 100

    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_emp.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.area_of_effect, 0, 0 ) )
    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Invoker.EMP.Charge", self:GetCaster() )
end

function modifier_invoker_emp_custom:OnDestroy( kv )
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.area_of_effect, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, 0, false )

    local damageTable = 
    {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }

    for _,enemy in pairs(enemies) do
        local mana_burn = math.min( enemy:GetMana(), self.mana_burned )
        enemy:Script_ReduceMana( mana_burn, self:GetAbility() )
        damageTable.victim = enemy
        damageTable.damage = mana_burn * self.damage_per_mana_pct
        ApplyDamage(damageTable)
    end

    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end

    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Invoker.EMP.Discharge", self:GetCaster() )
    UTIL_Remove( self:GetParent() )
end

LinkLuaModifier( "modifier_invoker_ghost_walk_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invoker_ghost_walk_custom_debuff", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )

invoker_ghost_walk_custom = class({})

function invoker_ghost_walk_custom:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():StartGesture(ACT_DOTA_CAST_GHOST_WALK)

    local duration = self:GetSpecialValueFor("duration")

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_invoker_ghost_walk_custom", { duration = duration } )

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetCaster():EmitSound("Hero_Invoker.GhostWalk")
end

modifier_invoker_ghost_walk_custom = class({})

function modifier_invoker_ghost_walk_custom:IsPurgable()
    return false
end

function modifier_invoker_ghost_walk_custom:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor( "area_of_effect" )
    self.aura_duration = self:GetAbility():GetSpecialValueFor( "aura_fade_time" )
    self.self_slow = self:GetAbility():GetSpecialValueFor("self_slow")
    self.enemy_slow = self:GetAbility():GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_custom:OnRefresh()
    self.radius = self:GetAbility():GetSpecialValueFor( "area_of_effect" )
    self.aura_duration = self:GetAbility():GetSpecialValueFor( "aura_fade_time" )
    self.self_slow = self:GetAbility():GetSpecialValueFor("self_slow")
    self.enemy_slow = self:GetAbility():GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_custom:IsAura()
    return true
end

function modifier_invoker_ghost_walk_custom:GetModifierAura()
    return "modifier_invoker_ghost_walk_custom_debuff"
end

function modifier_invoker_ghost_walk_custom:GetAuraRadius()
    return self.radius
end

function modifier_invoker_ghost_walk_custom:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_invoker_ghost_walk_custom:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_invoker_ghost_walk_custom:GetAuraDuration()
    return self.aura_duration
end

function modifier_invoker_ghost_walk_custom:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_invoker_ghost_walk_custom:GetModifierMoveSpeedBonus_Percentage()
    return self.self_slow
end

function modifier_invoker_ghost_walk_custom:GetModifierInvisibilityLevel()
    return 1
end

function modifier_invoker_ghost_walk_custom:OnAbilityExecuted( params )
    if IsServer() then
        if params.unit~=self:GetParent() then return end
        self:Destroy()
    end
end

function modifier_invoker_ghost_walk_custom:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("incoming_damage")
end

function modifier_invoker_ghost_walk_custom:OnAttack( params )
    if IsServer() then
        if params.attacker~=self:GetParent() then return end
        self:Destroy()
    end
end

modifier_invoker_ghost_walk_custom_debuff = class({})

function modifier_invoker_ghost_walk_custom_debuff:IsPurgable()
    return false
end

function modifier_invoker_ghost_walk_custom_debuff:OnCreated()
    self.enemy_slow = self:GetAbility():GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_custom_debuff:OnRefresh()
    self.enemy_slow = self:GetAbility():GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_custom_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_invoker_ghost_walk_custom_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.enemy_slow
end

function modifier_invoker_ghost_walk_custom_debuff:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_ghost_walk_debuff.vpcf"
end

function modifier_invoker_ghost_walk_custom_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_invoker_sun_strike_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )

invoker_sun_strike_custom = class({})

function invoker_sun_strike_custom:GetAOERadius()
    return self:GetSpecialValueFor( "area_of_effect" )
end

function invoker_sun_strike_custom:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("delay")
    local vision_distance = self:GetSpecialValueFor("vision_distance")
    local vision_duration = self:GetSpecialValueFor("vision_duration")

    CreateModifierThinker( self:GetCaster(), self, "modifier_invoker_sun_strike_custom", { duration = delay }, point, self:GetCaster():GetTeamNumber(), false )
    AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision_distance, vision_duration, false )
end

modifier_invoker_sun_strike_custom = class({})

function modifier_invoker_sun_strike_custom:IsHidden()
    return true
end

function modifier_invoker_sun_strike_custom:IsPurgable()
    return false
end

function modifier_invoker_sun_strike_custom:OnCreated( kv )
    if not IsServer() then return end

    self.area_of_effect = self:GetAbility():GetSpecialValueFor("area_of_effect")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    local effect_cast = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.area_of_effect, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationForAllies( self:GetParent():GetOrigin(), "Hero_Invoker.SunStrike.Charge", self:GetCaster() )
end

function modifier_invoker_sun_strike_custom:OnDestroy( kv )
    if not IsServer() then return end

    local damageTable =
    {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.area_of_effect, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        damageTable.damage = self.damage / #enemies
        ApplyDamage(damageTable)
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.area_of_effect, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Invoker.SunStrike.Ignite", self:GetCaster() )

    UTIL_Remove( self:GetParent() )
end

LinkLuaModifier( "modifier_invoker_cold_snap_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE )

invoker_cold_snap_custom = class({})

function invoker_cold_snap_custom:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    local duration = self:GetSpecialValueFor( "duration")

    target:AddNewModifier( self:GetCaster(), self, "modifier_invoker_cold_snap_custom", { duration = duration } )

    local direction = target:GetOrigin()-self:GetCaster():GetOrigin()

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_POINT_FOLLOW, target )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetOrigin() + direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetCaster():EmitSound("Hero_Invoker.ColdSnap.Cast")
    target:EmitSound("Hero_Invoker.ColdSnap")
end

modifier_invoker_cold_snap_custom = class({})

function modifier_invoker_cold_snap_custom:OnCreated( kv )
    self.damage = self:GetAbility():GetSpecialValueFor("freeze_damage")
    self.duration = self:GetAbility():GetSpecialValueFor("freeze_duration")
    self.cooldown = self:GetAbility():GetSpecialValueFor("freeze_cooldown")
    self.threshold = self:GetAbility():GetSpecialValueFor("damage_trigger")
    if not IsServer() then return end
    self.onCooldown = false
    self:Freeze()
end

function modifier_invoker_cold_snap_custom:OnRefresh( kv )
    self.damage = self:GetAbility():GetSpecialValueFor("freeze_damage")
    self.duration = self:GetAbility():GetSpecialValueFor("freeze_duration")
    self.cooldown = self:GetAbility():GetSpecialValueFor("freeze_cooldown")
    self.threshold = self:GetAbility():GetSpecialValueFor("damage_trigger")
end

function modifier_invoker_cold_snap_custom:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_invoker_cold_snap_custom:OnTakeDamage( params )
    if IsServer() then
        if params.unit~=self:GetParent() then return end
        if params.damage<self.threshold then return end
        if self.onCooldown then return end
        self:Freeze()
        self:PlayEffects( params.attacker )
    end
end

function modifier_invoker_cold_snap_custom:OnIntervalThink()
    self.onCooldown = false
    self:StartIntervalThink(-1)
end

function modifier_invoker_cold_snap_custom:Freeze()
    self.onCooldown = true
    local damageTable = 
    { 
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility() 
    }
    ApplyDamage(damageTable)
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_stunned", { duration = self.duration } )
    self:StartIntervalThink( self.cooldown )
end

function modifier_invoker_cold_snap_custom:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_invoker_cold_snap_custom:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_invoker_cold_snap_custom:PlayEffects( attacker )
    local direction = self:GetParent():GetOrigin()-attacker:GetOrigin()

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_POINT_FOLLOW, target )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 1,  self:GetParent():GetOrigin()+direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetParent():EmitSound("Hero_Invoker.ColdSnap.Freeze")
end

LinkLuaModifier("modifier_invoker_forge_spirit_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_forged_spirit_melting_strike_custom_debuff", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invulnerable_forge_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)

invoker_forge_spirit_custom = class({})

function invoker_forge_spirit_custom:OnSpellStart()
    if not IsServer() then return end

    local damage = self:GetSpecialValueFor("spirit_damage")
    local health = self:GetSpecialValueFor("spirit_hp")
    local mana = self:GetSpecialValueFor("spirit_mana")
    local duration = self:GetSpecialValueFor("spirit_duration")
    local spirit_armor = self:GetSpecialValueFor("spirit_armor")

    local spirit_count = 1

    if self.forged_spirits then
        for _, unit in pairs(self.forged_spirits) do
            if unit and not unit:IsNull() and unit:IsAlive() then
                unit:ForceKill(true)
            end
        end
    end

    self.forged_spirits = {}

    for i = 1, spirit_count do
        local forged_spirit = CreateUnitByName("npc_dota_invoker_forged_spirit", self:GetCaster():GetAbsOrigin() + RandomVector(100), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        forged_spirit:AddNewModifier(self:GetCaster(), self, "modifier_kill", { duration = duration })
        forged_spirit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        forged_spirit:SetBaseMaxHealth(health)
        forged_spirit:SetBaseDamageMin(damage)
        forged_spirit:SetBaseDamageMax(damage)
        forged_spirit:SetPhysicalArmorBaseValue(spirit_armor)
        FindClearSpaceForUnit(forged_spirit, forged_spirit:GetOrigin(), false)
        forged_spirit:SetAngles(0, 0, 0)
        forged_spirit:SetForwardVector(self:GetCaster():GetForwardVector())
        forged_spirit:AddNewModifier(self:GetCaster(), self, "modifier_invoker_forge_spirit_custom", { duration = duration })
        table.insert(self.forged_spirits, forged_spirit)
    end

    self:GetCaster():EmitSound("Hero_Invoker.ForgeSpirit")
end

modifier_invulnerable_forge_custom = class({})
function modifier_invulnerable_forge_custom:IsPurgable() return false end
function modifier_invulnerable_forge_custom:IsHidden() return true end
function modifier_invulnerable_forge_custom:IsPurgeException() return false end

function modifier_invulnerable_forge_custom:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

modifier_invoker_forge_spirit_custom = class({})

function modifier_invoker_forge_spirit_custom:IsHidden()
    return true
end

function modifier_invoker_forge_spirit_custom:IsDebuff()
    return false
end

function modifier_invoker_forge_spirit_custom:IsPurgable()
    return false
end

function modifier_invoker_forge_spirit_custom:OnCreated(kv)
    self.armor = self:GetAbility():GetSpecialValueFor("spirit_armor") - self:GetParent():GetPhysicalArmorBaseValue()
    self.attack_range = self:GetAbility():GetSpecialValueFor("spirit_attack_range")
end

function modifier_invoker_forge_spirit_custom:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_invoker_forge_spirit_custom:GetModifierAttackRangeBonus()
    return self.attack_range
end

function modifier_invoker_forge_spirit_custom:OnAttackLanded( params )
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_forged_spirit_melting_strike_custom_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration") })
end

modifier_forged_spirit_melting_strike_custom_debuff = class({})

function modifier_forged_spirit_melting_strike_custom_debuff:IsPurgable() return false end

function modifier_forged_spirit_melting_strike_custom_debuff:OnCreated()
    self.armor = self:GetAbility():GetSpecialValueFor("armor_per_attack")
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_forged_spirit_melting_strike_custom_debuff:OnRefresh()
    if not IsServer() then return end
    if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_armor_stacks") then
        self:IncrementStackCount()
    end
end

function modifier_forged_spirit_melting_strike_custom_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_forged_spirit_melting_strike_custom_debuff:GetModifierPhysicalArmorBonus()
    return self.armor * self:GetStackCount()
end


LinkLuaModifier("modifier_invoker_chaos_meteor_custom_thinker", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_chaos_meteor_custom_burn", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)

invoker_chaos_meteor_custom = class({})

function invoker_chaos_meteor_custom:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()

    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end

    CreateModifierThinker( self:GetCaster(), self, "modifier_invoker_chaos_meteor_custom_thinker", {}, point, self:GetCaster():GetTeamNumber(), false )
end

modifier_invoker_chaos_meteor_custom_thinker = class({})

function modifier_invoker_chaos_meteor_custom_thinker:IsHidden()
    return true
end

function modifier_invoker_chaos_meteor_custom_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.caster_origin = self:GetCaster():GetOrigin()
    self.parent_origin = self:GetParent():GetOrigin()
    self.direction = self.parent_origin - self.caster_origin
    self.direction.z = 0
    self.direction = self.direction:Normalized()

    self.delay = self:GetAbility():GetSpecialValueFor("land_time")

    self.radius = self:GetAbility():GetSpecialValueFor("area_of_effect")

    self.distance = self:GetAbility():GetSpecialValueFor("travel_distance")

    self.speed = self:GetAbility():GetSpecialValueFor("travel_speed")

    self.vision = self:GetAbility():GetSpecialValueFor("vision_distance")

    self.vision_duration = self:GetAbility():GetSpecialValueFor("end_vision_duration")


    self.interval = self:GetAbility():GetSpecialValueFor("damage_interval")

    self.duration = self:GetAbility():GetSpecialValueFor("burn_duration")

    local damage = self:GetAbility():GetSpecialValueFor("main_damage")

    self.fallen = false

    self.damageTable = 
    {
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }

    self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
    self.nMoveStep = 0
    self:StartIntervalThink(self.delay)

    self:PlayEffects1()
end

function modifier_invoker_chaos_meteor_custom_thinker:OnDestroy()
    if IsServer() then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.vision, self.vision_duration, false)
        StopSoundOn("Hero_Invoker.ChaosMeteor.Loop", self:GetParent())
        if self.nLinearProjectile then
            ProjectileManager:DestroyLinearProjectile(self.nLinearProjectile)
        end
    end
end

function modifier_invoker_chaos_meteor_custom_thinker:OnIntervalThink()
    if not self.fallen then
        self.fallen = true
        self:StartIntervalThink(self.interval)
        self:Burn()
        self:PlayEffects2()
    else
        self:Move_Burn()
    end
end

function modifier_invoker_chaos_meteor_custom_thinker:Burn()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _, enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        ApplyDamage(self.damageTable)
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invoker_chaos_meteor_custom_burn", { duration = self.duration } )
    end
end

function modifier_invoker_chaos_meteor_custom_thinker:Move_Burn()
    local parent = self:GetParent()
    local target = self.direction * self.speed * self.interval
    parent:SetOrigin(parent:GetOrigin() + target)
    self.nMoveStep = self.nMoveStep+1
    self:Burn()

    if self.nMoveStep and self.nMoveStep > 20 then
        self:Destroy()
        return
    end

    if (parent:GetOrigin() - self.parent_origin + target):Length2D() > self.distance then
        self:Destroy()
        return
    end
end

function modifier_invoker_chaos_meteor_custom_thinker:PlayEffects1()
    local height = 1000
    local height_target = -0
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.caster_origin + Vector(0, 0, height))
    ParticleManager:SetParticleControl(effect_cast, 1, self.parent_origin + Vector(0, 0, height_target))
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(self.delay, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    EmitSoundOnLocationWithCaster(self.caster_origin, "Hero_Invoker.ChaosMeteor.Cast", self:GetCaster())
    self:GetParent():EmitSound( "Hero_Invoker.ChaosMeteor.Loop")
end

function modifier_invoker_chaos_meteor_custom_thinker:PlayEffects2()
    local meteor_projectile = 
    {
        Ability = self:GetAbility(),
        EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
        vSpawnOrigin = self.parent_origin,
        fDistance = self.distance,
        fStartRadius = self.radius,
        fEndRadius = self.radius,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_NONE,
        bDeleteOnHit = false,
        vVelocity = self.direction * self.speed,
        bProvidesVision = true,
        iVisionRadius = self.vision,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }
    self.nLinearProjectile = ProjectileManager:CreateLinearProjectile(meteor_projectile)
    EmitSoundOnLocationWithCaster(self.parent_origin, "Hero_Invoker.ChaosMeteor.Impact", self:GetCaster())
end

modifier_invoker_chaos_meteor_custom_burn = class({})

function modifier_invoker_chaos_meteor_custom_burn:OnCreated(kv)
    if IsServer() then
        if self:GetAbility() and (not self:GetAbility():IsNull()) then
            local damage = self:GetAbility():GetSpecialValueFor("burn_dps")
            local delay = 1
            self.damageTable = {
                victim = self:GetParent(),
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility(),
            }
            self:StartIntervalThink(delay)
        end
    end
end

function modifier_invoker_chaos_meteor_custom_burn:OnIntervalThink()
    if IsServer() then
        if self:GetParent() and self:GetAbility() and (not self:GetAbility():IsNull()) then
            ApplyDamage(self.damageTable)
            self:GetParent():EmitSound("Hero_Invoker.ChaosMeteor.Damage")
        end
    end
end

function modifier_invoker_chaos_meteor_custom_burn:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_invoker_chaos_meteor_custom_burn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_invoker_tornado_custom", "abilities/invoker", LUA_MODIFIER_MOTION_BOTH)

invoker_tornado_custom = class({})

function invoker_tornado_custom:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()

    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end

    self.caster_origin = self:GetCaster():GetOrigin()

    self.parent_origin = point

    self.direction = self.parent_origin - self.caster_origin

    self.direction.z = 0

    self.direction = self.direction:Normalized()

    self.radius = self:GetSpecialValueFor("area_of_effect")
    self.distance = self:GetSpecialValueFor("travel_distance")
    self.speed = self:GetSpecialValueFor("travel_speed")
    self.vision = self:GetSpecialValueFor("vision_distance")
    self.vision_duration = self:GetSpecialValueFor("end_vision_duration")
    self.duration = self:GetSpecialValueFor("lift_duration")

    local tornado_projectile = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        vSpawnOrigin = self.caster_origin,
        fDistance = self.distance,
        fStartRadius = self.radius,
        fEndRadius = self.radius,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit = false,
        vVelocity = self.direction * self.speed,
        bProvidesVision = true,
        iVisionRadius = self.vision,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        fExpireTime = GameRules:GetGameTime() + 10
    }

    ProjectileManager:CreateLinearProjectile(tornado_projectile)
    EmitSoundOnLocationWithCaster(self.caster_origin, "Hero_Invoker.Tornado.Cast", self:GetCaster())
end

function invoker_tornado_custom:OnProjectileHit(hTarget, vLocation)
    if not hTarget then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, self.vision, self.vision_duration, false)
        return nil
    end
    hTarget:AddNewModifier(self:GetCaster(), self, "modifier_invoker_tornado_custom", { duration = self.duration })
    return false
end

modifier_invoker_tornado_custom = class({})

function modifier_invoker_tornado_custom:IsMotionController()
    return true
end

function modifier_invoker_tornado_custom:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH
end

function modifier_invoker_tornado_custom:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf"
end

function modifier_invoker_tornado_custom:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_invoker_tornado_custom:OnCreated(kv)
    if not IsServer() then return end
    EmitSoundOn("Hero_Invoker.Tornado.Target", self:GetParent())
    self:GetParent():Purge(true, false, false, false, false)
    local delay = 1
    self:GetParent():StartGesture(ACT_DOTA_FLAIL)
    self.angle = self:GetParent():GetAngles()
    self.abs = self:GetParent():GetAbsOrigin()
    self.cyc_pos = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(FrameTime())
end

function modifier_invoker_tornado_custom:OnIntervalThink()
    if not self:CheckMotionControllers() then
        self:Destroy()
        return
    end
    self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_invoker_tornado_custom:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("Hero_Invoker.Tornado.Target", self:GetParent())

    self:GetParent():EmitSound("Hero_Invoker.Tornado.LandDamage")

    self:GetParent():FadeGesture(ACT_DOTA_FLAIL)

    self:GetParent():SetAbsOrigin(self.abs)

    ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)

    self:GetParent():SetAngles(self.angle[1], self.angle[2], self.angle[3])

    local damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetAbility():GetSpecialValueFor("wex_damage")

    if self:GetCaster() and self:GetAbility() then
        local damageTable = 
        { 
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility() 
        }
        ApplyDamage(damageTable)
    end
end

function modifier_invoker_tornado_custom:CheckState()
    local state =    
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_invoker_tornado_custom:HorizontalMotion(unit, time)
    if not IsServer() then return end
    local angle = self:GetParent():GetAngles()
    local new_angle = RotateOrientation(angle, QAngle(0, 20, 0))
    self:GetParent():SetAngles(new_angle[1], new_angle[2], new_angle[3])
    if self:GetElapsedTime() <= 0.3 then
        self.cyc_pos.z = self.cyc_pos.z + 50
        self:GetParent():SetAbsOrigin(self.cyc_pos)
    elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
        self.step = self.step or (self.cyc_pos.z - self.abs.z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
        self.cyc_pos.z = self.cyc_pos.z - self.step
        self:GetParent():SetAbsOrigin(self.cyc_pos)
    else
        local pos = GetRandomPosition2D(self:GetParent():GetAbsOrigin(), 5)
        if (pos - self.abs):Length2D() < 50  then
            self:GetParent():SetAbsOrigin(pos)
        end
    end
end

function modifier_invoker_tornado_custom:CheckMotionControllers()
    if not IsServer() then
       return 
    end

    local parent = self:GetParent()
    local modifier_priority = self:GetMotionControllerPriority()
    local is_motion_controller = false
    local motion_controller_priority
    local found_modifier_handler

    local non_motion_controllers =
    {
        "modifier_earthshaker_enchant_moment_jump",
        "modifier_earthshaker_enchant_totem_custom_jump",
        "modifier_invoker_tornado",
        "modifier_pudge_chain_binding",
    }

    local modifiers = parent:FindAllModifiers() 

    for _,modifier in pairs(modifiers) do       
        if self ~= modifier then            
            if modifier.IsMotionController then
                if modifier:IsMotionController() then
                    found_modifier_handler = modifier
                    is_motion_controller = true
                    motion_controller_priority = modifier:GetMotionControllerPriority()                 
                    break
                end
            end
            for _,non_imba_motion_controller in pairs(non_motion_controllers) do                
                if modifier:GetName() == non_imba_motion_controller then
                    found_modifier_handler = modifier
                    is_motion_controller = true
                    motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST              
                    break
                end
            end
        end
    end

    if is_motion_controller and motion_controller_priority then
        if motion_controller_priority > modifier_priority then          
            return false
        elseif motion_controller_priority == modifier_priority then         
            if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then              
                return false
            else                
                found_modifier_handler:Destroy()
                return true
            end
        else            
            parent:InterruptMotionControllers(true)
            found_modifier_handler:Destroy()
            return true
        end
    else
        return true
    end
end

function GetRandomPosition2D(point, distance)
    return point + RandomVector(distance)
end

LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_invoker_deafening_blast_custom", "abilities/invoker",LUA_MODIFIER_MOTION_NONE )

invoker_deafening_blast_custom = class({})

function invoker_deafening_blast_custom:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)

    if target_loc == self:GetCaster():GetAbsOrigin() then
        target_loc = target_loc + self:GetCaster():GetForwardVector()
    end

    local direction = (target_loc - caster_loc):Normalized()

    local index = DoUniqueString("invoker_deafening_blast_custom")
    self[index] = {}

    local travel_distance = self:GetSpecialValueFor("travel_distance")
    local travel_speed = self:GetSpecialValueFor("travel_speed")
    local radius_start = self:GetSpecialValueFor("radius_start")
    local radius_end = self:GetSpecialValueFor("radius_end")

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = travel_distance,
        fStartRadius        = radius_start,
        fEndRadius          = radius_end,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 1.5,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * travel_speed,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }

    --if caster:HasTalent("special_bonus_birzha_ram_8") then
    --    i = -30
    --    for var=1,13, 1 do
    --        ProjectileManager:CreateLinearProjectile(projectile)
    --        projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * 1000
    --        i = i + 30
    --    end
    --else
        ProjectileManager:CreateLinearProjectile(projectile)
    --end

    caster:EmitSound("Hero_Invoker.DeafeningBlast")
end

function invoker_deafening_blast_custom:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then

        local was_hit = false

        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end

        if was_hit then
            return false
        end

        table.insert(self[ExtraData.index],target)

        local damage = self:GetSpecialValueFor("damage")
        local knockback_duration = self:GetSpecialValueFor("knockback_duration")
        local knockback_distance = self:GetSpecialValueFor("knockback_distance")
        local disarm_duration =  self:GetSpecialValueFor("disarm_duration")

        local direction = (target:GetAbsOrigin() - location):Normalized()

        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = knockback_duration, distance = knockback_distance, height = 0, direction_x = direction.x, direction_y = direction.y})

        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

        target:AddNewModifier(self:GetCaster(), self, "modifier_invoker_deafening_blast_custom", {duration = disarm_duration * (1 - target:GetStatusResistance())})

        if knockback then
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_deafening_blast_knockback_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            knockback:AddParticle(particle, false, false, -1, false, false)
        end
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end

modifier_invoker_deafening_blast_custom = class({})

function modifier_invoker_deafening_blast_custom:IsPurgable()
    return false
end

function modifier_invoker_deafening_blast_custom:IsPurgeException()
    return true
end

function modifier_invoker_deafening_blast_custom:GetEffectName() return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf" end
function modifier_invoker_deafening_blast_custom:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_invoker_deafening_blast_custom:GetStatusEffectName() return "particles/status_fx/status_effect_iceblast.vpcf" end
function modifier_invoker_deafening_blast_custom:StatusEffectPriority() return 10 end

function modifier_invoker_deafening_blast_custom:CheckState() 
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

LinkLuaModifier("modifier_invoker_ice_wall_custom", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_ice_wall_custom_slow", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_ice_wall_custom_aura", "abilities/invoker", LUA_MODIFIER_MOTION_NONE)

invoker_ice_wall_custom = class({})

function invoker_ice_wall_custom:OnSpellStart()
    if not IsServer() then return end

    local caster                        = self:GetCaster()
    local caster_point                  = caster:GetAbsOrigin() 
    local caster_direction              = caster:GetForwardVector()
    local cast_direction                = Vector(-caster_direction.y, caster_direction.x, caster_direction.z)
    local ice_wall_placement_distance   = self:GetSpecialValueFor("wall_place_distance")
    local ice_wall_length               = 1120
    local ice_wall_slow_duration        = self:GetSpecialValueFor("slow_duration")
    local ice_wall_area_of_effect       = self:GetSpecialValueFor("wall_element_radius")
    local ice_wall_duration             = self:GetSpecialValueFor("duration")
    local ice_wall_slow                 = self:GetSpecialValueFor("slow")

    self.endpoint_distance_from_center   = (cast_direction * ice_wall_length) / 2
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ICE_WALL)
    self:GetCaster():EmitSound("Hero_Invoker.IceWall.Cast")

    local ice_wall_effects              = ""
    local ice_wall_spike_effects        = ""
    local ice_walls         = 1
    local ice_wall_offset   = 0
    local z_offset          = 0 

    for i = 0, (ice_walls -1) do 
        local target_point = caster_point + (caster_direction * ice_wall_placement_distance + (ice_wall_offset * i))
        target_point = GetGroundPosition(target_point, caster)
        
        local ice_wall_point = target_point
        ice_wall_point.z = ice_wall_point.z - z_offset

        local ice_wall_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(ice_wall_particle_effect, 0, ice_wall_point - self.endpoint_distance_from_center)
        ParticleManager:SetParticleControl(ice_wall_particle_effect, 1, ice_wall_point + self.endpoint_distance_from_center)

        if ice_wall_effects == "" then 
            ice_wall_effects = string.format("%d", ice_wall_particle_effect)
        else
            ice_wall_effects = string.format("%s %d", ice_wall_effects, ice_wall_particle_effect)
        end
    end

    local thinker_point = caster_point 
    local thinger_area  = ice_wall_area_of_effect
    if ice_walls - 1 == 0 then 
        thinker_point = thinker_point + (caster_direction * ice_wall_placement_distance)
    else
        thinker_point = thinker_point + (caster_direction * ice_wall_placement_distance + (ice_wall_offset * ((ice_walls - 1) / 2)))
        ice_wall_area_of_effect = ice_wall_area_of_effect + (100 * ((ice_walls - 1) / 2))
    end

    CreateModifierThinker(caster, self, "modifier_invoker_ice_wall_custom", { duration = ice_wall_duration, ice_wall_slow_duration = ice_wall_slow_duration, ice_wall_slow = ice_wall_slow, ice_wall_area_of_effect = ice_wall_area_of_effect, ice_wall_length = ice_wall_length, ice_wall_particle_effect = ice_wall_effects, ice_wall_particle_effect_spikes = ice_wall_spike_effects}, thinker_point, caster:GetTeamNumber(), false)
end

modifier_invoker_ice_wall_custom = class({})
modifier_invoker_ice_wall_custom.npc_radius_constant = 65

function modifier_invoker_ice_wall_custom:OnCreated(kv)
    if IsServer() then
        self.slow_duration                      = kv.ice_wall_slow_duration
        self.ice_wall_slow                      = kv.ice_wall_slow
        self.ice_wall_area_of_effect            = kv.ice_wall_area_of_effect
        self.ice_wall_length                    = kv.ice_wall_length
        self.search_area                        = kv.ice_wall_length + (kv.ice_wall_area_of_effect * 2)
        self.GetTeam                            = self:GetParent():GetTeam()
        self.origin                             = self:GetParent():GetAbsOrigin()
        self.ability                            = self:GetAbility()
        self.endpoint_distance_from_center      = self:GetAbility().endpoint_distance_from_center
        self.ice_wall_start_point               = self.origin - self.endpoint_distance_from_center
        self.ice_wall_end_point                 = self.origin + self.endpoint_distance_from_center
        self.ice_wall_particle_effect           = kv.ice_wall_particle_effect
        self.ice_wall_particle_effect_spikes    = kv.ice_wall_particle_effect_spikes

        -- ОПТИМИЗАЦИЯ: Уменьшена частота проверки с 0.1 до 0.2 секунды
        self:StartIntervalThink(0.2)
    end
end

function modifier_invoker_ice_wall_custom:OnIntervalThink()
    if IsServer() then
        local nearby_enemy_units = FindUnitsInRadius( self.GetTeam,  self.origin,  nil,  self.search_area,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  0,  FIND_ANY_ORDER,  false)
        for _,enemy in pairs(nearby_enemy_units) do
            if enemy ~= nil and enemy:IsAlive() then
                local target_position = enemy:GetAbsOrigin()
                if self:IsUnitInProximity(self.ice_wall_start_point, self.ice_wall_end_point, target_position, self.ice_wall_area_of_effect) then
                    enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_invoker_ice_wall_custom_slow", {duration = self.slow_duration, enemy_slow = self.ice_wall_slow * (1 - enemy:GetStatusResistance())})
                end
            end
        end
    end
end

function modifier_invoker_ice_wall_custom:OnRemoved() 
    if self.ice_wall_particle_effect ~= nil then
        for effect in string.gmatch(self.ice_wall_particle_effect, "([^ ]+)") do
            ParticleManager:DestroyParticle(tonumber(effect), false)                
        end
    end
    if self.ice_wall_particle_effect_spikes ~= nil then
        for effect in string.gmatch(self.ice_wall_particle_effect_spikes, "([^ ]+)") do
            ParticleManager:DestroyParticle(tonumber(effect), false)
        end
    end
end

function modifier_invoker_ice_wall_custom:IsUnitInProximity(start_point, end_point, target_position, ice_wall_radius)
    local ice_wall = end_point - start_point
    local target_vector = target_position - start_point
    local ice_wall_normalized = ice_wall:Normalized()
    local ice_wall_dot_vector = target_vector:Dot(ice_wall_normalized)
    local search_point
    if ice_wall_dot_vector <= 0 then
        search_point = start_point
    elseif ice_wall_dot_vector >= ice_wall:Length2D() then
        search_point = end_point
    else
        search_point = start_point + (ice_wall_normalized * ice_wall_dot_vector)
    end 
    local distance = target_position - search_point
    return distance:Length2D() <= ice_wall_radius + modifier_invoker_ice_wall_custom.npc_radius_constant
end

modifier_invoker_ice_wall_custom_aura = class({})

function modifier_invoker_ice_wall_custom_aura:IsHidden() return true end
function modifier_invoker_ice_wall_custom_aura:IsPurgable() return false end

function modifier_invoker_ice_wall_custom_aura:OnCreated(kv)
    if IsServer() then
        self.slow_duration                      = kv.ice_wall_slow_duration
        self.ice_wall_slow                      = kv.ice_wall_slow
        self.GetTeam                            = self:GetParent():GetTeam()
        self.origin                             = self:GetParent():GetAbsOrigin()
        self.ability                            = self:GetAbility()
        self.ice_wall_particle_effect           = kv.ice_wall_particle_effect

        -- ОПТИМИЗАЦИЯ: Уменьшена частота проверки с 0.1 до 0.2 секунды
        self:StartIntervalThink(0.2)
    end
end

function modifier_invoker_ice_wall_custom_aura:OnIntervalThink()
    if IsServer() then
        local nearby_enemy_units = FindUnitsInRadius( self.GetTeam,  self.origin,  nil,  650,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  0,  FIND_ANY_ORDER,  false)
        for _,enemy in pairs(nearby_enemy_units) do
            if enemy ~= nil and enemy:IsAlive() then
                local target_position = enemy:GetAbsOrigin()
                enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_invoker_ice_wall_custom_slow", {duration = self.slow_duration, enemy_slow = self.ice_wall_slow * (1 - enemy:GetStatusResistance())})
            end
        end
    end
end

function modifier_invoker_ice_wall_custom_aura:OnRemoved() 
    if self.ice_wall_particle_effect ~= nil then
        for effect in string.gmatch(self.ice_wall_particle_effect, "([^ ]+)") do
            ParticleManager:DestroyParticle(tonumber(effect), false)                
        end
    end
end

modifier_invoker_ice_wall_custom_slow = class({})

function modifier_invoker_ice_wall_custom_slow:IsPassive() return false end
function modifier_invoker_ice_wall_custom_slow:IsBuff() return false end
function modifier_invoker_ice_wall_custom_slow:IsDebuff() return true  end
function modifier_invoker_ice_wall_custom_slow:IsPurgable() return false end
function modifier_invoker_ice_wall_custom_slow:IsHidden() return false end
function modifier_invoker_ice_wall_custom_slow:GetEffectName() return "particles/units/heroes/hero_invoker/invoker_ice_wall_debuff.vpcf" end
function modifier_invoker_ice_wall_custom_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_invoker_ice_wall_custom_slow:StatusEffectPriority() return 10 end

function modifier_invoker_ice_wall_custom_slow:OnCreated()
    if not IsServer() then return end
    self.origin = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(0.5)
end

function modifier_invoker_ice_wall_custom_slow:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second")

    if (self:GetParent():GetAbsOrigin() - self.origin):Length2D() > 0 then
        self.origin = self:GetParent():GetAbsOrigin()
    end

    damage = damage * 0.5

    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_invoker_ice_wall_custom_slow:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_invoker_ice_wall_custom_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end
