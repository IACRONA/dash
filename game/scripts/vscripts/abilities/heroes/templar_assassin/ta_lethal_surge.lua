LinkLuaModifier("modifier_ta_lethal_surge_fly", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ta_lethal_surge_aim", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_lethal_surge_slow", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)

ta_lethal_surge = class({})

function ta_lethal_surge:OnSpellStart()
    local caster = self:GetCaster()

    -- Если уже в режиме прицеливания — вылетаем
    if caster:HasModifier("modifier_ta_lethal_surge_aim") then
        caster:RemoveModifierByName("modifier_ta_lethal_surge_aim")
        self:Launch()
        return
    end

    -- Первое нажатие — входим в режим прицеливания
    caster:AddNewModifier(caster, self, "modifier_ta_lethal_surge_aim", {})
end

function ta_lethal_surge:Launch()
    local caster = self:GetCaster()
    local cursor_pos = self:GetCursorPosition()
    local caster_pos = caster:GetAbsOrigin()

    local direction = (cursor_pos - caster_pos):Normalized()
    direction.z = 0

    local dist_to_cursor = (cursor_pos - caster_pos):Length2D()
    local max_dist = self:GetSpecialValueFor("max_distance")
    local flight_distance = math.min(dist_to_cursor, max_dist)

    EmitSoundOn("Hero_StormSpirit.BallLightning", caster)

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_stormspirit/stormspirit_balllightning.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster_pos)
    ParticleManager:ReleaseParticleIndex(particle)

    caster:AddNewModifier(caster, self, "modifier_ta_lethal_surge_fly", {
        duration = flight_distance / self:GetSpecialValueFor("flight_speed"),
        distance = flight_distance,
        direction_x = direction.x,
        direction_y = direction.y,
    })
end

-- Modifier: режим прицеливания (индикатор направления)
modifier_ta_lethal_surge_aim = class({})

function modifier_ta_lethal_surge_aim:IsHidden() return false end
function modifier_ta_lethal_surge_aim:IsBuff() return true end
function modifier_ta_lethal_surge_aim:IsPurgable() return false end

function modifier_ta_lethal_surge_aim:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_squirrel/squirrel_acorn_toss_aim.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        parent
    )
    ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)
end

-- Modifier: полёт
modifier_ta_lethal_surge_fly = class({})

function modifier_ta_lethal_surge_fly:IsHidden() return true end
function modifier_ta_lethal_surge_fly:IsPurgable() return false end

function modifier_ta_lethal_surge_fly:OnCreated(kv)
    if not IsServer() then return end

    self.direction = Vector(kv.direction_x, kv.direction_y, 0)
    self.distance = kv.distance
    self.duration = self:GetDuration()
    self.elapsed = 0
    self.start_pos = self:GetParent():GetAbsOrigin()
    self.end_pos = self.start_pos + self.direction * self.distance
    self.hit_units = {}

    self.update_interval = 0.03
    self:StartIntervalThink(self.update_interval)

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_stormspirit/stormspirit_balllightning.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    self:AddParticle(particle, false, false, -1, false, false)

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_ta_lethal_surge_fly:UpdateHorizontalMotion(me, dt)
    self.elapsed = self.elapsed + dt
    local progress = math.min(self.elapsed / self.duration, 1.0)
    local new_pos = self.start_pos + (self.end_pos - self.start_pos) * progress
    new_pos.z = GetGroundHeight(new_pos, me)
    me:SetAbsOrigin(new_pos)
end

function modifier_ta_lethal_surge_fly:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    local dmg_mult = ability:GetSpecialValueFor("damage_multiplier")
    local slow_pct = ability:GetSpecialValueFor("slow_pct")
    local slow_dur = ability:GetSpecialValueFor("slow_duration")
    local hamstring_dur = ability:GetSpecialValueFor("hamstring_duration")

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    for _, enemy in pairs(enemies) do
        if not self.hit_units[enemy:GetEntityIndex()] then
            self.hit_units[enemy:GetEntityIndex()] = true

            local damage = parent:GetAttackDamage() * dmg_mult
            ApplyDamage({
                victim = enemy,
                attacker = parent,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = ability,
            })

            -- Крит партикл
            local crit_particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_templar_assassin/templar_assassin_crit_impact.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                enemy
            )
            ParticleManager:SetParticleControl(crit_particle, 0, enemy:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_particle)

            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, enemy, damage, nil)
            EmitSoundOn("Hero_TemplarAssassin.Meld.Impact", enemy)

            -- Замедление
            enemy:AddNewModifier(parent, ability, "modifier_ta_lethal_surge_slow", {
                duration = slow_dur,
                slow_pct = slow_pct,
                hamstring_duration = hamstring_dur,
            })
        end
    end
end

function modifier_ta_lethal_surge_fly:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = false,
    }
end

function modifier_ta_lethal_surge_fly:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_ta_lethal_surge_fly:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    StopSoundOn("Hero_StormSpirit.BallLightning", parent)
    FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
end

-- Modifier: замедление + слабость (сало = hamstring)
modifier_ta_lethal_surge_slow = class({})

function modifier_ta_lethal_surge_slow:IsHidden() return false end
function modifier_ta_lethal_surge_slow:IsDebuff() return true end
function modifier_ta_lethal_surge_slow:IsPurgable() return true end

function modifier_ta_lethal_surge_slow:OnCreated(kv)
    self.slow_pct = kv.slow_pct or self:GetAbility():GetSpecialValueFor("slow_pct")
    self.hamstring_duration = kv.hamstring_duration or self:GetAbility():GetSpecialValueFor("hamstring_duration")

    if IsServer() then
        -- Слабость (hamstring — снижение атаки) на 1.5 сек
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ta_lethal_surge_hamstring", {
            duration = self.hamstring_duration,
        })
    end

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_slow.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_ta_lethal_surge_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_ta_lethal_surge_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow_pct
end

-- Modifier: hamstring (слабость — снижение урона)
LinkLuaModifier("modifier_ta_lethal_surge_hamstring", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)

modifier_ta_lethal_surge_hamstring = class({})

function modifier_ta_lethal_surge_hamstring:IsHidden() return false end
function modifier_ta_lethal_surge_hamstring:IsDebuff() return true end
function modifier_ta_lethal_surge_hamstring:IsPurgable() return true end

function modifier_ta_lethal_surge_hamstring:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_ta_lethal_surge_hamstring:GetModifierAttackSpeedBonus_Constant()
    return -60
end
