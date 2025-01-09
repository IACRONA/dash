LinkLuaModifier('cursed_knight_belial_pack_modifier', 'abilities/heroes/cursed_knight/cursed_knight_belial_pack', LUA_MODIFIER_MOTION_NONE)


cursed_knight_belial_pack = cursed_knight_belial_pack or {}
function cursed_knight_belial_pack:GetIntrinsicModifierName()
    return "cursed_knight_belial_pack_modifier"
end


cursed_knight_belial_pack_modifier = cursed_knight_belial_pack_modifier or {}
function cursed_knight_belial_pack_modifier:GetTexture() return "cursed_knight/belial_pack" end
function cursed_knight_belial_pack_modifier:IsHidden() return false end
function cursed_knight_belial_pack_modifier:IsPurgable() return false end
function cursed_knight_belial_pack_modifier:OnCreated()
    local ability = self:GetAbility()
    self.pct = ability:GetSpecialValueFor("amp_damage")/100
    self.cd = 0
    if not IsServer() then return end
    self:GetParent():RemoveAbility(ability:GetAbilityName())
end
function cursed_knight_belial_pack_modifier:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function cursed_knight_belial_pack_modifier:OnTakeDamage(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local attacker = keys.attacker
    local unit = keys.unit
    if self.cd > 0 then return end
    if attacker == parent then 
        if unit:HasModifier("modifier_cursed_knight_curse_of_blood") and unit:HasModifier("modifier_cursed_knight_curse_of_blood_ally_curse") and unit:HasModifier("modifier_cursed_knight_curse_of_cold") then
            local reflect_damage = keys.damage*self.pct
            self.cd = 2
            Timers:CreateTimer(3, function()
                self.cd = 0
            end)
            ApplyDamage({
                victim = unit,
                attacker = parent,
                damage = reflect_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
            })    
        end
    end
end


