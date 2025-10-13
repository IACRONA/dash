LinkLuaModifier("cursed_knight_summon_deadman_generic_modifier", "abilities/heroes/cursed_knight/cursed_knight_summon_deadman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("cursed_knight_summon_deadman_generic_modifier2", "abilities/heroes/cursed_knight/cursed_knight_summon_deadman", LUA_MODIFIER_MOTION_NONE)

cursed_knight_summon_deadman = cursed_knight_summon_deadman or {}
function cursed_knight_summon_deadman:GetIntrinsicModifierName()
    return "cursed_knight_summon_deadman_generic_modifier2"
end

cursed_knight_summon_deadman_generic_modifier2 = cursed_knight_summon_deadman_generic_modifier2 or {}
function cursed_knight_summon_deadman_generic_modifier2:IsHidden() return false end
function cursed_knight_summon_deadman_generic_modifier2:IsPurgable() return false end
function cursed_knight_summon_deadman_generic_modifier2:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function cursed_knight_summon_deadman_generic_modifier2:OnTakeDamage(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local attacker = keys.attacker
    local unit = keys.unit
    if attacker == parent then 
        local random = RandomInt(1, 100)
        if random <= 30 then
            local caster = self:GetCaster()
            local unitname = "npc_dota_cursed_big_skeleton"
            local point = caster:GetOrigin() 
            local team = caster:GetTeam()
            
            -- Проверка: если скелет жив, убиваем старого
            if self.skeleton and not self.skeleton:IsNull() and self.skeleton:IsAlive() then 
                self.skeleton:ForceKill(false)
            end
            
            -- КД на призыв - не чаще 1 раза в 15 секунд
            if self.summon_cooldown and GameRules:GetGameTime() < self.summon_cooldown then return end
            
            self.skeleton = CreateUnitByName(unitname, point, true, caster, caster, team)
            local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
            ParticleManager:SetParticleControl(nfx, 0, self.skeleton:GetOrigin())
            ParticleManager:ReleaseParticleIndex(nfx)
            EmitSoundOn( "n_creep_Skeleton.Spawn", caster )
            EmitSoundOn( "summon_deadman", caster )
            self.skeleton:StartGesture( ACT_DOTA_SPAWN )
            self.skeleton:AddNewModifier(caster, self, "cursed_knight_summon_deadman_generic_modifier", {duration = -1})
            self.skeleton.owner = caster
            self.skeleton:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
            
            -- Устанавливаем КД 15 секунд
            self.summon_cooldown = GameRules:GetGameTime() + 15
        end
    end
end

function cursed_knight_summon_deadman_generic_modifier2:OnCreated()
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.ability:SetHidden(true)
end
function cursed_knight_summon_deadman_generic_modifier2:GetTexture() return "cursed_knight/summon_deadman" end



cursed_knight_summon_deadman_generic_modifier = cursed_knight_summon_deadman_generic_modifier or {}
function cursed_knight_summon_deadman_generic_modifier:IsHidden() return false end
function cursed_knight_summon_deadman_generic_modifier:IsPurgable() return false end
function cursed_knight_summon_deadman_generic_modifier:OnCreated()
    if not IsServer() then return end
    self.parent = self:GetParent() 
    self.caster = PlayerResource:GetSelectedHeroEntity(self.parent:GetPlayerOwnerID()) 
    self.follow_distance = 200 -- Дистанция, на которой скелет будет следовать за создателем
    self:StartIntervalThink(0.5)
end
function cursed_knight_summon_deadman_generic_modifier:OnDestroy()
    if not IsServer() then return end
    -- Сбрасываем КД при смерти скелета
    local caster_modifier = self.caster:FindModifierByName("cursed_knight_summon_deadman_generic_modifier2")
    if caster_modifier then
        caster_modifier.skeleton = nil
    end
end
function cursed_knight_summon_deadman_generic_modifier:OnIntervalThink()
    if not IsServer() then return end

    -- Проверяем валидность кастера
    if not self.caster or self.caster:IsNull() or not self.caster:IsAlive() then
        self.parent:ForceKill(false)
        return
    end

    local distance = (self.parent:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if distance > self.follow_distance then
        self.parent:MoveToPosition(self.caster:GetAbsOrigin() + RandomVector(100))
    end
    if self.caster:IsAttacking() then
        local target = self.caster:GetAttackTarget()
        if target and target:IsAlive() then
            if self.parent:GetAttackTarget() ~= target and target:GetTeam() ~= self.parent:GetTeam() then
                self.parent:MoveToTargetToAttack(target)
            end
        end
    end
end