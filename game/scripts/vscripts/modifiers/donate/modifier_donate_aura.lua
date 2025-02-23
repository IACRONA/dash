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

 
modifier_donate_aura_pumpkin_green = class(modifier_donate_aura)
modifier_donate_aura_pumpkin_green.effectName = "particles/econ/events/diretide_2020/emblem/fall20_emblem_v1_effect.vpcf"

modifier_donate_aura_pumpkin_red = class(modifier_donate_aura)
modifier_donate_aura_pumpkin_red.effectName = "particles/econ/events/diretide_2020/emblem/fall20_emblem_v2_effect.vpcf"

modifier_donate_aura_pumpkin_yellow = class(modifier_donate_aura)
modifier_donate_aura_pumpkin_yellow.effectName = "particles/econ/events/diretide_2020/emblem/fall20_emblem_effect.vpcf"

modifier_donate_aura_aghanim_quantum = class(modifier_donate_aura)
modifier_donate_aura_aghanim_quantum.effectName = "particles/econ/events/fall_2021/fall_2021_emblem_game_effect.vpcf"

modifier_donate_aura_lava = class(modifier_donate_aura)
modifier_donate_aura_lava.effectName = "particles/econ/events/fall_2022/player/fall_2022_emblem_effect_player_base.vpcf"

modifier_donate_aura_nature = class(modifier_donate_aura)
modifier_donate_aura_nature.effectName = "particles/econ/events/summer_2021/summer_2021_emblem_effect.vpcf"

modifier_donate_aura_golden = class(modifier_donate_aura)
modifier_donate_aura_golden.effectName = "particles/econ/events/ti10/emblem/ti10_emblem_effect.vpcf"

modifier_donate_aura_lotus = class(modifier_donate_aura)
modifier_donate_aura_lotus.effectName = "particles/econ/events/ti9/ti9_emblem_effect.vpcf"