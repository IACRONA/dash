modifier_mounted = class({})

----------------------------------------------------------------------------------
function modifier_mounted:IsHidden()
	return true
end

----------------------------------------------------------------------------------
function modifier_mounted:IsPurgable()
	return false
end

function modifier_mounted:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 9999999
end

----------------------------------------------------------------------------------
function modifier_mounted:OnCreated( kv )
	self.movementSpeedBonus = 0

	local summonMount = self:GetParent():FindAbilityByName("summon_mount")
	if summonMount then
		self.movementSpeedBonus = summonMount:GetSpecialValueFor("ms_speed_bonus")
	end

	if not IsServer() then 
		return 
	end

	self.mountOffset = 0
	self.heroOffset = 0
	self.modifierZDelta = ""

	self.rotated = 0
	self.flCreationTime = GameRules:GetDOTATime( false, true )
	self:GetParent().hMount = self:GetMount()

	local cosmeticModifier = self:GetParent():FindModifierByName("modifier_cosmetic_inventory_sb2023")
	if cosmeticModifier then
		cosmeticModifier:SwitchEmblemEffectWithMount()
	end

	self.horizontalAttachmentName = "attach_hitloc"
	self.verticalAttachmentName = "attach_hitloc"
	self.attachDelay = 0.25

	self:AdjustZDeltaOffset()

	if self.ApplyHorizontalMotionController and self:ApplyHorizontalMotionController() == false or self.ApplyVerticalMotionController and self:ApplyVerticalMotionController() == false then 
		self:Destroy()
		return
	end

	self.startTime = GameRules:GetGameTime()

	self.allowedSpellsCast = {
		high_five_custom_sb_2023 = true,
		
		item_phase_boots = true,
		item_slippers_of_the_abyss = true,
	}

	self.extraActivityModifiers = {
		npc_dota_hero_weaver = "crimson"
	}

	if self.extraActivityModifiers[self:GetParent():GetUnitName()] then
		self:GetParent():AddActivityModifier(self.extraActivityModifiers[self:GetParent():GetUnitName()])
	end
end

function modifier_mounted:AdjustZDeltaOffset()
	self.mountOffset = 0
	self.heroOffset = 0
	self.modifierZDelta = ""

	if self:GetMount() then
		if self:GetMount():GetModelName() == "models/items/courier/blue_lightning_horse/blue_lightning_horse.vmdl" then
			self.mountOffset = -150
			self.modifierZDelta = "modifier_mount_z_delta_visual_big"
		end

		if self:GetMount():GetModelName() == "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl" then
			self.mountOffset = -90
			self.modifierZDelta = "modifier_mount_z_delta_visual"
			self.attachDelay = 0.25
		end

		if self:GetMount():GetModelName() == "models/items/courier/starladder_grillhound/starladder_grillhound.vmdl" then
			self.mountOffset = -110
			self.modifierZDelta = "modifier_mount_z_delta_visual"
		end

		if self:GetMount():GetModelName() == "models/heroes/snapfire/snapfire.vmdl" then
			self.mountOffset = -100
			self.modifierZDelta = "modifier_mount_z_delta_visual"
		end

		if self:GetMount():GetModelName() == "models/heroes/batrider/batrider.vmdl" then
			self.mountOffset = -335
			self.modifierZDelta = "modifier_mount_z_delta_visual_very_big"
			self.attachDelay = 0.25
		end

		if self:GetMount():GetModelName() == "models/heroes/dragon_knight_persona/dk_persona_dragon.vmdl" then
			self.mountOffset = -255
			self.modifierZDelta = "modifier_mount_z_delta_visual_very_big"
		end

		if self:GetMount():GetModelName() == "models/courier/badger/courier_badger_flying.vmdl" then
			self.modifierZDelta = "modifier_mount_z_delta_visual_big"
		end
	end

	if self.modifierZDelta == "modifier_mount_z_delta_visual_small" then
		self.heroOffset = 35
	end

	if self.modifierZDelta == "modifier_mount_z_delta_visual" then
		self.heroOffset = 85
	end

	if self.modifierZDelta == "modifier_mount_z_delta_visual_big" then
		self.heroOffset = 135
	end

	if self.modifierZDelta == "modifier_mount_z_delta_visual_very_big" then
		self.heroOffset = 200
	end

	if self.modifierZDelta and self.modifierZDelta ~= "" then
		self:GetParent():AddNewModifier(self:GetParent(), nil, self.modifierZDelta, {})
	end
end

function modifier_mounted:OnRefresh(kv)
	if IsServer() then
		if self.modifierZDelta then
			self:GetParent():RemoveModifierByName(self.modifierZDelta)

			self:AdjustZDeltaOffset()
		end
	end
end

function modifier_mounted:UpdateHorizontalMotion( me, dt )
	if not IsServer() or not self:GetParent() then return end

	if GameRules:GetGameTime() < self.startTime + self.attachDelay then
		return
	end

	if self:GetMount() then
		local origin = self:GetMount():GetAbsOrigin()
		origin.z = 0.0

		local attachment = self:GetMount():ScriptLookupAttachment(self.horizontalAttachmentName)

		if attachment then
			local attachmentOrigin = self:GetMount():GetAttachmentOrigin(attachment)

			if attachmentOrigin then
				origin = attachmentOrigin
				origin.z = 0.0
			end
		end

		local angles = self:GetMount():GetLocalAngles()

		me:SetOrigin(origin)
		me:SetLocalAngles(angles.x, angles.y, angles.z)
	end
end

function modifier_mounted:UpdateVerticalMotion(me, dt)
	if not IsServer() or not self:GetParent() then return end

	if GameRules:GetGameTime() < self.startTime + self.attachDelay then
		return
	end

	if self:GetMount() then
		local vMyPos = me:GetOrigin()
		vMyPos.z = self:GetMount():GetAbsOrigin().z

		local attachment = self:GetMount():ScriptLookupAttachment(self.verticalAttachmentName)

		if attachment then
			local attachmentOrigin = self:GetMount():GetAttachmentOrigin(attachment)
			if attachmentOrigin then
				vMyPos = attachmentOrigin
				vMyPos.z = vMyPos.z + self.mountOffset
			end
		end

		me:SetOrigin(vMyPos)
	end
end

function modifier_mounted:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_mounted:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end


--------------------------------------------------------------------------------
function modifier_mounted:CheckState()
	local state = 
	{
		[ MODIFIER_STATE_DISARMED ] = true,
		[ MODIFIER_STATE_PASSIVES_DISABLED ] = true,
	}
	
	return state
end

--------------------------------------------------------------------------------
function modifier_mounted:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_TAKEDAMAGE,

		--only on client to show bonus from mount
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,

		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_mounted:GetModifierMoveSpeedBonus_Constant()
	if IsClient() then
		return self.movementSpeedBonus
	end
end

function modifier_mounted:GetModifierIgnoreMovespeedLimit()
    return 1
end

--------------------------------------------------------------------------------
function modifier_mounted:OnStateChanged( params )
	local hParent = self:GetParent()
	if not IsServer() or params.unit ~= hParent then return end

	if hParent:IsStunned() or hParent:IsHexed() or hParent:IsFrozen() or hParent:IsTaunted() or hParent:IsFeared() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
function modifier_mounted:OnOrder( params )
	if not IsServer() then return end

	if params.unit == self:GetParent() then
		local validMoveOrders =
		{
			[DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
			[DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
			[DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
			[DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
		}

		local dismountOrders = {
			[DOTA_UNIT_ORDER_CAST_POSITION] = true,
			[DOTA_UNIT_ORDER_CAST_TARGET] = true,
			[DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
			[DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
			[DOTA_UNIT_ORDER_CAST_TOGGLE] = true,
			[DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
			[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
		}

		local stopOrders = {
			[DOTA_UNIT_ORDER_HOLD_POSITION] = true,
			[DOTA_UNIT_ORDER_STOP] = true,
		}

		local patrolOrders = {
			[DOTA_UNIT_ORDER_PATROL] = true,
		}

		if validMoveOrders[params.order_type] then
			local vTargetPos = params.new_pos
			if params.target ~= nil and params.target:IsNull() == false then
				vTargetPos = params.target:GetAbsOrigin()
			end

			--give order to mount!
			self:GetMount():MoveToPosition(vTargetPos)
			
		elseif dismountOrders[params.order_type] then
			if params.ability then
				local abilityName = params.ability:GetAbilityName()
				
				--dismount is handled inside summon_mount
				if abilityName == "summon_mount" or self.allowedSpellsCast[abilityName] then
					return
				end
			end
			--other abilities: just dismount!
			self:Destroy()
		elseif stopOrders[params.order_type] then
			--give order to mount!
			self:GetMount():Stop()
		elseif patrolOrders[params.order_type] then
			local vTargetPos = params.new_pos
			if params.target ~= nil and params.target:IsNull() == false then
				vTargetPos = params.target:GetAbsOrigin()
			end

			--give order to mount!
			if vTargetPos then
				self:GetMount():PatrolToPosition(vTargetPos)
			end
		end
	end
end

----------------------------------------------------------------------------------
function modifier_mounted:OnTakeDamage( params )
	if not IsServer() then return end

	local hVictim = params.unit
	local hAttacker = params.attacker

	if hVictim == nil or hVictim:IsNull() or hVictim ~= self:GetParent() then
		return
	end

	if hAttacker == nil or hAttacker:IsNull() or hAttacker == hVictim then
		return
	end

	if self:GetAbility() and self:GetAbility():GetSpecialValueFor("dismount_from_damage") == 1 then
		
		local currentMount = self:GetCaster():_GetPlayerMount_SB2023()
		if currentMount then
			local mountModifier = currentMount:FindModifierByName("modifier_mount_passive")
			if mountModifier then
				mountModifier:RemoveHeroClone()
			end
		end

		self.interrupted = true

		local summonMount = self:GetParent():FindAbilityByName("summon_mount")
		if summonMount then
			local cdOnDamage = summonMount:GetSpecialValueFor("cooldown_on_dismount")
			summonMount:StartCooldown(cdOnDamage)
		end
	
		self:Destroy()
	end
end
--------------------------------------------------------------------------------
function modifier_mounted:OnDestroy()
	if not IsServer() then return end

	self:GetParent():RemoveEffects(EF_NODRAW)
	self:GetParent():RemoveGesture( ACT_DOTA_CAPTURE )
	self:GetParent():RemoveGesture( ACT_DOTA_IDLE )
	self:GetParent():RemoveGesture( ACT_DOTA_RUN )

	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():RemoveVerticalMotionController( self )

	self:GetParent():RemoveModifierByName(self.modifierZDelta)

	local summonMount = self:GetParent():FindAbilityByName("summon_mount")
	if summonMount and summonMount.DismountHero then
		summonMount:DismountHero()
	end

	local cosmeticModifier = self:GetParent():FindModifierByName("modifier_cosmetic_inventory_sb2023")
	if cosmeticModifier then
		cosmeticModifier:SwitchEmblemEffectWithMount()
	end

	local currentMount = self:GetParent():_GetPlayerMount_SB2023()

	if currentMount then
		local mountModifier = currentMount:FindModifierByName("modifier_mount_passive")
		if mountModifier then
			mountModifier:RemoveHeroClone()
		end

		currentMount.mountExpired = true
	end

	if self:GetAbility().OnDismount ~= nil then
		self:GetAbility():OnDismount()
	end

	local distance = 0

	if self.interrupted then
		distance = 150
	end

	-- Animate dismount
	local vLocation = self:GetParent():GetAbsOrigin() + ( self:GetParent():GetForwardVector() * 50 )
	local kv =
	{
		center_x = vLocation.x,
		center_y = vLocation.y,
		center_z = vLocation.z,
		should_stun = false, 
		duration = 0.5,
		knockback_duration = 0.5,
		knockback_distance = distance,
		knockback_height = 150,
	}

	self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_knockback", kv )
end

--------------------------------------------------------------------------------
function modifier_mounted:IsMountMoving()
	return self:GetCaster():HasModifier("modifier_mount_movement")
end

--------------------------------------------------------------------------------
function modifier_mounted:GetMount()
	return self:GetCaster()
end
