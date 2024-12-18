morphling_boss_finger = class({})

function morphling_boss_finger:Start(target)
    local damageTable = { attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self }
    local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs(targets) do
        self:PlayEffects( enemy )
        Timers:CreateTimer(0.25, function()
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end)
    end
end

function morphling_boss_finger:PlayEffects( target )
    local caster = self:GetCaster()
    local direction = (caster:GetOrigin()-target:GetOrigin()):Normalized()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControlEnt(  effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 2, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 3, target:GetOrigin() + direction )
    ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("Hero_Lion.FingerOfDeathImpact")
end