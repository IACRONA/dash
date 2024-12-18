LinkLuaModifier('modifier_true_sight_portal_debuff', 'modifiers/modifier_true_sight_portal_aura', LUA_MODIFIER_MOTION_NONE)

modifier_true_sight_portal_aura = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
 
})

function modifier_true_sight_portal_aura:IsAura() return true end
function modifier_true_sight_portal_aura:GetAuraRadius() return 800 end
function modifier_true_sight_portal_aura:GetModifierAura() return "modifier_true_sight_portal_debuff" end
function modifier_true_sight_portal_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_true_sight_portal_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_true_sight_portal_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER end
function modifier_true_sight_portal_aura:GetAuraDuration() return 0.5 end


modifier_true_sight_portal_debuff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsPurgeException 		= function(self) return false end,
	IsDebuff                 = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	GetAttributes 			= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	GetEffectAttachType     = function(self) return PATTACH_OVERHEAD_FOLLOW end,
})

function modifier_true_sight_portal_debuff:OnCreated()
	local parent = self:GetParent()

	if not parent.visibleModifier then 
		parent.visibleModifier = self
	end
	if IsClient() then return end
 
 
	self.modifier = parent:AddNewModifier(self:GetCaster(),nil, "modifier_truesight", {})
end
 
function modifier_true_sight_portal_debuff:OnDestroy()
	local parent = self:GetParent()

	if self == parent.visibleModifier then 
		parent.visibleModifier = nil
	end
	if IsClient() then return end

 
	self.modifier:Destroy()
end

function modifier_true_sight_portal_debuff:GetEffectName()
	if self == self:GetParent().visibleModifier then 
		return "particles/items2_fx/true_sight_debuff.vpcf"
	end
end