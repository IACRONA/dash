Upgrades = Upgrades or {}
require('libraries/shared')
require('libraries/summons_list')
BOOK_REROLL_COUNT  = BOOK_REROLL_COUNT  or 3
function Upgrades:Init()
	self.upgrades_kv = {}
	self:UpdateHeroUpgradeData()
	self.summon_list = {}
	self.abilities_requires_level_reset = {}
	self.abilities_requires_level_reset["medusa_split_shot"] = true
	self.abilities_requires_level_reset["medusa_mana_shield"] = true
	self.abilities_requires_level_reset["lone_druid_spirit_link"] = true
	-- save sent selection choices and queued selections
	Upgrades.pending_selection = {}
	Upgrades.queued_selection = {}
	Upgrades.favorites_upgrades = {}
	Upgrades.disabled_upgrades_per_player = {}
	Upgrades.lucky_trinket_proc  = {}
    CustomGameEventManager:RegisterListener('player_talent_selected', function(_, event)
        Upgrades:UpgradeSelected(event)
	end)
    CustomGameEventManager:RegisterListener('reroll_talents', function(_, event)
        Upgrades:Reroll(event)
	end)
end

 
function Upgrades:GetPendingUpgradesCount(player_id)
	if not Upgrades.queued_selection or not Upgrades.queued_selection[player_id] then return 0 end

	return #Upgrades.queued_selection[player_id]
end

  

function Upgrades:QueueSelection(hero, rarity)
	if not IsValidEntity(hero) then return end

	local player_id = hero:GetPlayerOwnerID()
	if not  PlayerResource:IsValidPlayerID(player_id) then return end

	Upgrades.queued_selection[player_id] = Upgrades.queued_selection[player_id] or {}

	table.insert(Upgrades.queued_selection[player_id], {
		rarity = rarity, 
		is_lucky_trinket_proc = Upgrades.lucky_trinket_proc[player_id]
	})
	-- print("QueueSelection LVL 1")
	-- if not Upgrades.pending_selection[player_id] then
		Upgrades:ShowSelection(hero, rarity, player_id)
	-- else
	-- 	local player = PlayerResource:GetPlayer(player_id)
	-- 	if IsValidEntity(player) then
	-- 		CustomGameEventManager:Send_ServerToPlayer(player, "Upgrades:update_pending_count", {
	-- 			upgrades_count = #Upgrades.queued_selection[player_id];
	-- 		})
	-- 	end
	-- end

	-- local hero = PlayerResource:GetSelectedHeroEntity(player_id)
	-- local upgrades_count = Upgrades:GetPendingUpgradesCount(player_id)

	-- if upgrades_count >= 2 then 
	-- 	GameRules:SendCustomMessage(hero:GetName().. " очередь из ".. upgrades_count, 0, 0)
	-- end
	
	-- if upgrades_count >= 5 then 
	-- 	GameRules:SendCustomMessage("<font color='#ff0000'>" .. hero:GetName().. " выбирается рандомно бонусы</font>", 0, 0)

	-- 	for i=1, 150 do 
	-- 		local rolled_upgrades = Upgrades:RollUpgradesOfType(
	-- 			UPGRADE_TYPE.ABILITY,
	-- 			player_id,
	-- 			UPGRADE_RARITY_EPIC,
	-- 			{},
	-- 			3
	-- 		)
		
	-- 		local random = rolled_upgrades[RandomInt(1, #rolled_upgrades)]
	-- 		local event = {
	-- 			PlayerID = player_id,
	-- 			upgrade_name = random.upgrade_name,
	-- 			ability_name = random.ability_name
	-- 		}

	-- 		Upgrades:AddAbilityUpgrade(
	-- 			hero,
	-- 			random.ability_name,
	-- 			random.upgrade_name,
	-- 			UPGRADE_RARITY_EPIC
	-- 		)
	-- 	end
	-- end
end


function Upgrades:QueueSelectionForTeam(team, rarity)
	for player_id, hero in pairs(GameLoop.heroes_by_team[team] or {}) do
		Upgrades:QueueSelection(hero, rarity)
	end
end


function Upgrades:Reroll(event)
	local player_id = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(player_id)

	if not hero then return end

	local pending = Upgrades.pending_selection[player_id]
	if not pending then return end
    local reroll = PlayerInfo:GetRollPlayer(player_id)

    if reroll > 0 then 
        PlayerInfo:UpdateRollTable(player_id, -1, 1)
		Upgrades:ShowSelection(hero, pending.upgrade_rarity, player_id, true, pending.is_lucky_trinket_proc)
	end
end


function Upgrades:ShowSelection(hero, rarity, player_id, is_reroll, is_lucky_trinket_proc)
	local pending_selection = Upgrades.pending_selection[player_id]
 
	local previous_choices = (is_reroll and pending_selection) and pending_selection.previous_choices or {}

	local choices = {}
	local new_previous_choices = {}

	local count_per_selection = 4

	local upgrade_type = UPGRADE_TYPE.ABILITY
	local rolled_upgrades = Upgrades:RollUpgradesOfType(
		upgrade_type,
		player_id,
		rarity,
		{},
		count_per_selection
	)


	new_previous_choices[upgrade_type] = rolled_upgrades
	table.extend(choices, rolled_upgrades)
 
	local selection_id = DoUniqueString("selection_id")

	Upgrades.pending_selection[player_id] = {
		upgrade_rarity = rarity,
		choices = choices,
		previous_choices = new_previous_choices,
		selection_id = selection_id,
		is_lucky_trinket_proc = is_lucky_trinket_proc,
	}

	local player = PlayerResource:GetPlayer(player_id)
	if not IsValidEntity(player) then return end

	Timers:CreateTimer(function()
		CustomGameEventManager:Send_ServerToPlayer(player, "open_talents_choose_players", {
			upgrades = {
				upgrade_rarity = rarity,
				choices = choices,
				reroll = is_reroll,
				selection_id = selection_id,
				is_lucky_trinket_proc = is_lucky_trinket_proc,
			},
			upgrades_count = Upgrades:GetPendingUpgradesCount(player_id),
			favorites_upgrades = Upgrades.favorites_upgrades[player_id] or {}
		})
	end)
end


function Upgrades:RollUpgradesOfType(upgrade_type, player_id, rarity, previous_choices, count)
	local pool = {}

	local hero = PlayerResource:GetSelectedHeroEntity(player_id)
	if not IsValidEntity(hero) then return end

	local hero_name = hero:GetUnitName()
		-- turns table of <ability_name>:<list of ability upgrades> into <list of all abilities upgrades>
	pool = table.join(unpack(table.make_value_table(Upgrades.upgrades_kv[hero_name])))
 
	-- transform previous choices into lookup table for filtering
	local excluded_by_name = {}

	for _, choice in pairs(previous_choices or {}) do
		excluded_by_name[choice.upgrade_name .. "_" .. choice.ability_name] = choice
	end

	local disabled_upgrades = Upgrades.disabled_upgrades_per_player[player_id] or {}

	local selected_facet_id = hero:GetHeroFacetID()

	local upgrades = table.random_some_with_condition(pool, count, function(t, index, upgrade_data)
		local upgrade_name = upgrade_data.upgrade_name

		if previous_choices and excluded_by_name[upgrade_name .. "_" .. upgrade_data.ability_name] then return false end
		-- min rarity for ability upgrades
		if upgrade_data.min_rarity and upgrade_data.min_rarity > rarity then return false end
		-- strict rarity for generics
		if upgrade_data.rarity and upgrade_data.rarity ~= rarity then return false end
		if upgrade_data.disabled and upgrade_data.disabled == 1 then return false end

		if disabled_upgrades[upgrade_name] then return false end

		local ability_upgrades = hero.upgrades[upgrade_data.ability_name] or {}

		-- in case max count is less than 4 for non-generic upgrades
		if tonumber(upgrade_data.max_count) and not upgrade_data.rarity then
			local max_count = tonumber(upgrade_data.max_count)
			if max_count and max_count < rarity then return end
		end

		if tonumber(upgrade_data.max_count) and ability_upgrades[upgrade_data.upgrade_name] then
			local current_count = ability_upgrades[upgrade_data.upgrade_name].count

			-- strict rarity is (atm) only defined for generics
			-- and for generics it means that count is applied as-is, without 1/2/4 multiplier of rarity
			if current_count + (rarity / (upgrade_data.rarity or 1)) > tonumber(upgrade_data.max_count)  then return false end
		end

		if upgrade_data.RequiresFacetID and tonumber(upgrade_data.RequiresFacetID) ~= selected_facet_id then
			-- print("1) discarded", upgrade_data.ability_name, upgrade_name, "wrong facet", upgrade_data.RequiresFacetID, selected_facet_id)
			return false
		end

		if upgrade_data.DisabledWithFacetID and tonumber(upgrade_data.DisabledWithFacetID) == selected_facet_id then
			-- print("2) discarded", upgrade_data.ability_name, upgrade_name, "wrong facet", upgrade_data.DisabledWithFacetID, selected_facet_id)
			return false
		end

		return true
	end)

	-- pool was exhaused, we need extra upgrades
	-- this could only happen if previous_choices is supplied
	-- (otherwise means critical error due to insufficient overall upgrades count)
	-- which means we can just roll extra from them
	if #upgrades < count and previous_choices then
		print("[Upgrades] POOL WAS EXHAUSED FOR", player_id, upgrade_type, count - #upgrades)
		local extra_upgrades = table.random_some(previous_choices, count - #upgrades)

		table.extend(upgrades, extra_upgrades)
	end

	return upgrades
end
 


function Upgrades:UpgradeSelected(event)
	local player_id = event.PlayerID
	if not player_id then return end

	local player = PlayerResource:GetPlayer(player_id)
	if not IsValidEntity(player) then return end

	local pending_selection = Upgrades.pending_selection[player_id]
	if not pending_selection then print("no pending upgrades") return end

	local hero = PlayerResource:GetSelectedHeroEntity(player_id)

	local rarity = pending_selection.upgrade_rarity
 
	local index, upgrade_data = table.find_element(pending_selection.choices, function(t, k, v)
		return v.upgrade_name == event.upgrade_name and v.ability_name == event.ability_name
	end)

	if not index or not upgrade_data then print("failed to find selected upgrade") return end
 
	Upgrades:AddAbilityUpgrade(
		hero,
		upgrade_data.ability_name,
		upgrade_data.upgrade_name,
		rarity
	)
 

	Upgrades.pending_selection[player_id] = nil

	table.remove(Upgrades.queued_selection[player_id], #Upgrades.queued_selection[player_id])
	local length = #Upgrades.queued_selection[player_id]
	if length > 0 then
		local selection_data = Upgrades.queued_selection[player_id][length]
		Upgrades:ShowSelection(hero, selection_data.rarity, player_id, false, selection_data.is_lucky_trinket_proc or false)
	end
end

function Upgrades:UpdateHeroUpgradeData()
	ServerManager:GetHeroUpgradeData(function(data)
		if not data then return end
		for k, v in pairs(data) do
			Upgrades:LoadUpgradesData(k, v)
		end
	end)
end

function Upgrades:LoadUpgradesData(hero_name, data)
	if self.upgrades_kv[hero_name] then return end
	self.upgrades_kv[hero_name] = data[hero_name]
	for ability_name, upgrades in pairs(self.upgrades_kv[hero_name] or {}) do
		for upgrade_name, upgrade_data in pairs(self.upgrades_kv[hero_name][ability_name]) do
			UpgradesUtilities:ParseUpgrade(upgrade_data, upgrade_name, UPGRADE_TYPE.ABILITY, ability_name)
		end
	end
	CustomNetTables:SetTableValue("ability_upgrades", hero_name, self.upgrades_kv[hero_name] or {})
end


function Upgrades:GetUpgradeValue(hero_name, ability_name, special_value_name)
	return self.upgrades_kv[hero_name][ability_name][special_value_name].value
end


function Upgrades:DisableUpgrade(player_id, ability_name, upgrade_name)
	Upgrades.disabled_upgrades_per_player[player_id] = Upgrades.disabled_upgrades_per_player[player_id] or {}
	Upgrades.disabled_upgrades_per_player[player_id][ability_name] = Upgrades.disabled_upgrades_per_player[player_id][ability_name] or {}

	Upgrades.disabled_upgrades_per_player[player_id][ability_name][upgrade_name] = true
end


function Upgrades:AddOrIncrementUpgrade(hero, ability_name, upgrade_name, value, rarity)
	if type(value) == "table" then
		return Upgrades:AddUpgradeFromTable(hero, ability_name, upgrade_name, value, rarity)
	end

	if not hero.upgrades then hero.upgrades = {} end
	if not hero.upgrades[ability_name] then hero.upgrades[ability_name] = {} end

	local upgrade_data = hero.upgrades[ability_name][upgrade_name]

	if not upgrade_data then
		local upgrade_config = self.upgrades_kv[hero:GetUnitName()][ability_name] and self.upgrades_kv[hero:GetUnitName()][ability_name][upgrade_name] or nil
		-- not copying upgrade kv - but referencing (if definition exists)
		hero.upgrades[ability_name][upgrade_name] = upgrade_config or {
			value = value,
			count = rarity,
		}
		upgrade_data = hero.upgrades[ability_name][upgrade_name]

		-- in this case count indeed mutates original KV
		-- but it is based on the core rule that all heroes are unique
		upgrade_data.count = rarity
	else
		upgrade_data.count = upgrade_data.count + rarity
	end

	Upgrades:RefreshIntrinsicModifierByName(hero, ability_name)

	return upgrade_data
end


function Upgrades:AddUpgradeFromTable(hero, ability_name, upgrade_name, new_upgrade_data, rarity)
	if not hero.upgrades then hero.upgrades = {} end
	if not hero.upgrades[ability_name] then hero.upgrades[ability_name] = {} end

	local upgrade_data = hero.upgrades[ability_name][upgrade_name]

	if upgrade_data then
		upgrade_data.count = upgrade_data.count + rarity
	else
		hero.upgrades[ability_name][upgrade_name] = new_upgrade_data
		upgrade_data = hero.upgrades[ability_name][upgrade_name]
		upgrade_data.count = rarity
	end

	Upgrades:RefreshIntrinsicModifierByName(hero, ability_name)

	return upgrade_data
end


function Upgrades:ApplyLinkedUpgrades(hero, hero_name, ability_name, special_value_name, rarity)
	local upgrade_config = self.upgrades_kv[hero_name][ability_name][special_value_name]
	local linked_special_values = upgrade_config.linked_special_values or {}

	-- applying upgrades from in-ability links
	for linked_name, value in pairs(linked_special_values) do
		-- print("[Upgrades] adding linked upgrade for", linked_name, "with value", value)
		local upgrade_data = Upgrades:AddOrIncrementUpgrade(hero, ability_name, linked_name, value, rarity)

		-- linked upgrades operators default to parent upgrade value
		if not upgrade_data.operator then upgrade_data.operator = UPGRADE_OPERATOR.ADD end
	end

	-- applying upgrades from cross-abilities links
	local linked_abilities = upgrade_config.linked_abilities or {}

	for linked_ability_name, link_config in pairs(linked_abilities) do
		hero.upgrades[linked_ability_name] = hero.upgrades[linked_ability_name] or {}

		for linked_name, value in pairs(link_config) do
			local upgrade_data = Upgrades:AddOrIncrementUpgrade(hero, linked_ability_name, linked_name, value, rarity)

			if not upgrade_data.operator then upgrade_data.operator = UPGRADE_OPERATOR.ADD end
		end
	end
end


function Upgrades:RefreshIntrinsicModifierByName(hero, ability_name)
	Upgrades:RefreshIntrinsicModifier(hero, hero:FindAbilityByName(ability_name))
end


function Upgrades:RefreshIntrinsicModifier(hero, ability)
	if IsValidEntity(ability) and ability:GetLevel() > 0 then
		ability:RefreshIntrinsicModifier()

		if self.abilities_requires_level_reset[ability:GetAbilityName()] then
			ability:SetLevel(ability:GetLevel())
		end
	end
end


function Upgrades:AddAbilityUpgrade(hero, ability_name, special_value_name, rarity)
	local player_id = hero:GetPlayerOwnerID()
	if not player_id then return end

	if not rarity then rarity = UPGRADE_RARITY_COMMON end
	if not hero.upgrades then hero.upgrades = {} end

	local hero_name = hero:GetUnitName()
	-- print("[Upgrades] adding ability upgrade for", hero_name, ability_name, special_value_name, rarity)

	local base_value = Upgrades:GetUpgradeValue(hero_name, ability_name, special_value_name)

	local upgrade_data = hero.upgrades[ability_name] and hero.upgrades[ability_name][special_value_name]

	-- rarity there is a multiplier effectively, being 1, 2, 4 for common, rare and legendary respectively
	-- instead of pushing several upgrades with table for each, make a counter that is incremented depending on rarity
	-- (making rare count for 2, complying to multiplier)
	-- and record added upgrades as a rarity sequence to display in UIs and whatnot
	if not upgrade_data then
		upgrade_data = Upgrades:AddOrIncrementUpgrade(hero, ability_name, special_value_name, base_value, rarity)
	else
		upgrade_data.count = upgrade_data.count + rarity
	end

	if tonumber(upgrade_data.max_count) and upgrade_data.count >= tonumber(upgrade_data.max_count) then
		Upgrades:DisableUpgrade(player_id, ability_name, special_value_name)
	end

	Upgrades:ApplyLinkedUpgrades(hero, hero_name, ability_name, special_value_name, rarity)

	local controller_modifier = hero:FindModifierByName("modifier_ability_upgrades_controller")

	if not controller_modifier then
		controller_modifier = hero:AddNewModifier(hero, nil, "modifier_ability_upgrades_controller", {})
	end

	controller_modifier:ForceRefresh()

	CustomNetTables:SetTableValue("ability_upgrades", tostring(player_id), hero.upgrades)

	Upgrades:RefreshIntrinsicModifierByName(hero, ability_name)

	Upgrades:ProcessClones(hero, true)

	Upgrades:ProcessRetroactiveSummonUpgrades(hero, ability_name)
end


function Upgrades:SetGenericUpgrade(hero, upgrade_name, count)
	if not count then return end

	local player_id = hero:GetPlayerOwnerID()
	if not player_id then return end

	hero.upgrades.generic = hero.upgrades.generic or {}
	local upgrade_data = hero.upgrades.generic[upgrade_name]

	if not upgrade_data then
		local upgrade_def = GenericUpgrades.generic_upgrades_data[upgrade_name]
		hero.upgrades.generic[upgrade_name] = {
			count = count,
			operator = upgrade_def.operator,
			min_rarity = upgrade_def.rarity,
			max_count = tonumber(upgrade_def.max_count)
		}
		upgrade_data = hero.upgrades.generic[upgrade_name]
	else
		upgrade_data.count = count
	end

	local upgrade_kv = self.generic_upgrades_kv[upgrade_name]
	if not upgrade_kv then return end

	if upgrade_kv.class == "modifier" then
		Upgrades:AddGenericUpgradeModifier(hero, upgrade_name, upgrade_data.count)
	end

	return upgrade_data
end


function Upgrades:AddGenericUpgradeModifier(unit, upgrade_name, upgrade_count)
	local upgrade_definition = self.generic_upgrades_kv[upgrade_name]

	if (unit:IsClone() or unit:IsSpiritBear()) and (upgrade_definition.ignore_clones and upgrade_definition.ignore_clones == 1) then
		-- print("AddGenericUpgradeModifier discarded", upgrade_name, "for", unit:GetUnitName(), "- can't be applied to clones", upgrade_definition.ignore_clones)
		return
	end

	if (unit:IsIllusion() or unit:IsMonkeyKingSoldier()) and upgrade_definition.ignore_illusions then
		-- print("AddGenericUpgradeModifier discarded", upgrade_name, "for", unit:GetUnitName(), "- can't be applied to illusions")
		return
	end

	local modifier_name = "modifier_" .. upgrade_name .. "_upgrade"

	local modifier = unit:FindModifierByName(modifier_name)

	if not modifier or modifier:IsNull() then
		modifier = unit:AddNewModifier(unit, nil, modifier_name, {duration = -1})
	end

	-- in some cases adding new modifier fails
	-- usually happens when trying to add modifier to dead unit
	-- which is irrelevant in this case since generics are refreshed / reapplied on hero respawn
	if not modifier or modifier:IsNull() then return end

	modifier:SetStackCount(upgrade_count)
	modifier:ForceRefresh()

	if unit.CalculateStatBonus then
		unit:CalculateStatBonus(true)
	end
end


function Upgrades:AddGenericUpgrade(hero, upgrade_name, count)
	if not count then return end

	local player_id = hero:GetPlayerOwnerID()
	if not player_id then return end

	local current_count = hero.upgrades.generic and hero.upgrades.generic[upgrade_name] and hero.upgrades.generic[upgrade_name].count or 0
	local new_count = current_count + count

	local applied_upgrade = Upgrades:SetGenericUpgrade(hero, upgrade_name, new_count)
	if not applied_upgrade then return end

	CustomNetTables:SetTableValue("ability_upgrades", tostring(player_id), hero.upgrades)

	for _, clone in pairs(hero:GetClones()) do
		Upgrades:AddGenericUpgradeModifier(clone, upgrade_name, new_count)
	end

	if applied_upgrade.max_count and applied_upgrade.count >= applied_upgrade.max_count then
		Upgrades:DisableUpgrade(player_id, "generic", upgrade_name)
		print("Disabled", upgrade_name, "from rolling - max count reached", applied_upgrade.count, applied_upgrade.max_count)
	end

	Upgrades:AddGenericToSummons(hero, upgrade_name, new_count)
end


function Upgrades:ProcessClone(clone, hero)
	if not clone or not IsValidEntity(clone) or not clone:IsAlive() then return end
	if not IsValidEntity(hero) then hero = clone:GetCloneSource() end
	if not IsValidEntity(hero) then return end
 
	local controller_modifier = clone:FindModifierByName("modifier_ability_upgrades_controller")

	if not controller_modifier then
		controller_modifier = clone:AddNewModifier(clone, nil, "modifier_ability_upgrades_controller", nil)

		for ability_name, _ in pairs(hero.upgrades) do
			Upgrades:RefreshIntrinsicModifierByName(clone, ability_name)
		end
	end

	controller_modifier:ForceRefresh()
end


function Upgrades:ProcessClones(hero, skip_generics)
	local clones = hero:GetClones()

	for _, clone in pairs(clones) do
		Upgrades:ProcessClone(clone, hero, skip_generics)
	end
end


function Upgrades:IterateSummonList(hero, callback)
	for summon_entity_index, summon in pairs(self.summon_list[hero:GetPlayerOwnerID()] or {}) do
		if not IsValidEntity(summon) then
			self.summon_list[summon_entity_index] = nil
		else
			local summon_name = summon:GetUnitName()
			local summon_params = SUMMON_TO_ABILITY_MAP[summon_name]

			ErrorTracking.Try(callback, summon, summon_name, summon_params)
		end
	end
end


function Upgrades:ProcessRetroactiveSummonUpgrades(hero, ability_name)
	Upgrades:IterateSummonList(hero, function(summon, summon_name, summon_params)
		if ability_name == summon_params.ability then
			self:ApplySummonUpgrades(summon, summon_name, hero)
		end
	end)
end


function Upgrades:AddGenericToSummons(hero, upgrade_name, new_count)
	Upgrades:IterateSummonList(hero, function(summon, summon_name, summon_params)
		if summon_params.generic_upgrades then
			Upgrades:AddGenericUpgradeModifier(summon, upgrade_name, new_count)
		end
	end)
end


function Upgrades:ApplySummonUpgrades(summon, summon_name, owner)
	if not summon or not summon_name then return end
	-- some summons have players as owners, instead of heroes (thanks valve)
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
			-- print("[Upgrades] updating summon health to", required_health, ability:GetLevelSpecialValueNoOverride(summon_params.health, ability:GetLevel() - 1))

			-- bear is now a full hero, which requires special health handling
			if summon_params.health_bonus_as_modifier then
				-- deduct base health value since modifier acts as a bonus (unlike Set solution which overrides)
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

		-- print("[Upgrades] updating summon health to", new_max_health)
		local health_pct = summon:GetHealthPercent()

		summon:SetBaseMaxHealth(new_max_health)
		summon:SetMaxHealth(new_max_health)

		if summon:IsAlive() then
			summon:SetHealth(summon:GetMaxHealth() * health_pct / 100)
		end
	end

	if summon_params.damage then
		local required_damage = ability:GetSpecialValueFor(summon_params.damage)
		-- print("[Upgrades] updating summon damage to", required_damage)
		summon:SetBaseDamageMin(required_damage)
		summon:SetBaseDamageMax(required_damage)
	end

	if summon_params.armor then
		local required_armor = ability:GetSpecialValueFor(summon_params.armor)
		-- print("[Upgrades] updating summon armor to", required_armor)
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

	if summon_params.retroactive and not (self.summon_list[summon_owner_id] and self.summon_list[summon_owner_id][summon_entity_index]) then
		if not self.summon_list[summon_owner_id] then self.summon_list[summon_owner_id] = {} end
		self.summon_list[summon_owner_id][summon_entity_index] = summon
	end

	if summon_params.ability_upgrades then

		summon:AddNewModifier(owner, nil, "modifier_ability_upgrades_controller", nil)

		-- Update intrinsic modifiers after upgrades added
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

	if summon_params.generic_upgrades then
		for name, data in pairs(owner.upgrades.generic or {}) do
			if data.count and data.count > 0 then
				Upgrades:AddGenericUpgradeModifier(summon, name, data.count)
			end
		end
	end
end
 

function Upgrades:OnModifierAdded(event)
	local modifier = event.modifier
	if not modifier or modifier:IsNull() then return end

	local modifier_name = modifier:GetName()

	if modifier_name == "modifier_monkey_king_fur_army_soldier_in_position" then
		local parent = modifier:GetParent()
		local caster = modifier:GetCaster()

		Upgrades:ProcessClone(parent, caster, false)
	end

	if modifier_name == "modifier_invoker_ice_wall_slow_aura" or modifier_name == "modifier_invoker_ice_wall_thinker" then
		local parent = modifier:GetParent()
		parent:AddNewModifier(parent, modifier:GetAbility(), "modifier_dummy_caster", {})
	end
end


function Upgrades:GetPlayerUpgrades(player_id)
	local player_upgrades = {}

	local hero = GameLoop.hero_by_player_id[player_id]
	if not IsValidEntity(hero) then return {} end

	local hero_name = hero:GetUnitName()
	local hero_upgrades = Upgrades.upgrades_kv[hero_name] or {}

	for ability_name, upgrades in pairs(hero_upgrades) do
		for upgrade_name, _ in pairs(upgrades) do
			if hero.upgrades and hero.upgrades[ability_name] and hero.upgrades[ability_name][upgrade_name] and hero.upgrades[ability_name][upgrade_name].count > 0 then
				table.insert(player_upgrades, {ability_name, upgrade_name, hero.upgrades[ability_name][upgrade_name].count})
			end
		end
	end

	for upgrade_name, _ in pairs(Upgrades.generic_upgrades_kv or {}) do
		if hero.upgrades and hero.upgrades.generic and hero.upgrades.generic[upgrade_name] and hero.upgrades.generic[upgrade_name].count > 0 then
			table.insert(player_upgrades, {"generic", string.gsub(upgrade_name, "generic_", ""), hero.upgrades.generic[upgrade_name].count})
		end
	end

	return player_upgrades
end


Upgrades:Init()
