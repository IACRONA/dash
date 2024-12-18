item_mana_potion = class({})

--------------------------------------------------------------------------------

function item_mana_potion:Precache( context )
	PrecacheResource( "model", "models/props_gameplay/salve_blue.vmdl", context )
	PrecacheResource( "particle", "particles/items3_fx/mango_active.vpcf", context )
	PrecacheResource( "particle", "particles/gameplay/bottle_glow_mp.vpcf", context )
end



--------------------------------------------------------------------------------

function item_mana_potion:OnSpellStart()
	if IsServer() then
		local mana_restore_pct = self:GetSpecialValueFor( "mana_restore_pct" )
		self:GetCaster():EmitSoundParams( "DOTA_Item.Mango.Activate", 0, 0.5, 0 )

		local nTeamNumber = self:GetCaster():GetTeamNumber()
		local Heroes = HeroList:GetAllHeroes()

		for _,Hero in pairs ( Heroes ) do
			if Hero ~= nil and Hero:IsRealHero() and Hero:IsAlive() and Hero:GetTeamNumber() == nTeamNumber then
				local flManaAmount = Hero:GetMaxMana() * mana_restore_pct / 100
				Hero:GiveMana( flManaAmount )

				local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/mango_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, Hero )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end

		self:SpendCharge(0.1)
	end
end

--------------------------------------------------------------------------------