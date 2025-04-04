local _,class = UnitClass("player")
if class~="WARRIOR" then return end
local HarmonyMedia, _A, _Y = ...
-- local _, class = UnitClass("player");
-- if class ~= "WARRIOR" then return end;
local DSL = function(api) return _A.DSL:Get(api) end
local hooksecurefunc =_A.hooksecurefunc
local Listener = _A.Listener
local spell_name = function(idd) return _A.Core:GetSpellName(idd) end
local spell_ID = function(idd) return _A.Core:GetSpellID(idd) end
-- top of the CR
local player
_A.numtangos = 0
local prot = {}
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
	--
	_A.casttimers = {}
	_A.casttimers_tars = {}
	_A.scattertargets = {}
	_Y.enemyGuid = {}
	_A.ImIcastingsomething = {}
	Listener:Add("warArms_delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		if guidsrc == UnitGUID("player") then
			-- if spell_name(idd)=="Throw" then print(subevent) end
			if subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_CAST_START" or subevent == "SPELL_CAST_FAILED" or subevent == "RANGE_DAMAGE" then -- doesnt work with channeled spells
				_Y.enemyGuid[guiddest]=true
				C_Timer.After(10, function()
					if _Y.enemyGuid[guiddest] then
						_Y.enemyGuid[guiddest]=nil
					end
				end)
			end
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[spell_name(idd)] = _A.GetTime()
				_A.ImIcastingsomething[spell_name(idd)]=false
				if not _A.casttimers_tars[guiddest] then
					_A.casttimers_tars[guiddest] = {}
					_A.casttimers_tars[guiddest][spell_name(idd)]=_A.GetTime()
					-- if spell_name(idd)=="Throw" then print(spell_name(idd), guiddest) end
					else 
					_A.casttimers_tars[guiddest][spell_name(idd)]=_A.GetTime()
					-- if spell_name(idd)=="Throw" then print(spell_name(idd), guiddest) end
				end
			end
			if subevent == "SPELL_CAST_START" then
				_A.ImIcastingsomething[spell_name(idd)]=true
				C_Timer.After(10, function()
					if _A.ImIcastingsomething[spell_name(idd)] and not player:isCastingAny() then
						_A.ImIcastingsomething[spell_name(idd)]=false
					end
				end)
			end
		end
	end)
	_Y.spellqueuestuff = {}
	Listener:Add("warArms_spellqueue", {"UNIT_SPELLCAST_SUCCEEDED","UNIT_SPELLCAST_SENT"}, function(event, source, spellname, targetname)
		if source == "player" then
			local SPELLNN = spell_ID(spellname)
			if SPELLNN and not _Y.spellqueuestuff[SPELLNN] then
				_Y.spellqueuestuff[SPELLNN]=true
			end
		end
	end)
	function _Y.spellqcheck()
		for k,_ in pairs(_Y.spellqueuestuff) do
			if k and IsCurrentSpell(k) then return true end
		end
		return false
	end
	function _A.castdelay(idd, delay)
		local spellid = idd and spell_name(idd)
		if delay == nil then return true end
		if _A.casttimers[spellid]==nil then return true end
		return (_A.GetTime() - _A.casttimers[spellid])>=delay
	end
	function _A.castdelaytarget(idd, target, delay)
		local spellid = spell_name(idd)
		if _A.casttimers_tars[target] and _A.casttimers_tars[target][spellid] and (_A.GetTime() - _A.casttimers_tars[target][spellid])then
			-- print("IT PASSED THE CHECK", (_A.GetTime() - _A.casttimers_tars[target][spellid]))
			return (_A.GetTime() - _A.casttimers_tars[target][spellid])>=delay
		end
		return true
	end
	function _A.castwhen(idd)
		local spellid = idd and spell_name(idd)
		if _A.casttimers[spellid]==nil then return 9999 end
		return (_A.GetTime() - _A.casttimers[spellid])
	end
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
				return true
			end
		end
		if slot==STOPSLOT then 
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			print(_A.ObjectFacing("player"))
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
	
	function _A.MissileExists(ID, tartar)
		local ID_CORE = spell_ID(ID)
		local missiles = _A.GetMissiles()
		for _, missile in ipairs(missiles) do
			local spellid, _, _, _, caster, _, _, _, target, _, _, _ = unpack(missile) -- prior Legion
			if caster == player.guid and spellid==ID_CORE then
				if tartar == nil or tartar==target then
					return true
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
		if target and target:enemy() and target:alive() and target:spellRange(spell) and target:Infront() and  _A.notimmune(target)  and target:los() then
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
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
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
end
local exeOnUnload = function()
	Listener:Remove("warrior_stuff")
	Listener:Remove("warArms_delaycasts")
	Listener:Remove("warrior_stuff")
end

prot.rot = {
	defstance = function()
		if player:SpellCooldown("Defensive Stance")<player:gcd() then
			if player:stance()~=2 then player:cast("Defensive Stance")
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
			and player:ItemCount(76088) > 0
			and player:ItemUsable(76088)
			and not player:Buff(105696)
			then
			if _A.pull_location=="pvp" then
				player:useitem("Flask of Winter's Bite")
			end
		end
	end,
	
	Pummel = function()
		if player:SpellCooldown("Pummel")==0 then
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
	
	knife_pullcombat = function()
		local target = nil
		if not player:moving() and player:SpellCooldown("Throw")==0 and not _Y.spellqcheck() and player:health()>60 then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if (Obj:spellRange("Taunt") or Obj:spellRange("Throw")) and (not UnitTarget(Obj.guid) or UnitTarget(Obj.guid)~=player.guid)
					and not Obj.isplayer and Obj:los() then
					if Obj:Infront() then
						if Obj:spellrange("Taunt") and player:SpellCooldown("Taunt")==0 then
							return Obj:cast("Taunt")
						end
						if Obj:spellrange("Throw") and not UnitTarget(Obj.guid) then
							return Obj:cast("Throw")
						end
						else return _A.FaceDirection(Obj.guid, true)
					end
				end
			end
		end
	end,
	
	Disruptingshout = function()
		if player:talent("Disrupting Shout") and player:SpellCooldown("Disrupting Shout")==0 then
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
	
	shieldslam = function()
		if  player:SpellCooldown("Shield Slam")<player:gcd() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Shield Slam)")
			if lowestmelee then
				player:cast("Shield Block")
				return lowestmelee:Cast("Shield Slam")
			end
		end
	end,
	
	revenge = function()
		if  player:SpellCooldown("Revenge")<player:gcd() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Revenge)")
			if lowestmelee then
				return lowestmelee:Cast("Revenge")
			end
		end
	end,
	
	devastate = function()
		if player:SpellCooldown("Devastate")<player:gcd() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Devastate)")
			if lowestmelee then
				return lowestmelee:Cast("Devastate")
			end
		end
	end,
	
	thunderclapPVE = function()
		if player:SpellCooldown("Thunder clap")<player:gcd() and player:SpellUsable("Thunder clap")then
			local lowestmelee = Object("lowestEnemyInSpellRange(Devastate)")
			if lowestmelee then
				return player:Cast("Thunder clap")
			end
		end
	end,
	
	shockwaves = function()
		if player:Talent("Shockwave") and player:SpellCooldown("Shockwave")<player:gcd() then
			local bestfacing, bestfacing_number = _Y.bestfacing(90, 10, 0.1)
			local playerfacing = _A.ObjectFacing("player")
			if bestfacing_number>=3 then
				if not _Y.IsFacingEqual(bestfacing, playerfacing, 0.05) then _A.FaceDirection(bestfacing, true)
					else
					return player:Cast("Shockwave")
				end
			end
		end
	end,
	
	heroicstrike = function()
		if (player:rage()>=100 or player:buff("Ultimatum")) and player:SpellCooldown("Heroic Strike")==0 and player:Spellusable("Heroic Strike") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Heroic Strike)")
			if lowestmelee then
				return lowestmelee:Cast("Cleave")
			end
		end
	end,
	
	battleshout = function ()
		if player:SpellCooldown("battle shout")<player:gcd() and player:rage()<=75 then return player:cast("battle shout")
		end
	end,
	
	-- Defs
	diebythesword = function()
		if player:health() <= 50 then
			if player:SpellCooldown("Die by the Sword") == 0
				and not player:buff("Shield Wall")
				then
				player:cast("Die by the Sword")
			end
		end
	end,
	
	shieldwall = function()
		if player:health() <= 30 then
			if player:SpellCooldown("Shield Wall") == 0
				and not player:buff("Die By the Sword")
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
		reflectcheck = false
		if player:SpellCooldown("Spell Reflection")==0 then
			if _A.unitfrozen(player) then player:cast("Spell Reflection") end
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:range()<=25 and Obj:BuffAny("Nature's Swiftness") then
					reflectcheck = true
				end
			end
			if reflectcheck == true then player:cast("Spell Reflection") end
		end
	end,
	
	safeguard_unroot = function()
		local tempTable = {}
		if player:Talent("Safeguard") and player:SpellCooldown("Safeguard")==0 and player:SpellUsable("Safeguard") and player:State("root") then
			for _, fr in pairs(_A.OM:Get('Friendly')) do
				if fr.isplayer and fr:spellRange("Safeguard") then
					if _A.nothealimmune(fr) and fr:los() then
						tempTable[#tempTable+1] = {
							obj = fr,
							range = fr:range(),
							guid = fr.guid
						}
					end
				end
			end
			table.sort( tempTable, function(a,b) return ( a.range < b.range ) end )
			return tempTable[1] and tempTable[1].obj:cast("Safeguard")
		end
	end,
	
	activetrinket = function()
		if player:combat() and player:buff("Surge of Victory") then
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
	
	bloodbath = function()
		if player:combat() and player:buff("Call of Victory") and player:SpellCooldown("Bloodbath")==0 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee.isplayer and lowestmelee:health()>=30
				then 
				return player:cast("Bloodbath")
			end
		end
	end,
	
	reckbanner = function()
		if player:combat() and player:buff("Call of Victory") and player:SpellCooldown("Recklessness")==0 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee.isplayer and lowestmelee:health()>=30
				then 
				player:cast("Skull Banner")
				player:cast("Recklessness")
			end
		end
	end,
	
	bladestorm = function()
		if player:combat() and player:buffany("Bloodbath") and player:SpellCooldown("bladestorm")<player:gcd() then
			return player:cast("Bladestorm")
		end
	end,
	
	victoryrush = function()
		if  player:SpellUsable("Victory Rush") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Victory Rush)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Victory Rush")
			end
		end
	end,
	
	faceafk = function()
		local lowestmelee = Object("lowestEnemyInSpellRange(Shield Slam)")
		if not lowestmelee then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange("Shield Slam") and not Obj:Infront() and Obj:combat() and _A.UnitTarget(Obj.guid)==player.guid and _A.notimmune(Obj) and Obj:los() then
					_A.FaceDirection(Obj.guid, true)
				end
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
	if not player then return end
	_A.numenemiesinfront()
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	-- if _A.buttondelayfunc()  then return true end
	if  player:isCastingAny() then return true end
	if player:iscasting("Throw") then return true end
	-- print(player:iscasting("Throw"))
	-- if player:lostcontrol()  then return end 
	if player:mounted() then return true end
	if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return true end
	-- out of gcd
	if prot.rot.Pummel() then return true end
	if prot.rot.defstance() then return true end
	--
	-- if _Y.spellqcheck() then return true end
	if prot.rot.shockwaves() then return true end
	if prot.rot.battleshout() then return true end
	if prot.rot.thunderclapPVE() then return true end
	if prot.rot.victoryrush() then return true end
	if prot.rot.heroicstrike() then return true end
	if prot.rot.shieldslam() then return true end
	if prot.rot.revenge() then return true end
	if prot.rot.devastate() then return true end
	if not player:moving() and prot.rot.knife_pullcombat() then return true end
	if not player:moving() then prot.rot.faceafk() end
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(73, {
	name = "Youcef's Prot Warrior",
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
