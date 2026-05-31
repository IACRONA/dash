LinkLuaModifier("modifier_ta_lethal_surge_fly", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ta_lethal_surge_trap", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_lethal_surge_slow", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_lethal_surge_hamstring", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_lethal_surge_charges", "abilities/heroes/templar_assassin/ta_lethal_surge", LUA_MODIFIER_MOTION_NONE)

ta_lethal_surge = class({})

-- Интринзик: без аганима ограничивает максимум до 1 заряда (с аганимом 2)
function ta_lethal_surge:GetIntrinsicModifierName()
    return "modifier_ta_lethal_surge_charges"
end

-- R: ставим ловушку (движок сам тратит заряд и стартует его откат).
-- Влёт — НЕ здесь, а по правому клику по ловушке (см. TrySurgeOrder).
function ta_lethal_surge:OnSpellStart()
    self:PlaceTrap(self:GetCursorPosition())
end

-- ===== Ловушки (на поле всегда максимум 1) =====

function ta_lethal_surge:GetTrap()
    if self.trap and IsValidEntity(self.trap) and not self.trap:IsNull() and self.trap:IsAlive() then
        return self.trap
    end
    self.trap = nil
    return nil
end

function ta_lethal_surge:RemoveTrap()
    local t = self.trap
    self.trap = nil
    if t and IsValidEntity(t) and not t:IsNull() then
        t.ta_removing = true  -- чтобы OnDestroy не дёргал UTIL_Remove повторно
        UTIL_Remove(t)
    end
end

-- Ставим ловушку-юнит (кликабельный, со своим виженом). Новая убивает старую.
function ta_lethal_surge:PlaceTrap(point)
    local caster = self:GetCaster()
    point.z = GetGroundHeight(point, nil)

    self:RemoveTrap()

    local trap = CreateUnitByName("npc_ta_lethal_trap", point, false, caster, caster, caster:GetTeamNumber())
    trap:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    trap:AddNewModifier(caster, self, "modifier_ta_lethal_surge_trap", {})
    trap.ta_surge_ability = self
    self.trap = trap
    -- Ссылка на герое, чтобы фильтр приказов нашёл ульту при клике по земле
    caster.ta_surge_ability = self

    EmitSoundOnLocationWithCaster(point, "Hero_TemplarAssassin.Trap.Cast", caster)
end

-- Можно ли долететь до ловушки с текущей позиции (в пределах дистанции влёта)
function ta_lethal_surge:CanSurge(trap)
    if not trap then return false end
    if self:GetCaster():HasModifier("modifier_ta_lethal_surge_fly") then return false end
    local dist = (trap:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    return dist <= self:GetSpecialValueFor("max_distance")
end

-- Влёт по клику ПО ловушке-юниту (точное попадание)
function ta_lethal_surge:TrySurgeOrder(target)
    local trap = self:GetTrap()
    if not trap or target ~= trap then return false end
    if not self:CanSurge(trap) then return false end
    self:Launch(trap)
    return true
end

-- Влёт по клику ПО ЗЕМЛЕ рядом с ловушкой (правый клик мимо юнита)
function ta_lethal_surge:TrySurgeAtPoint(point)
    local trap = self:GetTrap()
    if not trap then return false end
    if self:GetCaster():HasModifier("modifier_ta_lethal_surge_fly") then return false end
    local snap = self:GetSpecialValueFor("launch_snap_radius")
    if (trap:GetAbsOrigin() - point):Length2D() > snap then return false end
    if not self:CanSurge(trap) then return false end
    self:Launch(trap)
    return true
end

function ta_lethal_surge:Launch(trap)
    local caster = self:GetCaster()
    local caster_pos = caster:GetAbsOrigin()
    local trap_pos = trap:GetAbsOrigin()

    local offset = trap_pos - caster_pos
    offset.z = 0
    local dist = offset:Length2D()
    local direction = offset:Normalized()

    local max_dist = self:GetSpecialValueFor("max_distance")
    -- Минимум, чтобы не делить на ноль и не глючил мотион-контроллер
    local flight_distance = math.max(1, math.min(dist, max_dist))

    -- Убираем ловушку сразу (нельзя ткнуть дважды)
    self:RemoveTrap()

    EmitSoundOn("TemplarAssassin.LethalSurge.Jump", caster)

    caster:AddNewModifier(caster, self, "modifier_ta_lethal_surge_fly", {
        duration = flight_distance / self:GetSpecialValueFor("flight_speed"),
        distance = flight_distance,
        direction_x = direction.x,
        direction_y = direction.y,
        trap_x = trap_pos.x,
        trap_y = trap_pos.y,
        trap_z = trap_pos.z,
    })
end

-- Долетели до ловушки — взрыв с доп. уроном (ловушка уже убрана при Launch)
function ta_lethal_surge:Detonate(pos)
    local caster = self:GetCaster()
    pos = pos or caster:GetAbsOrigin()

    EmitSoundOnLocationWithCaster(pos, "Hero_TemplarAssassin.Trap.Explode", caster)

    local explode_fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf",
        PATTACH_WORLDORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(explode_fx, 0, pos)
    ParticleManager:ReleaseParticleIndex(explode_fx)

    local radius = self:GetSpecialValueFor("explosion_radius")
    local explosion_damage = self:GetSpecialValueFor("explosion_damage")
    local slow_pct = self:GetSpecialValueFor("slow_pct")
    local slow_dur = self:GetSpecialValueFor("slow_duration")
    local hamstring_dur = self:GetSpecialValueFor("hamstring_duration")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        pos,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = explosion_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        })

        enemy:AddNewModifier(caster, self, "modifier_ta_lethal_surge_slow", {
            duration = slow_dur,
            slow_pct = slow_pct,
            hamstring_duration = hamstring_dur,
        })
    end
end

-- ===== Modifier: ловушка (партикл на земле + таймаут жизни) =====
modifier_ta_lethal_surge_trap = class({})

function modifier_ta_lethal_surge_trap:IsHidden() return true end
function modifier_ta_lethal_surge_trap:IsPurgable() return false end

function modifier_ta_lethal_surge_trap:OnCreated()
    if not IsServer() then return end
    local trap = self:GetParent()

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        trap
    )
    ParticleManager:SetParticleControl(particle, 0, trap:GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)

    -- Ловушка живёт ограниченное время, потом сама исчезает.
    -- (Вижен через туман даёт сам юнит-ловушка: VisionDaytimeRange в KV.)
    self:SetDuration(self:GetAbility():GetSpecialValueFor("trap_lifetime"), true)
end

-- Истёк таймаут — убираем юнит-ловушку (если её ещё не удаляют вручную)
function modifier_ta_lethal_surge_trap:OnDestroy()
    if not IsServer() then return end
    local trap = self:GetParent()
    if trap and IsValidEntity(trap) and not trap:IsNull() and not trap.ta_removing then
        local ability = self:GetAbility()
        if ability and not ability:IsNull() and ability.trap == trap then
            ability.trap = nil
        end
        UTIL_Remove(trap)
    end
end

-- ===== Modifier: полёт =====
modifier_ta_lethal_surge_fly = class({})

function modifier_ta_lethal_surge_fly:IsHidden() return true end
function modifier_ta_lethal_surge_fly:IsPurgable() return false end

function modifier_ta_lethal_surge_fly:OnCreated(kv)
    if not IsServer() then return end

    self.direction = Vector(kv.direction_x, kv.direction_y, 0)
    self.distance = kv.distance
    self.duration = math.max(0.01, self:GetDuration())
    self.elapsed = 0
    self.start_pos = self:GetParent():GetAbsOrigin()
    self.end_pos = self.start_pos + self.direction * self.distance
    self.trap_pos = Vector(kv.trap_x, kv.trap_y, kv.trap_z)
    self.hit_units = {}
    self.detonated = false

    self.update_interval = 0.03
    self:StartIntervalThink(self.update_interval)

    -- Анимация бега ног во время влёта (motion controller сам её не играет)
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_RUN, 1.2)

    -- След-хвост за героиней во время полёта (чардж Spirit Breaker / Bara)
    local parent = self:GetParent()
    local trail = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        parent
    )
    self:AddParticle(trail, false, false, -1, false, false)

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

            -- Урон от руки * множитель (pure)
            local damage = parent:GetAttackDamage() * dmg_mult
            ApplyDamage({
                victim = enemy,
                attacker = parent,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = ability,
            })

            local crit_particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_templar_assassin/templar_assassin_meld_hit.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                enemy
            )
            ParticleManager:SetParticleControl(crit_particle, 0, enemy:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_particle)

            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, enemy, damage, nil)
            EmitSoundOn("Hero_TemplarAssassin.Meld.Impact", enemy)

            -- Замедление по всем врагам, по которым попала
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
    StopSoundOn("TemplarAssassin.LethalSurge.Jump", parent)
    FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    parent:RemoveGesture(ACT_DOTA_RUN)  -- убираем анимацию бега

    -- Долетели — взрыв ловушки с доп. уроном (точно в точке ловушки)
    if not self.detonated then
        self.detonated = true
        self:GetAbility():Detonate(self.trap_pos)
    end
end

-- ===== Modifier: замедление + слабость (hamstring) =====
modifier_ta_lethal_surge_slow = class({})

function modifier_ta_lethal_surge_slow:IsHidden() return false end
function modifier_ta_lethal_surge_slow:IsDebuff() return true end
function modifier_ta_lethal_surge_slow:IsPurgable() return true end

function modifier_ta_lethal_surge_slow:OnCreated(kv)
    self.slow_pct = kv.slow_pct or self:GetAbility():GetSpecialValueFor("slow_pct")
    self.hamstring_duration = kv.hamstring_duration or self:GetAbility():GetSpecialValueFor("hamstring_duration")

    if IsServer() then
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

-- ===== Modifier: hamstring (снижение скорости атаки) =====
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

-- ===== Клампер зарядов: без аганима максимум 1, с аганимом 2 =====
-- KV даёт 2 заряда (для нативного кружка), тут режем до 1 пока нет скипетра.
modifier_ta_lethal_surge_charges = class({})

function modifier_ta_lethal_surge_charges:IsHidden() return true end
function modifier_ta_lethal_surge_charges:IsPurgable() return false end
function modifier_ta_lethal_surge_charges:RemoveOnDeath() return false end

function modifier_ta_lethal_surge_charges:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_ta_lethal_surge_charges:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability or ability:IsNull() or ability:GetLevel() < 1 then return end

    if not self:GetParent():HasScepter() then
        if ability:GetCurrentAbilityCharges() > 1 then
            ability:SetCurrentAbilityCharges(1)
        end
    end
end
