item_poombang = class({})
--------------------------------------------------------------------------------
function item_poombang:Precache( context )
	PrecacheResource( "particle", "particles/items/lifes_branch.vpcf", context )
end

--[[function item_poombang:IsMuted()

	if self:GetCaster():HasModifier( "modifier_item_vladmir_aura" ) then
        return true
    end

	return self.BaseClass.IsMuted( self )
end--]]

function item_poombang:GetIntrinsicModifierName()
	return "modifier_item_vladmir"
end

--------------------------------------------------------------------------------

function item_poombang:OnSpellStart()
	if IsServer() then
		
		--EmitSoundOn( "DOTA_Item.GhostScepter.Activate", self:GetCaster() )

		local aura_radius = self:GetSpecialValueFor( "aura_radius" )
		local heal_radius = self:GetSpecialValueFor( "heal_radius" )
		local hp_restore_pct = self:GetSpecialValueFor( "hp_restore_pct" )

		local Heroes = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), heal_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED, 0, false )
		for _,Hero in pairs( Heroes ) do
			if Hero ~= nil and Hero:IsRealHero() and Hero:IsAlive() then
			-- Get the percentage of missing health
			local missing_health_percentage = 100 - Hero:GetHealthPercent()

			-- Get the total health of the caster
			local max_health = Hero:GetMaxHealth()

			-- Calculate the amount of healing
			local flHealAmount = max_health * missing_health_percentage * hp_restore_pct / 10000

			if flHealAmount >= 1 then
				Hero:Heal( flHealAmount, self )
				--Hero:ModifyHealth( flHealAmount, self, false, 0 )			
				SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, Hero, flHealAmount, nil )
			end

			local nFXIndex1 = ParticleManager:CreateParticle( "particles/items/lifes_branch.vpcf", PATTACH_CUSTOMORIGIN, Hero )
			ParticleManager:SetParticleControlEnt( nFXIndex1, 0, Hero, PATTACH_ABSORIGIN_FOLLOW, nil, Hero:GetOrigin(), true  );
			ParticleManager:SetParticleControl( nFXIndex1, 1, Vector( 250, 250, 250 ) );
			ParticleManager:ReleaseParticleIndex( nFXIndex1 );
			end
		end
		
		EmitSoundOn( "Hero_Omniknight.Purification", self:GetCaster() )

		if self:GetIntrinsicModifierName() ~= nil then
			local hIntrinsicModifier = self:GetCaster():FindModifierByName( self:GetIntrinsicModifierName() )
			if hIntrinsicModifier then
				hIntrinsicModifier:ForceRefresh()
			end
		end
	end
end


--------------------------------------------------------------------------------

