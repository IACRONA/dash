LinkLuaModifier("modifier_ta_lethal_surge_fly", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ta_lethal_surge_aim", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_lethal_surge_slow", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)

ta_lethal_surge = class({})

function ta_lethal_surge:OnSpellStart()
    local caster = self:GetCaster()

    -- POINT: точка выбрана при первом касте
    local target_pos = self:GetCursorPosition()

    -- Активируем визуальный индикатор направления
    caster:AddNewModifier(caster, self, "modifier_ta_lethal_surge_aim", {
        target_x = target_pos.x,
        target_y = target_pos.y,
        target_z = target_pos.z,
    })

    -- Сбрасываем КД основного скилла
    self:EndCooldown()

    -- Подменяем кнопку на launch (NO_TARGET, мгновенный)
    local launch_ab = caster:FindAbilityByName("ta_lethal_surge_launch")
    if not launch_ab then
        launch_ab = caster:AddAbility("ta_lethal_surge_launch")
    end
    launch_ab:SetLevel(self:GetLevel())
    launch_ab.parent_ability = self
    launch_ab.saved_target = target_pos

    caster:SwapAbilities("ta_lethal_surge", "ta_lethal_surge_launch", false, true)
end

-- Кнопка-триггер для запуска полёта (подменяется на месте основного ульта)
ta_lethal_surge_launch = class({})

function ta_lethal_surge_launch:OnSpellStart()
    local caster = self:GetCaster()
    local main_ab = self.parent_ability or caster:FindAbilityByName("ta_lethal_surge")
    local target = self.saved_target or caster:GetAbsOrigin()

    -- Возвращаем основной скилл на слот ультимейта и запускаем КД
    caster:SwapAbilities("ta_lethal_surge", "ta_lethal_surge_launch", true, false)
    caster:RemoveModifierByName("modifier_ta_lethal_surge_aim")

    if main_ab then
        main_ab:StartCooldown(main_ab:GetCooldown(main_ab:GetLevel()))
        main_ab:Launch(target)
    end

    -- Удаляем launch-абилку после использования
    caster:RemoveAbility("ta_lethal_surge_launch")
end

function ta_lethal_surge:Launch(target_pos)
    local caster = self:GetCaster()
    local caster_pos = caster:GetAbsOrigin()

    local diff = target_pos - caster_pos
    diff.z = 0
    local dist_to_cursor = diff:Length2D()

    -- Защита от каста на самого себя — используем forward, если курсор на герое
    if dist_to_cursor < 50 then
        dist_to_cursor = 300
        local fwd = caster:GetForwardVector()
        fwd.z = 0
        diff = fwd * 300
    end

    local direction = diff:Normalized()
    direction.z = 0

    local max_dist = self:GetSpecialValueFor("max_distance")
    local flight_distance = math.min(dist_to_cursor, max_dist)
    local final_pos = caster_pos + direction * flight_distance
    final_pos.z = GetGroundHeight(final_pos, caster)

    -- Ставим Psionic Trap в конечной точке (визуал + звук как у Psionic Projection / Aghanim)
    local trap_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(trap_particle, 0, final_pos)

    EmitSoundOnLocationWithCaster(final_pos, "Hero_TemplarAssassin.TrapTeleport", caster)

    -- Звук рывка Kez (Kaze прицепляется к дереву и летит к нему)
    EmitSoundOn("Hero_Kez.GrapplingClaw", caster)

    local fly_mod = caster:AddNewModifier(caster, self, "modifier_ta_lethal_surge_fly", {
        duration = flight_distance / self:GetSpecialValueFor("flight_speed"),
        distance = flight_distance,
        direction_x = direction.x,
        direction_y = direction.y,
        end_x = final_pos.x,
        end_y = final_pos.y,
        end_z = final_pos.z,
    })
    if fly_mod then
        fly_mod.trap_particle = trap_particle
    end
end

-- Modifier: режим прицеливания (индикатор направления)
modifier_ta_lethal_surge_aim = class({})

function modifier_ta_lethal_surge_aim:IsHidden() return false end
function modifier_ta_lethal_surge_aim:IsBuff() return true end
function modifier_ta_lethal_surge_aim:IsPurgable() return false end

function modifier_ta_lethal_surge_aim:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ORDER }
end

function modifier_ta_lethal_surge_aim:OnOrder(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    local order = event.order_type
    if order == DOTA_UNIT_ORDER_STOP or order == DOTA_UNIT_ORDER_HOLD_POSITION then
        local caster = self:GetParent()

        -- Возвращаем основной скилл на слот (без КД — каст был отменён)
        if caster:HasAbility("ta_lethal_surge_launch") then
            caster:SwapAbilities("ta_lethal_surge", "ta_lethal_surge_launch", true, false)
            caster:RemoveAbility("ta_lethal_surge_launch")
        end

        self:Destroy()
    end
end

function modifier_ta_lethal_surge_aim:OnCreated(kv)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local max_dist = ability:GetSpecialValueFor("max_distance")

    local target = Vector(kv.target_x or 0, kv.target_y or 0, kv.target_z or 0)
    local origin = parent:GetAbsOrigin()
    local dir = target - origin
    dir.z = 0
    local dist = dir:Length2D()
    if dist > max_dist then
        dir = dir:Normalized() * max_dist
    end
    local end_pos = origin + dir
    end_pos.z = GetGroundHeight(end_pos, parent)

    local dir_norm = dir:Normalized()

    self.aim_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_pangolier/pangolier_swashbuckle_aim.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(self.aim_particle, 0, origin)
    ParticleManager:SetParticleControl(self.aim_particle, 1, end_pos)
    ParticleManager:SetParticleControl(self.aim_particle, 2, Vector(dist, 0, 0))
    ParticleManager:SetParticleControlForward(self.aim_particle, 0, dir_norm)
    ParticleManager:SetParticleControlForward(self.aim_particle, 1, dir_norm)
    self:AddParticle(self.aim_particle, false, false, -1, false, false)
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
    self.end_pos = Vector(kv.end_x or 0, kv.end_y or 0, kv.end_z or 0)
    self.hit_units = {}

    self.update_interval = 0.03
    self:StartIntervalThink(self.update_interval)

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
    StopSoundOn("Hero_Kez.GrapplingClaw", parent)
    FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)

    -- Удаляем партикл трапа
    if self.trap_particle then
        ParticleManager:DestroyParticle(self.trap_particle, false)
        ParticleManager:ReleaseParticleIndex(self.trap_particle)
        self.trap_particle = nil
    end

    -- Взрыв трапа в точке прибытия
    local explode_pos = self.end_pos or parent:GetAbsOrigin()
    local explode_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(explode_particle, 0, explode_pos)
    ParticleManager:ReleaseParticleIndex(explode_particle)

    EmitSoundOnLocationWithCaster(explode_pos, "Hero_TemplarAssassin.Trap.Explode", parent)
    StopSoundOn("Hero_TemplarAssassin.PsionicTrap", parent)
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
