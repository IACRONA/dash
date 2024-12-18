LinkLuaModifier('modifier_sniper_aim_bonus', 'abilities/heroes/sniper/sniper_aim_bonus', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sniper_aim_bonus_debuff', 'abilities/heroes/sniper/sniper_aim_bonus', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sniper_aim_bonus_cooldown', 'abilities/heroes/sniper/sniper_aim_bonus', LUA_MODIFIER_MOTION_NONE)
 
sniper_aim_bonus = class({})

 
function sniper_aim_bonus:Spawn()
	if IsClient() then return end

	self:SetLevel(1)
end

function sniper_aim_bonus:GetIntrinsicModifierName()
	return "modifier_sniper_aim_bonus"
end

function sniper_aim_bonus:OnProjectileHit(target)
	if not target then return end
	local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("sniper_take_aim")

    target:EmitSound("n_creep_TrollWarlord.Ensnare")
	target:AddNewModifier(caster, ability, "modifier_sniper_aim_bonus_debuff", {duration = ability:GetSpecialValueFor("grid_duration")})
end

modifier_sniper_aim_bonus = class({
	IsHidden 				= function(self) return true end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    } end,
})

function modifier_sniper_aim_bonus:OnAttackLanded(event)
    local parent = self:GetParent()
    local attacker = event.attacker

	if attacker ~= self:GetParent() then return end   
    local ability = parent:FindAbilityByName("sniper_take_aim")

    if ability and not parent:HasModifier("modifier_sniper_aim_bonus_cooldown") and RollPercentage(ability:GetSpecialValueFor("chance_grid")) then 
    	parent:AddNewModifier(parent, self:GetAbility(), "modifier_sniper_aim_bonus_cooldown", {duration = ability:GetSpecialValueFor("cooldown_grid")})
	 	ProjectileManager:CreateTrackingProjectile({
	 		EffectName = "particles/units/heroes/hero_siren/siren_net_projectile.vpcf",
	 		Ability = self:GetAbility(),
	 		Source = self:GetCaster(),
	 		Target = event.target,
	 		iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"),
	 	})
   	end
end

modifier_sniper_aim_bonus_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	GetEffectName 			= function(self) return "particles/neutral_fx/dark_troll_ensnare.vpcf" end,
    CheckState      = function(self) return 
    {
    	[MODIFIER_STATE_ROOTED] = true,
    } end,
})

modifier_sniper_aim_bonus_cooldown = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})

function modifier_sniper_aim_bonus_cooldown:GetTexture()
	return "sniper_take_aim"
end