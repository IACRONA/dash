earthshaker_totem_custom = class({})

function earthshaker_totem_custom:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetOrigin()
    local radius = 300
    local magic_damage = self:GetSpecialValueFor("magic_damage")
    local pure_damage = self:GetSpecialValueFor("pure_damage")
    local chance_iskr = self:GetSpecialValueFor("chance_iskr")
    local knockback_height = self:GetSpecialValueFor("knockback_height")
    -- Находим врагов в радиусе
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )
    
    -- Создаем эффект удара
    local effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_earthshaker/earthshaker_totem_cast.vpcf",
        PATTACH_WORLDORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(effect, 0, point)
    ParticleManager:ReleaseParticleIndex(effect)
    
    -- Проигрываем звук
    EmitSoundOn("Hero_EarthShaker.Totem", caster)
    
    for _, enemy in pairs(enemies) do
        -- Подбрасываем врагов
        local knockback = {
            center_x = point.x, 
            center_y = point.y,
            center_z = point.z,
            duration = 0.5,
            knockback_duration = 0.5,
            knockback_height = knockback_height
        }
        enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)
        
        -- Наносим магический урон всегда
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = magic_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        })
        
        -- Проверяем шанс искры для чистого урона
        if RollPercentage(chance_iskr) then
            ApplyDamage({
                victim = enemy,
                attacker = caster,
                damage = pure_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self
            })
            local radius = 0.5
            -- Эффект искры
            local spark_effect = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_low.vpcf",
                PATTACH_ABSORIGIN,
                enemy
            )
            ParticleManager:SetParticleControl(spark_effect, 1, Vector(radius, radius, radius))
            ParticleManager:ReleaseParticleIndex(spark_effect)
        end
    end
end