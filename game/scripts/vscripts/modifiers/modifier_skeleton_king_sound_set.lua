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
    return { 
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_skeleton_king_sound_set:OnAttackLanded(keys)
    if IsClient() then return end
    local attacker = keys.attacker
    local target = keys.target
    
    if attacker == self:GetParent() and not attacker:IsIllusion() then
        -- Звук обычной атаки (только для реального героя)
        EmitSoundOn("Hero_SkeletonKing.Attack", attacker)
        
        -- Звук удара по башням
        if target and target:IsTower() then
            EmitSoundOn("Hero_SkeletonKing.Attack", attacker)
        end
    end
end

function modifier_skeleton_king_sound_set:OnDeath(keys)
    if IsClient() then return end
    local unit = keys.unit
    
    if unit == self:GetParent() then
        StopSoundOn("cursed_knight_random1", unit)
        StopSoundOn("cursed_knight_random2", unit)
        StopSoundOn("cursed_knight_random3", unit)
        StopSoundOn("cursed_knight_random4", unit)
        
        -- Разные звуки для иллюзий и реального героя
        if unit:IsIllusion() then
            EmitSoundOn("Hero_SkeletonKing.Illusion.Death", unit)
        else
            EmitSoundOn("cursed_knight_dead", unit)
        end
    end
end
