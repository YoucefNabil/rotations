local _, class = UnitClass("player");
if class ~= "WARLOCK" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
_A.pressedbuttonat = 0
_A.buttondelay = 0.5
_A.STARTSLOT = 1
_A.STOPSLOT = 8
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
	if player then
		-- print(slot)
		if slot ~= _A.STARTSLOT and slot ~= _A.STOPSLOT and clickType~=nil
			then
			Type, id, subType = _A.GetActionInfo(slot)
			
			if Type == "spell" or Type == "macro" -- remove macro?
				then
				_A.pressedbuttonat = _A.GetTime() 
			end
		end
	end
	if slot==_A.STARTSLOT then 
		_A.pressedbuttonat = 0
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
			_A.Interface:toggleToggle("mastertoggle", true)
			_A.print("ON")
			return true
		end
	end
	if slot==_A.STOPSLOT then
		-- local target = Object("target")
		-- if target and target:exists() then print(target:creatureType()) end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
			_A.Interface:toggleToggle("mastertoggle", false)
			_A.print("OFF")
			return true
		end
	end
end)
_A.buttondelayfunc = function()
	if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
	return false
end
-------------------------------------------------------
-------------------------------------------------------
local types_i_dont_need = {
	[0] = true, -- unknown
	[10] = true, -- not specified
	[11] = true, -- totems
	[12] = true, -- non combat pets
	[13] = true -- gas cloud
}
function _A.attackable(unit)
	if _A.pull_location and _A.pull_location ~= "arena" and _A.pull_location ~= "pvp" then return true end
	if unit then 
		if unit:CreatureType()==nil then return false end
		if types_i_dont_need[unit:CreatureType()] then return false end
		return true
	end	
end	
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
immunebuffs = {
	"Deterrence",
	"Anti-Magic Shell",
	"Hand of Protection",
	"Spell Reflection",
	"Mass Spell Reflection",
	"Dematerialize",
	"Smoke Bomb",
	"Cloak of Shadows",
	"Ice Block",
	"Divine Shield"
}
immunedebuffs = {
	"Cyclone",
	"Smoke Bomb"
}

function _A.notimmune(unit) -- needs to be object
	if unit then 
		if unit:immune("all") then return false end
		for _,v in ipairs(immunebuffs) do
			if unit:BuffAny(v) then return false end
		end
		for _,v in ipairs(immunedebuffs) do
			if unit:DebuffAny(v) then return false end
		end
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

function _A.ceeceed(unit)
	if unit and unit:State("fear || sleep || charm || disorient || incapacitate || misc || stun")
		then return true
	end
	return false
end

function _A.breakableceecee(unit)
	if unit and unit:State("fear || sleep || charm || disorient || incapacitate")
		then return true
	end
	return false
end

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
		if Obj.isplayer  and Obj:spellRange(spell) and Obj:Infront() and _A.isthisahealer(Obj) and _A.notimmune(Obj) and Obj:los() then
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

_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
	local tempTable = {}
	local target = Object("target")
	if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.attackable and _A.notimmune(target)  and target:los() then
		return target and target.guid
	end
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:spellRange(spell) and Obj:Infront() and _A.notimmune(Obj) and Obj:los() then
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
end
)
_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
	local tempTable = {}
	for _, Obj in pairs(_A.OM:Get('Enemy')) do
		if Obj:spellRange(spell) and Obj:Infront() and  _A.notimmune(Obj) and Obj:los() then
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
end
)
--========================
--========================
--========================
--========================
--========================
--========================
--========================
--========================
_A.FakeUnits:Add('mostgroupedenemy', function(num, spell_range_threshhold)
    local tempTable = {}
    local most, mostGuid = 0
    local spell, range, threshhold = _A.StrExplode(spell_range_threshhold)
    if not spell then return end
    range = tonumber(range) or 10
    threshhold = tonumber(threshhold) or 1
    for _, Obj in pairs(_A.OM:Get('Enemy')) do
        if Obj:spellRange(spell) and  Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
            tempTable[Obj.guid] = 1
            for _, Obj2 in pairs(_A.OM:Get('Enemy')) do
                if Obj.guid~=Obj2.guid and Obj:rangefrom(Obj2)<=range and _A.attackable(Obj2) and _A.notimmune(Obj2)  and Obj2:los() then
                    tempTable[Obj.guid] = tempTable[Obj.guid] + 1
				end
			end
		end
	end
    for guid, count in pairs(tempTable) do
        if count > most then
            most = count
            mostGuid = guid
		end
	end
    if most>=threshhold then return mostGuid end
end
)

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

function _A.myscore()
	local ap = GetSpellBonusDamage(6) -- shadowdamage
	local mastery = GetCombatRating(26)
	local crit = GetCombatRating(9)
	local haste = GetCombatRating(18)
	return (ap + mastery + crit + haste)
end

-- CreatureType = {
-- Unknown = 0,
-- Beast = 1,
-- Dragon = 2,
-- Demon = 3,
-- Elemental = 4,
-- Giant = 5,
-- Undead = 6,
-- Humanoid = 7,
-- Critter = 8,
-- Mechanical = 9,
-- NotSpecified = 10,
-- Totem = 11,
-- NonCombatPet = 12,
-- GasCloud = 13,
-- }