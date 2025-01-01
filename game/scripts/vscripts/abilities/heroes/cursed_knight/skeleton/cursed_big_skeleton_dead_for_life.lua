

cursed_big_skeleton_dead_for_life = cursed_big_skeleton_dead_for_life or {}

function cursed_big_skeleton_dead_for_life:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster() -- наш скелет
    local damage = self:GetSpecialValueFor("damage")
    local heal_pct = self:GetSpecialValueFor("heal_pct")/100
    local radius = self:GetSpecialValueFor("radius")
    local team = caster:GetTeam()
    local point = caster:GetOrigin()
    local hp = caster:GetHealth()
    local caster_owner = caster:GetPlayerOwner()
    local caster_ownerHERO = caster_owner:GetAssignedHero()
    local hp_to_owner = hp*heal_pct
    local units = FindUnitsInRadius(team,point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC ,DOTA_UNIT_TARGET_FLAG_NONE ,FIND_ANY_ORDER ,false )
    for _, unit in pairs(units) do
        ApplyDamage({
            victim = unit,
            attacker = caster, 
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
        })
    end
    caster_ownerHERO:Heal(hp_to_owner,self)
    ApplyDamage({
        victim = caster,
        attacker = caster_ownerHERO, 
        damage = hp_to_owner,
        damage_type = DAMAGE_TYPE_PURE,
    })
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pfx)
    EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", caster)
end