require("settings/morph_settings")

modifier_custom_morph_boss_ai = class({})
function modifier_custom_morph_boss_ai:IsPurgable() return false end
function modifier_custom_morph_boss_ai:IsHidden() return true end
function modifier_custom_morph_boss_ai:IsPurgeException() return false end
function modifier_custom_morph_boss_ai:CheckState()
    return
    {
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

function modifier_custom_morph_boss_ai:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_custom_morph_boss_ai:GetModifierProvidesFOWVision() return 1 end

function modifier_custom_morph_boss_ai:OnCreated()
    if not IsServer() then return end
    self.attackerUnits = {}
    local effect2 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_ambient_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(effect2, false, false, -1, false, false)
    local effect3 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(effect3, false, false, -1, false, false)
    local head = ParticleManager:CreateParticle("particles/morph_head_skull.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(head, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
    self.head = head
    self:AddParticle(head, false, false, -1, false, false)
    self.target_kill = {}
    self.cast_interval = 0
    self:StartIntervalThink(0.1)
end

function modifier_custom_morph_boss_ai:OnDestroy()
    if not IsServer() then return end
    if self.head then
        ParticleManager:DestroyParticle(self.head, true)
    end
end

function modifier_custom_morph_boss_ai:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        if params.attacker:GetPlayerOwnerID() then
            self.attackerUnits[params.attacker:GetPlayerOwnerID()] = true
        end
    end
end

function modifier_custom_morph_boss_ai:OnIntervalThink()
    if not IsServer() then return end
    for i=0, 14 do
        AddFOWViewer(i, self:GetParent():GetAbsOrigin(), 500, 0.1, false)
    end
    self.cast_interval = self.cast_interval + FrameTime()

    if self.cast_interval >= 0.5 then
        self.cast_interval = 0
        if self:GetParent():IsSilenced() then return end
        if self:GetParent():IsStunned() then return end

        local morphling_boss_blast = self:GetParent():FindAbilityByName("morphling_boss_blast")
        if morphling_boss_blast and morphling_boss_blast:IsFullyCastable() and self:GetParent().current_target ~= nil then
            morphling_boss_blast:Start()
            morphling_boss_blast:UseResources(false, false, false, true)
        end

        local morphling_boss_wave = self:GetParent():FindAbilityByName("morphling_boss_wave")
        if morphling_boss_wave and morphling_boss_wave:IsFullyCastable() and self:GetParent().current_target ~= nil then
            morphling_boss_wave:Start(self:GetParent().current_target)
            morphling_boss_wave:UseResources(false, false, false, true)
            return
        end

        local morphling_boss_crystalnova = self:GetParent():FindAbilityByName("morphling_boss_crystalnova")
        if morphling_boss_crystalnova and morphling_boss_crystalnova:IsFullyCastable() and self:GetParent().current_target ~= nil then
            morphling_boss_crystalnova:Start(self:GetParent().current_target)
            morphling_boss_crystalnova:UseResources(false, false, false, true)
            return
        end

        local morphling_boss_frostbite = self:GetParent():FindAbilityByName("morphling_boss_frostbite")
        if morphling_boss_frostbite and morphling_boss_frostbite:IsFullyCastable() and self:GetParent().current_target ~= nil then
            morphling_boss_frostbite:Start(self:GetParent().current_target)
            morphling_boss_frostbite:UseResources(false, false, false, true)
            return
        end

        local morphling_boss_finger = self:GetParent():FindAbilityByName("morphling_boss_finger")
        if morphling_boss_finger and morphling_boss_finger:IsFullyCastable() and self:GetParent().current_target ~= nil then
            morphling_boss_finger:Start(self:GetParent().current_target)
            morphling_boss_finger:UseResources(false, false, false, true)
            return
        end
    end
end

function modifier_custom_morph_boss_ai:OnDeath(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and params.unit:IsRealHero() then
        if GameRules.AddonTemplate.nCapturedFlagsCount[params.unit:GetTeamNumber()] > 0 then
            if self.target_kill[params.unit:entindex()] == nil then
                self.target_kill[params.unit:entindex()] = 0
            end
            if self.target_kill[params.unit:entindex()] > MORPH_KILL_HERO_STEAL_POINT_MAX then
                return
            end
            self.target_kill[params.unit:entindex()] = self.target_kill[params.unit:entindex()] + 1
            GameRules.AddonTemplate.nCapturedFlagsCount[params.unit:GetTeamNumber()] = GameRules.AddonTemplate.nCapturedFlagsCount[params.unit:GetTeamNumber()] - MORPH_KILL_HERO_STEAL_POINT
            GameRules.AddonTemplate.nMorphKillsCount[params.unit:GetTeamNumber()] = GameRules.AddonTemplate.nMorphKillsCount[params.unit:GetTeamNumber()] - MORPH_KILL_HERO_STEAL_POINT
            CustomNetTables:SetTableValue("kills_morph", tostring(params.unit:GetTeamNumber()), {kills = GameRules.AddonTemplate.nMorphKillsCount[params.unit:GetTeamNumber()]})
            EmitAnnouncerSoundForPlayer("titan_lose", params.unit:GetPlayerOwnerID())
        end
    end
    if params.attacker ~= self:GetParent() and params.unit == self:GetParent() then
        self:GetParent().die = true
        local team = params.attacker:GetTeamNumber()
        GameRules.AddonTemplate.nMorphKillsCount[team] = GameRules.AddonTemplate.nMorphKillsCount[team] + MORPH_REWARD_MAX_KILLS
        GameRules.AddonTemplate.nCapturedFlagsCount[team] = GameRules.AddonTemplate.nCapturedFlagsCount[team] + MORPH_REWARD_MAX_KILLS
        
        CustomNetTables:SetTableValue("kills_morph", tostring(team), {kills = GameRules.AddonTemplate.nMorphKillsCount[team]})
        CustomGameEventManager:Send_ServerToAllClients('kill_morphling_notification', {team = params.attacker:GetTeamNumber()})

        DoWithAllPlayers(function(player, hero, index)
            if not hero then return end
            if hero:GetTeamNumber() == team then
                Upgrades:QueueSelection(hero, UPGRADE_RARITY_EPIC)
            elseif self.attackerUnits[hero:GetPlayerOwnerID()] then
                Upgrades:QueueSelection(hero, UPGRADE_RARITY_RARE)
            end
        end)
        EmitGlobalSound("titan_killing")
    end
end