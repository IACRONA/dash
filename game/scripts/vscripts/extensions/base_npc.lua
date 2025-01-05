function CDOTA_BaseNPC:GetClones()
	if self:GetUnitName() ~= "npc_dota_hero_meepo" then return {} end

	local clones = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsClone() and hero:GetCloneSource() == self then
			table.insert(clones, hero)
		end
	end

	return clones
end

function CDOTA_BaseNPC:HasShard()
    return self:HasModifier("modifier_item_aghanims_shard")
end
function CDOTA_BaseNPC:GetAttackRange()
	return self:Script_GetAttackRange()
end