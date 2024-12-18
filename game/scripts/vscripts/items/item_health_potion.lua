item_health_potion = class({})

--------------------------------------------------------------------------------

function item_health_potion:Precache( context )
	PrecacheResource( "model", "models/props_gameplay/salve_red.vmdl", context )
	PrecacheResource( "particle", "particles/gameplay/bottle_glow.vpcf", context )
	PrecacheResource( "particle", "particles/items3_fx/fish_bones_active.vpcf", context )
end

--------------------------------------------------------------------------------

function item_health_potion:OnSpellStart()
	if IsServer() then
		local hp_restore_pct = self:GetSpecialValueFor( "hp_restore_pct" )
		self:GetCaster():EmitSoundParams( "DOTA_Item.FaerieSpark.Activate", 0, 0.5, 0)

		local nTeamNumber = self:GetCaster():GetTeamNumber()
		local Heroes = HeroList:GetAllHeroes()

		for _,Hero in pairs ( Heroes ) do
			if Hero ~= nil and Hero:IsRealHero() and Hero:IsAlive() and Hero:GetTeamNumber() == nTeamNumber then
				local flHealAmount = Hero:GetMaxHealth() * hp_restore_pct / 100
				Hero:Heal( flHealAmount / #Heroes, self )

				local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, Hero )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end

		self:SpendCharge(0.1)
	end
end

--------------------------------------------------------------------------------