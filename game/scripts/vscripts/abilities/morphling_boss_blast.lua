LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_morphling_boss_blast_disarm", "abilities/morphling_boss_blast", LUA_MODIFIER_MOTION_BOTH)

morphling_boss_blast = class({})

function morphling_boss_blast:Start()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local caster_loc = caster:GetAbsOrigin()
    local direction = caster:GetForwardVector()
    local index = DoUniqueString("morph_blast")

    self[index] = {}

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = self:GetSpecialValueFor("radius"),
        fStartRadius        = 175,
        fEndRadius          = 225,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 1.5,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * self:GetSpecialValueFor("speed"),
        bProvidesVision     = false,
        ExtraData           = {index = index}
    }

    for i = 1, 12 do
        ProjectileManager:CreateLinearProjectile(projectile)
        projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,30*i,0), caster:GetForwardVector()) * 1000
    end

    caster:EmitSound("Hero_Invoker.DeafeningBlast")
end

function morphling_boss_blast:OnProjectileHit_ExtraData(target, location, ExtraData)
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

        local distance_knock = 100
        local direction = (target:GetAbsOrigin() - location):Normalized()
        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.75, distance = distance_knock, height = 0, direction_x = direction.x, direction_y = direction.y})
        local damage = self:GetSpecialValueFor("damage")

        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

        local callback = function()
            local duration = self:GetSpecialValueFor('disarm_duration')
            target:AddNewModifier(self:GetCaster(), self, "modifier_morphling_boss_blast_disarm", {duration = duration * (1 - target:GetStatusResistance())})
        end

        knockback:SetEndCallback( callback )
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end

modifier_morphling_boss_blast_disarm = class({})
function modifier_morphling_boss_blast_disarm:IsPurgable() return true end
function modifier_morphling_boss_blast_disarm:IsPurgeException() return true end
function modifier_morphling_boss_blast_disarm:GetEffectName() return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf" end
function modifier_morphling_boss_blast_disarm:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_morphling_boss_blast_disarm:CheckState() 
    return
    {
        [MODIFIER_STATE_DISARMED] = true,
    }
end