diretide_bucket_soldier_scream = class({})

function diretide_bucket_soldier_scream:OnSpellStart()
	if not IsServer() then return end

	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()

	local vDir = vPos - hCaster:GetAbsOrigin()
	vDir.z = 0
	local flLen = vDir:Length2D()
	if flLen < 1 then return end
	vDir = vDir / flLen

	local info = {
		EffectName    = "particles/hw_fx/golem_terror.vpcf",
		Ability       = self,
		vSpawnOrigin  = hCaster:GetAbsOrigin(),
		fStartRadius  = 150,
		fEndRadius    = 250,
		vVelocity     = vDir * 1200,
		fDistance     = 800,
		Source        = hCaster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	ProjectileManager:CreateLinearProjectile( info )
	EmitSoundOn( "Hero_WarlockGolem.Roar", hCaster )
end

function diretide_bucket_soldier_scream:OnProjectileHit( hTarget, vLocation )
	if not IsServer() then return end
	if hTarget == nil or hTarget:IsNull() then return false end
	if hTarget:IsMagicImmune() or hTarget:IsInvulnerable() then return false end

	local hCaster = self:GetCaster()

	ApplyDamage({
		victim      = hTarget,
		attacker    = hCaster,
		damage      = 120,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability     = self,
	})

	hTarget:AddNewModifier( hCaster, self, "modifier_bucket_soldier_attack_fear", { duration = 2.0 } )

	return false
end

function diretide_bucket_soldier_scream:ProcsMagicStick() return false end
function diretide_bucket_soldier_scream:IsStealable() return false end
