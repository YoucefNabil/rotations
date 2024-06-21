local mediaPath, _A, _Y = ...
local C_Timer = _A.C_Timer
local garbagedelay = 10
local flagclick = 0.1
local randomDuration = 1
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true, ["Orb of Power"] = true,}
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
end
Listener:Add("Master", "PLAYER_ENTERING_WORLD", function(event)
	local stuffsff = pull_location()
	_Y.pull_location = stuffsff
end
)
Listener:Add("BG", {'LFG_PROPOSAL_SHOW', 'UPDATE_BATTLEFIELD_STATUS'}, function(evt)
	if evt=="LFG_PROPOSAL_SHOW" then
		_A.AcceptProposal()
		else
		for i=1, 3 do
			local status, _, _ = _A.GetBattlefieldStatus(i)
			if status == "confirm" then
				_A.AcceptBattlefieldPort(i,1)
				_A.StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
			end
		end
	end
end)
local ClickthisPleasepvp = function()
	-- if not _Y.pull_location or _Y.pull_location~="pvp" then return end
	local tempTable = {}
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
	-- local newDuration = math.random(5,15)/10
	-- local newDuration = .1
	local battlefieldstatus = GetBattlefieldWinner()
	if battlefieldstatus~=nil then LeaveBattlefield() end
	ClickthisPleasepvp()
	local newDuration = _A.Parser.frequency or .1
	local updatedDuration = ticker:UpdateTicker(newDuration)
end
C_Timer.NewTicker(1, MyTickerCallback, false, "clickpvp")
---
-- C_Timer.NewTicker(garbagedelay, function()
	-- collectgarbage("collect")
-- end, false, "garbage")