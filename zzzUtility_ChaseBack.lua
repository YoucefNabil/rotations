local mediaPath, _A, _Y = ...
local C_Timer = _A.C_Timer
local garbagedelay = 10
local flagclick = 0.1
local player
local randomDuration = 1
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true, ["Orb of Power"] = true,}
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
end
Listener:Add("Master", "PLAYER_ENTERING_WORLD", function(event)
	local stuffsff = pull_location()
	_Y.pull_location = stuffsff
end)
local function ChaseBack()
	local player = player or Object("player")
    local target = Object("target")
	if player and player:keybind("E") then
		if target and target:Enemy() and target:alive() then 
			-- if (target:range()>4 or not target:behind()) then -- disable this check to constantly run behind the target
				local tx, ty, tz = _A.ObjectPosition(target.guid)
				local facing = _A.ObjectFacing(target.guid)
				local destX = tx - math.cos(facing) * 1.0
				local destY = ty - math.sin(facing) * 1.0
				local px, py, pz = _A.ObjectPosition("player")
				_A.ClickToMove(destX, destY, tz)
				if not target:infront() and not player:BuffAny("Bladestorm") 
					and not player:moving() -- makes it look smoother, but might miss attacks
					then
					_A.FaceDirection(target.guid, false)
				end
				-- Warrior specific
				if player:spec()==71 and target:SpellRange("Charge") and not player:BuffAny("Bladestorm") and target:infront() and target:los() and not IsCurrentSpell(100) then
					target:cast("Charge")
				-- end
			end
		end
	end
end
C_Timer.NewTicker(.1, ChaseBack, false, "chase")