item_kadens_blade = class({})
--LinkLuaModifier( "modifier_item_kadens_blade", "modifiers/items/modifier_item_kadens_blade", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_item_kadens_blade_debuff", "modifiers/items/modifier_item_kadens_blade_debuff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function item_kadens_blade:Precache( context )
	PrecacheResource( "particle", "particles/items3_fx/gleipnir_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_totem_cast_ti6_combined.vpcf", context )
end
--------------------------------------------------------------------------------

function item_kadens_blade:GetIntrinsicModifierName()
	return "modifier_item_gungir"
end

function item_kadens_blade:OnSpellStart()
	if IsServer() then

		local castAnim = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_totem_cast_ti6_combined.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl(castAnim, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(castAnim)

		EmitSoundOn( "Item.Gleipnir.Cast", self:GetCaster() )

		self.duration = self:GetSpecialValueFor("duration")
		self.radius = self:GetSpecialValueFor("radius")
		self.active_damage = self:GetSpecialValueFor("active_damage")

		local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		for _,enemy in pairs(nearby_enemies) do

			local projectile =
			{
				Target = enemy,
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/items3_fx/gleipnir_projectile.vpcf",
				iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),
				vSourceLoc = self:GetCaster():GetOrigin(),
				bDodgeable = false,
				bProvidesVision = false,
			}

			ProjectileManager:CreateTrackingProjectile( projectile )

		end
	end
end

function item_kadens_blade:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			EmitSoundOn( "Item.Gleipnir.Target", hTarget )
			ApplyDamage({attacker = self:GetCaster(), victim = hTarget, ability = self, damage = self.active_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_gungnir_debuff", { duration = self.duration } )
		end

		return true
	end
end
--------------------------------------------------------------------------------
