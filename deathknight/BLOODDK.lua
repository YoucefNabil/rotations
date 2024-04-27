local _, class = UnitClass("player");
if class ~= "DEATHKNIGHT" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
local Listener = _A.Listener
local C_Timer = _A.C_Timer



local pressedbuttonat = 0
local buttondelay = 0.5
local STARTSLOT = 1
local STOPSLOT = 8
local GRABKEY = "R"
-- top of the CR
local player
local blood = {}
local hooksecurefunc = _A.hooksecurefunc
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

local SPELL_SHIELD_LOW    = GetSpellInfo(142863)
local SPELL_SHIELD_MEDIUM = GetSpellInfo(142864)
local SPELL_SHIELD_FULL   = GetSpellInfo(142865)

local function modifier_shift()
	local modkeyb = IsShiftKeyDown()
	if modkeyb then
		return true
		else
		return false
	end
end

function _A.modifier_shift()
	local modkeyb = IsShiftKeyDown()
	if modkeyb then
		return true
		else
		return false
	end
end

local function pull_location()
	return string.lower(select(2, _A.GetInstanceInfo()))
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
--
--




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

local function spellcost(spellid)
	local intel4 = (select(4, GetSpellInfo(spellid)))
	if intel4 == 0
		or intel4 == nil
		then return 0
		else return intel4
	end
end


local function unitDD(unit)
	local UnitExists = UnitExists
	local UnitGUID = UnitGUID
	if UnitExists(unit) then
		return tonumber((UnitGUID(unit)):sub(-13, -9), 16)
		else return -1
	end
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
	end
	return false
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

local GUI = {
}
local exeOnLoad = function()
	_A.depleted = 0
	function _A.enoughmana(id)
		local cost,_,powertype = select(4, _A.GetSpellInfo(id))
		if powertype then
			local currentmana = _A.UnitPower("player", powertype)
			if currentmana>=cost then
				return true
				else return false
			end
		end
		return true
	end
	function _A.isthishuman(unit)
		if _A.UnitIsPlayer(unit)==1
			then return true
		end
		return false
	end
	--
	_A.buttondelayfunc = function()
		if _A.GetTime() - pressedbuttonat < buttondelay then return true end
		return false
	end
	
	function _A.depletedrune()
		local batch1 = 0
		local batch2 = 0
		local batch3 = 0
		if (select(3,GetRuneCooldown(1)))==false and (select(3,GetRuneCooldown(2)))==false
			then batch1=1
			else batch1=0
		end
		if (select(3,GetRuneCooldown(3)))==false and (select(3,GetRuneCooldown(4)))==false
			then batch2=1
			else batch2=0
		end
		if (select(3,GetRuneCooldown(5)))==false and (select(3,GetRuneCooldown(6)))==false
			then batch3=1
			else batch3=0
		end
		return (batch1 + batch2 + batch3)
	end	
	
	function _A.runes()
		local bloodrunenb = 0
		local frostrunenb = 0
		local unholyrunenb = 0
		local deathrunenb = 0
		for i = 1, 6 do
			if (select(3,GetRuneCooldown(i)))==true
				then
				if GetRuneType(i)==1
					then bloodrunenb = bloodrunenb + 1
					elseif GetRuneType(i)==3
					then frostrunenb = frostrunenb + 1
					elseif GetRuneType(i)==4
					then deathrunenb = deathrunenb + 1
					elseif GetRuneType(i)==2
					then unholyrunenb = unholyrunenb + 1
				end
			end
		end
		return bloodrunenb, frostrunenb, unholyrunenb, deathrunenb, bloodrunenb + frostrunenb + deathrunenb + unholyrunenb
	end
	
	
	function _A.myscore()
		local base, posBuff, negBuff = UnitAttackPower("player");
		local ap = base + posBuff + negBuff
		local mastery = GetCombatRating(26)
		local crit = GetCombatRating(9)
		local haste = GetCombatRating(18)
		return (ap + mastery + crit + haste)
		--return (mastery + crit + haste)
	end
	
	function _A.usablelite(spellid)
		if spellcost(spellid)~=nil then
			if power("player")>=spellcost(spellid)
				then return true
				else return false
			end
			else return false
		end
	end
	_A.FakeUnits:Add('lowestEnemyInRange', function(num, range_target)
		local tempTable = {}
		local ttt = Object("target")
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		if ttt and  ttt:enemy() and ttt:rangefrom(target)<=range and ttt:Infront() and _A.notimmune(ttt)  and ttt:los() then
			return ttt and ttt.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:rangefrom(target)<=range and Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
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
	--
	_A.FakeUnits:Add('lowestEnemyInRangeNOTAR', function(num, range_target)
		local tempTable = {}
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:rangefrom(target)<=range  and Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
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
	--
	_A.FakeUnits:Add('lowestEnemyInRangeNOTARNOFACE', function(num, range_target)
		local tempTable = {}
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:rangefrom(target)<=range  and  _A.notimmune(Obj) and Obj:los() then
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
	--
	--
	--
	--
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
	--
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
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
	--========================
	
	
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
	
	function _A.someoneislow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _A.isthishuman(Obj.guid) then
				if Obj:Health()<65 then
					if Obj:range()<40 then
						return true
					end
				end
			end
		end
		return false
	end
	
	function _A.someoneisuperlow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _A.isthishuman(Obj.guid) then
				if Obj:Health()<35 then
					if Obj:range()<40 then
						return true
					end
				end
			end
		end
		return false
	end
	
	_A.DSL:Register('UnitCastID', function(t)
		if t=="player" then
			t = U.playerGUID
		end
		return _A.UnitCastID(t) -- castid, channelid, guid, pointer
	end)
	_A.DSL:Register('castspecial', function(u, arg1, arg2)
		if u:los() then
			return u:cast(arg1, arg2)
		end
	end)
	
	
	function _A.powerpercent()
		local currmana = UnitPower("player", 0)
		local maxmana = UnitPowerMax("player", 0)
		return ((currmana * 100) / maxmana)
	end
	local next = next
	
	_A.DSL:Register('caninterrupt', function(unit)
		return interruptable(unit)
	end)
	--
	_A.DSL:Register('castsecond', function(unit)
		return castsecond(unit)
	end)
	
	_A.DSL:Register('chanpercent', function(unit)
		return chanpercent(unit)
	end)
	
	_A.DSL:Register('unitisimmobile', function()
		return GetUnitSpeed(unit)==0 
	end)
	
	
	
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		player = player or Object("player")
		if slot==STARTSLOT then 
			pressedbuttonat = 0
			if DSL("toggle")(_,"MasterToggle")~=true then
				_A.Interface:toggleToggle("mastertoggle", true)
				_A.print("ON")
			end
		end
		if slot==STOPSLOT then 
			if DSL("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				_A.print("OFF")
			end
		end
		--
		if slot ~= STARTSLOT and slot ~= STOPSLOT and clickType ~= nil then
			Type, id, subType = _A.GetActionInfo(slot)
			if Type == "spell" or Type == "macro" -- remove macro?
				then
				pressedbuttonat = _A.GetTime()
			end
		end
	end)
	--=======================
	--=======================
	--=======================
	--=======================
	local function MyTickerCallback(ticker)
		player = player or Object("player")
		
		if player and player:SpellReady("Death Grip") and player:SpellUsable("Death Grip") and player:Keybind("R")
			then
			local target = Object("target")
			if target
				and target:exists()
				and target:enemy()
				and target:spellRange("Death Grip")
				and target:alive()
				and not target:State("root")
				and _A.isthishuman(target.guid)
				and _A.notimmune(target)
				and target:infront()
				and target:los() then
				return target:Cast("Death Grip")
			end
		end
		--
		-- local newDuration = math.random(5,15)/10
		-- local newDuration = .1
		-- local updatedDuration = ticker:UpdateTicker(newDuration)
		-- print(newDuration)
	end
	C_Timer.NewTicker(.1, MyTickerCallback, false, "dkstuff")
end
local exeOnUnload = function()
end

blood.rot = {
	blank = function()
	end,
	
	gnawinterrupt = function()
	end,
	
	leapinterrupt = function()
	end,
	
	petmagnet = function()
	end,
	
	caching= function()
		_A.dkenergy = _A.UnitPower("player") or 0
		_A.blood, _A.frost, _A.unholy, _A.death, _A.total = _A.runes()
		_A.depleted = _A.depletedrune()
		_A.pull_location = pull_location()
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
	
	Empowerruneweapon = function()
		if player:SpellCooldown("Empower Rune Weapon")==0 and (player:Buff("Unholy Frenzy")) and _A.depletedrune()>=3
			then 
			player:Cast("Empower Rune Weapon", true)
		end
	end,
	
	
	MindFreeze = function()
		if player:SpellCooldown("Mind Freeze")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Death Strike") and obj:infront()
					and obj:caninterrupt() 
					and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=95
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Mind Freeze")
				end
			end
		end
	end,
	
	
	GrabGrab = function()
		if player:SpellCooldown("Death Grip")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if (_A.pull_location ~= "arena") or (_A.pull_location == "arena" and not hunterspecs[_A.UnitSpec(obj.guid)]) then
					if obj.isplayer and obj:isCastingAny() and obj:SpellRange("Death Grip") and obj:infront() 
						and (player:SpellCooldown("Mind Freeze")>.3 or not obj:caninterrupt() or not obj:SpellRange("Death Strike"))
						and not obj:State("root")
						and _A.notimmune(obj)
						and obj:los() then
						obj:Cast("Death Grip", true)
					end
				end
			end
		end
	end,
	
	GrabGrabHunter = function()
		if _A.pull_location == "arena" then
			local roster = Object("roster")
			if player:SpellCooldown("Death Grip")==0 then
				if roster and roster:DebuffAny("Scatter Shot") then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if 	obj.isplayer and hunterspecs[_A.UnitSpec(obj.guid)] and obj:SpellRange("Death Grip") and obj:infront() 
							and not obj:State("root")
							and _A.notimmune(obj)
							and obj:los() then
							obj:Cast("Death Grip", true)
						end
					end
				end
			end
		end
	end,
	
	strangulatesnipe = function()
		if (_A.blood>=1 or _A.death>=1)  then
			if   not player:talent("Asphyxiate") and player:SpellCooldown("Strangulate")==0 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Strangulate")  and obj:infront() 
						-- and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and not obj:DebuffAny("Strangulate")
						and not obj:State("silence")
						and not obj:lostcontrol()
						and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and _A.notimmune(obj)
						and _A.someoneisuperlow()
						and obj:los() then
						obj:Cast("Strangulate", true)
					end
				end
			end
		end
	end,
	
	Asphyxiatesnipe = function()
		if player:talent("Asphyxiate") and player:SpellCooldown("Asphyxiate")<.3 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Asphyxiate")  and obj:infront() 
					and not obj:lostcontrol()
					and not obj:DebuffAny("Asphyxiate")
					and not obj:State("silence")
					and (obj:drState("Asphyxiate") == 1 or obj:drState("Asphyxiate")==-1)
					and _A.notimmune(obj)
					and _A.someoneisuperlow()
					and obj:los() then
					return obj:Cast("Asphyxiate")
				end
			end
		end
	end,
	
	AsphyxiateBurst = function()
		if player:talent("Asphyxiate") and player:SpellCooldown("Asphyxiate")<.3 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer  and not _A.isthisahealer(obj)  and obj:SpellRange("Asphyxiate")  and obj:infront()
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest"))
					and not obj:lostcontrol()
					and not obj:DebuffAny("Asphyxiate")
					and not obj:BuffAny("bladestorm")
					and not obj:BuffAny("Anti-Magic Shell")
					and not obj:State("silence")
					and (obj:drState("Asphyxiate") == 1 or obj:drState("Asphyxiate")==-1)
					and _A.notimmune(obj)
					and obj:los() then
					return obj:Cast("Asphyxiate")
				end
			end
		end
	end,
	
	darksimulacrum = function()
		if _A.dkenergy>=20 and player and player:SpellCooldown("Dark Simulacrum")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer then
					if darksimulacrumspecsBGS[_A.UnitSpec(obj.guid)] or darksimulacrumspecsARENA[_A.UnitSpec(obj.guid)] 
						then
						if obj:SpellRange("Dark Simulacrum") and obj:infront() and not obj:State("silence") 
							and not obj:lostcontrol()
							and _A.notimmune(obj)
							and obj:los() 
							then
							obj:Cast("Dark Simulacrum", true)
						end
					end
				end
			end
		end
	end,
	
	root = function()
		local target = Object("target")
		if target and player:SpellCooldown("Chains of Ice")
			and target.isplayer
			and not target:spellRange("Death Strike") 
			and target:spellRange("Chains of Ice") 
			and target:infront()
			-- and _A.isthishuman("target")
			and target:exists()
			and target:enemy() 
			and not target:buffany(50435)
			and not target:buffany(1044)
			and not target:buffany(45524)
			and not target:buffany(48707)
			and not target:buffany("Bladestorm")
			and not target:Debuff("Chains of Ice") -- remove this
			and not target:state("root")
			and _A.notimmune(target)
			then if target:los()
				then 
				return target:Cast("Chains of Ice") -- slow/root
			end
		end
	end,
	
	boneshield = function()
		if player:SpellCooldown(49222)==0 then player:cast(49222) end
	end,
	
	
	petres = function()
		if player:SpellCooldown("Raise Dead")<.3 then
			if not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or not _A.HasPetUI()
				then 
				return player:cast("Raise Dead")
			end
		end
	end,
	
	antimagicshell = function()
		if player:SpellCooldown("Anti-Magic Shell")==0  then
			local lowestmelee = Object("lowestEnemyInRangeNOTARNOFACE(30)")
			if lowestmelee and lowestmelee:exists()
				then 
				player:Cast("Anti-Magic Shell", true)
			end
		end
	end,
	
	deathpact = function()
		if player:Talent("Death Pact") then
			if player:SpellCooldown("Death Pact")==0 then
				if player:health()<=50 then
					if  _A.UnitExists("pet")
						and not _A.UnitIsDeadOrGhost("pet")
						and _A.HasPetUI() then
						player:cast("Death Pact")
					end
				end
			end
		end
	end,
	
	Lichborne = function()
		if player:Talent("Lichborne") then
			if player:health()<=40 then
				if player:SpellCooldown("Lichborne")==0 then
					player:cast("Lichborne", true)
				end
			end
		end
	end,
	
	outbreak = function()
		if player:SpellCooldown("Outbreak")<.3 --OUTBREAK
			and _A.enoughmana(77575)
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Outbreak)")
			if lowestmelee then
				if lowestmelee:exists() then
					if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) 
						then 
						return lowestmelee:Cast("Outbreak")  --outbreak
					end
				end
			end
		end
	end,
	
	BonusDeathStrike = function()
		if player:Buff("Dark Succor")
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Death Strike")
				end
			end
		end
	end,
	
	
	
	DeathSiphon = function()
		if player:talent("Death Siphon") and _A.death >= 1
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Siphon)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Death Siphon")
				end
			end
		end
	end,
	
	DeathStrike = function()
		if player:SpellCooldown("Death Strike")<.3
		-- if _A.death>=2 or ( _A.unholy>=1 and _A.frost>=1)
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Death Strike")
				end
			end
		end
	end,
	
	Deathcoil = function()
		if _A.dkenergy>=40
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Coil)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Death Coil")
				end
			end
		end
	end,
	
	runestrikedump = function()
		if _A.dkenergy>=85
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Rune Strike")
				end
			end
		end
	end,
	
	runestrike = function()
		if _A.dkenergy>=30
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Rune Strike")
				end
			end
		end
	end,
	
	runetap = function()
		if _A.blood >=1 and player:SpellCooldown("Rune Tap")==0 and player:SpellUsable("Rune Tap") and player:health()<=90 then
			return player:Cast("Rune Tap")
		end
	end,
	
	BloodboilProc = function()
		if player:buff(81141) then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return player:Cast("Blood Boil")
				end
			end
		end
	end,
	
	Bloodboil_shift = function()
		if player:SpellCooldown("Blood Boil")<.3 and player:SpellUsable("Blood boil") and player:keybind("shift") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return player:Cast("Blood Boil")
				end
			end
		end
	end,
	
	Bloodboil = function()
		if _A.blood >=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return player:Cast("Blood Boil")
				end
			end
		end
	end,
	
	heartstrike = function()
		if _A.blood >=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Heart Strike")
				end
			end
		end
	end,
	
	dotapplication = function()
		if player:SpellCooldown("Outbreak")<.3 and player:SpellUsable("Outbreak")
			then 
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) then
						return lowestmelee:Cast("Outbreak")
					end
				end
			end
		end
	end,
	
	SoulReaper = function()
		if (_A.death>=1 or _A.unholy>=1)
			then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Soul Reaper)")
			if lowestmelee then
				if lowestmelee:exists() then
					if lowestmelee:health()<35 then
						return lowestmelee:Cast("Soul Reaper")
					end
				end
			end
		end
	end,
	
	dancingweapon = function()
		if player:SpellCooldown(49028)==0 and not player:buff(77535) and not player:buff(48707) and not player:buff(48792) and _A.depleted >= 3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return player:Cast("Dancing Rune Weapon")
				end
			end
		end
	end,
	
	vampiricblood = function()
		if player:SpellCooldown(55233)==0 and player:health()<=80 then player:cast(55233)
		end
	end,
	
	ams = function()
		if player:SpellCooldown(48707)==0 and
			(_A.death<=1 and player:SpellCooldown(49998)>=4 and not player:buff(77535) and not player:buff(48707) and not player:buff(48792)) then 
			player:cast(48707)
		end
	end,
	
	icbf = function()
		if player:SpellCooldown(48792)==0 and player:health()<20 and not player:buff(77535) and not player:buff(48707) and not player:buff(48792) then
			player:cast(48792)
		end
	end,
	
	deathpact = function()
		if player:Talent("Death Pact") and player:SpellCooldown("Death Pact")==0 and player:health()<=60 and not player:buff(77535) and not player:buff(48707) and not player:buff(48792) then
			player:cast(46584) player:cast("Death Pact")
		end
	end,
	
	Empowerruneweapon = function()
		if player:SpellCooldown("Empower Rune Weapon")==0 and player:health()<50 and _A.depleted>=3 
			and not player:buff(77535) 
			and not player:buff(48707) 
			and not player:buff(48792)
			then 
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					player:Cast("Empower Rune Weapon")
				end
			end
		end
	end,
	
	Buffbuff = function()
		if player:SpellCooldown("Horn of Winter")<.3 and _A.dkenergy <= 90 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Horn of Winter")
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
	blood.rot.caching()
	_A.latency = (select(3, GetNetStats())) and ((select(3, GetNetStats()))/1000) or 0
	_A.interrupttreshhold = math.max(_A.latency, .3)
	if _A.buttondelayfunc()  then return end
	if  player:isCastingAny() then return end
	if player:mounted() then return end
	-- if player:lostcontrol()  then return end 
	-- blood.rot.GrabGrab()
	blood.rot.boneshield()
	blood.rot.dancingweapon()
	blood.rot.ams()
	blood.rot.vampiricblood()
	blood.rot.icbf()
	blood.rot.deathpact()
	blood.rot.Empowerruneweapon()
	blood.rot.BonusDeathStrike()
	blood.rot.MindFreeze()
	blood.rot.dotapplication()
	blood.rot.runestrikedump()
	blood.rot.BloodboilProc()
	blood.rot.DeathSiphon()
	blood.rot.runetap()
	blood.rot.Bloodboil_shift()
	blood.rot.DeathStrike()
	blood.rot.Bloodboil()
	blood.rot.heartstrike()
	blood.rot.runestrike()
	blood.rot.Buffbuff()
	-- blood.rot.Deathcoil()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(250, {
	name = "Youcef's Blood dk",
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
