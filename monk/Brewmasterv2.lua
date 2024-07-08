local _, class = UnitClass("player");
if class ~= "MONK" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local hooksecurefunc =_A.hooksecurefunc
local player
local brewmaster = {}
local immunebuffs = {
	"Deterrence",
	-- "Anti-Magic Shell",
	"Hand of Protection",
	-- "Spell Reflection",
	-- "Mass Spell Reflection",
	"Dematerialize",
	-- "Smoke Bomb",
	-- "Cloak of Shadows",
	"Ice Block",
	"Divine Shield"
}
local immunedebuffs = {
	"Cyclone",
	-- "Smoke Bomb"
}
local healerspecid = {
	-- [265]="Lock Affli",
	-- [266]="Lock Demono",
	-- [267]="Lock Destro",
	[105]="Druid Resto",
	[102]="Druid Balance",
	[270]="monk mistweaver",
	-- [65]="Paladin Holy",
	-- [66]="Paladin prot",
	-- [70]="Paladin retri",
	[257]="Priest Holy",
	[256]="Priest discipline",
	-- [258]="Priest shadow",
	[264]="Sham Resto",
	-- [262]="Sham Elem",
	-- [263]="Sham enh",
	-- [62]="Mage Arcane",
	-- [63]="Mage Fire",
	-- [64]="Mage Frost"
}
local darksimulacrumspecsBGS = {
	[265]="Lock Affli",
	[266]="Lock Demono",
	[267]="Lock Destro",
	-- [105]="Druid Resto",
	-- [102]="Druid Balance",
	-- [270]="monk mistweaver",
	-- [65]="Paladin Holy",
	-- [66]="Paladin prot",
	-- [70]="Paladin retri",
	-- [257]="Priest Holy",
	-- [256]="Priest discipline",
	[258]="Priest shadow",
	-- [264]="Sham Resto",
	[262]="Sham Elem",
	[263]="Sham enh",
	[62]="Mage Arcane",
	[63]="Mage Fire",
	[64]="Mage Frost"
}
local darksimulacrumspecsARENA = {
	[265]="Lock Affli",
	[266]="Lock Demono",
	[267]="Lock Destro",
	[105]="Druid Resto",
	[102]="Druid Balance",
	[270]="monk mistweaver",
	[65]="Paladin Holy",
	[66]="Paladin prot",
	[70]="Paladin retri",
	[257]="Priest Holy",
	[256]="Priest discipline",
	[258]="Priest shadow",
	[264]="Sham Resto",
	[262]="Sham Elem",
	[263]="Sham enh",
	[62]="Mage Arcane",
	[63]="Mage Fire",
	[64]="Mage Frost"
}
local hunterspecs = {
	[253]=true,
	[254]=true,
	[255]=true
}
local function power(unit)
	local intel2 = UnitPower(unit)
	if intel2 == 0
		or intel2 == nil
		then return 0
		else return intel2
	end
	intel2=nil
end
local function pull_location()
	local whereimi = string.lower(select(2, GetInstanceInfo()))
	return string.lower(select(2, GetInstanceInfo()))
end
local function manaregen()
	local intel3 = (select(1, GetPowerRegen()))
	if intel3 == 0
		or intel3 == nil
		then return 0
		else return intel3
	end
end

local function cdRemains(spellid)
	local endcast, startcast = GetSpellCooldown(spellid)
	local gettm = GetTime()
	if startcast + (endcast - gettm) > 0 then
		return startcast + (endcast - gettm)
		else
		return 0
	end
end
local function power(unit)
	local intel2 = UnitPower(unit)
	if intel2 == 0
		or intel2 == nil
		then return 0
		else return intel2
	end
	intel2=nil
end
local function unitDD(unit)
	local UnitExists = UnitExists
	local UnitGUID = UnitGUID
	if UnitExists(unit) then
		return tonumber((UnitGUID(unit)):sub(-13, -9), 16)
		else return -1
	end
end
local function isActive(spellID)
	local conda, condb = IsUsableSpell(spellID);
	if conda ~= nil then
		return true
		else
		return false
	end
end
--
--


local GUI = {
}
local exeOnLoad = function()
	local STARTSLOT = 85
	local STOPSLOT = 92
	_A.pressedbuttonat = 0
	_A.buttondelay = 0.6
	Listener:Add("warrior_stuff", {"PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD"}, function(event)
		_A.pull_location = pull_location()
	end)
	--
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		local player = Object("player")
		if slot==STARTSLOT then 
			_A.pressedbuttonat = 0
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
				_A.Interface:toggleToggle("mastertoggle", true)
				_A.print("ON")
			end
		end
		if slot==STOPSLOT then 
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			-- TEST STUFF
			-- local target = Object("target")
			-- if target and target:exists() then print(target:creatureType()) end
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				_A.print("OFF")
			end
		end
		--
		if slot ~= STARTSLOT and slot ~= STOPSLOT and clickType ~= nil then
			Type, id, subType = _A.GetActionInfo(slot)
			if Type == "spell" or Type == "macro" -- remove macro?
				then
				_A.pressedbuttonat = _A.GetTime()
			end
		end
	end)
	_A.buttondelayfunc = function()
		local player = Object("player")
		if player and player:stance()==1 then
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end end
		return false
	end
	
	function _A.notimmune(unit) -- needs to be object
		if unit then 
			if unit:immune("all") then return false end
		end
		for _,v in ipairs(immunebuffs) do
			if unit:BuffAny(v) then return false end
		end
		for _,v in ipairs(immunedebuffs) do
			if unit:DebuffAny(v) then return false end
		end
		return true
	end
	
	local function chanpercent(unit)
		local tempvar1, tempvar2 = select(5, UnitChannelInfo(unit))
		local givetime = GetTime()
		if unit == nil
			then 
			unit = "target"
		end	
		if UnitChannelInfo(unit)~=nil
			then local maxcasttime = abs(tempvar1-tempvar2)/1000
			local remainingcasttimeinsec = abs(givetime - (tempvar2/1000))
			local percentageofthis = (remainingcasttimeinsec * 100)/maxcasttime
			return percentageofthis
		end
		return 999
	end
	
	local function interruptable(unit)
		if unit == nil
			then unit = "target"
		end
		local intel5 = (select(9, UnitCastingInfo(unit)))
		local intel6 = (select(8, UnitChannelInfo(unit)))
		if intel5==false
			or intel6==false
			then return true
			else return false
		end
		return false
	end
	
	local function castsecond(unit)
		local givetime = GetTime()
		local tempvar = select(6, UnitCastingInfo(unit))
		local timetimetime15687
		if unit == nil
			then 
			unit = "target"
		end
		if UnitCastingInfo(unit)~=nil
			then timetimetime15687 = abs(givetime - (tempvar/1000)) 
		end
		return timetimetime15687 or 999
	end
	
	local function channelinfo(unit)
		local channeling = _A.UnitChannelInfo(unit)
		return channeling and string.lower((select(1, channeling))) or " "
	end
	
	
	_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
		local tempTable = {}
		local target = Object("target")
		if target and target:enemy() and target:spellRange(spell) and target:Infront() and  _A.notimmune(target)  and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end)
	
	function _A.enemiesinrangeofspin()
		local tempnumber = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			--if Obj:los() then
			if Obj:range()<=8 and Obj:alive() then
				if _A.notimmune(Obj) then
					tempnumber = tempnumber + 1
				end
			end
			--end
		end
		return tempnumber
	end
	
	function _A.pSpeed(unit, maxDistance)
		local munit = Object(unit)
		--local unitGUID = unit.guid
		local x, y, z = _A.ObjectPosition(unit)
		local facing = _A.ObjectFacing(unit)
		local speed = _A.GetUnitSpeed(unit)
		if not munit then return end
		-- Check if the unit is standing still or moving backward
		if not munit:Moving() or _A.UnitIsMovingBackward(unit) then
			return x, y, z
		end 
		-- Determine the dynamic distance, with a minimum of 2 units for moving units
		local distance = math.max(2, math.min(maxDistance, speed - 4.5))
		-- Adjust facing based on strafing or moving forward
		if _A.UnitIsStrafeLeft(unit) then
			facing = facing + math.pi / 2 -- 90 degrees to the right for strafe left
			elseif _A.UnitIsStrafeRight(unit) then
			facing = facing - math.pi / 2 -- 90 degrees to the left for strafe right
		end
		-- Calculate and return the new position
		local newX = x + distance * math.cos(facing)
		local newY = y + distance * math.sin(facing)
		return newX, newY, z
	end
	function _A.CastPredictedPos(unit, spell, distance)
		local player = Object("player")
		local px, py, pz = _A.pSpeed(unit, distance)
		if not px then return end
		_A.CallWowApi("CastSpellByName", spell)
		if player:SpellIsTargeting() then
			_A.ClickPosition(px, py, pz)
			_A.CallWowApi("SpellStopTargeting")
		end
	end
	
	_A.DSL:Register('caninterrupt', function(unit)
		return interruptable(unit)
	end)
	
	_A.DSL:Register('chanpercent', function(unit)
		return chanpercent(unit)
	end)
	
	_A.DSL:Register('castsecond', function(unit)
		return castsecond(unit)
	end)
	
	_A.DSL:Register('channame', function(unit)
		return channelinfo(unit)
	end)
	
	_A.DSL:Register('chifix', function()
		return _A.UnitPower("player", 12)
	end)
	_A.DSL:Register('chifixmax', function()
		return _A.UnitPowerMax("player", 12)
	end)
	_A.DSL:Register('kegcheck', function()
		return (power("player")+(manaregen()*cdRemains(121253)))>=80
	end)
	_A.DSL:Register('spinnumber', function()
		return _A.enemiesinrangeofspin()
	end)
end
local exeOnUnload = function()
end

brewmaster.rot = {
	items_healthstone = function()
		if player:health() <= 35 then
			if player:ItemCooldown(5512) == 0
				and player:ItemCount(5512) > 0
				and player:ItemUsable(5512) then
				player:useitem("Healthstone")
			end
		end
	end,
	
	items_noggenfogger = function()
		if player:ItemCooldown(8529) == 0
			and player:ItemCount(8529) > 0
			and player:ItemUsable(8529)
			and (not player:BuffAny(16591) or not player:BuffAny(16595)) -- drink until you get both these buffs
			then
			if _A.pull_location=="pvp" then
				player:useitem("Noggenfogger Elixir")
			end
		end
	end,
	
	items_strpot = function()
		if player:ItemCooldown(76095) == 0
			and player:ItemCount(76095) > 0
			and player:ItemUsable(76095)
			and player:Buff("Unholy Frenzy")
			then
			if _A.pull_location=="pvp" then
				player:useitem("Potion of Mogu Power")
			end
		end
	end,
	
	items_strflask = function()
		if not player:isCastingAny() and player:ItemCooldown(76088) == 0
			and player:ItemCount(76088) > 0
			and player:ItemUsable(76088)
			and not player:Buff(105696)
			then
			if _A.pull_location=="pvp" then
				player:useitem("Flask of Winter's Bite")
			end
		end
	end,
	
	turtletoss = function()
		local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable = UnitCastingInfo("boss1");
		local channelName, _, _, _, channelStartTime, channelEndTime, _, channelInterruptable = UnitChannelInfo("boss1");
		if channelName ~= nil then
			castName = channelName
		end
		if unitDD("boss1") == 67977 then -- tortos id
			if castName == GetSpellInfo(133939) then -- furious stone breath
				if unitDD("target") == 67966 then -- turtle id
					if isActive(134031) then -- kick shell	
						_A.CallWowApi("RunMacroText", "/click ExtraActionButton1")
					end
				end
			end
		end
		-- if unitDD("target") == 71604 then -- puddle id
		-- if HP("target")<100 then --
		-- if GetShapeshiftForm()==1 then
		-- cast(115460) -- ORB big heal, but mana drain
		-- castonthis("target")
		-- stoptargeting()
		-- return true
		-- end
		-- end
		-- end
	end,
	
	spear = function()
		if player:SpellCooldown("Spear Hand Strike")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" or _A.pull_location == "none" ) and obj:isCastingAny() and obj:SpellRange("Spear Hand Strike") and obj:infront()
					and obj:caninterrupt() 
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Spear Hand Strike")
				end
			end
		end
	end,
	
	stun_kick = function()
		if player:talent("Leg Sweep") and  player:SpellCooldown("Leg Sweep")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" or _A.pull_location == "none" ) and obj:isCastingAny() and obj:range()<5
					and _A.notimmune(obj)
					and not obj:state("silence")
					then
					obj:Cast("Leg Sweep")
				end
			end
		end
	end,
	
	blackoutkick = function()
		if  player:chi()>=2 and player:buffduration("Shuffle")<=1.5 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and lowestmelee:exists()  then
				return lowestmelee:Cast("Blackout Kick")
			end
		end
	end,
	
	guard = function()
		if  player:chi()>=2 and player:SpellCooldown("Guard")<.3 and player:buff("Power Guard") and not player:buff("Guard") then
			return player:Cast("Guard")
		end
	end,
	
	purifyingbrew = function()
		if  player:chi()>=1 and player:SpellCooldown("Purifying Brew")==0 and  
			( player:debuff("Heavy Stagger") or ( player:debuff("Moderate Stagger") and player:buffduration("Shuffle")>1.5 ) )
			then
			return player:Cast("Purifying Brew")
		end
	end,

	elusivebrew = function()
		if player:SpellCooldown("Elusive Brew")==0 and  player:BuffStack("Elusive Brew")>=8 and player:Health()<=55
			and (player:debuff("Heavy Stagger") or player:debuff("Moderate Stagger"))
			then
			return player:Cast("elusive brew")
		end
	end,

	
	kegsmash = function()
		if  (player:chi())<(player:chifixmax()-1) and player:SpellCooldown("Keg Smash")<.3 and player:energy()>=40  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Keg Smash)")
			if lowestmelee and lowestmelee:exists()  then
				return lowestmelee:Cast("Keg Smash")
			end
		end
	end,
	
	jab = function()
		if  player:chi()<player:chifixmax() and player:energy()>=40  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and lowestmelee:exists()  then
				return lowestmelee:Cast("Jab")
			end
		end
	end,
	
	chiwave = function()
		if  player:talent("Chi Wave") and player:SpellCooldown("Chi Wave")<.3  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Chi Wave)")
			if lowestmelee and lowestmelee:exists()  then
				return lowestmelee:Cast("Chi Wave")
			end
		end
	end,
	--=============================
	RS_shift = function()
		if  player:talent("Rushing Jade Wind") and player:energy()>=40 and player:SpellCooldown("Rushing Jade Wind")<.3 and player:keybind("Shift") then
			return player:Cast("Rushing Jade Wind")
		end
	end,
	stun_shift = function()
		if  player:talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<.3 and player:keybind("Shift") then
			return player:Cast("Leg Sweep")
		end
	end,
	BR_shift = function()
		if  player:Glyph("Glyph of Breath of Fire") and player:chi()>=2 and player:keybind("Shift") then
			return player:Cast("Breath of Fire")
		end
	end,
	--=============================
	RS_AOEPrio = function()
		if  player:talent("Rushing Jade Wind") and player:energy()>=40 and player:SpellCooldown("Rushing Jade Wind")<.3 and player:spinnumber()>=3  then
			return player:Cast("Rushing Jade Wind")
		end
	end,
	
	RS_Fill = function()
		if  player:talent("Rushing Jade Wind") and player:energy()>=40 and player:SpellCooldown("Rushing Jade Wind")<.3 and player:kegcheck()  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and lowestmelee:exists()  then
				return player:Cast("Rushing Jade Wind")
			end
		end
	end,
	
	tigerpalm = function()
		local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
		if lowestmelee and lowestmelee:exists()  then
			return lowestmelee:Cast(100787)
		end
	end,
	
	healingsphere = function()
		if player:Health()<90 and player:energy()>=40 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if not lowestmelee  then
				return _A.CastPredictedPos(player.guid, "Healing Sphere", 20)
			end
		end
	end,
	
	
}
---========================
---========================
---========================
---========================
---========================
local inCombat = function()	
	player = player or Object("player")
	if not player then return end
	_A.latency = (select(3, GetNetStats())) and ((select(3, GetNetStats()))/1000) or 0
	_A.interrupttreshhold = math.max(_A.latency, .2) 
	if _A.buttondelayfunc()  then return end
	if  player:isCastingAny() then return end
	if player:mounted() then return end
	-- if player:lostcontrol()  then return end 
	--interrupts
	brewmaster.rot.turtletoss()
	brewmaster.rot.spear()
	-- brewmaster.rot.stun_kick()
	--Shift mode
	brewmaster.rot.RS_shift()
	brewmaster.rot.stun_shift()
	brewmaster.rot.BR_shift()
	-- Aoe
	brewmaster.rot.RS_AOEPrio()
	-- Combo Consumer
	brewmaster.rot.blackoutkick()
	brewmaster.rot.guard()
	brewmaster.rot.purifyingbrew()
	-- Combo Builder
	brewmaster.rot.kegsmash()
	brewmaster.rot.jab()
	-- Fills
	brewmaster.rot.RS_Fill()
	brewmaster.rot.tigerpalm()
	brewmaster.rot.healingsphere()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(268, {
	name = "Youcef's LUA brewmaster",
	ic = inCombat,
	ooc = inCombat,
	use_lua_engine = true,
	gui = GUI,
	gui_st = {title="CR Settings", color="87CEFA", width="315", height="370"},
	wow_ver = "5.4.8",
	apep_ver = "1.1",
	-- ids = spellIds_Loc,
	-- blacklist = blacklist,
	-- pooling = false,
	load = exeOnLoad,
	unload = exeOnUnload
})
