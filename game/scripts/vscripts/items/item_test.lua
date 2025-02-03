item_test = class({})

function item_test:OnSpellStart()
	local caster = self:GetCaster()
    DeepPrintTable(json)
	DeepPrintTable(CustomNetTables:GetTableValue("player_info", tostring(caster:GetPlayerOwnerID())) )
end