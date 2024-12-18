LinkLuaModifier('modifier_lina_flame_cloak_custom', 'abilities/heroes/lina/lina_flame_cloak_custom', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_lina_flame_cloak_custom_buff', 'abilities/heroes/lina/lina_flame_cloak_custom', LUA_MODIFIER_MOTION_NONE)
 
lina_flame_cloak_custom = class({})

function lina_flame_cloak_custom:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context)
end

function lina_flame_cloak_custom:Spawn()
	if IsClient() then return end

	self:SetLevel(1)
end

function lina_flame_cloak_custom:GetIntrinsicModifierName()
	return "modifier_lina_flame_cloak_custom"
end

modifier_lina_flame_cloak_custom = class({
	IsHidden 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_EVENT_ON_TAKEDAMAGE,
    } end,
})

function modifier_lina_flame_cloak_custom:OnCreated()
	self.healthThreshold = self:GetAbility():GetSpecialValueFor("health_threshold")
end

function modifier_lina_flame_cloak_custom:OnTakeDamage(event)
	local parent = self:GetParent()

	if parent ~= event.unit then return end
	if not parent:HasScepter() then return end
	local ability = self:GetAbility()

	if ability:IsFullyCastable() and parent:GetHealthPercent() <= self.healthThreshold then 
		EmitSoundOn("Hero_Dark_Seer.Surge", parent)
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		parent:AddNewModifier(parent, ability, "modifier_lina_flame_cloak_custom_buff", {duration = ability:GetSpecialValueFor("duration")})
	end
end

modifier_lina_flame_cloak_custom_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	GetEffectName 			= function(self) return "particles/generic_gameplay/rune_haste.vpcf" end,
    DeclareFunctions        = function(self) return 
    {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    } end,
})

function modifier_lina_flame_cloak_custom_buff:OnCreated()
	self.moveSpeed = self:GetAbility():GetSpecialValueFor("move_speed")
end

function modifier_lina_flame_cloak_custom_buff:GetModifierMoveSpeed_Absolute()
	return self.moveSpeed
end