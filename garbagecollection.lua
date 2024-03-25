local mediaPath, _A = ...
local garbagedelay = 10
_A.C_Timer.NewTicker(garbagedelay, function()
	-- print("It's working")
	collectgarbage("collect")
end, false, "garbage")