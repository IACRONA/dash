LinkLuaModifier('modifier_on_death', 'modifiers/generic/modifier_on_death', LUA_MODIFIER_MOTION_NONE)

modifier_on_death = class({
  IsHidden         = function(self) return true end,
  IsPurgable         = function(self) return false end,
  DeclareFunctions        = function(self) return 
  {
    MODIFIER_EVENT_ON_DEATH,
  } end,

})

function modifier_on_death:OnDeath(event)
  if event.unit == self:GetParent() then 
    if self.CallbackOnDeath then self.CallbackOnDeath() end 
  end
end
 