item_test = class({})

function item_test:OnSpellStart()
	local caster = self:GetCaster()
	print(caster:GetHeroFacetID())
end