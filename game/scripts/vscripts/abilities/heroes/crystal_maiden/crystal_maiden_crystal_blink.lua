LinkLuaModifier('modifier_crystal_maiden_crystal_blink', 'abilities/heroes/crystal_maiden/crystal_maiden_crystal_blink', LUA_MODIFIER_MOTION_NONE)

crystal_maiden_crystal_blink = class({})

function crystal_maiden_crystal_blink:Precache(context)
	PrecacheResource("particle", "particles/econ/events/winter_major_2016/blink_dagger_start_winter_major_2016.vpcf", context)
end

function crystal_maiden_crystal_blink:GetCastRange(location, target)
	if IsServer() then
	  return 99999 
	end

	return self.BaseClass.GetCastRange(self, location, target)  
end

function crystal_maiden_crystal_blink:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local casterPos = caster:GetAbsOrigin()
 	local difference = point - casterPos
	difference.z = 0.0
	local difference_norm_vector = difference:Normalized()
	local range = self:GetSpecialValueFor("cast_range") + caster:GetCastRangeBonus()
 
 	if difference:Length2D() > range then
		point = casterPos + difference_norm_vector *  range   
	end
    ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/blink_dagger_start_winter_major_2016.vpcf", PATTACH_ABSORIGIN, caster)
	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

	FindClearSpaceForUnit(caster, point, true)
	caster:AddNewModifier(caster, self, "modifier_crystal_maiden_crystal_blink", {duration = self:GetSpecialValueFor("duration")})
end

modifier_crystal_maiden_crystal_blink = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE ,
    } end,
})

function modifier_crystal_maiden_crystal_blink:GetModifierIncomingDamage_Percentage(event)
	local parent = self:GetParent()

	if event.damage_category == DOTA_DAMAGE_CATEGORY_SPELL  then 
		return self:GetAbility():GetSpecialValueFor("spell_damage_reduce")
	end
end