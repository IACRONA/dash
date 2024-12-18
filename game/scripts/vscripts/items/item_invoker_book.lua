item_invoker_book = class({})
--------------------------------------------------------------------------------
function item_invoker_book:Precache( context )
	PrecacheResource( "particle", "particles/gameplay/invoker_book_hero_effect.vpcf", context )
end

function item_invoker_book:GetIntrinsicModifierName()
	return "modifier_item_octarine_core"
end

--------------------------------------------------------------------------------

function item_invoker_book:OnSpellStart()
	if IsServer() then

		local nPreviewFX2 = ParticleManager:CreateParticle( "particles/gameplay/invoker_book_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nPreviewFX2, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( nPreviewFX2, 1, Vector( 1000, 1000, 1000 ) )

		EmitSoundOn( "DOTA_Item.Arcane_Blink.Activate", self:GetCaster() )
		local kv =
		{
			duration = self:GetSpecialValueFor( "duration" ),
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_ring_of_aquila_aura", kv )
		
	end
end
--------------------------------------------------------------------------------

