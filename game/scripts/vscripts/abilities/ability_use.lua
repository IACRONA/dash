ability_use = class{
	GetCastRangeBonus = function(self)
		return 0
	end
}

function ability_use:ProcsMagicStick()
    return false
end

function ability_use:IsHiddenAbilityCastable()
    return true
end