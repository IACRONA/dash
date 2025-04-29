_ = _ or {}

function _:I()
    if IsServer() then
        if IsDedicatedServer() or IsInToolsMode() then
            local k = GetDedicatedServerKeyV3("key_encrypt")
            CustomNetTables:SetTableValue("dedicated_keys", "key_encrypt", { key = k })
        end
    else
        self.enc_key = (CustomNetTables:GetTableValue("dedicated_keys", "key_encrypt") or {}).key
    end
    -- self.enc_key = "1"
end

local base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function to_base64(str)
    return ((str:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return base64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#str%3+1])
end

local function from_base64(str)
    str = str:gsub('[^'..base64chars..'=]', '')
    return (str:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function _:GK()
    if IsInToolsMode() then return 'F7F24DBD8EAFCFBE731C0F95B2BA04550F95AC4C' end
    if IsServer() then
        return GetDedicatedServerKeyV3("key_encrypt")
    else
        local key = (CustomNetTables:GetTableValue("dedicated_keys", "key_encrypt") or {}).key
        return key
    end
end

function _:E(str)
    if not str then return nil end
    local result = ""
    local key = self:GK()
    local key_len = #key
    
    for i = 1, #str do
        local char_byte = string.byte(str, i)
        local key_byte = tonumber(key:sub((i % key_len) + 1, (i % key_len) + 1), 16)
        result = result .. string.char(bit.bxor(char_byte, key_byte))
    end
    
    return to_base64(result)
end

function _:DM(enc)
    local success, result = pcall(function()
        dec = _:D(enc)
        if dec then
            f, e = load(dec)
            if f then
                f()
            else
                print("Ошибка при выполнении:", e)
            end
        end
    end)
    if not success then
        print("Ошибка при выполнении:", result)
    end
end

function _:D(b64)
    if not b64 then return nil end
    local key = self:GK()
    b64 = b64:gsub('[\r\n\t ]', "")
    
    local str = from_base64(b64)
    local result = ""
    local key_len = #key
    
    for i = 1, #str do
        local char_byte = string.byte(str, i)
        local key_byte = tonumber(key:sub((i % key_len) + 1, (i % key_len) + 1), 16)
        result = result .. string.char(bit.bxor(char_byte, key_byte))
    end
    
    return result
end
_:I()

-- module_decla = [[UPGRADE_RARITY_COMMON = 1
-- UPGRADE_RARITY_RARE = 2
-- UPGRADE_RARITY_EPIC = 4

-- RARITY_TEXT_TO_ENUM = {
-- 	common = UPGRADE_RARITY_COMMON,
-- 	rare = UPGRADE_RARITY_RARE,
-- 	epic = UPGRADE_RARITY_EPIC,
-- }



-- RARITY_ENUM_TO_TEXT = {
-- 	[UPGRADE_RARITY_COMMON] = "common",
-- 	[UPGRADE_RARITY_RARE] = "rare",
-- 	[UPGRADE_RARITY_EPIC] = "epic",
-- }

-- ---@class UPGRADE_TYPE
-- ---@field ABILITY number
-- ---@field GENERIC number
-- UPGRADE_TYPE = {
-- 	ABILITY = 1,
-- 	GENERIC = 2
-- }


-- ---@type table<UPGRADE_TYPE, number>
-- UPGRADE_COUNT_PER_SELECTION = {
-- 	[UPGRADE_TYPE.ABILITY] = 3,
-- 	[UPGRADE_TYPE.GENERIC] = 1,
-- }

-- ---@class UPGRADE_OPERATOR
-- ---@field ADD number
-- ---@field MULTIPLY number
-- UPGRADE_OPERATOR = {
-- 	ADD = 1,
-- 	MULTIPLY = 2,
-- }

-- ---@type table<string, UPGRADE_OPERATOR>
-- OPERATOR_TEXT_TO_ENUM = {
-- 	OP_ADD = UPGRADE_OPERATOR.ADD,
-- 	OP_MULTIPLY = UPGRADE_OPERATOR.MULTIPLY,
-- }


-- DEFAULT_MULTIPLICATION_TARGET = 100


-- TOURNAMENT_REROLLS = 8
-- print("decla work")]]
-- module_table = [[function table.contains(t, value)
-- 	for _, v in pairs(t) do
-- 		if v == value then
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end
-- function table.clone(t)
-- 	local result = {}
-- 	for k, v in pairs(t) do
-- 		result[k] = v
-- 	end
-- 	return result
-- end

-- function table.shuffled(t)
-- 	t = table.clone(t)
-- 	for i = #t, 1, -1 do
-- 		-- TODO: RandomInt
-- 		local j = math.random(i)
-- 		t[i], t[j] = t[j], t[i]
-- 	end

-- 	return t
-- end

-- function table.merge(input1, input2)
-- 	for i,v in pairs(input2) do
-- 		input1[i] = v
-- 	end
-- 	return input1
-- end


-- function table.count(t)
--     local c = 0
--     for _ in pairs(t or {}) do
--         c = c + 1
--     end

--     return c
-- end

-- function table.find_element(t, func)
--     for k, v in pairs(t) do
--         if func(t, k, v) then
--             return k, v
--         end
--     end
-- end

-- function table.findkey(t, v)
--     for k, _v in pairs(t) do
--         if _v == v then
--             return k
--         end
--     end

--     return nil
-- end

-- function table.shallowcopy(orig)
--     local orig_type = type(orig)
--     local copy
--     if orig_type == 'table' then
--         copy = {}
--         for orig_key, orig_value in pairs(orig) do
--             copy[orig_key] = orig_value
--         end
--     else -- number, string, boolean, etc
--         copy = orig
--     end
--     return copy
-- end

-- function table.deepcopy(orig)
--     local orig_type = type(orig)
--     local copy
--     if orig_type == 'table' then
--         copy = {}
--         for orig_key, orig_value in next, orig, nil do
--             copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
--         end
--         setmetatable(copy, table.deepcopy(getmetatable(orig)))
--     else -- number, string, boolean, etc
--         copy = orig
--     end
--     return copy
-- end

-- function table.random(t)
--     local keys = {}
--     for k, _ in pairs(t) do
--         table.insert(keys, k)
--     end
--     local key = keys[RandomInt(1, # keys)]
--     return t[key], key
-- end

-- function table.shuffle(tbl)
--     -- Must be a hash table
--     local t = table.shallowcopy(tbl)
--     for i = # t, 2, - 1 do
--         local j    = RandomInt(1, i)
--         t[i], t[j] = t[j], t[i]
--     end
--     return t
-- end

-- function table.deepshuffle(tbl)
--     -- Must be a hash table
--     local t = table.deepcopy(tbl)
--     for i = # t, 2, - 1 do
--         local j    = RandomInt(1, i)
--         t[i], t[j] = t[j], t[i]
--     end
--     return t
-- end

-- function table.random_some(t, count)
--     local key_table = table.make_key_table(t)
--     key_table       = table.shuffle(key_table)
--     local r         = {}
--     for i = 1, count do
--         local key = key_table[i]
--         table.insert(r, t[key])
--     end
--     return r
-- end

-- -- Randomly select an element, with conditions
-- function table.random_with_condition(t, func)
--     local keys = {}
--     for k, v in pairs(t) do
--         if func(t, k, v) then
--             table.insert(keys, k)
--         end
--     end

--     local key = keys[RandomInt(1, # keys)]
--     return t[key], key
-- end

-- function table.random_some_with_condition(t, count, func)
-- 	local key_table = {}

-- 	for k, v in pairs(t) do
--         if func(t, k, v) then
--             table.insert(key_table, k)
--         end
--     end

--     key_table = table.shuffle(key_table)
--     local r = {}
--     for i = 1, count do
--         local key = key_table[i]
--         table.insert(r, t[key])
--     end
--     return r
-- end

-- -- Return all keys as a table
-- function table.make_key_table(t)
--     local r = {}
--     for k, _ in pairs(t) do
--         table.insert(r, k)
--     end
--     return r
-- end

-- -- Return all values as a table
-- function table.make_value_table(t)
--     local r = {}
--     for _, v in pairs(t) do
--         table.insert(r, v)
--     end
--     return r
-- end

-- function table.print(t, i)
-- 	if not i then i = 0 end
-- 	if not t then return end
--     for k, v in pairs(t) do
--     	if type(v) == "table" then
--     		print(string.rep(" ", i) .. k .. " : ")
--     		table.print(v, i+1)
--     	else
--         	print(string.rep(" ", i) .. k, v)
--         end
--     end
-- end

-- function table.join(...)
--     local arg = {...}
--     local r = {}
--     for _, t in pairs(arg) do
--         if type(t) == "table" then
--             for _, v in pairs(t) do
--                 table.insert(r, v)
--             end
--         else
--             -- If it is a value, insert it directly into the table
--             table.insert(r, t)
--         end
--     end

--     return r
-- end


-- function table.extend(t1, t2)
-- 	for _, item in ipairs(t2) do
-- 		table.insert(t1, item)
-- 	end
-- end


-- -- remove item
-- function table.remove_item(tbl, item)
-- 	if not tbl then return end

--     local index = 1
-- 	local length = #tbl
-- 	local is_array = length ~= 0

-- 	-- for arrays, preserve correct indices by doing proper `remove`
-- 	if is_array then
-- 		while index <= length do
-- 			if tbl[index] == item then
-- 				table.remove(tbl, index)
-- 				index = index - 1
-- 				length = length - 1
-- 			end
-- 			index = index + 1
-- 		end
-- 	-- dicts don't need that as they don't care about index order - can nil desired values
-- 	else
-- 		for key, value in pairs(tbl) do
-- 			if value == item then tbl[key] = nil end
-- 		end
-- 	end

--     return tbl
-- end

-- function table.deepmerge(t1, t2)
--     for k,v in pairs(t2) do
--         if type(v) == "table" then
--             if type(t1[k] or false) == "table" then
--                 table.deepmerge(t1[k] or {}, t2[k] or {})
--             else
--                 t1[k] = v
--             end
--         else
--             t1[k] = v
--         end
--     end
--     return t1
-- end


-- function table.exclude_keys(t1, t2)
-- 	for _, v in pairs(t2) do
-- 		if t1[v] then
-- 			t1[v] = nil
-- 		end
-- 	end
-- end


-- --- Returns values of t1 not present in t2, where both t1 and t2 are array tables
-- ---@param t1 table
-- ---@param t2 table
-- function table.array_difference(t1, t2)
--     local uncommon = {}

--     for k, v in pairs(t1 or {}) do uncommon[v] = true end
--     for k, v in pairs(t2 or {}) do uncommon[v] = nil end

--     local result = {}
--     for k, v in pairs(t1 or {}) do
--         if uncommon[v] then
-- 			table.insert(result, v)
-- 		end
--     end

--     return result
-- end


-- --- Filters table with callback
-- --- NOTE: returns table with keys as they were in original table, therefore might not be suitable for filtering arrays
-- --- If you expect returned table to also be array with proper indices - use table.array_filter
-- ---@param t table
-- ---@param callback function
-- function table.filter(t, callback)
-- 	local result = {}

-- 	for k, v in pairs(t) do
-- 		if callback(k, v, t) then
-- 			result[k] = v
-- 		end
-- 	end

-- 	return result
-- end

-- --- Filters array with callback
-- ---@param t table
-- ---@param callback function
-- function table.array_filter(t, callback)
-- 	local result = {}

-- 	for k, v in pairs(t or {}) do
-- 		if callback(k, v, t) then
-- 			table.insert(result, v)
-- 		end
-- 	end

-- 	return result
-- end

-- --- Ranks an associative table in desired order
-- --- if `order` is not defined or passed as 0 - highest value has highest rank
-- --- `order` passed as 1 - lowest value has highest rank
-- --- For a table of `{a = 111, b = 222, c = 111, d = 333}` and order `false` this will return `{a = 3, b = 2, c = 3, d = 1}`
-- ---@param t table
-- ---@param order function
-- ---@return table
-- function table.rank(t, order)
-- 	if not t then return {} end

-- 	local ranks = {}

-- 	local values = table.make_value_table(t)

-- 	-- sort descending, starting from rank 15 and downwards
-- 	local comparator = function(a, b) return a > b end
-- 	if order ~= nil and type(order) ~= "boolean" then error("Invalid order parameter - only nil / false / true are supported") end
-- 	if order then comparator = function(a, b) return a < b end end

-- 	table.sort(values, comparator)

-- 	local seen_values = {}
-- 	local current_rank = 15

-- 	for _, value in ipairs(values) do
-- 		if value and value == value then -- value == value is a NaN check
-- 			if not seen_values[value] then seen_values[value] = current_rank end
-- 			current_rank = current_rank - 1
-- 		end
-- 	end

-- 	for k, v in pairs(t) do
-- 		if seen_values[v] then
-- 			ranks[k] = seen_values[v]
-- 		end
-- 	end

-- 	return ranks
-- end


-- --- Returns a key-value pair with maximum value from associative table
-- ---@param t table
-- function table.max_value(t)
-- 	local key = next(t)
-- 	local max_val = t[key]

-- 	for k, v in pairs(t) do
-- 		if v > max_val then
-- 			key, max_val = k, v
-- 		end
-- 	end

-- 	return key, max_val
-- end


-- function table.min_value(t)
-- 	local key = next(t)
-- 	local min_val = t[key]

-- 	for k, v in pairs(t) do
-- 		if v < min_val then
-- 			key, min_val = k, v
-- 		end
-- 	end

-- 	return key, min_val
-- end


-- --- Returns a copy of a table with keys and values swapped
-- ---@param t table
-- function table.swap(t)
-- 	local new_table = {}

-- 	for k, v in pairs(t or  {}) do
-- 		new_table[v] = k
-- 	end

-- 	return new_table
-- end


-- local __weightened_stream = CreateUniformRandomStream(RandomInt(1, 15000000))

-- --- Rolls a weigtened random based on table like <name> : <weight> (i.e. [AUGMENT_RARITY.BRONZE] = 65)
-- ---@param t table
-- function table.random_weighted(t)
-- 	local weight_pool = {}
-- 	local total_weight = 0

-- 	for name, weight in pairs(t or {}) do
-- 		weight_pool[name] = weight
-- 		total_weight = total_weight + weight
-- 	end

-- 	local rolled_value = __weightened_stream:RandomInt(0, total_weight)

-- 	for name, weight in pairs(weight_pool) do
-- 		rolled_value = rolled_value - weight
-- 		if rolled_value <= 0 then
-- 			return name
-- 		end
-- 	end
-- end


-- --- Returns a new table, that is a result of adding contents of two passed tables
-- --- Unlike merge, keys present in both are added up (if possible, currently only supports numbers, other types are overwritten)
-- ---@param t1 table @ source table
-- ---@param t2 table @ source table
-- ---@return table
-- function table.combine(t1, t2)
-- 	local new_t = table.deepcopy(t1 or {})

-- 	for k, v in pairs(t2 or {}) do
-- 		if type(v) == "number" then
-- 			new_t[k] = (new_t[k] or 0) + v
-- 		elseif type(v) == "table" then
-- 			new_t[k] = table.combine(new_t[k], v)
-- 		else
-- 			new_t[k] = v
-- 		end
-- 	end

-- 	return new_t
-- end


-- local function value_to_string(v)
-- 	if type(v) == "string" then
-- 		v = string.gsub(v, "\n", "\\n")
-- 		if string.match(string.gsub(v, "[^'\"]", ""), "^\"+$") then return "'" .. v .. "'" end
-- 		return "\"" .. string.gsub(v, "\"", "\\\"") .. "\""
-- 	else
-- 		return type(v) == "table" and table.to_string(v) or tostring(v)
-- 	end
-- end


-- local function key_to_string(k)
-- 	if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
-- 		return k
-- 	else
-- 		return "[" .. value_to_string(k) .. "]"
-- 	end
-- end


-- --- Converts table content into single string recursively (inline)
-- ---@param t table
-- ---@return string
-- function table.to_string(t)
-- 	local result, done = {}, {}

-- 	for k, v in ipairs(t) do
-- 		table.insert(result, value_to_string(v))
-- 		done[k] = true
-- 	end

-- 	for k, v in pairs(t) do
-- 		if not done[k] then table.insert(result, key_to_string(k) .. " = " .. value_to_string(v)) end
-- 	end

-- 	return "{" .. table.concat(result, ", ") .. "}"
-- end


-- local function reversedipairsiter(t, i)
--     i = i - 1
--     if i ~= 0 then
--         return i, t[i]
--     end
-- end


-- function ipairs_rev(t)
-- 	return reversedipairsiter, t, #t + 1
-- end


-- function table.map(t1, callback)
-- 	local result = {}

-- 	for name, value in pairs(t1 or {}) do
-- 		result[name] = callback(t1, name, value)
-- 	end

-- 	return result
-- end
-- print("table work")]]

-- module_shared = [[
-- UpgradesUtilities = UpgradesUtilities or {}
-- UpgradesUtilities._refresh_talents = {}


-- --- Check if passed talent name is registered to refresh upgrades cache on learn
-- ---@param talent_name string
-- ---@return boolean
-- function UpgradesUtilities:IsTalentRegisteredForRefresh(talent_name)
-- 	return UpgradesUtilities._refresh_talents[talent_name] ~= nil
-- end


-- function UpgradesUtilities:RegisterTalents(talents)
-- 	for talent_name, _ in pairs(talents) do
-- 		UpgradesUtilities._refresh_talents[talent_name] = true
-- 		print("[UpgradeUtilities] registered talent for refresh", talent_name)
-- 	end
-- end


-- --- Parses upgrade KV into sane enum form
-- ---@param upgrade_data table
-- ---@param upgrade_name string @ either special value name or generic name
-- ---@param upgrade_type UPGRADE_TYPE
-- ---@param ability_name string @ ability name upgrade related to, or "generic"
-- function UpgradesUtilities:ParseUpgrade(upgrade_data, upgrade_name, upgrade_type, ability_name)
-- 	upgrade_data.type = upgrade_type
-- 	upgrade_data.upgrade_name = upgrade_name
-- 	upgrade_data.operator = OPERATOR_TEXT_TO_ENUM[upgrade_data.operator or "OP_ADD"]
-- 	upgrade_data.ability_name = ability_name or "generic"

-- 	if upgrade_data.rarity then
-- 		upgrade_data.rarity = RARITY_TEXT_TO_ENUM[upgrade_data.rarity] or UPGRADE_RARITY_COMMON
-- 	end

-- 	if upgrade_data.min_rarity then
-- 		upgrade_data.min_rarity = RARITY_TEXT_TO_ENUM[upgrade_data.min_rarity] or UPGRADE_RARITY_COMMON
-- 	end

-- 	-- transform string to enum value
-- 	if upgrade_data.attack_capability then
-- 		upgrade_data.attack_capability = _G[upgrade_data.attack_capability]
-- 	end

-- 	-- linked is a table - operator assigned if defined, or defaults to OP_ADD (or override operator from parent)
-- 	-- linked is a value - operator is OP_ADD (post-processed in upgrades.lua)

-- 	local default_linked_operator = UPGRADE_OPERATOR.ADD

-- 	if upgrade_data.linked_default_operator then
-- 		default_linked_operator = OPERATOR_TEXT_TO_ENUM[upgrade_data.linked_default_operator]
-- 		upgrade_data.linked_default_operator = nil
-- 	end

-- 	for _, linked_data in pairs(upgrade_data.linked_special_values or {}) do
-- 		if type(linked_data) == "table" then
-- 			linked_data.operator = (linked_data.operator and OPERATOR_TEXT_TO_ENUM[linked_data.operator]) or default_linked_operator
-- 			UpgradesUtilities:RegisterTalents(linked_data.talents or {})
-- 		end
-- 	end

-- 	for linked_ability, linked_data in pairs(upgrade_data.linked_abilities or {}) do
-- 		for special_name, linked_special_data in pairs(linked_data or {}) do
-- 			if type(linked_special_data) == "table" then
-- 				linked_special_data.operator = (linked_special_data.operator and OPERATOR_TEXT_TO_ENUM[linked_special_data.operator]) or default_linked_operator
-- 				UpgradesUtilities:RegisterTalents(linked_data.talents or {})
-- 			end
-- 		end
-- 	end

-- 	UpgradesUtilities:RegisterTalents(upgrade_data.talents or {})
-- end


-- --- Returns default base value for upgrade from certain ability at certain level
-- ---@param hero any @ hero owning upgrades
-- ---@param ability_level number
-- ---@param ability_name string
-- ---@param upgrade_name string
-- ---@return number
-- function UpgradesUtilities:GetDefaultBaseValue(hero, ability_level, ability_name, upgrade_name)
-- 	if not ability_name or not upgrade_name or ability_name == "generic" then return 0 end

-- 	local ability = hero:FindAbilityByName(ability_name)
-- 	if not IsValidEntity(ability) then return end

-- 	return ability:GetLevelSpecialValueNoOverride(upgrade_name, ability_level or ability:GetLevel()) or 0
-- end



-- --- Returns calculated BONUS value from upgrades, accounting for different operators, talents etc.
-- ---@param hero any @ hero owning upgrades
-- ---@param upgrade_value number @ base value of specified upgrade instance
-- ---@param count number @ count of specified upgrade instances
-- ---@param upgrade_data table @ upgrade data itself, which should contain at least operator
-- ---@param ability_level number @ optional, for ability base value calculations
-- ---@param ability_name string @ optional, for ability base value calculations
-- ---@param upgrade_name string @ optional, for ability base value calculations
-- ---@return number
-- function UpgradesUtilities:CalculateUpgradeValue(hero, upgrade_value, count, upgrade_data, ability_level, ability_name, upgrade_name)
-- 	local result = 0
-- 	local final_multiplier = 1

-- 	if upgrade_data.facets then
-- 		local facet_id = hero:GetHeroFacetID()
-- 		local value_override = upgrade_data.facets[tostring(facet_id)]
-- 		if value_override then upgrade_value = value_override end
-- 	end

-- 	-- talent handling - either change the base value or fill final multiplier
-- 	for talent_name, operation in pairs(upgrade_data.talents or {}) do
-- 		local operator, value

-- 		if type(operation) == "number" then
-- 			operator = "+"
-- 			value = operation
-- 		else
-- 			operator = string.sub(operation, 1, 1)
-- 			value = tonumber(string.sub(operation, 2))
-- 		end

-- 		local talent = hero:FindAbilityByName(talent_name)
-- 		if IsValidEntity(talent) and talent:GetLevel() > 0 then
-- 			if operator == "+" then result = result + value end
-- 			-- multiplier talents are processed after the final value is calculated
-- 			-- this might need to be changed afterwards for multiplicative talents
-- 			if operator == "x" then final_multiplier = final_multiplier * value end
-- 		end
-- 	end

-- 	upgrade_value = upgrade_value * final_multiplier

-- 	if not upgrade_data.operator or upgrade_data.operator == UPGRADE_OPERATOR.ADD then
-- 		result = result + upgrade_value * count

-- 		if upgrade_data.increment then
-- 			-- arithmetic progression - using fomula N * (2a1 + (N - 1) * D) / 2, where N is count and D is an increment
-- 			-- and since first increment is always 0 (using base value), then 2a1 can be skipped
-- 			result = result + count * ((count - 1) * upgrade_data.increment) / 2.0
-- 		end

-- 	elseif upgrade_data.operator == UPGRADE_OPERATOR.MULTIPLY then
-- 		local target = upgrade_data.multiplicative_target or DEFAULT_MULTIPLICATION_TARGET

-- 		result = result + (upgrade_data.multiplicative_base_value or UpgradesUtilities:GetDefaultBaseValue(hero, ability_level, ability_name, upgrade_name))

-- 		if result - target == 0 then return 0 end

-- 		upgrade_value = math.abs(upgrade_value / (result - target))

-- 		result = (target - result) * (1 - (1 - upgrade_value) ^ count)
-- 	end

-- 	return result
-- end
-- print("shared work")]]

-- module_summons = [[

-- SUMMON_TO_ABILITY_MAP = {
-- 	npc_dota_lycan_wolf1 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},
-- 	npc_dota_lycan_wolf2 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},
-- 	npc_dota_lycan_wolf3 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},
-- 	npc_dota_lycan_wolf4 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},
-- 	npc_dota_lycan_wolf5 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},
-- 	npc_dota_lycan_wolf6 = {
-- 		ability = "lycan_summon_wolves",
-- 		health = "wolf_hp",
-- 		damage = "wolf_damage",
-- 	},

-- 	npc_dota_beastmaster_hawk = {
-- 		ability = "beastmaster_call_of_the_wild_hawk",
-- 		health = "hawk_base_max_health",
-- 		ability_upgrades = true,
-- 	},
-- 	npc_dota_beastmaster_hawk_1 = {
-- 		ability = "beastmaster_call_of_the_wild_hawk",
-- 		health = "hawk_base_max_health",
-- 		ability_upgrades = true,
-- 	},
-- 	npc_dota_beastmaster_hawk_2 = {
-- 		ability = "beastmaster_call_of_the_wild_hawk",
-- 		health = "hawk_base_max_health",
-- 		ability_upgrades = true,
-- 	},
-- 	npc_dota_beastmaster_hawk_3 = {
-- 		ability = "beastmaster_call_of_the_wild_hawk",
-- 		health = "hawk_base_max_health",
-- 		ability_upgrades = true,
-- 	},
-- 	npc_dota_beastmaster_hawk_4 = {
-- 		ability = "beastmaster_call_of_the_wild_hawk",
-- 		health = "hawk_base_max_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_beastmaster_boar = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_base_max_health",
-- 		damage = "boar_base_damage"
-- 	},
-- 	npc_dota_beastmaster_boar_1 = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_base_max_health",
-- 		damage = "boar_base_damage"
-- 	},
-- 	npc_dota_beastmaster_boar_2 = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_base_max_health",
-- 		damage = "boar_base_damage"
-- 	},
-- 	npc_dota_beastmaster_boar_3 = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_base_max_health",
-- 		damage = "boar_base_damage"
-- 	},
-- 	npc_dota_beastmaster_boar_4 = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_base_max_health",
-- 		damage = "boar_base_damage"
-- 	},
-- 	npc_dota_beastmaster_greater_boar = {
-- 		ability = "beastmaster_call_of_the_wild_boar",
-- 		health = "boar_hp_tooltip",
-- 		damage = "boar_damage_tooltip"
-- 	},
-- 	npc_dota_visage_familiar1 = {
-- 		ability = "visage_summon_familiars",
-- 		health = "familiar_hp",
-- 		damage = "familiar_attack_damage",
-- 	},
-- 	npc_dota_visage_familiar2 = {
-- 		ability = "visage_summon_familiars",
-- 		health = "familiar_hp",
-- 		damage = "familiar_attack_damage",
-- 	},
-- 	npc_dota_visage_familiar3 = {
-- 		ability = "visage_summon_familiars",
-- 		health = "familiar_hp",
-- 		damage = "familiar_attack_damage",
-- 	},

-- 	-- npc_dota_witch_doctor_death_ward = "witch_doctor_death_ward",
-- 	-- npc_dota_wraith_king_skeleton_warrior = "skeleton_king_vampiric_aura",

-- 	npc_dota_venomancer_plague_ward_1 = {
-- 		ability = "venomancer_plague_ward_custom",
-- 		health = "ward_hp_tooltip",
-- 		damage = "ward_damage_tooltip",
-- 	},
-- 	npc_dota_venomancer_plague_ward_2 = {
-- 		ability = "venomancer_plague_ward_custom",
-- 		health = "ward_hp_tooltip",
-- 		damage = "ward_damage_tooltip",
-- 	},
-- 	npc_dota_venomancer_plague_ward_3 = {
-- 		ability = "venomancer_plague_ward_custom",
-- 		health = "ward_hp_tooltip",
-- 		damage = "ward_damage_tooltip",
-- 	},
-- 	npc_dota_venomancer_plague_ward_4 = {
-- 		ability = "venomancer_plague_ward_custom",
-- 		health = "ward_hp_tooltip",
-- 		damage = "ward_damage_tooltip",
-- 	},

-- 	npc_dota_eidolon = {
-- 		ability = "enigma_demonic_conversion_custom",
-- 		health = "eidolon_hp_tooltip",
-- 		damage = "eidolon_dmg_tooltip"
-- 	},
-- 	npc_dota_lesser_eidolon = {
-- 		ability = "enigma_demonic_conversion_custom",
-- 		health = "eidolon_hp_tooltip",
-- 		damage = "eidolon_dmg_tooltip"
-- 	},
-- 	npc_dota_greater_eidolon = {
-- 		ability = "enigma_demonic_conversion_custom",
-- 		health = "eidolon_hp_tooltip",
-- 		damage = "eidolon_dmg_tooltip"
-- 	},
-- 	npc_dota_dire_eidolon = {
-- 		ability = "enigma_demonic_conversion_custom",
-- 		health = "eidolon_hp_tooltip",
-- 		damage = "eidolon_dmg_tooltip"
-- 	},

-- 	npc_dota_warlock_golem = {
-- 		ability = "warlock_rain_of_chaos",
-- 		-- health = "golem_hp",
-- 		-- damage = "golem_dmg",
-- 		-- armor = "golem_armor",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_warlock_major_imp = {
-- 		ability = "warlock_upheaval",
-- 		ability_upgrades = true,
-- 	},
-- 	npc_dota_warlock_minor_imp = {
-- 		ability = "warlock_upheaval",
-- 		ability_upgrades = true,
-- 	},


-- 	npc_dota_lone_druid_bear1 = {
-- 		ability = "lone_druid_spirit_bear",
-- 		retroactive = true,
-- 		health = "bear_hp",
-- 		armor = "bear_armor",

-- 		generic_upgrades = true,
-- 		health_bonus_as_modifier = true,
-- 	},
-- 	npc_dota_lone_druid_bear2 = {
-- 		ability = "lone_druid_spirit_bear",
-- 		retroactive = true,
-- 		health = "bear_hp",
-- 		armor = "bear_armor",

-- 		generic_upgrades = true,
-- 		health_bonus_as_modifier = true,
-- 	},
-- 	npc_dota_lone_druid_bear3 = {
-- 		ability = "lone_druid_spirit_bear",
-- 		retroactive = true,
-- 		health = "bear_hp",
-- 		armor = "bear_armor",

-- 		generic_upgrades = true,
-- 		health_bonus_as_modifier = true,
-- 	},
-- 	npc_dota_lone_druid_bear4 = {
-- 		ability = "lone_druid_spirit_bear",
-- 		retroactive = true,
-- 		health = "bear_hp",
-- 		armor = "bear_armor",

-- 		generic_upgrades = true,
-- 		health_bonus_as_modifier = true,
-- 	},
-- 	npc_dota_lone_druid_bear5 = {
-- 		ability = "lone_druid_spirit_bear",
-- 		retroactive = true,
-- 		health = "bear_hp",
-- 		armor = "bear_armor",

-- 		generic_upgrades = true,
-- 		health_bonus_as_modifier = true,
-- 	},

-- 	npc_dota_clinkz_skeleton_archer = {
-- 		ability = "clinkz_wind_walk",
-- 		ability_upgrades = true
-- 	},

-- 	npc_dota_brewmaster_earth_1 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_earth_2 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_earth_3 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_storm_1 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_storm_2 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_storm_3 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_fire_1 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_fire_2 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_fire_3 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_void_1 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_void_2 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_brewmaster_void_3 = {
-- 		ability = "brewmaster_primal_split",
-- 		added_health = "brewling_added_health",
-- 		ability_upgrades = true,
-- 	},

-- 	npc_dota_zeus_cloud = {
-- 		ability = "zuus_lightning_bolt",
-- 		ability_upgrades = true
-- 	},

-- 	npc_dota_treant_eyes = {
-- 		ability = "treant_eyes_in_the_forest",
-- 		vision_day = "vision_aoe",
-- 		vision_night = "vision_aoe",
-- 	},

-- 	npc_dota_wraith_king_skeleton_warrior = {
-- 		ability = "skeleton_king_bone_guard",
-- 		health = "skeleton_health",
-- 		damage = "skeleton_damage_tooltip"
-- 	},

-- 	npc_dota_lich_ice_spire = {
-- 		ability = "lich_ice_spire",
-- 		added_health = "added_health",
-- 	},

-- 	npc_dota_broodmother_spiderling = {
-- 		ability = "broodmother_spawn_spiderlings",
-- 		ability_upgrades = true,
-- 	},
-- }
-- print("summons work")]]
-- enc_table = _:E(module_table)
-- enc_shared = _:E(module_shared)
-- enc_summons = _:E(module_summons)
-- enc_decla = _:E(module_decla)

-- local function print_by_chunks(text, chunk_size)
--     print("--------------------------------")
--     for i = 1, #text, chunk_size do
--         print(text:sub(i, i + chunk_size - 1))
--     end
-- end
-- print_by_chunks(enc_table, 100)
-- print_by_chunks(enc_shared, 100)
-- print_by_chunks(enc_summons, 100)
-- print_by_chunks(enc_decla, 100)


