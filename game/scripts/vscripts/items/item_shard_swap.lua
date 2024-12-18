item_shard_swap = class({})
--------------------------------------------------------------------------------
function item_shard_swap:Precache( context )
	PrecacheResource( "model", "models/props_winter/present.vmdl", context )
	PrecacheResource( "particle", "models/props_gameplay/aghs21_device/particles/device_ambient_a.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context )
end

function item_shard_swap:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		if hTarget:FindModifierByName("modifier_aghanim_spell_swap") then
            hTarget:RemoveModifierByName( "modifier_aghanim_spell_swap" )
            self:SpendCharge(0.1)
        else
        	return
        end
	end
end

--------------------------------------------------------------------------------