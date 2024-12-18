item_byakko_lance = class({})
--------------------------------------------------------------------------------
function item_byakko_lance:Precache( context )
	--
end

function item_byakko_lance:GetIntrinsicModifierName()
	return "modifier_item_witch_blade"
end

--------------------------------------------------------------------------------

function item_byakko_lance:OnSpellStart()
	if IsServer() then
		local duration = self:GetSpecialValueFor( "duration" )
		EmitSoundOn( "Item.Brooch.Cast", self:GetCaster() )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_ancient_janggo_active", { duration = duration } )
	end
end
--------------------------------------------------------------------------------