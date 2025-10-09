-- DASH CR
LinkLuaModifier("modifier_high_five_thinker", "libraries/high_five", LUA_MODIFIER_MOTION_NONE)

modifier_high_five = class({})
function modifier_high_five:IsHidden() return true end
function modifier_high_five:IsPurgable() return false end
function modifier_high_five:IsPurgeException() return false end
function modifier_high_five:OnCreated()
    if not IsServer() then return end
    self.overhead_effect = "particles/econ/events/plus/high_five/high_five_lvl1_overhead.vpcf"
    self.proj_effect = "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf"
    self.target_proj = "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf"
    self:GetParent():EmitSound("high_five.cast")
    local particle = ParticleManager:CreateParticle(self.overhead_effect, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)

    -- ОПТИМИЗАЦИЯ: Уменьшена частота проверки с 0.1 до 0.25 секунды
    self:StartIntervalThink(0.25)
end

function modifier_high_five:StartProj(caster, target, vPoint)
    if not IsServer() then return end
    ProjectileManager:CreateLinearProjectile(
    {
        Source = caster,
        Ability = nil,
        vSpawnOrigin = caster:GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_NONE,
        EffectName = self.proj_effect,
        fDistance = (vPoint - caster:GetOrigin()):Length2D(),
        fStartRadius = 10,
        fEndRadius = 10,
        vVelocity = (vPoint - caster:GetOrigin()):Normalized() * 700,
    })

    ProjectileManager:CreateLinearProjectile(
    {
        Source = target,
        Ability = nil,
        vSpawnOrigin = target:GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_NONE,
        EffectName = self.target_proj,
        fDistance = (vPoint - target:GetOrigin()):Length2D(),
        fStartRadius = 10,
        fEndRadius = 10,
        vVelocity = (vPoint - target:GetOrigin()):Normalized() * 700,
    })
end

function modifier_high_five:OnIntervalThink()
    if not IsServer() then return end
    local target = nil
    
    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        600,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_CLOSEST,
        false
    )
    
    for k, hero in pairs(units) do
        if hero ~= self:GetParent() and hero:HasModifier("modifier_high_five") then
            target = hero
            break
        end
    end

    if target == nil then return end
    
    local vPoint = (target:GetOrigin() + self:GetParent():GetOrigin()) / 2
    self:StartProj(self:GetParent(), target, vPoint)
    CreateModifierThinker(self:GetParent(), nil, "modifier_high_five_thinker", {duration = (vPoint - target:GetOrigin()):Length2D()/700}, vPoint, self:GetParent():GetTeamNumber(), false)
    
    -- Отправляем сообщение в чат
    -- GameRules:SendCustomMessage("<font color='#00FF00'>" .. self:GetParent():GetUnitName() .. "</font> дал пять <font color='#00FF00'>" .. target:GetUnitName() .. "</font>!", 0, 0)
    self.high_five_done = true
    local targetModifier = target:FindModifierByName("modifier_high_five")
    if targetModifier then
        targetModifier.high_five_done = true
        targetModifier:Destroy()
    end
    self:Destroy()
end

function modifier_high_five:OnDestroy()
    if not IsServer() then return end
    
    -- Проверяем, не было ли уже "Дай пять" с героем
    if self.high_five_done then return end
    
    local target = nil
    local towers = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        600,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )
    
    for _, tower in pairs(towers) do
        if tower:IsTower() then
            target = tower
            break
        end
    end

    if target then
        local vPoint = (target:GetOrigin() + self:GetParent():GetOrigin()) / 2
        self:StartProj(self:GetParent(), target, vPoint)
        CreateModifierThinker(self:GetParent(), nil, "modifier_high_five_thinker", {duration = (vPoint - target:GetOrigin()):Length2D()/700}, vPoint, self:GetParent():GetTeamNumber(), false)
        
        -- Отправляем сообщение в чат при взаимодействии с башней
        -- GameRules:SendCustomMessage("<font color='#00FF00'>" .. self:GetParent():GetUnitName() .. "</font> дал пять башне!", 0, 0)
    end
end

modifier_high_five_thinker = class({})

function modifier_high_five_thinker:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound('high_five.impact')
end