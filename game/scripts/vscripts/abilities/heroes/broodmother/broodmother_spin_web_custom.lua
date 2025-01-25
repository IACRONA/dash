LinkLuaModifier("modifier_broodmother_spin_web_custom_aura", "abilities/heroes/broodmother/broodmother_spin_web_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_spin_web_custom_invisible", "abilities/heroes/broodmother/broodmother_spin_web_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_spin_web_custom", "abilities/heroes/broodmother/broodmother_spin_web_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_spin_web_custom_aura_enemy", "abilities/heroes/broodmother/broodmother_spin_web_custom", LUA_MODIFIER_MOTION_NONE)

broodmother_spin_web_custom = class({})
function broodmother_spin_web_custom:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function broodmother_spin_web_custom:OnSpellStart()
	if not self.webs then
		self.webs = {}
	end

	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local found = false

	local web = CreateUnitByName("npc_dota_broodmother_web", pos, true, caster, caster, caster:GetTeamNumber())
	web:FindAbilityByName("broodmother_spin_web_custom_destroy"):SetLevel(1)
	web:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	web:AddNewModifier(caster, nil, "modifier_invulnerable", {})
	web:AddNewModifier(caster, nil, "modifier_magicimmune", {})
	web:AddNewModifier(caster, self, "modifier_broodmother_spin_web_custom_aura", {})
	web:EmitSound("Hero_Broodmother.SpinWebCast")

	for i = 1, self:GetSpecialValueFor("count") do
		if not self.webs[i] then
			self.webs[i] = web
			web:AddNewModifier(caster, self, "modifier_broodmother_spin_web_custom_aura", {}):SetStackCount(i)
			found = true
			break
		end
	end
    
	if not found then
		local eldest = 0
		local time = 100000000
		for i=1, self:GetSpecialValueFor("count") do
			if self.webs[i] and self.webs[i]:GetCreationTime() < time then
				eldest = i
				time = self.webs[i]:GetCreationTime()
			end
		end
		self.webs[eldest]:FindAbilityByName("broodmother_spin_web_custom_destroy"):OnSpellStart()
		self.webs[eldest] = web
		web:AddNewModifier(caster, self, "modifier_broodmother_spin_web_custom_aura", {}):SetStackCount(eldest)
	end

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spin_web_cast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, pos)
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_broodmother_spin_web_custom_aura = class({})

function modifier_broodmother_spin_web_custom_aura:IsHidden() return true end
function modifier_broodmother_spin_web_custom_aura:IsAura() return true end
function modifier_broodmother_spin_web_custom_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_broodmother_spin_web_custom_aura:GetAuraSearchTeam() 
    return DOTA_UNIT_TARGET_TEAM_BOTH 
end
function modifier_broodmother_spin_web_custom_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_broodmother_spin_web_custom_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_broodmother_spin_web_custom_aura:GetModifierAura()
    if self.isEnemy then
        return "modifier_broodmother_spin_web_custom_aura_enemy"
    end
    return "modifier_broodmother_spin_web_custom"
end
function modifier_broodmother_spin_web_custom_aura:IsAuraActiveOnDeath() return false end
function modifier_broodmother_spin_web_custom_aura:GetAuraDuration() return 0.5 end

function modifier_broodmother_spin_web_custom_aura:GetAuraEntityReject(hEntity)
    if hEntity:GetUnitName() == "npc_dota_broodmother_web" then
        return true
    end
    
    if hEntity:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        self.isEnemy = false
        if hEntity:GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID() then
            return true
        end
    else
        self.isEnemy = true
    end
    return false
end

function modifier_broodmother_spin_web_custom_aura:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,

    }
end

function modifier_broodmother_spin_web_custom_aura:OnDestroy()
	if IsServer() then
		self:GetAbility().webs[self:GetStackCount()] = nil
	end
end

modifier_broodmother_spin_web_custom = class({})

function modifier_broodmother_spin_web_custom:IsHidden() return false end
function modifier_broodmother_spin_web_custom:IsDebuff() return false end
function modifier_broodmother_spin_web_custom:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,

    }
end
function modifier_broodmother_spin_web_custom:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        local parent_name = parent:GetUnitName()
        
        -- Проверяем, что юнит это брудмама или её пауки
        if parent_name == "npc_dota_hero_broodmother" or 
           parent_name == "npc_dota_broodmother_spiderling" or 
           parent_name == "npc_dota_broodmother_spiderite" then
            
            self.invisTimer = Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("invisible_delay"), function()
                self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_broodmother_spin_web_custom_invisible", {})
            end)
        else
            self:Destroy() 
        end
    end
end

function modifier_broodmother_spin_web_custom:GetModifierMoveSpeedBonus_Percentage()
    local parent = self:GetParent()
    local parent_name = parent:GetUnitName()
    
    if parent_name == "npc_dota_hero_broodmother" or 
       parent_name == "npc_dota_broodmother_spiderling" or 
       parent_name == "npc_dota_broodmother_spiderite" then
        return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    end
    
    return 0
end

function modifier_broodmother_spin_web_custom:OnDestroy()
    if IsServer() and self.invisTimer then
        Timers:RemoveTimer(self.invisTimer)

        self:GetParent():RemoveModifierByName("modifier_broodmother_spin_web_custom_invisible")
    end
end

modifier_broodmother_spin_web_custom_invisible = class({})

function modifier_broodmother_spin_web_custom_invisible:IsHidden() return true end
function modifier_broodmother_spin_web_custom_invisible:IsDebuff() return false end

function modifier_broodmother_spin_web_custom_invisible:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true
    }
end

function modifier_broodmother_spin_web_custom_invisible:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_broodmother_spin_web_custom_invisible:GetModifierInvisibilityLevel()
    if IsClient() then
        return 1
    end
end

function modifier_broodmother_spin_web_custom_invisible:OnAbilityExecuted(keys)
    if IsServer() then
        if keys.unit == self:GetParent() then
            local parent = self:GetParent()
            local caster = self:GetCaster()
            local ability = self:GetAbility()
            local delay = ability:GetSpecialValueFor("invisible_delay")
            
            self:Destroy()
            
            -- Создаем новый таймер для возврата в невидимость
            Timers:CreateTimer(delay, function()
                if parent:HasModifier("modifier_broodmother_spin_web_custom") then
                    parent:AddNewModifier(caster, ability, "modifier_broodmother_spin_web_custom_invisible", {})
                end
            end)
        end
    end
end

function modifier_broodmother_spin_web_custom_invisible:OnAttackLanded(keys)
    if IsServer() then
        if keys.attacker == self:GetParent() then
            local parent = self:GetParent()
            local caster = self:GetCaster()
            local ability = self:GetAbility()
            local delay = ability:GetSpecialValueFor("invisible_delay")
            
            self:Destroy()
            
            -- Создаем новый таймер для возврата в невидимость
            Timers:CreateTimer(delay, function()
                if parent:HasModifier("modifier_broodmother_spin_web_custom") then
                    parent:AddNewModifier(caster, ability, "modifier_broodmother_spin_web_custom_invisible", {})
                end
            end)
        end
    end
end

broodmother_spin_web_custom_destroy = class({})

function broodmother_spin_web_custom_destroy:IsHiddenWhenStolen() 		return false end
function broodmother_spin_web_custom_destroy:IsRefreshable() 			return false end
function broodmother_spin_web_custom_destroy:IsStealable() 			    return false end
function broodmother_spin_web_custom_destroy:IsNetherWardStealable()	return false end
function broodmother_spin_web_custom_destroy:OnSpellStart()
	local caster = self:GetCaster()
	for k, v in pairs(caster:FindAllModifiers()) do
		v:Destroy()
	end
	caster:ForceKill(false)
	Timers:CreateTimer(FrameTime(), function()
        if not caster:IsNull() then
            caster:RemoveSelf()
        end
        return nil
    end)
end

function broodmother_spin_web_custom:GetCastRange(location, target)
	if IsServer() then
		if IsNearEntity("npc_dota_broodmother_web", location, self:GetSpecialValueFor("radius") * 2, self:GetCaster()) then
			return 25000
		end
	end

	return self.BaseClass.GetCastRange(self, location, target)
end
function IsNearEntity(entities, location, distance, owner)
	for _, entity in pairs(Entities:FindAllByClassname(entities)) do
		if (entity:GetAbsOrigin() - location):Length2D() <= distance or owner and (entity:GetAbsOrigin() - location):Length2D() <= distance and entity:GetOwner() == owner then
			return true
		end
	end

	return false
end
modifier_broodmother_spin_web_custom_aura_enemy = class({})

function modifier_broodmother_spin_web_custom_aura_enemy:IsHidden() return false end
function modifier_broodmother_spin_web_custom_aura_enemy:IsDebuff() return true end
function modifier_broodmother_spin_web_custom_aura_enemy:IsPurgable() return false end
function modifier_broodmother_spin_web_custom_aura_enemy:OnCreated()
    self.lvlabel = self:GetAbility():GetLevel()
    self:SetHasCustomTransmitterData(true)
end
function modifier_broodmother_spin_web_custom_aura_enemy:AddCustomTransmitterData()
    return {
        lvlabel = self.lvlabel,
    }
end
function modifier_broodmother_spin_web_custom_aura_enemy:HandleCustomTransmitterData(data)
    self.lvlabel = data.lvlabel
end

function modifier_broodmother_spin_web_custom_aura_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT 
    }
end

function modifier_broodmother_spin_web_custom_aura_enemy:GetModifierConstantHealthRegen()
    if self:GetAbility() and self:GetAbility():GetCaster() and self:GetAbility():GetCaster():GetHeroFacetID() == 1 then
        return - 2 * self.lvlabel
    end
    return 0
end

