item_purple_shivas = class({})
--------------------------------------------------------------------------------
function item_purple_shivas:Precache( context )
	PrecacheResource( "particle", "particles/econ/events/ti10/shivas_guard_ti10_active.vpcf", context )
	PrecacheResource( "particle", "particles/econ/events/fall_2022/shivas/shivas_guard_fall2022_impact.vpcf", context )
end

function item_purple_shivas:GetIntrinsicModifierName()
	return "modifier_item_shivas_guard"
end

--------------------------------------------------------------------------------

function item_purple_shivas:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "DOTA_Item.ShivasGuard.Activate", self:GetCaster() )

		self.blast_radius = self:GetSpecialValueFor("blast_radius")
		self.blast_speed = self:GetSpecialValueFor("blast_speed") * 1.2
		self.blast_damage = self:GetSpecialValueFor("blast_damage")
		self.blast_debuff_duration = self:GetSpecialValueFor("blast_debuff_duration")
		self.freeze_duration = self:GetSpecialValueFor("freeze_duration")

		self.blast_duration = self.blast_radius / self.blast_speed
		self.current_loc = self:GetCaster():GetAbsOrigin()

		local blast_pfx = ParticleManager:CreateParticle( "particles/econ/events/ti10/shivas_guard_ti10_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl(blast_pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(1000, 0, self.blast_speed))
		ParticleManager:ReleaseParticleIndex(blast_pfx)

		CreateModifierThinker( self:GetCaster(), self, "modifier_item_shivas_guard_thinker", { duration = self.blast_debuff_duration }, self.current_loc, self:GetCaster():GetTeamNumber(), false )	

		self:GetCaster():SetContextThink( "KillEffects", function() return self:KillEffects() end, 1.75 )
	end
end

function item_purple_shivas:KillEffects()

		EmitSoundOn( "DOTA_Item.Necronomicon.Activate", self:GetCaster() )

		local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		for _,enemy in pairs(nearby_enemies) do
			ApplyDamage({attacker = self:GetCaster(), victim = enemy, ability = self, damage = self.blast_damage, damage_type = DAMAGE_TYPE_MAGICAL})

			-- Apply slow modifier
			enemy:AddNewModifier(caster, ability, "modifier_ogre_icicle_abyss", { duration = self.freeze_duration })
			-- blast it
			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/fall_2022/shivas/shivas_guard_fall2022_impact.vpcf", PATTACH_CUSTOMORIGIN, enemy )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

		end
end
--------------------------------------------------------------------------------

