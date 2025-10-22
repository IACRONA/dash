LinkLuaModifier("modifier_warsong_fate_defender_shield", "modifiers/modifier_warsong_fate_defender", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_defender_shield_cooldown", "modifiers/modifier_warsong_fate_defender", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_defender_shield_buff", "modifiers/modifier_warsong_fate_defender", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warsong_fate_defender_shield_cooldown_buff", "modifiers/modifier_warsong_fate_defender", LUA_MODIFIER_MOTION_NONE)

require("settings/game_settings")

modifier_warsong_fate_defender = class({})
function modifier_warsong_fate_defender:GetTexture() return "fate_defender" end
function modifier_warsong_fate_defender:IsPurgable() return false end
function modifier_warsong_fate_defender:IsPurgeException() return false end
function modifier_warsong_fate_defender:RemoveOnDeath() return false end

function modifier_warsong_fate_defender:OnCreated(params)
    if not IsServer() then return end
    self:SetStackCount(1)
    self:GetParent().tOldSpells = {}
    -- ОПТИМИЗАЦИЯ FPS: Увеличен интервал с FrameTime() (~0.03s) до 1s для очистки старых заклинаний
    self:StartIntervalThink(1.0)
end

function modifier_warsong_fate_defender:OnRefresh(params)
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_warsong_fate_defender:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        for i=#caster.tOldSpells,1,-1 do
            local hSpell = caster.tOldSpells[i]
            if hSpell:NumModifiersUsingAbility() <= -1 and not hSpell:IsChanneling() then
                hSpell:RemoveSelf()
                table.remove(caster.tOldSpells,i)
            end
        end
    end
end

function modifier_warsong_fate_defender:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_REFLECT_SPELL,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
end

function modifier_warsong_fate_defender:GetModifierEvasion_Constant()
    if DEFENDER_SETTINGS_EVASION_CHANCE then
        return DEFENDER_SETTINGS_EVASION_CHANCE[self:GetStackCount()]
    end
    return 0
end

function modifier_warsong_fate_defender:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if not DEFENDER_SETTINGS_SHIELD_CHANCE then return end
    
    if RollPercentage(DEFENDER_SETTINGS_SHIELD_CHANCE[self:GetStackCount()]) and not self:GetParent():HasModifier("modifier_warsong_fate_defender_shield_cooldown") then
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_defender_shield_cooldown", {duration = DEFENDER_SETTINGS_COOLDOWN})
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_defender_shield", {duration = DEFENDER_SETTINGS_SHIELD_DURATION[self:GetStackCount()]})
    end
    if RollPercentage(DEFENDER_BUFF_CHANCE[self:GetStackCount()]) and not self:GetParent():HasModifier("modifier_warsong_fate_defender_shield_cooldown_buff") then
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_defender_shield_buff", {duration = DEFENDER_SETTINGS_DURATION_BONUS[self:GetStackCount()]})
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_warsong_fate_defender_shield_cooldown_buff", {duration = DEFENDER_SETTINGS_COOLDOWN})
    end
end

local function SpellReflect(parent, params)
    local reflected_spell_name = params.ability:GetAbilityName()
    local target = params.ability:GetCaster()

    if target:GetTeamNumber() == parent:GetTeamNumber() then
        return nil
    end

    if target:HasModifier("modifier_item_lotus_orb_active") then
        return nil
    end

    if params.ability.spell_shield_reflect then
        return nil
    end
    local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(reflect_pfx)
    local old_spell = false
    for _,hSpell in pairs(parent.tOldSpells) do
        if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
            old_spell = true
            break
        end
    end
    if old_spell then
        ability = parent:FindAbilityByName(reflected_spell_name)
    else
        ability = parent:AddAbility(reflected_spell_name)
        ability:SetStolen(true)
        ability:SetHidden(true)
        ability.spell_shield_reflect = true
        ability:SetRefCountsModifiers(true)
        table.insert(parent.tOldSpells, ability)
    end
    ability:SetLevel(params.ability:GetLevel())
    parent:SetCursorCastTarget(target)
    ability:OnSpellStart()
    target:EmitSound("Hero_Antimage.Counterspell.Target")
    if ability.OnChannelFinish then
        ability:OnChannelFinish(false)
    end 

    if ability:GetIntrinsicModifierName() ~= nil then
        local modifier_intrinsic = parent:FindModifierByName(ability:GetIntrinsicModifierName())
        if modifier_intrinsic then
            parent:RemoveModifierByName(modifier_intrinsic:GetName())
        end
    end

    return false
end

function modifier_warsong_fate_defender:GetReflectSpell( params )
    if DEFENDER_SETTINGS_REFLECT_CHANCE and RollPercentage(DEFENDER_SETTINGS_REFLECT_CHANCE[self:GetStackCount()]) then
        return SpellReflect(self:GetParent(), params)
    end
end

function modifier_warsong_fate_defender:PlayEffects( bBlock )
    if bBlock then
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Block"
    else
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Reflect"
    end
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetParent():EmitSound(sound_cast)
end

modifier_warsong_fate_defender_shield_buff = class({})
function modifier_warsong_fate_defender_shield_buff:GetTexture() return "fate_defender" end
function modifier_warsong_fate_defender_shield_buff:IsPurgable() return false end
function modifier_warsong_fate_defender_shield_buff:OnCreated(params)
    if not IsServer() then return end
    self.armor = DEFENDER_SETTINGS_ARMOR or 0
    self.magical_resistance = DEFENDER_SETTINGS_MAGICAL_RESISTANCE or 0
    self.heal_amp = DEFENDER_SETTINGS_INCREASE_hEAL or 0
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_warsong_fate_defender_shield_buff:AddCustomTransmitterData()
    return 
    {
        armor = self.armor,
        magical_resistance = self.magical_resistance,
        heal_amp = self.heal_amp,
    }
end

function modifier_warsong_fate_defender_shield_buff:HandleCustomTransmitterData( data )
    self.armor = data.armor
    self.magical_resistance = data.magical_resistance
    self.heal_amp = data.heal_amp
end

function modifier_warsong_fate_defender_shield_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
    }
end

function modifier_warsong_fate_defender_shield_buff:GetModifierMagicalResistanceBonus()
    return self.magical_resistance
end

function modifier_warsong_fate_defender_shield_buff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_warsong_fate_defender_shield_buff:GetModifierHealAmplify_PercentageSource()
    return self.heal_amp
end

modifier_warsong_fate_defender_shield = class({})
function modifier_warsong_fate_defender_shield:IsPurgable() return false end
function modifier_warsong_fate_defender_shield:GetTexture() return "fate_defender" end
function modifier_warsong_fate_defender_shield:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 1, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 2, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 4, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 5, Vector(75,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_warsong_fate_defender_shield:OnDestroy()
    if not IsServer() then return end
    if not DEFENDER_SETTINGS_ROOTED_RADIUS then return end
    
    self:GetParent():EmitSound("Hero_Abaddon.AphoticShield.Destroy")
    
	local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, DEFENDER_SETTINGS_ROOTED_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
        unit:AddNewModifier(self:GetParent(), nil, "modifier_rooted", {duration = DEFENDER_SETTINGS_ROOTED_DURATION})
    end
end

function modifier_warsong_fate_defender_shield:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end

function modifier_warsong_fate_defender_shield:GetModifierTotal_ConstantBlock(params)
    if params.damage > 0 and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
        self:Destroy()
        return params.damage / 100 * (DEFENDER_SETTINGS_BLOCK_DAMAGE or 0)
    end
end

modifier_warsong_fate_defender_shield_cooldown = class({})
function modifier_warsong_fate_defender_shield_cooldown:IsPurgable() return false end
function modifier_warsong_fate_defender_shield_cooldown:IsHidden() return true end

modifier_warsong_fate_defender_shield_cooldown_buff = class({})
function modifier_warsong_fate_defender_shield_cooldown_buff:IsPurgable() return false end
function modifier_warsong_fate_defender_shield_cooldown_buff:IsHidden() return true end