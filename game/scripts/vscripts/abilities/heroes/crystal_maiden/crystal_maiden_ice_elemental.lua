LinkLuaModifier('modifier_crystal_maiden_ice_elemental', 'abilities/heroes/crystal_maiden/crystal_maiden_ice_elemental.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_on_death', 'modifiers/generic/modifier_on_death', LUA_MODIFIER_MOTION_NONE)

crystal_maiden_ice_elemental = class({})

function crystal_maiden_ice_elemental:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_ice_elemental"
end


modifier_crystal_maiden_ice_elemental = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    } end,
})

function modifier_crystal_maiden_ice_elemental:OnAbilityFullyCast(event)
	local parent = self:GetParent()

	if parent ~= event.unit or event.ability:IsItem() then return end
	local ability = self:GetAbility()
 	if parent:GetLevel() < ability:GetSpecialValueFor("level_required") then return end
 	if event.ability:GetName() == "ability_use" then return end
	if not ability:IsFullyCastable() or not RollPercentage(ability:GetSpecialValueFor("chance")) then return end
	ability:UseResources(true, true, true, true)
	local duration = ability:GetSpecialValueFor("duration")
	if parent.elemental and parent.elemental:IsAlive() then
	   Timers:RemoveTimer(parent.elemental.timer)
	   parent.elemental:Kill(nil, nil)
	end

	parent.elemental = CreateUnitByName("npc_water_elemental", parent:GetAbsOrigin(), true, parent, parent, parent:GetTeamNumber())
	parent.elemental:AddNewModifier(parent, ability, "modifier_kill", {duration = duration})
	parent.elemental:SetOwner(parent)
	parent.elemental:SetControllableByPlayer(parent:GetPlayerID(), true)

	parent.elemental.timer = Timers:CreateTimer(duration, function()
		parent.elemental = nil
	end)
	local modifierDeath = parent.elemental:AddNewModifier(parent.elemental, nil, "modifier_on_death", {})
	modifierDeath.CallbackOnDeath = function()
		parent.elemental = nil
	end

	EmitSoundOn("spawn_elemental", parent.elemental)
 end