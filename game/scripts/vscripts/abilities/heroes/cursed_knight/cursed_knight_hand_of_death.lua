LinkLuaModifier('modifier_cursed_knight_hand_of_death', 'abilities/heroes/cursed_knight/cursed_knight_hand_of_death', LUA_MODIFIER_MOTION_BOTH)

cursed_knight_hand_of_death = class({})

function cursed_knight_hand_of_death:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local hook_speed = self:GetSpecialValueFor( "hook_speed" )
	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = self.vStartPosition
	if not target:TriggerSpellAbsorb( self ) then 
		ProjectileManager:CreateTrackingProjectile({
			EffectName = "particles/units/heroes/hero_zuus/red_zuus_arc_lightning.vpcf",
			Ability = self,
			Source = caster,
			Target = target,
			iMoveSpeed = hook_speed*2.7,
		})
		self.bRetracting = false
		EmitSoundOn( "hand_of_death", self:GetCaster() )
	else 
        self:EndCooldown()
        self:RefundManaCost()
	end
end
 
function cursed_knight_hand_of_death:OnProjectileHit( hTarget, vLocation )
	if hTarget == self:GetCaster() then
		return false
	end

    if self.bRetracting == false then
 
		local bTargetPulled = false
        local hook_speed = self:GetSpecialValueFor( "hook_speed" )

        -- EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )
		if not hTarget then return end
        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_cursed_knight_hand_of_death", nil )
		self.bRetracting = true
	else
		if self.hVictim ~= nil then
			local vFinalHookPos = vLocation
			self.hVictim:InterruptMotionControllers( true )
			self.hVictim:RemoveModifierByName( "modifier_cursed_knight_hand_of_death" )

			local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos 
			local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
			if vVictimPosCheck:Length2D() > flPad then
				FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
			end
		end

		self.hVictim = nil
	end

	return true
end
 
function cursed_knight_hand_of_death:OnProjectileThink( vLocation )
	self.vProjectileLocation = vLocation
end


modifier_cursed_knight_hand_of_death = class({})
--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:RemoveOnDeath()
	return false
end

function modifier_cursed_knight_hand_of_death:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				local state = {
				[MODIFIER_STATE_STUNNED] = true,
				}
				return state
			end
		end
	end
	local state = {}
	return state
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_death:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		local caster = self:GetCaster()
		local victim = self:GetParent()
		local hook_speed = self:GetAbility():GetSpecialValueFor("hook_speed")

		local caster_position = caster:GetAbsOrigin()
		local victim_position = victim:GetAbsOrigin()
		

		local direction = (caster_position - victim_position):Normalized()
		local distance = (caster_position - victim_position):Length2D()
	
		local step = math.min(hook_speed * dt, distance)

		local new_position = victim_position + direction * step
		victim:SetAbsOrigin(new_position)
		if distance <= 128 then
			FindClearSpaceForUnit(victim, caster_position, true)
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------
function modifier_cursed_knight_hand_of_death:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:GetAbility().hVictim ~= nil and self:GetAbility().vHookOffset ~= nil then
			self:Destroy()
		end
	end
end
