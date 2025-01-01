LinkLuaModifier("cursed_knight_summon_deadman_generic_modifier", "abilities/heroes/cursed_knight/cursed_knight_summon_deadman", LUA_MODIFIER_MOTION_NONE)

cursed_knight_summon_deadman = cursed_knight_summon_deadman or {}



function cursed_knight_summon_deadman:OnSpellStart() 
    local caster = self:GetCaster()
    local unitname = "npc_dota_cursed_big_skeleton"
    local point = caster:GetOrigin() 
    local team = caster:GetTeam()
    if skeleton then skeleton:ForceKill(false) end
    skeleton = CreateUnitByName(unitname, point, true, caster, caster, team)
    skeleton:AddNewModifier(caster, self, "cursed_knight_summon_deadman_generic_modifier", {duration = -1})
    skeleton.owner = caster
    skeleton:SetControllableByPlayer(caster:GetPlayerOwnerID(), false) -- TODO: СДЕЛАТЬ ЧТОБЫ ХОДИТЬ НЕЛЬЗЯ БЫЛО, А ИСПОЛЬЗОВАТЬ АБИЛКИ МОЖНО
    local nfx = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, skeleton:GetOrigin())
	ParticleManager:ReleaseParticleIndex(nfx)
    EmitSoundOn( "n_creep_Skeleton.Spawn", caster )
    skeleton:StartGesture( ACT_DOTA_SPAWN )
end


cursed_knight_summon_deadman_generic_modifier = cursed_knight_summon_deadman_generic_modifier or {}
function cursed_knight_summon_deadman_generic_modifier:IsHidden() return true end
function cursed_knight_summon_deadman_generic_modifier:IsPurgable() return false end
function cursed_knight_summon_deadman_generic_modifier:OnCreated()
    if not IsServer() then return end
    self.parent = self:GetParent() 
    self.caster = self:GetCaster() 
    self.ability = self:GetAbility()
    self.follow_distance = 300 -- Дистанция, на которой скелет будет следовать за создателем
    self:StartIntervalThink(0.1)
end
function cursed_knight_summon_deadman_generic_modifier:OnIntervalThink()
    if not IsServer() then return end

    local distance = (self.parent:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if distance > self.follow_distance then
        self.parent:MoveToPosition(self.caster:GetAbsOrigin() + RandomVector(50))
    end

    local target = self.caster:GetAttackTarget()
    if target and target:IsAlive() then
        if self.parent:GetAttackTarget() ~= target and target:GetTeam() ~= self.parent:GetTeam() then
            self.parent:MoveToTargetToAttack(target)
        end
    end
end