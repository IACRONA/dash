lion_frog_jump = class({})
LinkLuaModifier( "modifier_lion_frog_jump", "abilities/heroes/lion/lion_frog_jump", LUA_MODIFIER_MOTION_BOTH )

function lion_frog_jump:OnSpellStart()
	local caster = self:GetCaster()

	local distance = self:GetSpecialValueFor( "jump_distance" ) -- special value
	local speed = self:GetSpecialValueFor( "jump_speed" ) -- special value
	local height = 150

 	local arc = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_lion_frog_jump", -- modifier name
		{
			distance = distance,
			speed = speed,
			height = height,
			fix_end = false,
			isForward = true,
		}  
	)

	local sound_cast = "Ability.Leap"
	EmitSoundOn( sound_cast, caster )
end

modifier_lion_frog_jump = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return true end,
    DeclareFunctions        = function(self) return 
    {
    	MODIFIER_PROPERTY_MODEL_CHANGE,
    } end,
    CheckState      = function(self) return 
    {
    	[MODIFIER_STATE_SILENCED] = true,
    	[MODIFIER_STATE_MUTED] = true,
    	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    } end,
})
  
function modifier_lion_frog_jump:OnCreated( kv )
	if not IsServer() then return end
	self.interrupted = false
	self:SetJumpParameters( kv )
	self:Jump()
	local parent = self:GetParent()
	parent:StartGestureWithPlaybackRate(ACT_DOTA_RUN, 0.6)
	parent:SetModelScale(parent:GetModelScale() + self:GetAbility():GetSpecialValueFor("model_scale"))
end

function modifier_lion_frog_jump:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_lion_frog_jump:GetModifierModelChange()
	return "models/props_gameplay/cold_frog.vmdl"
end

function modifier_lion_frog_jump:OnDestroy()
	if not IsServer() then return end

	-- preserve height
	local pos = self:GetParent():GetOrigin()

	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():RemoveVerticalMotionController( self )

	-- preserve height if has end offset
	if self.end_offset~=0 then
		self:GetParent():SetOrigin( pos )
	end

	if self.endCallback then
		self.endCallback( self.interrupted )
	end
	local parent = self:GetParent()
	parent:RemoveGesture(ACT_DOTA_RUN)
	parent:SetModelScale(parent:GetModelScale() - self:GetAbility():GetSpecialValueFor("model_scale"))
end
 
function modifier_lion_frog_jump:UpdateHorizontalMotion( me, dt )
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

	-- set relative position
	local pos = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( pos )
end

function modifier_lion_frog_jump:UpdateVerticalMotion( me, dt )
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

	local pos = me:GetOrigin()
	local time = self:GetElapsedTime()

	-- set relative position
	local height = pos.z
	local speed = self:GetVerticalSpeed( time )
	pos.z = height + speed * dt
	me:SetOrigin( pos )

	if not self.fix_duration then
		local ground = GetGroundHeight( pos, me ) + self.end_offset
		if pos.z <= ground then

			-- below ground, set height as ground then destroy
			pos.z = ground
			me:SetOrigin( pos )
			self:Destroy()
		end
	end
end

function modifier_lion_frog_jump:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_lion_frog_jump:OnVerticalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_lion_frog_jump:SetJumpParameters( kv )
	self.parent = self:GetParent()

	-- load types
	self.fix_end = true
	self.fix_duration = true
	self.fix_height = true
	if kv.fix_end then
		self.fix_end = kv.fix_end==1
	end
	if kv.fix_duration then
		self.fix_duration = kv.fix_duration==1
	end
	if kv.fix_height then
		self.fix_height = kv.fix_height==1
	end

	-- load other types
	self.isStun = kv.isStun==1
	self.isRestricted = kv.isRestricted==1
	self.isForward = kv.isForward==1
	self.activity = kv.activity or 0
	self:SetStackCount( self.activity )

	-- load direction
	if kv.target_x and kv.target_y then
		local origin = self.parent:GetOrigin()
		local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
		dir.z = 0
		dir = dir:Normalized()
		self.direction = dir
	end
	if kv.dir_x and kv.dir_y then
		self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
	end
	if not self.direction then
		self.direction = self.parent:GetForwardVector()
	end

	-- load horizontal data
	self.duration = kv.duration
	self.distance = kv.distance
	self.speed = kv.speed
	if not self.duration then
		self.duration = self.distance/self.speed
	end
	if not self.distance then
		self.speed = self.speed or 0
		self.distance = self.speed*self.duration
	end
	if not self.speed then
		self.distance = self.distance or 0
		self.speed = self.distance/self.duration
	end

	-- load vertical data
	self.height = kv.height or 0
	self.start_offset = kv.start_offset or 0
	self.end_offset = kv.end_offset or 0

	-- calculate height positions
	local pos_start = self.parent:GetOrigin()
	local pos_end = pos_start + self.direction * self.distance
	local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
	local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
	local height_max

	-- determine jumping height if not fixed
	if not self.fix_height then
	
		-- ideal height is proportional to max distance
		self.height = math.min( self.height, self.distance/4 )
	end

	-- determine height max
	if self.fix_end then
		height_end = height_start
		height_max = height_start + self.height
	else
		-- calculate height
		local tempmin, tempmax = height_start, height_end
		if tempmin>tempmax then
			tempmin,tempmax = tempmax, tempmin
		end
		local delta = (tempmax-tempmin)*2/3

		height_max = tempmin + delta + self.height
	end

	-- set duration
	if not self.fix_duration then
		self:SetDuration( -1, false )
	else
		self:SetDuration( self.duration, true )
	end

	-- calculate arc
	self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_lion_frog_jump:Jump()
	-- apply horizontal motion
	if self.distance>0 then
		if not self:ApplyHorizontalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end

	-- apply vertical motion
	if self.height>0 then
		if not self:ApplyVerticalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end
end

function modifier_lion_frog_jump:InitVerticalArc( height_start, height_max, height_end, duration )
	local height_end = height_end - height_start
	local height_max = height_max - height_start

	-- fail-safe1: height_max cannot be smaller than height delta
	if height_max<height_end then
		height_max = height_end+0.01
	end

	-- fail-safe2: height-max must be positive
	if height_max<=0 then
		height_max = 0.01
	end

	-- math magic
	local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
	self.const1 = 4*height_max*duration_end/duration
	self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_lion_frog_jump:GetVerticalPos( time )
	return self.const1*time - self.const2*time*time
end

function modifier_lion_frog_jump:GetVerticalSpeed( time )
	return self.const1 - 2*self.const2*time
end

function modifier_lion_frog_jump:SetEndCallback( func )
	self.endCallback = func
end