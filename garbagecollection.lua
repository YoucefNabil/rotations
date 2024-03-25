local mediaPath, _A = ...
local garbagedelay = 10
local flagclick = .1
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}
local function pull_location()
	local whereimi = string.lower(select(2, GetInstanceInfo()))
	return string.lower(select(2, GetInstanceInfo()))
end
local ClickthisPleasepvp = function()
	local tempTable = {}
	if pull_location()=="pvp" then
		for _, Obj in pairs(_A.OM:Get('GameObject')) do
			if heFLAGS[Obj.name] then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					distance = Obj:distance()
				}
			end
		end
		if #tempTable > 1 then
			table.sort(tempTable, function(a, b) return a.distance < b.distance end)
		end
		if tempTable[1] then _A.ObjectInteract(tempTable[1].guid) end
	end
end
_A.C_Timer.NewTicker(flagclick, function()
	-- print("It's working")
	ClickthisPleasepvp()
end, false, "flagclicking")

_A.C_Timer.NewTicker(garbagedelay, function()
	-- print("It's working")
	collectgarbage("collect")
end, false, "garbage")
