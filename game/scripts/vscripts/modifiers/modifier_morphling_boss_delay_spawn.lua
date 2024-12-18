modifier_morphling_boss_delay_spawn = class({})
function modifier_morphling_boss_delay_spawn:IsPurgable() return false end
function modifier_morphling_boss_delay_spawn:IsHidden() return true end
function modifier_morphling_boss_delay_spawn:IsPurgeException() return false end
function modifier_morphling_boss_delay_spawn:RemoveOnDeath() return false end
function modifier_morphling_boss_delay_spawn:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

function modifier_morphling_boss_delay_spawn:OnCreated()
    if not IsServer() then return end
end

function modifier_morphling_boss_delay_spawn:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StartGesture(ACT_DOTA_SPAWN)
end