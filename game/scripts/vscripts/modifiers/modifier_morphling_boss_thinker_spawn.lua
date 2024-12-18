modifier_morphling_boss_thinker_spawn = class({})

function modifier_morphling_boss_thinker_spawn:IsAura()
    return true
end

function modifier_morphling_boss_thinker_spawn:GetModifierAura()
    return "modifier_morphling_boss_thinker_spawn_stun"
end

function modifier_morphling_boss_thinker_spawn:GetAuraRadius()
    return -1
end

function modifier_morphling_boss_thinker_spawn:GetAuraDuration()
    return 0
end

function modifier_morphling_boss_thinker_spawn:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_morphling_boss_thinker_spawn:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_morphling_boss_thinker_spawn:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

modifier_morphling_boss_thinker_spawn_stun = class({})
function modifier_morphling_boss_thinker_spawn_stun:IsHidden() return true end
function modifier_morphling_boss_thinker_spawn_stun:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
end