modifier_donate_aura = class({})
 
function modifier_donate_aura:IsHidden()
	return true
end

function modifier_donate_aura:RemoveOnDeath()
	return false
end

function modifier_donate_aura:IsPurgable()
	return false
end

function modifier_donate_aura:IsPurgeException()
	return false
end

function modifier_donate_aura:GetEffectName()
	return self.effectName
end
 
--=======================================================================================

modifier_donate_aura_aghanim = class(modifier_donate_aura)
modifier_donate_aura_aghanim.effectName = "particles/econ/events/spring_2021/agh_aura_spring_2021_lvl2.vpcf"

modifier_donate_aura_autumn = class(modifier_donate_aura)
modifier_donate_aura_autumn.effectName = "particles/econ/events/fall_2022/agh/agh_aura_fall2022_lvl2.vpcf"

 
 