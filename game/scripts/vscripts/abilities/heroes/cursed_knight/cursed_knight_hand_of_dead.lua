LinkLuaModifier('modifier_cursed_knight_hand_of_dead', 'abilities/heroes/cursed_knight/cursed_knight_hand_of_dead', LUA_MODIFIER_MOTION_BOTH)

cursed_knight_hand_of_dead = class({})

function cursed_knight_hand_of_dead:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()
 
    local hook_speed = self:GetSpecialValueFor( "hook_speed" )
 
	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = self.vStartPosition
 
  

    
    ProjectileManager:CreateTrackingProjectile({
        EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
        Ability = self,
        Source = caster,
        Target = target,
        iMoveSpeed = hook_speed,
    })

    self.bRetracting = false
end

function cursed_knight_hand_of_dead:OnProjectileHit( hTarget, vLocation )
	if hTarget == self:GetCaster() then
		return false
	end

    if self.bRetracting == false then
 
		local bTargetPulled = false
        local hook_speed = self:GetSpecialValueFor( "hook_speed" )

        EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )
        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_cursed_knight_hand_of_dead", nil )
    
        self.hVictim = hTarget
        bTargetPulled = true

            
		local vHookPos = hTarget:GetOrigin()
		local flPad = self:GetCaster():GetPaddedCollisionRadius() + hTarget:GetPaddedCollisionRadius()

		--Missing: Setting target facing angle
		local vVelocity = self.vStartPosition - vHookPos
		vVelocity.z = 0.0

		local flDistance = vVelocity:Length2D() - flPad
		vVelocity = vVelocity:Normalized() * hook_speed

		local info = {
			Ability = self,
			vSpawnOrigin = vHookPos,
			vVelocity = vVelocity,
			fDistance = flDistance,
			Source = self:GetCaster(),
		}

		ProjectileManager:CreateLinearProjectile( info )
		self.vProjectileLocation = vHookPos

		-- if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
		-- 	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
		-- 	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
		-- 	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
		-- else
		-- 	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
		-- end

		EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )
 
		self.bRetracting = true
	else
 
		if self.hVictim ~= nil then
			local vFinalHookPos = vLocation
			self.hVictim:InterruptMotionControllers( true )
			self.hVictim:RemoveModifierByName( "modifier_cursed_knight_hand_of_dead" )

			local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos 
			local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
			if vVictimPosCheck:Length2D() > flPad then
				FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
			end
		end

		self.hVictim = nil
		-- ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
		EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
	end

	return true
end
 
function cursed_knight_hand_of_dead:OnProjectileThink( vLocation )
	self.vProjectileLocation = vLocation
end


modifier_cursed_knight_hand_of_dead = class({})
--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_cursed_knight_hand_of_dead:CheckState()
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

function modifier_cursed_knight_hand_of_dead:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:GetAbility().hVictim ~= nil then
			self:GetAbility().hVictim:SetOrigin( self:GetAbility().vProjectileLocation )
			local vToCaster = self:GetAbility().vStartPosition - self:GetCaster():GetOrigin()
			local flDist = vToCaster:Length2D()
			if self:GetAbility().bChainAttached == false and flDist > 128.0 then 
				self:GetAbility().bChainAttached = true  
				ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:SetParticleControl( self:GetAbility().nChainParticleFXIndex, 0, self:GetAbility().vStartPosition + self:GetAbility().vHookOffset )
			end                   
		end
	end
end

--------------------------------------------------------------------------------
function modifier_cursed_knight_hand_of_dead:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:GetAbility().hVictim ~= nil then
			ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().vHookOffset, true )
			self:Destroy()
		end
	end
end
