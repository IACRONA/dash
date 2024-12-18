LinkLuaModifier("modifier_morphling_boss_waveform_buff", "abilities/morphling_boss_wave", LUA_MODIFIER_MOTION_HORIZONTAL)

morphling_boss_wave = class({})

function morphling_boss_wave:Start(target)
	if not IsServer() then return end
    local vDirection = target:GetAbsOrigin() - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    local distance = vDirection:Length2D()+150
    vDirection = vDirection:Normalized()
    self:GetCaster():SetForwardVector(vDirection)
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_morphling_boss_waveform_buff", { duration = distance / self:GetSpecialValueFor("speed"), x = target:GetAbsOrigin().x, y = target:GetAbsOrigin().y, z = target:GetAbsOrigin().z})

    local info = 
    {
        EffectName = 'particles/units/heroes/hero_morphling/morphling_waveform.vpcf',
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = self:GetSpecialValueFor("width"),
        fEndRadius = self:GetSpecialValueFor("width"),
        vVelocity = vDirection * self:GetSpecialValueFor("speed"),
        fDistance = distance,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_DAMAGE_FLAG_NONE,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function morphling_boss_wave:OnProjectileHit(target, vLocation)
    local caster = self:GetCaster()
    if target then 
    	if caster == nil then return end
    	if caster:IsNull() then return end
    	if not caster:IsAlive() then return end
    	local damage = self:GetSpecialValueFor("damage")
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
    end
end 

modifier_morphling_boss_waveform_buff = class({})

function modifier_morphling_boss_waveform_buff:IsPurgable() return false end
function modifier_morphling_boss_waveform_buff:IsHidden() return true end
function modifier_morphling_boss_waveform_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_morphling_boss_waveform_buff:IgnoreTenacity() return true end
function modifier_morphling_boss_waveform_buff:IsMotionController() return true end
function modifier_morphling_boss_waveform_buff:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_morphling_boss_waveform_buff:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_DISARMED]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_morphling_boss_waveform_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
end

function modifier_morphling_boss_waveform_buff:GetModifierDisableTurning() 
	return 1
end 

function modifier_morphling_boss_waveform_buff:OnCreated(params)
    if IsServer() then
        self:GetParent():AddNoDraw()
        self:GetParent():AddEffects(EF_NODRAW)
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        self.velocity = self:GetAbility():GetSpecialValueFor("speed")
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_morphling_boss_waveform_buff:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    self:GetParent():RemoveNoDraw()
    self:GetParent():RemoveEffects(EF_NODRAW)
end

function modifier_morphling_boss_waveform_buff:OnIntervalThink()
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_morphling_boss_waveform_buff:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end
		