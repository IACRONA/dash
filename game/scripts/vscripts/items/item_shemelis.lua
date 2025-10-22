item_shemelis = class({})

LinkLuaModifier("modifier_item_shemelis", "modifiers/items/modifier_item_shemelis", LUA_MODIFIER_MOTION_NONE)

function item_shemelis:GetIntrinsicModifierName()
	return "modifier_item_shemelis"
end

function item_shemelis:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		if caster then
			local modifier = caster:FindModifierByName("modifier_item_shemelis")
			if modifier and modifier.TimeRewind then
				modifier:TimeRewind()
			end
			
			EmitSoundOn("Hero_Weaver.TimeLapse", caster)
		end
	end
end
