item_tp_scroll_custom = class({})

function item_tp_scroll_custom:CreateTeleportParticles(caster, targetPoint)
    local playerColor = Vector(50,20,3)
    local playerParticle = DonateManager:GetCurrentTeleportationEffect(caster)

    local startParticle = playerParticle and playerParticle.particleStart or "particles/items2_fx/teleport_start.vpcf"
    local endParticle = playerParticle and playerParticle.particleEnd or "particles/items2_fx/teleport_end.vpcf"

    self.startParticle = ParticleManager:CreateParticle(
        startParticle,
        PATTACH_WORLDORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(self.startParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.startParticle, 2, playerColor)
    ParticleManager:SetParticleControl(self.startParticle, 3, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.startParticle, 4, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.startParticle, 5, Vector(3,0,0))
    ParticleManager:SetParticleControl(self.startParticle, 6, caster:GetAbsOrigin())

    self.endParticle = ParticleManager:CreateParticle(
        endParticle,
        PATTACH_WORLDORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(self.endParticle, 0, targetPoint)
    ParticleManager:SetParticleControl(self.endParticle, 1, targetPoint)
    ParticleManager:SetParticleControl(self.endParticle, 2, playerColor)
    ParticleManager:SetParticleControlEnt(self.endParticle, 3, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", targetPoint, false)
    ParticleManager:SetParticleControl(self.endParticle, 5, targetPoint)
    ParticleManager:SetParticleControl(self.endParticle, 4, Vector(1,0,0))

    caster:StartGesture(ACT_DOTA_TELEPORT)
    EmitSoundOn("Portal.Loop_Disappear", caster)
    EmitSoundOn("Portal.Loop_Appear", caster)
end
 
function item_tp_scroll_custom:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()

    if not bInterrupted then
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Portal.Hero_Disappear", caster)

        FindClearSpaceForUnit(caster, self.point, true)
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Portal.Hero_Appear", caster)

        -- Создаём эффект появления героя в точке телепортации
        local playerParticle = DonateManager:GetCurrentTeleportationEffect(caster)
        local heroAppearParticle = playerParticle and playerParticle.particleEnd or "particles/items2_fx/teleport_end.vpcf"

        local appearEffect = ParticleManager:CreateParticle(heroAppearParticle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(appearEffect, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(appearEffect, 1, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(appearEffect, 2, caster:GetAbsOrigin())

        -- Удаляем все частицы сразу
        ParticleManager:DestroyParticle(self.startParticle, true)
        ParticleManager:DestroyParticle(self.endParticle, true)
        ParticleManager:ReleaseParticleIndex(self.startParticle)
        ParticleManager:ReleaseParticleIndex(self.endParticle)

        -- Удаляем эффект появления через 0.3 секунды
        Timers:CreateTimer(0.3, function()
            ParticleManager:DestroyParticle(appearEffect, false)
            ParticleManager:ReleaseParticleIndex(appearEffect)
        end)
    else
        self:EndCooldown()
        ParticleManager:DestroyParticle(self.startParticle, true)
        ParticleManager:DestroyParticle(self.endParticle, true)
        ParticleManager:ReleaseParticleIndex(self.startParticle)
        ParticleManager:ReleaseParticleIndex(self.endParticle)
    end

    caster:RemoveGesture(ACT_DOTA_TELEPORT)
    caster:StartGesture(ACT_DOTA_TELEPORT_END)

    StopSoundOn("Portal.Loop_Disappear", caster)
    StopSoundOn("Portal.Loop_Appear", caster)
end
  
function item_tp_scroll_custom:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local vision_radius = self:GetSpecialValueFor("vision_radius")
    local cursorPoint = self:GetCursorPosition()
    local target = self:GetCursorTarget()

    -- Проверяем наличие Boots of Travel через поиск предметов
    local hasBoT1 = false
    local hasBoT2 = false

    for i = 0, 8 do
        local item = caster:GetItemInSlot(i)
        if item then
            local itemName = item:GetName()
            if itemName == "item_travel_boots" then
                hasBoT1 = true
            elseif itemName == "item_travel_boots_2" then
                hasBoT2 = true
            end
        end
    end

    print("[TP DEBUG] hasBoT1: " .. tostring(hasBoT1) .. ", hasBoT2: " .. tostring(hasBoT2))

    -- Если кликнули на цель (крип или герой) и есть нужные бутсы
    if target and target ~= caster then
        print("[TP DEBUG] Target: " .. target:GetUnitName() .. ", IsCreep: " .. tostring(target:IsCreep()) .. ", IsHero: " .. tostring(target:IsHero()))

        local canTPToTarget = false

        -- BoT 2 позволяет телепортироваться к героям
        if hasBoT2 and target:IsHero() and target:GetTeamNumber() == caster:GetTeamNumber() then
            canTPToTarget = true
            print("[TP DEBUG] Can TP to hero!")
        end

        -- BoT 1 или BoT 2 позволяют телепортироваться к крипам
        if (hasBoT1 or hasBoT2) and target:IsCreep() and target:GetTeamNumber() == caster:GetTeamNumber() then
            canTPToTarget = true
            print("[TP DEBUG] Can TP to creep!")
        end

        if canTPToTarget then
            -- Телепортируемся прямо к цели
            print("[TP DEBUG] Teleporting to target!")
            self.point = target:GetAbsOrigin()
            self.viewer = AddFOWViewer(caster:GetTeamNumber(), self.point, vision_radius, self:GetChannelTime(), false)
            self:CreateTeleportParticles(caster, self.point)
            return
        else
            print("[TP DEBUG] Cannot TP to target - no valid boots or wrong target type")
        end
    end

    -- Телепортация к своему спавну
    if target == caster and caster.spawnPoint then
        cursorPoint = caster.spawnPoint
    end

    -- Обычная телепортация к зданиям
    local building = FindUnitsInRadius(
        caster:GetTeamNumber(),
        cursorPoint,
        nil,
        -1,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST , false
    )

    if not building or #building == 0 then
        self:EndCooldown()
        return
    end

    local buildAbsOrigin = building[1]:GetAbsOrigin()
    local distance = (cursorPoint - buildAbsOrigin):Length2D()
    local minDistance = self:GetSpecialValueFor("minimum_distance")
    local maxDistance = self:GetSpecialValueFor("maximum_distance")

    if distance < minDistance then
        distance = minDistance
    elseif distance > maxDistance then
        distance = maxDistance
    end

    local vDirection = cursorPoint - buildAbsOrigin
    vDirection.z = 0
    vDirection = vDirection:Normalized()

    self.point = buildAbsOrigin + vDirection * distance

    self.viewer = AddFOWViewer(caster:GetTeamNumber(), self.point, vision_radius, self:GetChannelTime(), false)
    self:CreateTeleportParticles(caster, self.point)
end

 

-- custom_modifier_tp_scroll = class({})

-- function custom_modifier_tp_scroll:IsHidden()
--     return true
-- end

-- function custom_modifier_tp_scroll:IsPurgable() 
--     return false 
-- end

-- function custom_modifier_tp_scroll:RemoveOnDeath() 
--     return false 
-- end

-- function custom_modifier_tp_scroll:OnCreated()
--     self.min_distance = self:GetAbility():GetSpecialValueFor("minimum_distance")
--     self.max_distance = self:GetAbility():GetSpecialValueFor("maximum_distance")
--     self:GetAbility().custom_indicator = self

--     if IsServer() then
--         self.allied_buildings = {}
--         self:SetHasCustomTransmitterData(true)
--         self:OnBuildingKilled({})
--     end
-- end

-- --------------------------------------------------------------------------------
-- -- Transmitter data
-- function custom_modifier_tp_scroll:AddCustomTransmitterData()
--     -- on server
--     local data = {
--         allied_buildings = {}
--     }

--     for k, v in pairs(self.allied_buildings) do
--         data.allied_buildings[k] = v:entindex()
--     end

--     return data
-- end

-- function custom_modifier_tp_scroll:HandleCustomTransmitterData( data )
--     -- on client
--     self.allied_buildings = {}
--     for k,v in pairs(data.allied_buildings) do
--         self.allied_buildings[k] = EntIndexToHScript(v)
--     end
-- end

-- function custom_modifier_tp_scroll:DeclareFunctions()
--     return {
--         MODIFIER_EVENT_ON_BUILDING_KILLED
--     }
-- end

-- function custom_modifier_tp_scroll:OnBuildingKilled( event )
--     if not IsServer() then return end
--     if not event.unit or event.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then
--         local allied_buildings = FindUnitsInRadius(
--             self:GetCaster():GetTeamNumber(),
--             Vector(0,0,0),
--             nil,
--             FIND_UNITS_EVERYWHERE,
--             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
--             DOTA_UNIT_TARGET_BUILDING,
--             DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
--             FIND_ANY_ORDER,
--             false
--         )

--         for k,v in pairs(allied_buildings) do
--             self.allied_buildings[k] = v
--         end

--         self:SendBuffRefreshToClients()
--     end
-- end

-- function custom_modifier_tp_scroll:GetTPInfo( point ) -- client only

--     local building_distances = {}
--     local ordered_buildings = {}

--     for _, building in pairs(self.allied_buildings) do
--         ordered_buildings[#ordered_buildings+1] = building
--         building_distances[building] = (point - building:GetAbsOrigin()):Length2D()
--     end

--     table.sort(ordered_buildings, function(a, b) return building_distances[a] < building_distances[b] end)

--     local target_building = ordered_buildings[1]

--     local distance = building_distances[target_building]
--     if distance < self.min_distance then
--         distance = self.min_distance
--     elseif distance > self.max_distance then
--         distance = self.max_distance
--     end

--     local vDirection = point - target_building:GetAbsOrigin()
--     vDirection.z = 0
--     vDirection = vDirection:Normalized()

--     location = target_building:GetAbsOrigin() + vDirection * distance
--     --location.z = GetGroundHeight(location, nil)

--     return {
--         building = target_building,
--         location = location
--     }
-- end

-- function custom_modifier_tp_scroll:OnIntervalThink()
--     self:StartIntervalThink(-1)
--     self:DestroyCustomIndicator()
-- end

-- function custom_modifier_tp_scroll:CreateCustomIndicator( point )
--     local tp_info = self:GetTPInfo( point )

--     if tp_info.building ~= self.target_building then
--         self.target_building = tp_info.building
--         if self.casting_particle then
--             self:DestroyCustomIndicator()
--         end
--         -- send event to panorama so it can highlight the correct building in the minimap
--     end

--     -- TODO: look at Dawnbreaker particle effect see how they make it stick to the ground

--     --cp2 = ring position
--     --cp3 = ring radius
--     --cp4 = ring color
--     --cp6 = glow alpha
--     --cp7 = design position
--     if not self.casting_particle then
--         self.casting_particle = ParticleManager:CreateParticle(
--             "particles/ui_mouseactions/tp_custom_indicator.vpcf", 
--             PATTACH_WORLDORIGIN, 
--             self:GetCaster()
--         )

--         ParticleManager:SetParticleControl(self.casting_particle, 3, Vector(140, 0, 0))
--         ParticleManager:SetParticleControl(self.casting_particle, 6, Vector(1, 0, 0))
--     end

--     ParticleManager:SetParticleControl(self.casting_particle, 2, tp_info.location)
--     ParticleManager:SetParticleControl(self.casting_particle, 7, tp_info.location)

--     ParticleManager:SetParticleControl(self.casting_particle, 4, Vector(255, 255, 255)) -- TODO: adjust based on tp delay

--     self:StartIntervalThink(0.1)
-- end

-- function custom_modifier_tp_scroll:DestroyCustomIndicator()
--     if IsServer() then return end
--     ParticleManager:DestroyParticle(self.casting_particle, true)
--     ParticleManager:ReleaseParticleIndex(self.casting_particle)
--     self.casting_particle = nil
-- end