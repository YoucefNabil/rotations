local _,class = UnitClass("player")
if class~="WARRIOR" then return end
local media, _A, _Y = ...
-- local _, class = UnitClass("player");
-- if class ~= "WARRIOR" then return end;
local DSL = function(api) return _A.DSL:Get(api) end
local hooksecurefunc =_A.hooksecurefunc
local Listener = _A.Listener
local spell_name = function(idd) return _A.Core:GetSpellName(idd) end
local spell_ID = function(idd) return _A.Core:GetSpellID(idd) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local cdcd = .3
local specstoslap = {
	-- PRIESTS
	[256] = true,
	[257] = true,
	[258] = true,
	-- DRUIDS
	[102] = true,
	[103] = true,
	[104] = true,
	[105] = true,
	-- MONKS
	-- [268] = true,
	-- [269] = true,
	[270] = true, -- MW
	--
	-- [] = true
	-- [] = true
	-- [] = true
}
local InterruptSpells = {118,116,61305,28271,28272,61780,61721,2637,33786,5185,8936,50464,19750,82326,2061,9484,605,8129,331,8004,51505,403,77472,51514,5782,1120,48181,30108,
	33786, -- Cyclone		(cast)
	28272, -- Pig Poly		(cast)
	118, -- Sheep Poly		(cast)
	61305, -- Cat Poly		(cast)
	82691,
	31687,
	10326,
	113792,	-- Psyfiend Fear
	61721, -- Rabbit Poly		(cast)
	61780, -- Turkey Poly		(cast)
	28271, -- Turtle Poly		(cast)
	51514, -- Hex			(cast)
	51505, -- Lava Burst		(cast)
	339, -- Entangling Roots	(cast)
	30451, -- Arcane Blast		(cast)
	605, -- Dominate Mind		(cast)
	20066, --Repentance		(cast)
	116858, --Chaos Bolt		(cast)
	113092, --Frost Bomb		(cast)
	8092, --Mind Blast		(cast)
	11366, --Pyroblast		(cast)
	48181, --Haunt			(cast)
	102051, --Frost Jaw		(cast)
	1064, -- Chain Heal		(cast)
	77472, -- Greater Healing Wave	(cast)
	8004, -- Healing Surge		(cast)
	73920, -- Healing Rain		(cast)
	51505, -- Lava Burst		(cast)
	8936, -- Regrowth		(cast)
	2061, -- Flash Heal		(cast)
	2060, -- Greater Heal		(cast)
	--32375, -- Mass Dispel		(cast)
	2006, -- Resurrection		(cast)
	5185, -- Healing Touch		(cast)
	596, -- Prayer of Healing	(cast)
	19750, -- Flash of Light	(cast)
	635, -- Holy Light		(cast)
	7328, -- Redemption		(cast)
	2008, -- Ancestral Spirit	(cast)
	50769, -- Revive		(cast)
	2812, -- Denounce		(cast)
	82327, -- Holy Radiance		(cast)
	10326, -- Turn Evil		(cast)
	82326, -- Divine Light		(cast)
	82012, -- Repentance		(cast)
	116694, -- Surging Mist		(cast)
	124682, -- Enveloping Mist	(cast)
	115151, -- Renewing Mist	(cast)
	115310, -- Revival		(cast)
	126201, -- Frost Bolt		(cast)
	44614, -- Frostfire Bolt	(cast)
	133, -- Fireball		(cast)
	1513, -- Scare Beast		(cast)
	982, -- Revive Pet		(cast)
	111771, -- Demonic Gateway			(cast)
	118297, -- Immolate				(cast)
	"Cyclone",
	124465 -- Vampiric Touch			(cast)
	--32375 -- Mass Dispel				(cast) 
}
local reflectSpellsIDs = {
	5782,		-- Fear
	118699,		-- Fear
	118,		-- Polymorph
	339, 		-- Entangling Roots	(cast)
	10326,		--
	61305,		-- Polymorph: Black Cat
	28272,		-- Polymorph: Pig
	61721,		-- Polymorph: Rabbit
	61780,		-- Polymorph: Turkey
	28271,		-- Polymorph: Turtle
	33786, 		-- Cyclone
	113506, 	-- Cyclone
	20066,		-- Repentance
	51514,		-- Hex
	605,		-- Dominate Mind
	14515,
	-- damaze
	11366, 		--Pyroblast		(cast)
	48181, 		--Haunt			(cast)
	116858	 	--Chaos Bolt		(cast)
}
-- top of the CR
local player
_A.numtangos = 0
local arms = {}
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
	-- [102]="Druid Balance",
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
local frozen_debuffs = {
	"Frost Nova",
	"Freeze",
	33395,
	122
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
local usableitems= { -- item slots
	13, --first trinket
	14 --second trinket
}

local function cditemRemains(itemid)
	local itempointerpoint;
	if itemid ~= nil
		then 
		if tonumber(itemid)~=nil
			then 
			if itemid<=23
				then itempointerpoint = (select(1, GetInventoryItemID("player", itemid)))
			end
			if itemid>23
				then itempointerpoint = itemid
			end
		end
	end
	local startcast1 = (select(2, GetItemCooldown(itempointerpoint)))
	local endcast1 = (select(1, GetItemCooldown(itempointerpoint)))
	local gettm1 = GetTime()
	if startcast1 + (endcast1 - gettm1) > 0 then
		return startcast1 + (endcast1 - gettm1)
		else
		return 0
	end
end
--
--
local function ChaseBack()
    local target = Object("target")
	if target and target:Enemy() and target:alive() then 
		local tx, ty, tz = _A.ObjectPosition(target.guid)
		local facing = _A.ObjectFacing(target.guid)
		local destX = tx - math.cos(facing) * 1.0
		local destY = ty - math.sin(facing) * 1.0
		local px, py, pz = _A.ObjectPosition("player")
		_A.ClickToMove(destX, destY, tz)
		if not target:infront() and not player:BuffAny("Bladestorm") and not player:moving() then
			_A.FaceDirection(target.guid, false)
		end
		if target:SpellRange("Charge") and not player:BuffAny("Bladestorm") and target:infront() and target:los() and not IsCurrentSpell(100) then
			target:cast("Charge")
		end
	end
end
local GUI = {
}
local exeOnLoad = function()
	local STARTSLOT = 1
	local STOPSLOT = 8
	_A.pressedbuttonat = 0
	_A.buttondelay = 0.6
	--
	_A.latency = (select(3, GetNetStats())) and ((select(3, GetNetStats()))/1000) or 0
	_A.interrupttreshhold = math.max(_A.latency, .1)
	Listener:Add("warrior_stuff", {"PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD"}, function(event)
		_A.pull_location = pull_location()
	end)
	_A.pull_location = _A.pull_location or pull_location()
	_A.Interface:AddToggle({
		key = "Stambuff", 
		name = "Enable Pet Attacking Totem", 
		text = "ON = stam buff | OFF = AP buff",
		icon = select(3,GetSpellInfo("Commanding Shout")),
	})
	_A.Interface:ShowToggle("cooldowns", false)
	_A.Interface:ShowToggle("interrupts", false)
	_A.Interface:ShowToggle("aoe", false)
	--
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		--------------
		if slot then
			Type, id, subType = _A.GetActionInfo(slot)
			if id == 6544 then
				player = player or Object("player")
				if player:SpellCooldown(6544)<.3 then
					local px, py, pz = _A.ObjectPosition("cursor")
					_A.ClickPosition(px, py, pz)
					return _A.CallWowApi("SpellStopTargeting")
				end
			end
			if id == 97462 then
				player = player or Object("player")
				if player:SpellCooldown(97462)<.3 then
					local px, py, pz = _A.ObjectPosition("player")
					player:cast(114203)
					_A.ClickPosition(px, py, pz)
					_A.CallWowApi("SpellStopTargeting")
					player:cast(97462)
				end
			end
		end
		-------------
		local player = Object("player")
		if slot==STARTSLOT then 
			_A.pressedbuttonat = 0
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
				_A.Interface:toggleToggle("mastertoggle", true)
				_A.print("ON")
				return true
			end
		end
		if slot==STOPSLOT then 
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			-- TEST STUFF
			-- print(player:stance())
			-- local target = Object("target")
			-- if target and target:exists() then print(target:creatureType()) end
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				_A.print("OFF")
				return true
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
	
	
	function _A.someoneislow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer then
				if Obj:Health() <= 45 then
					return true
				end
			end
		end
		return false
	end
	
	function _Y.reflectcheck_personnal(unit)
		if unit then
			for _,v in ipairs(spell_name(InterruptSpells)) do
				if unit:IscastingOnMe() then
					if unit:iscasting(v) or unit:channeling(v) then
						return true
					end
				end
			end
		end
		return false
	end
	function _Y.reflectcheck_all(unit)
		if unit then
			for _,v in ipairs(spell_name(InterruptSpells)) do
				if not unit:IscastingOnMe() then
					if unit:iscasting(v) or unit:channeling(v) then
						return true
					end
				end
			end
		end
		return false
	end
	
	function _A.unitfrozen(unit)
		if unit then 
			for _,debuffs in ipairs(frozen_debuffs) do
				if unit:DebuffAny(debuffs) then return true
				end
			end
		end
		return false
	end
	
	function _A.groundposition(unit)
		if unit then 
			local x,y,z=_A.ObjectPosition(unit.guid)
			local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
			local los, cx, cy, cz = _A.TraceLine(x, y, z+5, x, y, z-200, flags)
			if not los then
				return cx, cy, cz
			end
		end
	end
	function _A.groundpositiondetail(x,y,z)
		local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
		local los, cx, cy, cz = _A.TraceLine(x, y, z+5, x, y, z-200, flags)
		if not los then
			return cx, cy, cz
		end
	end
	
	_A.buttondelayfunc = function()
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
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
	
	_A.numenemiesinfront = function()
		_A.numtangos = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange("Mortal Strike") and _A.notimmune(Obj)  and Obj:los() then
				_A.numtangos = _A.numtangos + 1
			end
		end
	end
	
	_A.numenemiesinfront_tighter = function()
		local number = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:spellRange("Mortal Strike") and _A.notimmune(Obj) and Obj:InConeOf("player", 90) and Obj:los() then
				number = number + 1
			end
		end
		return number
	end
	
	function _A.clickcast(unit, spell)
		local px,py,pz = _A.groundposition(unit)
		if px then
			_A.CallWowApi("CastSpellByName", spell)
			if player:SpellIsTargeting() then
				_A.ClickPosition(px, py, pz)
				_A.CallWowApi("SpellStopTargeting")
			end
		end
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
		local tGUID = target and target.guid or 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:InConeOf(player, 170) and _A.notimmune(Obj) 
				and not Obj:state("incapacitate || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					target = Obj.guid==tGUID and 1 or 0,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				if a.target ~= b.target then return a.target > b.target
					elseif a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end)
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		return nil
	end)
	_Y.autoattackmanager = function()
		local target = Object("target")
		local lowest = Object("lowestEnemyInSpellRange(Mortal Strike)")
		if lowest then
			if not target or lowest.guid~=target.guid then _A.TargetUnit(lowest.guid) end
		end
	end
	_Y.arenachecks = function()
		if _A.pull_location == "arena" then
			local healer = Object("party1")
			if healer and healerspecid[healer:spec()] and healer:state("incapacitate || disorient || charm || misc || sleep || fear || stun || silence") then 
				return true
			end
			return false
		end
		return false
	end
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:spellRange(spell) and  Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
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
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTARNOFACE', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and _A.notimmune(Obj) and Obj:los() then
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
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTARNOFACESTANCE', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:range()<=5 then
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
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
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
	function _Y.bestfacing(coneDegrees, Range, stepRadians)
		local coneRadians = math.rad(coneDegrees)
		local halfCone = coneRadians / 2
		local playerFacing = _A.ObjectFacing("player")
		local maxEnemies = 0
		local range = Range or 40
		local optimalFacing = playerFacing
		for facing = 0, 2 * math.pi, stepRadians do
			local count = 0
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				local yaw, _ = _A.GetAnglesBetweenObjects("player", Obj.guid)
				local relativeYaw = (yaw - facing + math.pi) % (2 * math.pi) - math.pi
				if math.abs(relativeYaw) <= halfCone then
					if Obj:range()<range and _A.notimmune(Obj) and Obj:los() then
						count = count + 1
					end
				end
			end
			if count > maxEnemies then
				maxEnemies = count
				optimalFacing = facing
			end
		end
		return optimalFacing, maxEnemies
	end
	function _Y.IsFacingEqual(CurrentFacing, TargetFacing, Tolerance)
		local tolerance = Tolerance or 0.1
		local currentFacing = CurrentFacing % (2 * math.pi)
		local targetFacing = TargetFacing % (2 * math.pi)
		local difference = math.abs(currentFacing - targetFacing)
		-- Handle wrapping around the circle
		if difference > math.pi then
			difference = (2 * math.pi) - difference
		end
		-- Check if the difference is within the tolerance
		return difference <= tolerance
	end
	function _A.modifier_shift()
		local modkeyb = IsShiftKeyDown()
		if modkeyb then
			return true
			else
			return false
		end
	end
	
	function _A.modifier_ctrl()
		local modkeyb = IsControlKeyDown()
		if modkeyb then
			return true
			else
			return false
		end
	end
	
	function _A.modifier_alt()
		local modkeyb = IsAltKeyDown()
		if modkeyb then
			return true
			else
			return false
		end
	end
end
local exeOnUnload = function()
	Listener:Remove("warrior_stuff")
end

arms.rot = {
	--
	stance_dance = function()
		local lowestmelee = Object("lowestEnemyInSpellRangeNOTARNOFACESTANCE")
		if player:SpellCooldown("Battle Stance")==0 then
			if player:stance()~=2 and player:health()<=42 then if not IsCurrentSpell(71) then player:cast("Defensive Stance") end return true 
				elseif player:stance()~=2 and not lowestmelee then if not IsCurrentSpell(71) then player:cast("Defensive Stance") end return true
				elseif player:stance()~=2 and _Y.arenachecks() then if not IsCurrentSpell(71) then player:cast("Defensive Stance") end return true
				elseif player:stance()~=1 and lowestmelee and player:health()>42 and not _Y.arenachecks() then if not IsCurrentSpell(2457) then player:cast("Battle Stance") end return true
			end
		end
	end,
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
			and player:Buff("Recklessness")
			then
			if _A.pull_location=="pvp" then
				player:useitem("Potion of Mogu Power")
			end
		end
	end,
	
	items_strflask = function()
		if not player:isCastingAny() and player:ItemCooldown(76088) == 0
			and player:combat()
			and not IsCurrentItem(76088)
			and player:ItemCount(76088) > 0
			and player:ItemUsable(76088)
			and not player:Buff(105696)
			then
			if _A.pull_location=="pvp" then
				player:useitem("Flask of Winter's Bite")
			end
		end
	end,
	
	Charge = function()
		if player:SpellCooldown("Charge")==0 and not IsCurrentSpell(100) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Charge") and obj:infront()
					and obj:caninterrupt() 
					-- and healerspecid[_A.UnitSpec(obj.guid)]
					and obj:IscastingOnMe()
					and obj:channame()~="mind sear"
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					and obj:los()
					then
					obj:Cast("Charge")
				end
			end
		end
	end,
	
	Pummel = function()
		if player:SpellCooldown("Pummel")==0 and not IsCurrentSpell(23920) and not IsCurrentSpell(6552) and not IsCurrentSpell(102060) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Mortal Strike") and obj:infront()
					and obj:caninterrupt() 
					and obj:channame()~="mind sear"
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Pummel")
				end
			end
		end
	end,
	
	Disruptingshout = function()
		if player:talent("Disrupting Shout") and player:SpellCooldown("Disrupting Shout")==0 and not IsCurrentSpell(23920) and not IsCurrentSpell(6552) and not IsCurrentSpell(102060) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and  obj:isCastingAny() and obj:range()<=10 then
					if player:SpellCooldown("Pummel")>0 or player:buff("Bladestorm") or (not obj:SpellRange("Mortal Strike")) or (obj:SpellRange("Mortal Strike") and not obj:infront()) then
						if obj:caninterrupt() and healerspecid[_A.UnitSpec(obj.guid)]
							and obj:channame()~="mind sear"
							and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=92
							)
							and _A.notimmune(obj)
							then
							obj:Cast("Disrupting Shout")
						end
					end
				end
			end
		end
	end,
	
	reflect_stuff_onme = function()
		if player:SpellCooldown("Spell Reflection")==0 and not IsCurrentSpell(23920) and not IsCurrentSpell(6552) and not IsCurrentSpell(102060) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:isCastingAny()
					and _Y.reflectcheck_personnal(obj)
					and (obj:castsecond() <=(_A.interrupttreshhold+.1) or obj:chanpercent()<=92
					)
					then
					player:Cast("Spell Reflection")
				end
			end
		end
	end,
	
	reflect_stuff_on_peer = function() -- rewrite this
		if player:talent("Mass Spell Reflection") and player:SpellCooldown("Mass Spell Reflection")==0 and not IsCurrentSpell(23920) and not IsCurrentSpell(6552) and not IsCurrentSpell(102060) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:isCastingAny()
					and _Y.reflectcheck_all(obj)
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					then
					player:Cast("Mass Spell Reflection")
				end
			end
		end
	end,
	
	thunderclap = function()
		if player:SpellCooldown("Thunder Clap")<cdcd and player:SpellUsable("thunder clap") then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=7 and  not healerspecid[_A.UnitSpec(obj.guid)] and _A.notimmune(obj) and obj:debuffduration("Weakened Blows")<1 and obj:los() then
					return player:cast("thunder clap")
				end
			end
		end
	end,
	
	hamstringpvp = function()
		if not player:talent("Piercing Howl") and player:SpellCooldown("Hamstring")<cdcd and player:spellusable("Hamstring") then
			local target = Object("target")
			if target and target.isplayer and target:enemy() 
				and target:debuffduration("Hamstring")<1
				and _A.notimmune(target)
				and not target:immune("snare") then
				return target:cast("Hamstring")
			end
		end
	end,
	
	piercing_howl = function()
		if player:talent("Piercing Howl") and player:SpellCooldown("Piercing Howl")<cdcd and player:spellusable("Piercing Howl") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:range()<=14 and _A.notimmune(Obj) and not Obj:immune("snare") and not Obj:state("snare")
					and not Obj:state("incapacitate || disorient || charm || misc || sleep") and Obj:los() then
					return player:cast("Piercing Howl")
				end
			end
		end
	end,
	
	stormbolt_on_heal_or_low = function()
		if _A.pull_location ~= "arena" then
			if player:talent("Storm Bolt") and player:SpellCooldown("Storm Bolt")<.3 then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:spellRange("Storm Bolt") 
						and (healerspecid[Obj:spec()] or (Obj:health()<50 and _A.pull_location=="pvp"))
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("stun") and Obj:InConeOf("player", 170) 
						and (Obj:drState("Storm Bolt") == 1 or Obj:drState("Storm Bolt")==-1)
						and Obj:los() then
						return Obj:cast("Storm Bolt") 
					end
				end
			end
		end
	end,
	
	stormbolt_arena = function()
		local target = Object("target")
		if _A.pull_location == "arena" and target and target.isplayer and target:alive() and target:enemy() then
			if player:talent("Storm Bolt") and player:SpellCooldown("Storm Bolt")<.3 then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:spellRange("Storm Bolt") 
						and (Obj.guid~=target.guid or (Obj:health()<30 and _A.pull_location=="pvp"))
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("stun") and Obj:InConeOf("player", 170) 
						and (Obj:drState("Storm Bolt") == 1 or Obj:drState("Storm Bolt")==-1)
						and Obj:los() then
						return Obj:cast("Storm Bolt") 
					end
				end
			end
		end
	end,
	
	shockwave_arena = function()
		local target = Object("target")
		if _A.pull_location == "arena" and target and target.isplayer and target:alive() and target:enemy() then
			if player:talent("Shockwave") and player:SpellCooldown("Shockwave")<.3 then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:range() <= 8
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("stun") and Obj:InConeOf("player", 90) 
						and (Obj:drState("Shockwave") == 1 or Obj:drState("Shockwave")==-1)
						and Obj:los() then
						return player:cast("Shockwave") 
					end
				end
			end
		end
	end,
	
	shockwave = function()
		if player:Talent("Shockwave") and player:SpellCooldown("Shockwave")<player:gcd() then
			local bestfacing, bestfacing_number = _Y.bestfacing(90, 10, 0.1)
			if bestfacing_number>=3 or (_A.pull_location=="arena" and bestfacing_number>=2)  then
				_A.FaceDirection(bestfacing, true)
				return C_Timer.After(0, function()
					player:Cast("Shockwave")
				end)
			end
		end
	end,
	
	shockwave_cheaper = function()
		if _A.pull_location ~= "arena" then
			if player:Talent("Shockwave") and player:SpellCooldown("Shockwave")<player:gcd() then
				local num = _A.numenemiesinfront_tighter()
				if num>=3 then
					player:Cast("Shockwave")
				end
			end
		end
	end,
	
	fearhealer = function()
		if _A.pull_location ~= "arena" then
			if player:SpellCooldown("Intimidating Shout")<.3 and (_A.someoneislow() or player:BuffAny("Recklessness")) then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:range()<=8
						and healerspecid[Obj:spec()]
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("fear") 
						and (Obj:drState("Intimidating Shout") == 1 or Obj:drState("Intimidating Shout")==-1)
						and Obj:los() then
						return Obj:cast("Intimidating Shout") 
					end
				end
			end
		end
	end,
	
	fear_arena = function()
		local target = Object("target")
		if _A.pull_location == "arena" and target and target.isplayer and target:alive() and target:enemy() and (_A.someoneislow() or player:BuffAny("Recklessness")) then
			if player:SpellCooldown("Intimidating Shout")<.3 then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:range()<=8
						and Obj.guid ~= target.guid
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("fear") 
						and (Obj:drState("Intimidating Shout") == 1 or Obj:drState("Intimidating Shout")==-1)
						and Obj:los() then
						return Obj:cast("Intimidating Shout") 
					end
				end
			end
		end
	end,
	
	colossussmash = function()
		if  player:SpellCooldown("Colossus Smash")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee:debuffduration("Colossus Smash")<1 then
				return lowestmelee:Cast("Colossus Smash")
			end
		end
	end,
	
	sunderarmor = function()
		if player:SpellCooldown("Sunder Armor")<cdcd and player:spellusable("Sunder Armor") and player:rage()>=15 then
			local target = Object("target")
			if target and target:alive() and target:enemy() and target:SpellRange("Mortal Strike") and target:infront() and target:los() then 
				if target:debuffduration("Weakened Armor")<3 or target:DebuffStackAny("Weakened Armor")<=2 then
					return target:Cast("Sunder Armor")
				end
			end
		end
	end,
	
	sunderarmor_target = function()
		if player:SpellCooldown("Sunder Armor")<cdcd and player:spellusable("Sunder Armor") then
			local target = Object("target")
			if target and target:enemy() and target:alive() and target:SpellRange("Mortal Strike") and target:infront() and healerspecid[target:spec()] and target:los() then 
				if target:debuffduration("Weakened Armor")<3 or target:DebuffStack("Weakened Armor")<=2 then
					return target:Cast("Sunder Armor")
				end
			end
		end
	end,
	
	Mortalstrike = function()
		if  player:SpellCooldown("Mortal Strike")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				return lowestmelee:Cast("Mortal Strike")
			end
		end
	end,
	
	thunderclapPVE = function()
		if player:SpellCooldown("Thunder clap")<cdcd and player:SpellUsable("Thunder clap") and _A.numtangos>=3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				return player:Cast("Thunder clap")
			end
		end
	end,
	
	Execute = function()
		if player:rage()>=30 then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Mortal Strike)")
			if lowestmelee and lowestmelee:health()<=20 then
				return lowestmelee:Cast("Execute")
			end
		end
	end,
	
	battleshout = function ()
		if not toggle("Stambuff") then
			if player:SpellCooldown("battle shout")<cdcd and player:rage()<=75 then return player:cast("battle shout") end
		end
		if toggle("Stambuff") then
			if player:SpellCooldown("Commanding Shout")<cdcd and player:rage()<=75 then return player:cast("Commanding Shout") end
		end
	end,
	
	slam = function()
		if player:SpellUsable("Slam") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				if lowestmelee:health()>20 or player:buff("Sweeping Strikes")  then
					if player:rage()>25 then
						if player:rage()>65 or lowestmelee:debuff("Colossus Smash") or player:buff("Sweeping Strikes") then
							return lowestmelee:Cast("Slam")
						end
					end
					else
					if player:rage()>30 then
						if player:rage()>65 or lowestmelee:debuff("Colossus Smash") then
							return lowestmelee:Cast("Execute")
						end
					end
				end
			end
		end
	end,
	
	slam_ragecap = function()
		if player:SpellUsable("Slam") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				if lowestmelee:health()>20 or player:buff("Sweeping Strikes")  then
					if player:rage()>25 then
						if player:rage()>65 or lowestmelee:debuff("Colossus Smash") or player:buff("Sweeping Strikes") then
							return lowestmelee:Cast("Slam")
						end
					end
					else
					if player:rage()>30 then
						if player:rage()>65 or lowestmelee:debuff("Colossus Smash") then
							return lowestmelee:Cast("Execute")
						end
					end
				end
			end
		end
	end,
	
	heroicstrike = function()
		if player:SpellUsable("Heroic Strike") and player:SpellCooldown("Heroic Strike")==0 and not IsCurrentSpell(78) then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				if player:rage()>30 then
					if player:rage()>=100 then
						return lowestmelee:Cast("Heroic Strike")
					end
				end
			end
		end
	end,
	
	burstdisarm = function()
		if player:SpellCooldown("Disarm")<cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer 
					and obj:SpellRange("Disarm") 
					and obj:Infront()
					and not healerspecid[_A.UnitSpec(obj.guid)] 
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest") or obj:BuffAny("Call of Dominance"))
					and not obj:BuffAny("Bladestorm")
					and not obj:state("incapacitate || disorient || charm || misc || sleep || stun || fear || disarm")
					and not obj:debuffany("Disarm") and not obj:debuffany("Grapple Weapon")
					and (obj:drState("Disarm") == 1 or obj:drState("Disarm")==-1)
					and _A.notimmune(obj)
					and obj:los() then
					return obj:Cast("Disarm")
				end
			end
		end
	end,
	
	chargegapclose = function()
		local target = Object("target")
		if target and player:SpellCooldown("Charge")==0 and player:SpellCooldown("Heroic Leap")>(player:gcd()+.3)
			and target.isplayer
			and not target:spellRange("Mortal Strike") 
			and target:spellRange("Charge") 
			and target:infront()
			-- and _A.isthishuman("target")
			and target:exists()
			and target:enemy() 
			and not target:buffany("Bladestorm")
			and _A.notimmune(target)
			then if target:los()
				then 
				return target:Cast("charge") -- slow/root
			end
		end
	end,
	
	
	heroicleap = function()
		local target = Object("target")
		if target and player:SpellCooldown("Heroic Leap")<cdcd
			and target.isplayer
			and not target:spellRange("Mortal Strike") 
			and target:range()>=8
			and target:range()<=40
			and target:infront()
			-- and _A.isthishuman("target")
			and target:exists()
			and target:enemy() 
			and not target:buffany("Bladestorm")
			and _A.notimmune(target)
			then if target:los()
				then 
				return _A.clickcast(target, "Heroic Leap") -- slow/root
			end
		end
	end,
	
	-- Defs
	diebythesword = function()
		if player:health() <= 35 then
			if player:SpellCooldown("Die by the Sword") == 0
				and not IsCurrentSpell(118038)
				and not IsCurrentSpell(871)
				and not player:buff("Shield Wall")
				then
				player:cast("Die by the Sword")
			end
		end
	end,
	
	burst_diebythesword = function()
		if player:SpellCooldown("Die by the Sword")==0 
			and not IsCurrentSpell(118038)
			and not IsCurrentSpell(871)
			then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer 
					and obj:SpellRange("Disarm") 
					and not healerspecid[_A.UnitSpec(obj.guid)] 
					and UnitTarget(obj.guid)==player.guid
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest") or obj:BuffAny("Call of Dominance"))
					and not obj:BuffAny("Bladestorm")
					and not obj:state("incapacitate || disorient || charm || misc || sleep || stun || fear || disarm")
					and not obj:state("disarm")
					and obj:los() then
					return player:Cast("Die by the Sword")
				end
			end
		end
	end,
	
	shieldwall = function()
		if player:health() <= 30 then
			if player:SpellCooldown("Shield Wall") == 0
				and not player:buff("Die By the Sword")
				and not IsCurrentSpell(118038)
				and not IsCurrentSpell(871)
				then
				player:cast("Shield Wall")
			end
		end
	end,
	
	antifear = function()
		if player:SpellCooldown("Berserker Rage")==0 and ( player:state("incapacitate") or player:state("fear") ) then
			player:cast("Berserker Rage")
		end
	end,
	
	reflectspell = function()
		if player:SpellCooldown("Spell Reflection")==0 and not IsCurrentSpell(23920) and not IsCurrentSpell(114029)  then
			--
			if _A.unitfrozen(player) then player:cast("Spell Reflection") end
			--
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:range()<=25 and Obj:BuffAny("Nature's Swiftness") then
					return player:cast("Spell Reflection")
				end
			end
		end
	end,
	
	safeguard_unroot_BG = function()
		local tempTable = {}
		if player:Talent("Safeguard") and player:SpellCooldown("Safeguard")==0
			and player:State("root") 
			and not player:buff("Spell Reflection")
			and not IsCurrentSpell(114029) and not IsCurrentSpell(23920) 
			then
			for _, raidobject in pairs(_A.OM:Get('Roster')) do
				if raidobject and not raidobject:Is(player)
					and raidobject:range()<25
					and raidobject:los()
					then
					tempTable[#tempTable+1] = {
						obj = raidobject,
						range = raidobject:range(),
					}
				end
			end
			if #tempTable>1 then
				table.sort( tempTable, function(a,b) return ( a.range < b.range ) end )
			end
			if tempTable[1] then print("HEY IM WORKING") 
				return tempTable[1].obj:cast("Safeguard")
			end
		end
	end,
	
	-- BURST
	
	activetrinket = function()
		if player:combat() and player:buff("Surge of Victory") and not player:talent("Bladestorm") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee.isplayer
				and lowestmelee:health()>=35
				then 
				for i=1, #usableitems do
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
						if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
							if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 then 
								return _A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i])))
							end
						end
					end
				end
			end
		end
	end,
	
	reckbanner = function()
		if player:combat() and player:buff("Call of Victory") and player:SpellCooldown("Recklessness")==0 and not player:talent("Bladestorm") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee.isplayer and lowestmelee:health()>=30
				then 
				player:cast("Skull Banner")
				player:cast("Recklessness")
			end
		end
	end,
	
	bloodbath = function()
		if player:combat() and player:buff("Call of Victory") and player:SpellCooldown("Bloodbath")==0 then
			if not player:talent("Bladestorm") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
				if lowestmelee and lowestmelee.isplayer and lowestmelee:health()>=30
					then 
					return player:cast("Bloodbath")
				end
			end
		end
	end,
	
	
	
	bladestorm = function()
		if player:combat() and player:buff("Surge of Victory") and player:talent("Bladestorm") and player:SpellCooldown("Bladestorm")<player:gcd() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee.isplayer and lowestmelee:health()>=30 then
				if player:stance()~=2 and not IsCurrentSpell(71) then player:cast("Defensive Stance") end
				player:cast("Skull Banner")
				player:cast("Recklessness")
				player:cast("Bloodbath")
				for i=1, #usableitems do
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
						if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
							if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 then 
								_A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i])))
							end
						end
					end
				end
				-- return player:buff("Bloodbath") and player:buff("Call of Victory") and player:cast("Bladestorm")
				return player:cast("Bladestorm")
			end
		end
	end,
	----------------------------
	sweeping_strikes = function()
		if _A.numtangos>=3 
			-- if _A.modifier_shift()
			and player:SpellUsable("Sweeping Strikes") and player:SpellCooldown("Sweeping Strikes")==0
			then
			return player:cast("sweeping strikes")
		end
	end,
	
	victoryrush = function()
		if  player:SpellUsable("Victory Rush") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				return lowestmelee:Cast("Victory Rush")
			end
		end
	end,
	overpower = function()
		if  player:SpellUsable("Overpower") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee then
				return lowestmelee:Cast("Overpower")
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
	player = Object("player")
	if not player then return true end
	_A.numenemiesinfront()
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
	if _A.buttondelayfunc()  then return true end
	if  player:isCastingAny() then return true end
	if player:mounted() then return true end
	if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return true end
	-- if player:lostcontrol()  then return end 
	-- Interrupts
	-- _Y.autoattackmanager()
	-- if player:keybind("E") then ChaseBack() end
	arms.rot.items_strpot()
	arms.rot.items_strflask()
	arms.rot.activetrinket()
	arms.rot.bloodbath()
	arms.rot.reckbanner()
	arms.rot.antifear()
	arms.rot.shieldwall()
	-- Precise sequence of non gcd spells
	if arms.rot.safeguard_unroot_BG() then return true end
	if arms.rot.Pummel() then return true end
	if arms.rot.reflectspell() then return true end
	if arms.rot.reflect_stuff_onme() then return true end
	if arms.rot.reflect_stuff_on_peer() then return true end
	if arms.rot.Charge() then return true end
	if arms.rot.Disruptingshout() then return true end
	-- Rotation
	if arms.rot.fearhealer() then return true end
	if arms.rot.fear_arena() then return true end -- arena spec
	if arms.rot.bladestorm() then return true end
	arms.rot.stance_dance()
	if arms.rot.shockwave_cheaper() then return true end
	if arms.rot.shockwave_arena() then return true end -- arena spec
	if arms.rot.stormbolt_on_heal_or_low() then print("STUNNING!!!") return true end
	if arms.rot.stormbolt_arena() then print("STUNNING!!!") return true end -- arena spec
	if arms.rot.diebythesword() then return true end
	if arms.rot.burst_diebythesword() then return true end -- arena spec
	if arms.rot.sweeping_strikes() then return true end
	if arms.rot.colossussmash() then return true end
	if arms.rot.thunderclap() then return true end
	if arms.rot.burstdisarm() then return true end
	if arms.rot.battleshout() then return true end
	if arms.rot.hamstringpvp() then return true end
	if arms.rot.piercing_howl() then return true end
	if arms.rot.victoryrush() then return true end
	if arms.rot.Mortalstrike() then return true end
	if arms.rot.thunderclapPVE() then return true end
	if arms.rot.sunderarmor_target() then return true end
	if arms.rot.slam() then return true end
	if arms.rot.overpower() then return true end
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(71, {
	name = "Youcef's Arms Warrior",
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
