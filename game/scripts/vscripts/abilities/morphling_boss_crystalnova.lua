LinkLuaModifier("modifier_morphling_boss_crystalnova", "abilities/morphling_boss_crystalnova", LUA_MODIFIER_MOTION_NONE)

morphling_boss_crystalnova = class({})

function morphling_boss_crystalnova:Start(target)
    if not IsServer() then return end
    self:PlayEffects(target:GetAbsOrigin(),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("duration"))
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),target:GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,0,0,false)
    local damageTable = {attacker = self:GetCaster(),damage = self:GetSpecialValueFor("nova_damage"),damage_type = DAMAGE_TYPE_MAGICAL,ability = self}
    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage(damageTable)
        enemy:AddNewModifier(self:GetCaster(),self,"modifier_morphling_boss_crystalnova",{duration = self:GetSpecialValueFor("duration") * ( 1 - enemy:GetStatusResistance() )})
    end
end

function morphling_boss_crystalnova:PlayEffects(point,radius,duration)
	local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
	local sound_cast = "Hero_Crystal.CrystalNova"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, duration, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

modifier_morphling_boss_crystalnova = class({})

function modifier_morphling_boss_crystalnova:IsHidden() return false end
function modifier_morphling_boss_crystalnova:IsDebuff() return true end
function modifier_morphling_boss_crystalnova:IsPurgable() return true end

function modifier_morphling_boss_crystalnova:OnCreated( kv )
	self.as_slow = self:GetAbility():GetSpecialValueFor( "attackspeed_slow" )
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "movespeed_slow" )
end

function modifier_morphling_boss_crystalnova:OnRefresh( kv )
	self.as_slow = self:GetAbility():GetSpecialValueFor( "attackspeed_slow" )
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "movespeed_slow" )
end

function modifier_morphling_boss_crystalnova:DeclareFunctions()
	return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_morphling_boss_crystalnova:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_morphling_boss_crystalnova:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow
end

function modifier_morphling_boss_crystalnova:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_morphling_boss_crystalnova:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end