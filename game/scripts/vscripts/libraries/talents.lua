Talents = Talents or {}
require('libraries/shared')
require('libraries/summons_list')
BOOK_REROLL_COUNT  = BOOK_REROLL_COUNT  or 3
function Talents:Init()
	self.talentsKv = {}
	self.summonList = {}
	self.abilitiesNeedRefresh = {
		["medusa_split_shot"] = true,
		["medusa_mana_shield"] = true,
		["lone_druid_spirit_link"] = true,
	}
 
 
	Talents.pendingSelection = {}
	Talents.queueSelection = {}
	Talents.disabledTalentsPlayer = {}
    CustomGameEventManager:RegisterListener('player_talent_selected', function(_, event)
        Talents:TalentSelected(event)
	end)
    CustomGameEventManager:RegisterListener('reroll_talents', function(_, event)
        Talents:Reroll(event)
	end)
end

 
function Talents:GetPendingTalentsCount(playerId)
	if not Talents.queueSelection or not Talents.queueSelection[playerId] then return 0 end

	return #Talents.queueSelection[playerId]
end

  

function Talents:GiveTalent(hero, rarity)
	if not IsValidEntity(hero) then return end

	local playerId = hero:GetPlayerOwnerID()
	if not  PlayerResource:IsValidPlayerID(playerId) then return end

	Talents.queueSelection[playerId] = Talents.queueSelection[playerId] or {}

	table.insert(Talents.queueSelection[playerId], {
		rarity = rarity, 
	})


	Talents:ShowSelection(hero, rarity, playerId)
end


function Talents:GiveTalentForTeam(team, rarity)
	for playerId, hero in pairs(GameLoop.heroes_by_team[team] or {}) do
		Talents:GiveTalent(hero, rarity)
	end
end


function Talents:Reroll(event)
	local playerId = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)

	if not hero then return end

	local pending = Talents.pendingSelection[playerId]
	if not pending then return end
    local reroll = PlayerInfo:GetRollPlayer(playerId)

    if reroll > 0 then 
        PlayerInfo:UpdateRollTable(playerId, -1, 1)
		Talents:ShowSelection(hero, pending.talentRarity, playerId, true)
	end
end


function Talents:ShowSelection(hero, rarity, playerId, is_reroll)
	local pendingSelection = Talents.pendingSelection[playerId]
 
	local previous_choices = (is_reroll and pendingSelection) and pendingSelection.previous_choices or {}

	local choices = {}
	local new_previous_choices = {}

	local count_per_selection = 4

	local rolled_upgrades = Talents:RollTalentsOfType(
		playerId,
		rarity,
		{},
		count_per_selection
	)


	new_previous_choices[TALENTS_TYPE.ABILITY] = rolled_upgrades
	table.extend(choices, rolled_upgrades)
 
	local selection_id = DoUniqueString("selection_id")

	Talents.pendingSelection[playerId] = {
		talentRarity = rarity,
		choices = choices,
		previous_choices = new_previous_choices,
		selection_id = selection_id,
	}

	local player = PlayerResource:GetPlayer(playerId)
	if not IsValidEntity(player) then return end

	Timers:CreateTimer(function()
		CustomGameEventManager:Send_ServerToPlayer(player, "open_talents_choose_players", {
			upgrades = {
				talentRarity = rarity,
				choices = choices,
				reroll = is_reroll,
				selection_id = selection_id,
			},
			upgrades_count = Talents:GetPendingTalentsCount(playerId),
		})
	end)
end


function Talents:RollTalentsOfType(playerId, rarity, previous_choices, count)
	local pool = {}

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if not IsValidEntity(hero) then return end

	local hero_name = hero:GetUnitName()

	pool = table.join(unpack(table.make_value_table(Talents.talentsKv[hero_name])))
 
	local excluded_by_name = {}

	for _, choice in pairs(previous_choices or {}) do
		excluded_by_name[choice.talentName .. "_" .. choice.ability_name] = choice
	end

	local disabledTalents = Talents.disabledTalentsPlayer[playerId] or {}

	local selected_facet_id = hero:GetHeroFacetID()

	local talents = table.random_some_with_condition(pool, count, function(t, index, talentData)
		local talentName = talentData.talentName

		if previous_choices and excluded_by_name[talentName .. "_" .. talentData.ability_name] then return false end

		if talentData.min_rarity and talentData.min_rarity > rarity then return false end

		if talentData.rarity and talentData.rarity ~= rarity then return false end
		if talentData.disabled and talentData.disabled == 1 then return false end

		if disabledTalents[talentName] then return false end

		local ability_upgrades = hero.talents[talentData.ability_name] or {}


		if talentData.max_count and not talentData.rarity and talentData.max_count < rarity then return end

		if talentData.max_count and ability_upgrades[talentData.talentName] then
			local current_count = ability_upgrades[talentData.talentName].count


			if current_count + (rarity / (talentData.rarity or 1)) > talentData.max_count  then return false end
		end

		if talentData.RequiresFacetID and talentData.RequiresFacetID ~= selected_facet_id then
			return false
		end

		if talentData.DisabledWithFacetID and talentData.DisabledWithFacetID == selected_facet_id then
			return false
		end

		return true
	end)


	if #talents < count and previous_choices then
		local extraTalents = table.random_some(previous_choices, count - #talents)

		table.extend(talents, extraTalents)
	end

	return talents
end
 


function Talents:TalentSelected(event)
	local playerId = event.PlayerID
	if not playerId then return end

	
	local player = PlayerResource:GetPlayer(playerId)
	if not IsValidEntity(player) then return end


	local pendingSelection = Talents.pendingSelection[playerId]
	if not pendingSelection then print("no pending talents") return end

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)

	local rarity = pendingSelection.talentRarity
 
	local index, talentData = table.find_element(pendingSelection.choices, function(t, k, v)
		return v.talentName == event.talentName and v.ability_name == event.ability_name
	end)

	if not index or not talentData then print("failed to find selected talent") return end
 

	Talents:AddAbilityUpgrade(
		hero,
		talentData.ability_name,
		talentData.talentName,
		rarity
	)
 

	Talents.pendingSelection[playerId] = nil

	table.remove(Talents.queueSelection[playerId], #Talents.queueSelection[playerId])
	local length = #Talents.queueSelection[playerId]
	if length > 0 then
		local selection_data = Talents.queueSelection[playerId][length]
		Talents:ShowSelection(hero, selection_data.rarity, playerId, false)
	end
end


function Talents:LoadUpgradesData(hero_name)
	if self.talentsKv[hero_name] then return end
  
	self.talentsKv[hero_name] = LoadKeyValues("scripts/npc/talents/heroes/" .. hero_name .. ".txt")
 
	for ability_name, upgrades in pairs(self.talentsKv[hero_name] or {}) do
		for talentName, talentData in pairs(self.talentsKv[hero_name][ability_name]) do
			 TalentsUtilities:ParseTalent(talentData, talentName, TALENTS_TYPE.ABILITY, ability_name)
		end
	end

	CustomNetTables:SetTableValue("ability_upgrades", hero_name, self.talentsKv[hero_name] or {})
end


function Talents:GetUpgradeValue(hero_name, ability_name, special_value_name)
	return self.talentsKv[hero_name][ability_name][special_value_name].value
end


function Talents:DisableUpgrade(playerId, ability_name, talentName)
	Talents.disabledTalentsPlayer[playerId] = Talents.disabledTalentsPlayer[playerId] or {}
	Talents.disabledTalentsPlayer[playerId][ability_name] = Talents.disabledTalentsPlayer[playerId][ability_name] or {}

	Talents.disabledTalentsPlayer[playerId][ability_name][talentName] = true
end


function Talents:AddOrIncrementUpgrade(hero, ability_name, talentName, value, rarity)
	if type(value) == "table" then
		return Talents:AddUpgradeFromTable(hero, ability_name, talentName, value, rarity)
	end

	if not hero.talents then hero.talents = {} end
	if not hero.talents[ability_name] then hero.talents[ability_name] = {} end

	local talentData = hero.talents[ability_name][talentName]

	if not talentData then
		local upgrade_config = self.talentsKv[hero:GetUnitName()][ability_name] and self.talentsKv[hero:GetUnitName()][ability_name][talentName] or nil

		hero.talents[ability_name][talentName] = upgrade_config or {
			value = value,
			count = rarity,
		}
		talentData = hero.talents[ability_name][talentName]

		talentData.count = rarity
	else
		talentData.count = talentData.count + rarity
	end

	Talents:RefreshIntrinsicModifierByName(hero, ability_name)

	return talentData
end


function Talents:AddUpgradeFromTable(hero, ability_name, talentName, newTalentData, rarity)
	if not hero.talents then hero.talents = {} end
	if not hero.talents[ability_name] then hero.talents[ability_name] = {} end

	local talentData = hero.talents[ability_name][talentName]

	if talentData then
		talentData.count = talentData.count + rarity
	else
		hero.talents[ability_name][talentName] = newTalentData
		talentData = hero.talents[ability_name][talentName]
		talentData.count = rarity
	end

	Talents:RefreshIntrinsicModifierByName(hero, ability_name)
	
	return talentData
end



function Talents:ApplyLinkedUpgrades(hero, hero_name, ability_name, special_value_name, rarity)
	local upgrade_config = self.talentsKv[hero_name][ability_name][special_value_name]
	local linked_special_values = upgrade_config.linked_special_values or {}

	for linked_name, value in pairs(linked_special_values) do

		local talentData = Talents:AddOrIncrementUpgrade(hero, ability_name, linked_name, value, rarity)

		if not talentData.operator then talentData.operator = TALENT_OPERATOR.ADD end
	end

	local linked_abilities = upgrade_config.linked_abilities or {}

	for linked_ability_name, link_config in pairs(linked_abilities) do
		hero.talents[linked_ability_name] = hero.talents[linked_ability_name] or {}

		for linked_name, value in pairs(link_config) do
			local talentData = Talents:AddOrIncrementUpgrade(hero, linked_ability_name, linked_name, value, rarity)

			if not talentData.operator then talentData.operator = TALENT_OPERATOR.ADD end
		end
	end
end


function Talents:RefreshIntrinsicModifierByName(hero, ability_name)
	Talents:RefreshIntrinsicModifier(hero, hero:FindAbilityByName(ability_name))
end


function Talents:RefreshIntrinsicModifier(hero, ability)
	if IsValidEntity(ability) and ability:GetLevel() > 0 then
		ability:RefreshIntrinsicModifier()

		if self.abilitiesNeedRefresh[ability:GetAbilityName()] then
			ability:SetLevel(ability:GetLevel())
		end
	end
end


function Talents:AddAbilityUpgrade(hero, ability_name, special_value_name, rarity)
	local playerId = hero:GetPlayerOwnerID()
	if not playerId then return end

	if not rarity then rarity = TALENT_RARITY_COMMON end
	if not hero.talents then hero.talents = {} end

	local hero_name = hero:GetUnitName()

	local base_value = Talents:GetUpgradeValue(hero_name, ability_name, special_value_name)

	local talentData = hero.talents[ability_name] and hero.talents[ability_name][special_value_name]

	if not talentData then
		talentData = Talents:AddOrIncrementUpgrade(hero, ability_name, special_value_name, base_value, rarity)
	else
		talentData.count = talentData.count + rarity
	end

	if talentData.max_count and talentData.count >= talentData.max_count then
		Talents:DisableUpgrade(playerId, ability_name, special_value_name)
	end

	Talents:ApplyLinkedUpgrades(hero, hero_name, ability_name, special_value_name, rarity)

	local controller_modifier = hero:FindModifierByName("modifier_ability_upgrades_controller")

	if not controller_modifier then
		controller_modifier = hero:AddNewModifier(hero, nil, "modifier_ability_upgrades_controller", {})
	end

	controller_modifier:ForceRefresh()

	CustomNetTables:SetTableValue("ability_upgrades", tostring(playerId), hero.talents)

	Talents:RefreshIntrinsicModifierByName(hero, ability_name)

	Talents:ProcessClones(hero, true)

	Talents:ProcessRetroactiveSummonUpgrades(hero, ability_name)
end


function Talents:ProcessClone(clone, hero)
	if not clone or not IsValidEntity(clone) or not clone:IsAlive() then return end
	if not IsValidEntity(hero) then hero = clone:GetCloneSource() end
	if not IsValidEntity(hero) then return end
 
	local controller_modifier = clone:FindModifierByName("modifier_ability_upgrades_controller")

	if not controller_modifier then
		controller_modifier = clone:AddNewModifier(clone, nil, "modifier_ability_upgrades_controller", nil)

		for ability_name, _ in pairs(hero.talents) do
			Talents:RefreshIntrinsicModifierByName(clone, ability_name)
		end
	end

	controller_modifier:ForceRefresh()
end


function Talents:ProcessClones(hero, skip_generics)
	local clones = hero:GetClones()

	for _, clone in pairs(clones) do
		Talents:ProcessClone(clone, hero, skip_generics)
	end
end


function Talents:IterateSummonList(hero, callback)
	for summon_entity_index, summon in pairs(self.summonList[hero:GetPlayerOwnerID()] or {}) do
		if not IsValidEntity(summon) then
			self.summonList[summon_entity_index] = nil
		else
			local summon_name = summon:GetUnitName()
			local summon_params = SUMMON_TO_ABILITY_MAP[summon_name]

			ErrorTracking.Try(callback, summon, summon_name, summon_params)
		end
	end
end


function Talents:ProcessRetroactiveSummonUpgrades(hero, ability_name)
	Talents:IterateSummonList(hero, function(summon, summon_name, summon_params)
		if ability_name == summon_params.ability then
			self:ApplySummonUpgrades(summon, summon_name, hero)
		end
	end)
end

 

function Talents:ApplySummonUpgrades(summon, summon_name, owner)
	if not summon or not summon_name then return end

	if owner:GetClassname() == "dota_player_controller" then
		owner = owner:GetAssignedHero()
	end

	local summon_params = SUMMON_TO_ABILITY_MAP[summon_name]
	if not summon_params then return end

	local ability = owner:FindAbilityByName(summon_params.ability)
	if not ability then return end

	local summon_entity_index = summon:GetEntityIndex()
	local summon_owner_id = owner:GetPlayerOwnerID()

	if summon_params.health then
		local required_health = ability:GetSpecialValueFor(summon_params.health)

		if summon:GetBaseMaxHealth() < required_health then
			if summon_params.health_bonus_as_modifier then
				local health_pct = summon:GetHealthPercent()

				required_health = required_health - ability:GetLevelSpecialValueNoOverride(summon_params.health, ability:GetLevel() - 1)

				local new_modifier = summon:AddNewModifier(summon, nil, "modifier_summon_bonus_health", {duration = -1})
				if new_modifier and not new_modifier:IsNull() then
					new_modifier:SetStackCount(required_health)
				end
				summon:CalculateGenericBonuses()
				summon:CalculateStatBonus(true)
				summon:SetHealth(summon:GetMaxHealth() * health_pct / 100)
			else
				local base_max_health_old = summon:GetBaseMaxHealth()
				local max_health_old = summon:GetMaxHealth()
				local health_diff = math.max(max_health_old - base_max_health_old, 0)
				local health_pct = summon:GetHealthPercent()

				summon:SetBaseMaxHealth(required_health)
				summon:SetMaxHealth(required_health + health_diff)

				if summon:IsAlive() then
					summon:SetHealth(summon:GetMaxHealth() * health_pct / 100)
				end
			end
		end
	end

	if summon_params.added_health then
		local new_max_health = summon:GetMaxHealth() + ability:GetSpecialValueFor(summon_params.added_health)

		local health_pct = summon:GetHealthPercent()


		summon:SetBaseMaxHealth(new_max_health)
		summon:SetMaxHealth(new_max_health)

		if summon:IsAlive() then
			summon:SetHealth(summon:GetMaxHealth() * health_pct / 100)
		end
	end

	if summon_params.damage then
		local required_damage = ability:GetSpecialValueFor(summon_params.damage)

		summon:SetBaseDamageMin(required_damage)
		summon:SetBaseDamageMax(required_damage)
	end

	if summon_params.armor then
		local required_armor = ability:GetSpecialValueFor(summon_params.armor)

		summon:SetPhysicalArmorBaseValue(required_armor)
	end

	if summon_params.vision_day then
		local vision = ability:GetSpecialValueFor(summon_params.vision_day)
		summon:SetDayTimeVisionRange(vision)
	end

	if summon_params.vision_night then
		local vision = ability:GetSpecialValueFor(summon_params.vision_night)
		summon:SetNightTimeVisionRange(vision)
	end

	if summon_params.retroactive and not (self.summonList[summon_owner_id] and self.summonList[summon_owner_id][summon_entity_index]) then
		if not self.summonList[summon_owner_id] then self.summonList[summon_owner_id] = {} end
		self.summonList[summon_owner_id][summon_entity_index] = summon
	end

	if summon_params.ability_upgrades then

		summon:AddNewModifier(owner, nil, "modifier_ability_upgrades_controller", nil)

		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local ability = summon:GetAbilityByIndex(i)
			if ability then
				local intrinsic_modifier_name = ability:GetIntrinsicModifierName()
				local modifier = summon:FindModifierByName(intrinsic_modifier_name)
				if modifier then
					modifier:ForceRefresh()
				end
			end
		end
	end
end
 

function Talents:OnModifierAdded(event)
	local modifier = event.modifier
	if not modifier or modifier:IsNull() then return end

	local modifier_name = modifier:GetName()

	if modifier_name == "modifier_monkey_king_fur_army_soldier_in_position" then
		local parent = modifier:GetParent()
		local caster = modifier:GetCaster()

		Talents:ProcessClone(parent, caster, false)
	end

	if modifier_name == "modifier_invoker_ice_wall_slow_aura" or modifier_name == "modifier_invoker_ice_wall_thinker" then
		local parent = modifier:GetParent()
		parent:AddNewModifier(parent, modifier:GetAbility(), "modifier_dummy_caster", {})
	end
end


function Talents:GetPlayerUpgrades(playerId)
	local playerTalents = {}

	local hero = GameLoop.hero_by_player_id[playerId]
	if not IsValidEntity(hero) then return {} end

	local hero_name = hero:GetUnitName()
	local heroTalents = Talents.talentsKv[hero_name] or {}

	for ability_name, talents in pairs(heroTalents) do
		for talentName, _ in pairs(talents) do
			if hero.talents and hero.talents[ability_name] and hero.talents[ability_name][talentName] and hero.talents[ability_name][talentName].count > 0 then
				table.insert(playerTalents, {ability_name, talentName, hero.talents[ability_name][talentName].count})
			end
		end
	end
  
	return playerTalents
end


Talents:Init()
