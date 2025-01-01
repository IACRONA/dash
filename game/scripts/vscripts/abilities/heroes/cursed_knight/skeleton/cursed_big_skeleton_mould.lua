LinkLuaModifier( "modifier_generic_arc_lua", "modifiers/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )


cursed_big_skeleton_mould = cursed_big_skeleton_mould or {}
function cursed_big_skeleton_mould:OnAbilityPhaseStart()
    self.interrupted =false
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local point = target:GetOrigin()
    local distance = (point - caster:GetOrigin()):Length2D()
    local duration = self:GetSpecialValueFor("leap_duration")
	local height = self:GetSpecialValueFor("height")
    local arc = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			target_x = point.x,
			target_y = point.y,
			distance = distance,
			duration = duration,
			height = height,
			fix_end = false,
			isForward = true,
			-- isRestricted = true,
		} 
	)
	arc:SetEndCallback(function()
        -- print("123")
		-- if not self.interrupted then return end
		-- self.interrupted = nil
		-- print("123")
        local duration_stun = self:GetSpecialValueFor("stun_duration")
        target:AddNewModifier(
            caster,
            self,
            "modifier_stunned", 
            { duration = duration_stun } 
        )
        EmitSoundOn( "Hero_EarthShaker.Totem", caster )
        caster:SetCursorCastTarget(target)
		self:OnSpellStart()
		self:UseResources( true, true, false, true )
	end)

	return true
end
function cursed_big_skeleton_mould:OnAbilityPhaseInterrupted()
	self.interrupted = true
end
function cursed_big_skeleton_mould:OnSpellStart()
    -- print("12312321")
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	
end