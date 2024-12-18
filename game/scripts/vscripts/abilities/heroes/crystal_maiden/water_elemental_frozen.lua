LinkLuaModifier('modifier_water_elemental_frozen', 'abilities/heroes/crystal_maiden/water_elemental_frozen', LUA_MODIFIER_MOTION_NONE)

water_elemental_frozen = class({})

function water_elemental_frozen:OnSpellStart()
	local target = self:GetCursorTarget()

	EmitSoundOn("hero_Crystal.frostbite", target)
	target:AddNewModifier(self:GetCaster(), self, "modifier_water_elemental_frozen", {duration = self:GetSpecialValueFor("duration")})
end

modifier_water_elemental_frozen = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
    CheckState      = function(self) return 
    {
      [MODIFIER_STATE_ROOTED] = true,
    } end,
})

function modifier_water_elemental_frozen:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end