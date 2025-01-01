function Wearing(hero, items,materialGroup)
	Timers:CreateTimer(0.5, function()
		hero.wearItems = {}

		for _,name in ipairs(items) do
		    local item = SpawnEntityFromTableSynchronous("prop_dynamic", {
		      model = name,
		    })	
		    if materialGroup then item:SetMaterialGroup(materialGroup) end
	    	item:FollowEntity(hero, true);
	    	table.insert(hero.wearItems, item)
		end
		hero.baseModel = hero:GetModelName()
		hero:AddNewModifier(hero, nil,"modifier_custom_wear", {})
	end)
end

function WearParticle(hero, particles)
	Timers:CreateTimer(0.5, function()

		for _,particle in ipairs(particles) do
			local effect = ParticleManager:CreateParticle(particle.name, PATTACH_ABSORIGIN_FOLLOW, hero )

			for _,attachment in ipairs(particle.attachment) do
				print(attachment.point, attachment.attach)
				ParticleManager:SetParticleControlEnt(effect, attachment.point, hero, PATTACH_POINT_FOLLOW, attachment.attach, hero:GetAbsOrigin(), true)
			end
		end
	end)
end

function CAddonWarsong:WearHero(hero)
	local heroName = hero:GetUnitName() 

	if heroName == "npc_dota_hero_crystal_maiden" then
		local items = {
			"models/items/crystal_maiden/lady_whitewind_shoulder/lady_whitewind_shoulder.vmdl",
			"models/items/crystal_maiden/lady_whitewind_head/lady_whitewind_head.vmdl",
			"models/items/crystal_maiden/lady_whitewind_back/lady_whitewind_back.vmdl",
			"models/items/crystal_maiden/lady_whitewind_arms/lady_whitewind_arms.vmdl",
			"models/items/crystal_maiden/lady_whitewind_weapon/lady_whitewind_weapon.vmdl",
		}

		Wearing(hero, items)
 	elseif heroName == "npc_dota_hero_dazzle" then
		local items = {
			"models/items/dazzle/ti9_cavern_crawl_dazzle_weapon/ti9_cavern_crawl_dazzle_weapon.vmdl",
			"models/items/dazzle/ti9_cavern_crawl_dazzle_legs/ti9_cavern_crawl_dazzle_legs.vmdl",
			"models/items/dazzle/ti9_cavern_crawl_dazzle_shoulders/ti9_cavern_crawl_dazzle_shoulders.vmdl",
			"models/items/dazzle/ti9_cavern_crawl_dazzle_head/ti9_cavern_crawl_dazzle_head.vmdl",
			"models/items/dazzle/ti9_cavern_crawl_dazzle_arms/ti9_cavern_crawl_dazzle_arms.vmdl",
		}

		Wearing(hero, items, "2") 
 	elseif heroName == "npc_dota_hero_axe" then
		local items = {
			"models/items/axe/ti8_axe_violent_prisoner_of_war_weapon/ti8_axe_violent_prisoner_of_war_weapon.vmdl",
			"models/items/axe/ti8_axe_violent_prisoner_of_war_armor/ti8_axe_violent_prisoner_of_war_armor.vmdl",
			"models/items/axe/ti8_axe_violent_prisoner_of_war_belt/ti8_axe_violent_prisoner_of_war_belt.vmdl",
			"models/items/axe/ti8_axe_violent_prisoner_of_war_misc/ti8_axe_violent_prisoner_of_war_misc.vmdl",
			"models/items/axe/ti8_axe_violent_prisoner_of_war_head/ti8_axe_violent_prisoner_of_war_head.vmdl",
		}

		Wearing(hero, items) 
	elseif heroName == "npc_dota_hero_lina" then 
		local items = {
			"models/items/lina/origins_flamehair/origins_flamehair.vmdl",
			"models/heroes/lina/lina_arms.vmdl",
			"models/heroes/lina/lina_belt.vmdl",
			"models/heroes/lina/lina_neck.vmdl",
		}

		local particles = {
			{name = "particles/econ/items/lina/lina_head_headflame/lina_headflame.vpcf", attachment = {{point = 0, attach = "attach_head"}}},			
			{name = "particles/econ/items/lina/lina_head_headflame/lina_flame_hand_dual_headflame.vpcf", attachment = {{point = 0, attach = "attach_attack1"}, {point = 1, attach = "attach_attack2"}}},
		}


		hero:SetMaterialGroup("1")
		WearParticle(hero, particles)
		Wearing(hero, items)
	elseif heroName == "npc_dota_hero_skeleton_king" then
		local items = {
			"models/items/wraith_king/destruction_lord_weapon/destruction_lord_weapon.vmdl",
			"models/items/lich/frostivus2018_lich_frozenworlds_head/frostivus2018_lich_frozenworlds_head.vmdl",
			"models/items/wraith_king/destruction_lord_back/destruction_lord_back.vmdl",
			"models/items/wraith_king/destruction_lord_shoulder/destruction_lord_shoulder.vmdl",
			"models/items/wraith_king/destruction_lord_arms/destruction_lord_arms.vmdl",
			"models/items/wraith_king/destruction_lord_armor/destruction_lord_armor.vmdl",
		}

		Wearing(hero, items) 
	end
end