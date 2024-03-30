local mediaPath, _A = ...
local petbattledelay = 0.3
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
end
local function gotoPath(path)
    if not path or #path<=1 then return end
    local point = 2
    _A.ClickToMove(path[point][1], path[point][2], path[point][3])
	if path[point+1] and path[point+1][1] then
		local px, py, pz = _A.ObjectPosition("player")
		local distance = _A.GetDistanceBetweenPositions(px, py, pz, path[point][1], path[point][2], path[point][3])
		if distance <= 1.5 then
			point = point + 1
			_A.ClickToMove(path[point][1], path[point][2], path[point][3])
		end
		local lastmoved = _A.DSL:Get("lastmoved")("player")
		if lastmoved>=0.5 and point<#path then            
			_A.JumpOrAscendStart()
			_A.ClickToMove(path[point][1], path[point][2], path[point][3])
		end
	end    
end
local function petinteract()
	local tempTable = {}
	for _, Obj in pairs(_A.OM:Get('Critters')) do
		if Obj:CreatureType()==nil then
			tempTable[#tempTable+1] = {
				guid = Obj.guid,
				range = Obj:range() or 40,
			}
		end
	end
	if #tempTable>1 then
		table.sort( tempTable, function(a,b) return ( a.range < b.range ) -- order by score
		end )
	end
	-- return tempTable[1] and _A.ObjectInteract(tempTable[1].guid)
	if C_PetBattles.IsInBattle()==false then
		-- print(C_PetBattles.IsInBattle())
		if tempTable[1] then 
			if tempTable[1].range<=4 then _A.ObjectInteract(tempTable[1].guid) end
			local x,y,z = _A.ObjectPosition(tempTable[1].guid)
			gotoPath(_A.CalculatePath(x,y,z))
		end
	end
end
_A.C_Timer.NewTicker(petbattledelay, function()
	petinteract()
	_A.SecureFunc("C_PetBattles.UseAbility(1)", 1)
end, false, "petbattle")