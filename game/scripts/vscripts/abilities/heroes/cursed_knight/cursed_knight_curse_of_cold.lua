LinkLuaModifier('modifier_cursed_knight_curse_of_cold', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_cold', LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier('modifier_cursed_knight_curse_of_cold_speed', 'abilities/heroes/cursed_knight/cursed_knight_curse_of_cold', LUA_MODIFIER_MOTION_NONE)

cursed_knight_curse_of_cold = cursed_knight_curse_of_cold or {}

function cursed_knight_curse_of_cold:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
    local duration = ability:GetSpecialValueFor("duration")
    local slow_movement = ability:GetSpecialValueFor("movement_slow_per_second")
    local FacetID = caster:GetHeroFacetID()
    if not target:TriggerSpellAbsorb( self ) then 
        EmitSoundOn("hero_Crystal.frostbite", target )
        target:AddNewModifier(caster, ability, "modifier_cursed_knight_curse_of_cold", {duration = duration})
    else 
        self:EndCooldown()
        self:RefundManaCost()
    end
end


modifier_cursed_knight_curse_of_cold = modifier_cursed_knight_curse_of_cold or {}
function modifier_cursed_knight_curse_of_cold:IsHidden() return false end
function modifier_cursed_knight_curse_of_cold:IsPurgable() return true end
function modifier_cursed_knight_curse_of_cold:OnCreated(kkd) self:StartIntervalThink(1) end
function modifier_cursed_knight_curse_of_cold:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE  } end

function modifier_cursed_knight_curse_of_cold:OnIntervalThink(sss)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()
    local perid_damage = ability:GetSpecialValueFor("perid_damage")
    local FacetID = caster:GetHeroFacetID()
    if FacetID == 3 then perid_damage = perid_damage*1.03 end
    ApplyDamage({victim = parent, attacker = ability:GetCaster(),damage = perid_damage, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_DAMAGE_FLAG_NONE, ability})
end
function modifier_cursed_knight_curse_of_cold:GetModifierMoveSpeedBonus_Percentage()
    local slow_pct_per_sec = self:GetAbility():GetSpecialValueFor("movement_slow_per_second") 
    local idur = self:GetRemainingTime() 
    return -slow_pct_per_sec*idur
end
function modifier_cursed_knight_curse_of_cold:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_cursed_knight_curse_of_cold:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end