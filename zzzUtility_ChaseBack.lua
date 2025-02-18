local mediaPath, _A, _Y = ...
local C_Timer = _A.C_Timer
local garbagedelay = 10
local flagclick = 0.1
local player
local randomDuration = 1
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true, ["Orb of Power"] = true,}
-- Simplified ChaseBack with state management
--
local lastDestX, lastDestY, lastFaceTime
local faceCooldown = 0.3  -- Reduce facing adjustment frequency
local moveThreshold = 0.5 -- Only update movement if destination changes by 0.5+ yards
local lastTx, lastTy, lastFacing
local function ChaseBack()
	player = player or Object("player") 
    local target = Object("target")
    if player and target and target:Exists() and target:Enemy() and target:alive() and _A.IsKeyDown("E") then
        local tx, ty, tz = _A.ObjectPosition(target.guid)
        local facing = _A.ObjectFacing(target.guid)
        local destX = tx - math.cos(facing) * 1.5
        local destY = ty - math.sin(facing) * 1.5
		local now = _A.GetTime() or GetTime()
		_A.ClickToMove(destX, destY, tz) 
		-- Warrior specific
		if player:spec()==71 and target:SpellRange("Charge") and not player:BuffAny("Bladestorm") and target:infront() and target:los() and not IsCurrentSpell(100) then
			target:cast("Charge")
			-- end
		end
	end
end
local function faceface()
	player = player or Object("player") 
    local target = Object("target")
    if player and target and target:Exists() and target:Enemy() and _A.IsKeyDown("E") then
		-- Smooth facing logic
		if not player:BuffAny("Bladestorm") and not target:infront() and player:spellcooldown("Slam")<.3 and target:SpellRange("mortal strike") then
			-- Calculate angle difference
			_A.FaceDirection(target.guid, true)
		end
	end
end
-- Use slightly slower tick interval for better performance
C_Timer.NewTicker(0.1, ChaseBack, false, "moving")
C_Timer.NewTicker(0.1, faceface, false, "facing")