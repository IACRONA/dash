LinkLuaModifier('cursed_knight_belial_pack_modifier', 'abilities/heroes/cursed_knight/cursed_knight_belial_pack', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('cursed_knight_belial_pack_modifier_main', 'abilities/heroes/cursed_knight/cursed_knight_belial_pack', LUA_MODIFIER_MOTION_NONE)


cursed_knight_belial_pack = cursed_knight_belial_pack or {}
function cursed_knight_belial_pack:GetIntrinsicModifierName()
    return "cursed_knight_belial_pack_modifier"
end


cursed_knight_belial_pack_modifier = cursed_knight_belial_pack_modifier or {
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    OnCreated = function(self)
        if not IsServer() then return end
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local main_modifier = parent:AddNewModifier(parent, ability, "cursed_knight_belial_pack_modifier_main", {})
        ability:SetHidden(true)
    end
}

cursed_knight_belial_pack_modifier_main = cursed_knight_belial_pack_modifier_main or {
    GetTexture = function() return "cursed_knight/belial_pack" end,
    IsHidden = function(self) 
        if not self:GetParent():HasScepter() then return true end
        return false 
    end,
    IsPurgable = function() return false end,
    OnCreated = function(self) 
        if not IsServer() then return end
        local ability = self:GetAbility()
        self.pct = ability:GetSpecialValueFor("amp_damage")/100
        self.cd = 0
    end,
    DeclareFunctions = function() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
    OnTakeDamage = function(self, keys)
        if not IsServer() then return end
        if not self:GetParent():HasScepter() then return end
        local parent = self:GetParent()
        local attacker = keys.attacker
        local unit = keys.unit
        if self.cd > 0 then return end
        if attacker == parent then 
            if unit:HasModifier("modifier_cursed_knight_curse_of_blood") and unit:HasModifier("modifier_cursed_knight_curse_of_blood_ally_curse") and unit:HasModifier("modifier_cursed_knight_curse_of_cold") then
                local reflect_damage = keys.damage*self.pct
                self.cd = 1
                Timers:CreateTimer(1, function()
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
}


