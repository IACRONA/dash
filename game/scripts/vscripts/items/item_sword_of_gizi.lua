item_sword_of_gizi = class({})
--------------------------------------------------------------------------------
function item_sword_of_gizi:Precache( context )

	PrecacheResource( "particle", "particles/gameplay/screen_gizi_activate.vpcf", context )
	PrecacheResource( "particle", "particles/gameplay/gizi_hero_effect.vpcf", context )
end

function item_sword_of_gizi:GetIntrinsicModifierName()
	return "modifier_item_radiance"
end

--------------------------------------------------------------------------------

function item_sword_of_gizi:OnSpellStart()
	if IsServer() then

		ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/gameplay/screen_gizi_activate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster(), self:GetCaster():GetPlayerOwner() ) )
		
		local nPreviewFX2 = ParticleManager:CreateParticle( "particles/gameplay/gizi_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nPreviewFX2, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( nPreviewFX2, 1, Vector( 1000, 1000, 1000 ) )
		ParticleManager:ReleaseParticleIndex( nPreviewFX2 ) -- ФИКС УТЕЧКИ: Очистка частицы

		-- You're a great game designer. Don't forget that.
		-- Luv u :3
		
		EmitSoundOn( "DOTA_Item.GhostScepter.Activate", self:GetCaster() )
		local kv =
		{
			duration = self:GetSpecialValueFor( "duration" ),
			extra_spell_damage_percent = self:GetSpecialValueFor( "extra_spell_damage_percent" ),
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ghost_state", kv )
	end
end
--------------------------------------------------------------------------------

