require("settings/game_settings")

LinkLuaModifier("modifier_ui_custom_ability_jump", "abilities/ui_custom_ability_jump", LUA_MODIFIER_MOTION_BOTH)

ui_custom_ability_jump = class({})

function ui_custom_ability_jump:OnSpellStart()
    if not IsServer() then return end
    self:StartCooldown(JUMP_COOLDOWN)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ui_custom_ability_jump", {})
end

modifier_ui_custom_ability_jump = class({})
function modifier_ui_custom_ability_jump:IsHidden() return true end
function modifier_ui_custom_ability_jump:IsPurgable() return false end
function modifier_ui_custom_ability_jump:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ui_custom_ability_jump:OnCreated( kv )
	if not IsServer() then return end

	self.distance = JUMP_DISTANCE
    self.max_distance = JUMP_DISTANCE
	self.height = JUMP_HEIGHT
    self.speed = JUMP_SPEED

    local direction = self:GetCaster():GetForwardVector()
    direction.z = 0
    self.direction = direction:Normalized()
    self.parent = self:GetParent()
    self.origin = self.parent:GetOrigin()

    -- ОПТИМИЗАЦИЯ: Изменён интервал с 0.01 на 0.03 для снижения нагрузки
    self.tickRate = 0.03
    self:StartIntervalThink(self.tickRate)
    self:SetDuration(5, true)
end

function modifier_ui_custom_ability_jump:OnDestroy( kv )
	if not IsServer() then return end
    GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self:GetParent():GetHullRadius(), true )
	if self.EndCallback then
		self.EndCallback( self.interrupted )
	end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	self:GetParent():InterruptMotionControllers( true )
end

function modifier_ui_custom_ability_jump:OnIntervalThink()
    if not IsServer() then return end

    -- Horizontal (использует tickRate для плавности)
    local horizontal_speed = (self.speed * self.tickRate)
    self.distance = self.distance - horizontal_speed
    local new_position = self:GetParent():GetAbsOrigin() + self.direction * horizontal_speed
    local is_low_ground_next = false

    local check_next_pos = new_position + self.direction * self.max_distance
    if GridNav:IsTraversable(check_next_pos) then
        if GetGroundHeight(check_next_pos, nil) < self:GetParent():GetAbsOrigin().z then
            is_low_ground_next = true
        end
    end

    if not GridNav:IsTraversable(new_position) and not is_low_ground_next then
        self.direction = self.direction * (-1)
    end
    self:GetParent():SetForwardVector(self.direction)
    
    new_position = self:GetParent():GetAbsOrigin() + self.direction * horizontal_speed

    if self.max_distance <= 0 then
        new_position = self:GetCaster():GetAbsOrigin()
    end

    -- Vertical (использует tickRate для плавности)
    local vertical_speed = (self.height * self.tickRate) * 3
    local new_height = new_position.z + vertical_speed
    if self.distance <= self.max_distance / 2 then
        new_height = new_position.z - vertical_speed
    end
    if self.distance <= 0 then
        self.height = self.height * 1.1
    end
    new_position.z = new_height
    local current_height = new_height
    local update_origin = self:GetParent():GetAbsOrigin() + self.direction * horizontal_speed
    local new_position_height_vertical = GetGroundHeight(update_origin, nil)

    if current_height <= new_position_height_vertical and self.distance <= 0 then
        self:Destroy()
        return
    end

	self:GetParent():SetOrigin( new_position )

    if self:GetParent():GetAbsOrigin().z < GetGroundHeight(self:GetParent():GetAbsOrigin(), nil) then
        local upd_pos = self:GetParent():GetAbsOrigin()
        upd_pos.z = GetGroundHeight(upd_pos, nil)
        self:GetParent():SetOrigin( upd_pos )
    end
end

function modifier_ui_custom_ability_jump:SetEndCallback( func ) 
	self.EndCallback = func
end

function modifier_ui_custom_ability_jump:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_ui_custom_ability_jump:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_ui_custom_ability_jump:CheckState()
	return
    {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_ui_custom_ability_jump:UpdateHorizontalMotion( me, dt )

end

function modifier_ui_custom_ability_jump:UpdateVerticalMotion( me, dt )

end

function modifier_ui_custom_ability_jump:OnVerticalMotionInterrupted()
	if not IsServer() then return end
	self.interrupted = true
	self:Destroy()
end

function modifier_ui_custom_ability_jump:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self.interrupted = true
	self:Destroy()
end