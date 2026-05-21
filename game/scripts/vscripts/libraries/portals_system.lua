-- ============================================================
-- Portal class (metatable-based, shared methods)
-- ============================================================
local Portal = {}
Portal.__index = Portal

function Portal:IsTouching(vPos)
	local dx = self.vPos.x - vPos.x
	local dy = self.vPos.y - vPos.y
	return (dx * dx + dy * dy) <= self.nRadiusSqr
end

function Portal:HasCooldown(hUnit)
	local nLastPass = self.tPasses[hUnit]
	if nLastPass then
		return GameRules:GetGameTime() - nLastPass < PORTAL_COOLDOWN
	end
	return false
end

function Portal:CanPass(hUnit)
	if not self.bFlag and HasFlag(hUnit) then
		return false
	elseif self.nTeam > 0 and hUnit:GetTeam() ~= self.nTeam then
		return false
	elseif self:HasCooldown(hUnit) then
		return false
	end
	return true
end

function Portal:IsEnemyPortal(hUnit)
	return self.nTeam > 0 and hUnit:GetTeam() ~= self.nTeam
end

function Portal:Teleport(hUnit)
	if not self.tNext then return end
	if not self:CanPass(hUnit) then return end

	local nPlayer = hUnit:GetPlayerOwnerID()
	local bCamera = (PlayerResource:GetSelectedHeroEntity(nPlayer) == hUnit)

	if bCamera then
		PlayerResource:SetCameraTarget(nPlayer, hUnit)
	end

	local vOrigin = hUnit:GetOrigin()
	local nParticle1 = ParticleManager:CreateParticle('particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf', PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(nParticle1, 0, vOrigin)

	EmitSoundOnLocationWithCaster(vOrigin, 'Hero_AbyssalUnderlord.DarkRift.Cancel', hUnit)

	FindClearSpaceForUnit(hUnit, self.tNext.vPos, true)

	local nParticle2 = ParticleManager:CreateParticle('particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf', PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(nParticle2, 0, hUnit:GetOrigin())

	EmitSoundOnLocationWithCaster(hUnit:GetOrigin(), 'Hero_Underlord.Portal.Out', hUnit)

	Timers:CreateTimer(0.6, function()
		if bCamera and not hUnit:IsNull() and PlayerResource:GetSelectedHeroEntity(nPlayer) == hUnit then
			PlayerResource:SetCameraTarget(nPlayer, nil)
		end
		ParticleManager:DestroyParticle(nParticle1, false)
		ParticleManager:DestroyParticle(nParticle2, false)
		ParticleManager:ReleaseParticleIndex(nParticle1)
		ParticleManager:ReleaseParticleIndex(nParticle2)
	end)

	local nTime = GameRules:GetGameTime()
	self.tPasses[hUnit] = nTime
	self.tNext.tPasses[hUnit] = nTime
end

-- ============================================================
-- Spatial grid for O(1) lookup by world position
-- ============================================================
local GRID_CELL = 512
local function GridKey(x, y)
	return math.floor(x / GRID_CELL) .. ":" .. math.floor(y / GRID_CELL)
end

-- ============================================================
-- Register portals
-- ============================================================
function CAddonWarsong:RegisterPortals()
	self.aPortals = {}
	self.tPortalGrid = {}

	local aPortalEnts = Entities:FindAllByName('warsong_portal')
	local tPairs = {}
	local nRadius = 200

	for _, hPortal in ipairs(aPortalEnts) do
		local nLink = hPortal:Attribute_GetIntValue('portal_link_id', -1)
		local tPortal = setmetatable({
			nLink     = nLink,
			vPos      = hPortal:GetOrigin(),
			nRadius   = nRadius,
			nRadiusSqr = nRadius * nRadius,
			index     = hPortal:entindex(),
			nTeam     = hPortal:Attribute_GetIntValue('portal_team', -1),
			bFlag     = hPortal:Attribute_GetIntValue('portal_flag', 1) ~= 0,
			-- Weak keys: дохлые юниты автоматически вычищаются GC
			tPasses   = setmetatable({}, {__mode = "k"}),
		}, Portal)

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

	-- Заполняем grid bucket для быстрого поиска по позиции клика.
	-- Портал радиуса 200 при cell 512 может пересекать до 4 соседних ячеек.
	for _, tPortal in ipairs(self.aPortals) do
		local vp = tPortal.vPos
		local cells = {}
		for dx = -nRadius, nRadius, nRadius do
			for dy = -nRadius, nRadius, nRadius do
				cells[GridKey(vp.x + dx, vp.y + dy)] = true
			end
		end
		for key in pairs(cells) do
			self.tPortalGrid[key] = self.tPortalGrid[key] or {}
			table.insert(self.tPortalGrid[key], tPortal)
		end
	end
end

-- ============================================================
-- Public lookup: найти портал, который содержит точку vPos
-- ============================================================
function CAddonWarsong:GetPortalAt(vPos)
	local bucket = self.tPortalGrid and self.tPortalGrid[GridKey(vPos.x, vPos.y)]
	if not bucket then return nil end
	for _, tPortal in ipairs(bucket) do
		if tPortal:IsTouching(vPos) then
			return tPortal
		end
	end
	return nil
end
