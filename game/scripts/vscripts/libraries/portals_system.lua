function CAddonWarsong:RegisterPortals()
	self.aPortals = {}
	local aPortalEnts = Entities:FindAllByName('warsong_portal')
	local tPairs = {}
	for _, hPortal in ipairs(aPortalEnts) do
		local nLink = hPortal:Attribute_GetIntValue('portal_link_id', -1)
		local tPortal = {
			nLink = nLink,
			vPos = hPortal:GetOrigin(),
			nRadius = 200,
            index = hPortal:entindex(),
			nTeam = hPortal:Attribute_GetIntValue('portal_team', -1),
			bFlag = hPortal:Attribute_GetIntValue('portal_flag', 1) ~= 0,
			tPasses = {},

			IsTouching = function(self, vPos)
				return (self.vPos - vPos):Length2D() <= self.nRadius
			end,

			HasCooldown = function(self, hUnit)
				if self.tPasses[hUnit] then
					return GameRules:GetGameTime() - self.tPasses[hUnit] < PORTAL_COOLDOWN
				end
				return false
			end,

			CanPass = function(self, hUnit)
				if not self.bFlag and HasFlag(hUnit) then
					return false
				elseif self.nTeam > 0 and hUnit:GetTeam() ~= self.nTeam then
					return false
				elseif self:HasCooldown(hUnit) then
					return false
				else
					return true
				end
			end,

            IsEnemyPortal = function(self, hUnit)
				if self.nTeam > 0 and hUnit:GetTeam() ~= self.nTeam then
					return true
                end
			end,

			Teleport = function(self, hUnit)
				if self:CanPass(hUnit) then
					local nPlayer = hUnit:GetPlayerOwnerID()
					local bCamera = (PlayerResource:GetSelectedHeroEntity(nPlayer) == hUnit)

					if bCamera then
						PlayerResource:SetCameraTarget(nPlayer, hUnit)
					end

					local sParticle = 'particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf'
					local nParticle1 = ParticleManager:CreateParticle(sParticle, PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(nParticle1, 0, hUnit:GetOrigin())

					EmitSoundOnLocationWithCaster(hUnit:GetOrigin(), 'Hero_AbyssalUnderlord.DarkRift.Cancel', hUnit)
					
					FindClearSpaceForUnit(hUnit, self.tNext.vPos, true)

					sParticle = 'particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf'
					local nParticle2 = ParticleManager:CreateParticle(sParticle, PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(nParticle2, 0, hUnit:GetOrigin())

					EmitSoundOnLocationWithCaster(hUnit:GetOrigin(), 'Hero_Underlord.Portal.Out', hUnit)

					hUnit:SetThink(function()
						if bCamera then
							PlayerResource:SetCameraTarget(nPlayer, nil)
						end

						ParticleManager:DestroyParticle(nParticle1, false)
						ParticleManager:DestroyParticle(nParticle2, false)
						ParticleManager:ReleaseParticleIndex(nParticle1)
						ParticleManager:ReleaseParticleIndex(nParticle2)
					end, 0.6)

					local nTime = GameRules:GetGameTime()
					self.tPasses[hUnit] = nTime
					self.tNext.tPasses[hUnit] = nTime

					for hUnit, nPassTime in pairs(self.tPasses) do
						if not self:HasCooldown(hUnit) then
							self.tPasses[hUnit] = nil
						end
					end
				end
			end,
		}

		if GetMapName() == "portal_duo" then 
			if tPortal.nTeam ~= -1 then 
				AddFOWViewer(tPortal.nTeam, tPortal.vPos, 400, 999999, true)
			end
		end

		if nLink >= 0 then
			local tNext = tPairs[nLink]
			if tNext then
				tNext.tNext = tPortal
				tPortal.tNext = tNext
				tPairs[nLink] = nil
				table.insert(self.aPortals, tNext)
				table.insert(self.aPortals, tPortal)
			else
				tPairs[nLink] = tPortal
			end
		end
	end
end