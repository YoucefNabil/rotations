local mediaPath, _A = ...
local C_Timer = _A.C_Timer
local garbagedelay = 10
local flagclick = 0.1
local randomDuration = 1
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true, ["Orb of Power"] = true,}
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
end
local ClickthisPleasepvp = function()
	local tempTable = {}
	-- if pull_location()=="pvp" then
	for _, Obj in pairs(_A.OM:Get('GameObject')) do
		if heFLAGS[Obj.name] then
			-- print("It's working")
			tempTable[#tempTable+1] = {
				guid = Obj.guid,
				distance = Obj:distance()
			}
		end
	end
	if #tempTable > 1 then
		table.sort(tempTable, function(a, b) return a.distance < b.distance end)
	end
	if tempTable[1] and tempTable[1].distance <= 15 then _A.ObjectInteract(tempTable[1].guid) end
end
--
local function MyTickerCallback(ticker)
	ClickthisPleasepvp()
	-- local newDuration = math.random(5,15)/10
	local newDuration = .1
	local updatedDuration = ticker:UpdateTicker(newDuration)
	-- print(newDuration)
end
C_Timer.NewTicker(1, MyTickerCallback, false, "clickpvp")
---
C_Timer.NewTicker(garbagedelay, function()
	-- print("It's working")
	collectgarbage("collect")
end, false, "garbage")