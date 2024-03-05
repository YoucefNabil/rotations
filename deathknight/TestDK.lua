local _, class = UnitClass("player");
if class ~= "DEATHKNIGHT" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
_A.pressedbuttonat = 0
_A.buttondelay = 0.5
_A.STARTSLOT = 1
_A.STOPSLOT = 8
_A.GRABKEY = "R"
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
--
_A.hooksecurefunc("UseAction", function(...)
	local slot, target, clickType = ...
	local Type, id, subType, spellID
	--print(slot)
	local player = Object("player")
	if slot ~= _A.STARTSLOT and slot ~= _A.STOPSLOT and clickType~=nil
		then
		Type, id, subType = _A.GetActionInfo(slot)
		
		if Type == "spell" or Type == "macro" -- remove macro?
			then
			if player then
				if (id == 48263 and player:Stance() == 1) or (id == 48266 and player:Stance() == 2) or (id == 48265 and player:Stance() == 3) -- stances
					then return 
					else
					_A.pressedbuttonat = _A.GetTime() 
				end
			end
		end
	end
	if slot==_A.STARTSLOT then 
		_A.pressedbuttonat = 0
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
			_A.Interface:toggleToggle("mastertoggle", true)
			_A.print("ON")
		end
	end
	if slot==_A.STOPSLOT then 
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
			_A.Interface:toggleToggle("mastertoggle", false)
			_A.print("OFF")
		end
	end
end)
_A.buttondelayfunc = function()
	if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
	return false
end
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
function _A.isthishuman(unit)
	if _A.UnitIsPlayer(unit)==1
		then return true
	end
	return false
end
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
function _A.IsPStr() --temporary method to get strafing.
	local player = Object("player")
	local isMoving = player:Moving()
	local moveLeft = _A.IsKeyDown("a")
	local moveRight = _A.IsKeyDown("z")
	if isMoving and moveLeft then
		return "left"
		elseif isMoving and moveRight then
		return "right"
		else
		return "none"
	end
end
function _A.pSpeed(unit, maxDistance)
	local player = Object("player")
	local x, y, z = _A.ObjectPosition(unit)
	local facing = _A.ObjectFacing(unit)
	local speed = _A.GetUnitSpeed(unit)
	local distance
	if speed <= 4.5 then
		distance = 1.5
		else
		distance = math.min(maxDistance, speed - 4.5)
	end
	-- Check strafing only if the unit is the player currently because can't get apep's lua functions to check for strafing
	if unit == player then
		local isMoving = _A.UnitMoving(unit)
		if not isMoving then
			return x, y, z
		end
		local strafeDirection = _A.IsPStr()
		if strafeDirection == "left" then
			facing = facing + math.pi / 2
			elseif strafeDirection == "right" then
			facing = facing - math.pi / 2
		end
	end
	local newX = x + distance * math.cos(facing)
	local newY = y + distance * math.sin(facing)
	return newX, newY, z
end
function _A.CastPredictedPos(unit, spell, distance)
	local player = Object("player")
	local px, py, pz = _A.pSpeed(unit, distance)
	_A.CastSpellByName(spell)
	if player:SpellIsTargeting() then
		_A.ClickPosition(px, py, pz)
		_A.SpellStopTargeting()
	end
end
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
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

function _A.powerpercent()
	local currmana = UnitPower("player", 0)
	local maxmana = UnitPowerMax("player", 0)
	return ((currmana * 100) / maxmana)
end
local next = next

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

_A.DSL:Register('caninterrupt', function(unit)
	return interruptable(unit)
end)
--
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

_A.DSL:Register('castsecond', function(unit)
	return castsecond(unit)
end)



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

_A.DSL:Register('chanpercent', function(unit)
	return chanpercent(unit)
end)

_A.DSL:Register('unitisimmobile', function()
	return GetUnitSpeed(unit)==0 
end)

-- Lowest enemy in range

function _A.notimmune(unit) -- needs to be object
	if unit then 
		if not unit:immune("all") then -- add saps and fears?
			if not unit:DebuffAny("Cyclone")
				and not unit:BuffAny("Deterrence") 
				and not unit:BuffAny("Hand of Protection")
				and not unit:BuffAny("Ice Block")
				and not unit:BuffAny("Divine Shield") then
				return true
			end
		end
	end
	return false
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

local healerspecid = {
	[105]=true,
	[270]=true,
	[65]=true,
	[257]=true,
	[256]=true,
	[102]=true,
	[264]=true
}

function _A.isthisahealer(unit)
	if unit then
		if healerspecid[_A.UnitSpec(unit.guid)] then
			return true
		end
	end
	return false
end

function _A.istereahealer()
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:range()<=40 then
			if healerspecid[_A.UnitSpec(Obj.guid)] then
				return true
			end
		end
	end
	return false
end

_A.FakeUnits:Add('EnemyHealer', function(num, spell)
	local tempTable = {}
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:spellRange(spell) and _A.isthisahealer(Obj) and _A.UnitIsPlayer(Obj.guid)==1  and _A.notimmune(Obj)  and not Obj:immune("all") and  Obj:Infront() and Obj:los() then
			tempTable[#tempTable+1] = {
				guid = Obj.guid,
				health = Obj:health()
			}
		end
	end
	if #tempTable>=1 then
		table.sort( tempTable, function(a,b) return a.health < b.health end )
	end
	return tempTable[num] and tempTable[num].guid
end)


--
_A.FakeUnits:Add('lowestEnemyInRange', function(num, range_target)
	local tempTable = {}
	local ttt = Object("target")
	local range, target = _A.StrExplode(range_target)
	range = tonumber(range) or 40
	target = target or "player"
	if ttt and  ttt:enemy() and ttt:rangefrom(target)<=range and _A.notimmune(ttt) and ttt:Infront() and ttt:los() then
		return ttt and ttt.guid
	end
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:rangefrom(target)<=range and _A.notimmune(Obj) and Obj:Infront() and Obj:los() then
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
		if Obj:rangefrom(target)<=range  and  _A.notimmune(Obj) and Obj:Infront() and Obj:los() then
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
	if target and target:enemy() and target:spellRange(spell) and  _A.notimmune(target) and target:Infront() and target:los() then
		return target and target.guid
	end
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:spellRange(spell) and _A.notimmune(Obj) and  Obj:Infront() and Obj:los() then
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
		if Obj:spellRange(spell) and _A.notimmune(Obj) and Obj:Infront()  and Obj:los() then
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
_A.DSL:Register('UnitCastID', function(t)
	if t=="player" then
		t = U.playerGUID
	end
	return _A.UnitCastID(t) -- castid, channelid, guid, pointer
end)	



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

function _A.usablelite(spellid)
	if spellcost(spellid)~=nil then
		if power("player")>=spellcost(spellid)
			then return true
			else return false
		end
		else return false
	end
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


local keyboardframe = CreateFrame("Frame")
keyboardframe:SetPropagateKeyboardInput(true)
local function testkeys(self, key)
	if key==_A.GRABKEY then
		local player = Object("player")
		local target = Object("target")
		if player and player:SpellReady("Death Grip") and player:SpellUsable("Death Grip")
			then
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
	end
end
keyboardframe:SetScript("OnKeyDown", testkeys)