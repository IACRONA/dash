modifier_skeleton_king_sound_set = modifier_skeleton_king_sound_set or class({})

function modifier_skeleton_king_sound_set:IsHidden()
	return true
end

function modifier_skeleton_king_sound_set:OnCreated()
    if IsClient() then return end
    self.cd = 15
	self:StartIntervalThink(1)
    EmitSoundOn( "cursed_knight_pick_hero", self:GetParent() )
end
 
function modifier_skeleton_king_sound_set:OnIntervalThink()
    if IsClient() then return end
    if self.cd <= 0 then
		local randInt = RandomInt(1, 4)
		EmitSoundOn("cursed_knight_random" .. randInt, self:GetParent())
        self.cd = 30
    end
    self.cd = self.cd - 1
end
function modifier_skeleton_king_sound_set:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_skeleton_king_sound_set:OnDeath(keys)
    if IsClient() then return end
    local unit = keys.unit
    if unit:GetUnitName() == "npc_dota_hero_skeleton_king" then
        StopSoundOn("cursed_knight_random1", unit)
        StopSoundOn("cursed_knight_random2", unit)
        StopSoundOn("cursed_knight_random3", unit)
        StopSoundOn("cursed_knight_random4", unit)
        EmitSoundOn("cursed_knight_dead", unit)
    end
end
