local _, class = UnitClass("player");
if class ~= "MONK" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
_A.pressedbuttonat = 0
_A.buttondelay = 0.6
local STARTSLOT = 97
local STOPSLOT = 104
--
_A.ceeceed = function(unit)
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
_A.hooksecurefunc("UseAction", function(...)
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
		local target = Object("target")
		if target and target:exists() then print(target:creatureType()) end
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
_A.faceunit = function(unit)
	if unit then
		if not unit:infront() then
			_A.FaceDirection(unit.guid, true)
		end
	end
end
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
local keyboardframe = CreateFrame("Frame")
keyboardframe:SetPropagateKeyboardInput(true)
local function testkeys(self, key)
	local player = Object("player")
	-- if key==STARTBUTTON then
	-- _A.pressedbuttonat = 0
	-- if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
	-- _A.Interface:toggleToggle("mastertoggle", true)
	-- _A.print("ON")
	-- end
	-- end
	-- if key==STOPBUTTON then
	-- if player:stance()==1 then
	-- if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
	-- _A.Interface:toggleToggle("mastertoggle", false)
	-- _A.print("OFF")
	-- end
	-- end
	-- end
	if key=="E" then
		local player = Object("player")
		if GetSpecialization()==1 then
			if player:SpellReady("Dizzying Haze") and player:SpellUsable("Dizzying Haze") and _A.GetShapeshiftForm() == 1
				then
				local mouseover = Object("mouseover")
				if mouseover then
					if mouseover:exists() then
						if mouseover:enemy() then
							if mouseover:alive() then
								return mouseover:CastGround("Dizzying Haze")
							end
						end
					end
				end
				return _A.CastGround("Dizzying haze", "cursor")
			end
		end		
		if GetSpecialization()==2 then
			if _A.enoughmana("Healing Sphere") and _A.GetShapeshiftForm() == 1
				then
				local target = Object("target")
				if target then
					if target:exists() then
						if not target:enemy() then
							if target:alive() then
								if target:Distance()<40 then
									_A.pressedbuttonat = _A.GetTime()
									return target:CastGround("Healing Sphere")
								end
							end
						end
					end
				end
				_A.pressedbuttonat = _A.GetTime()
				return _A.CastGround("Healing Sphere", "cursor")
			end
		end
	end
end
keyboardframe:SetScript("OnKeyDown", testkeys)
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
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

local function CalculateHPRAW(t)
	local shield = select(15, _A.UnitDebuff(t, SPELL_SHIELD_LOW)) or select(15, _A.UnitDebuff(t, SPELL_SHIELD_MEDIUM)) or select(15, _A.UnitDebuff(t, SPELL_SHIELD_FULL)) or 0 -- or ((select(15, UnitDebuff(t, SPELL_SHIELD_FULL)))~=nil and UnitHealthMax(t))
	if shield ~= 0 then return shield else return _A.UnitHealth(t) end
end
local function CalculateHPRAWMAX(t)
	return ( _A.UnitHealthMax(t) )
end
local function CalculateHP(t)
	return 100 * ( CalculateHPRAW(t) ) / CalculateHPRAWMAX(t)
end

local function CanHeal(t)
	if t=="player" or _A.UnitIsUnit(t, "player")==1 then return true end
	if (_A.UnitInRange(t)) and _A.UnitCanCooperate("player",t) and not _A.UnitIsEnemy("player",t) 
		and not _A.UnitIsCharmed(t) and not _A.UnitIsDeadOrGhost(t)
		and _A.UnitIsPlayer(t)
		then return true 
	end
	return false
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
--
local MW_LastHealth = {}
local MW_HealthUsedData = {}
--======================================================================
-- MANA, IMPROVE IT BY MAKING IT TIED TO GROUP HP, HIGHER GROUP HP = HIGHER secondsTillOOM, LOW GROUP HP = LOW secondstillOOM


local MW_ManaUsedData = {}
local MW_LastMana = UnitPower("player", 0)
local ManaWatchFrame = CreateFrame("Frame")
local MW_AnalyzedTimespan = 30
local avgDelta = 0
local avgDeltaPercent = 0
local secondsTillOOM = 99999
ManaWatchFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
ManaWatchFrame:RegisterEvent("UNIT_POWER")
ManaWatchFrame:SetScript("OnEvent", function(frame, event, firstArg, secondArg)
	if event == "UNIT_POWER" and secondArg == "MANA" then
		UnitManaHandler(firstArg)
	end
end)
function PlayerManaChanged(Current, Max, Usage)
	local uptime = GetTime()
	local manaUsed = 0
	MW_ManaUsedData[uptime] = Usage
	for Time, Mana in pairs(MW_ManaUsedData) do
		if uptime - Time > MW_AnalyzedTimespan then
			table.remove(MW_ManaUsedData, Time)
			else
			--if Mana<0 then
			manaUsed = manaUsed + Mana
			--end
		end
	end
	avgDelta = -(manaUsed / MW_AnalyzedTimespan)
	avgDeltaPercent = (avgDelta * 100 / Max)
	if avgDelta < 0 then
		secondsTillOOM = Current / (-avgDelta)
		else secondsTillOOM = 99999
	end
end
function UnitManaHandler(unitID)
	if unitID == "player" then
		--local currentMana = (UnitPower(unitID, 0) + (((4*UnitPowerMax(unitID, 0))/100)*uidcount(unitID, 115867)))
		--local currentMana = (((UnitPower(unitID, 0) + (((4*UnitPowerMax(unitID, 0))/100)*uidcount(unitID, 115867)))<UnitPowerMax(unitID, 0)) and (UnitPower(unitID, 0) + (((4*UnitPowerMax(unitID, 0))/100)*uidcount(unitID, 115867)))) or UnitPowerMax(unitID, 0)
		local currentMana = UnitPower(unitID, 0)
		PlayerManaChanged(currentMana, UnitPowerMax(unitID, 0), MW_LastMana - currentMana)
		MW_LastMana = currentMana
	end
end

--====================================================================== table.insert(membersnm,{ Unit = "player", HP = CalculateHPnm("player")})
-- HEALTH
local HealthWatchFrame = CreateFrame("Frame")
local MW_HealthAnalyzedTimespan = 30
HealthWatchFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
HealthWatchFrame:RegisterEvent("RAID_ROSTER_UPDATE")
HealthWatchFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
HealthWatchFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
HealthWatchFrame:RegisterEvent("GROUP_JOINED")
HealthWatchFrame:RegisterEvent("GROUP_LEFT")
HealthWatchFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
HealthWatchFrame:RegisterEvent("RAID_TARGET_UPDATE")
HealthWatchFrame:RegisterEvent("UNIT_OTHER_PARTY_CHANGED") --idk what this is
HealthWatchFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
HealthWatchFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
HealthWatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
HealthWatchFrame:RegisterEvent("RAID_INSTANCE_WELCOME")
HealthWatchFrame:RegisterEvent("PLAYER_LOGIN")
HealthWatchFrame:RegisterEvent("UNIT_POWER")
HealthWatchFrame:RegisterEvent("UNIT_HEALTH")
HealthWatchFrame:SetScript("OnEvent", function(frame, event
	, firstArg
)
if
	event == "RAID_ROSTER_UPDATE" or
	event == "GROUP_ROSTER_UPDATE" or
	event == "PARTY_MEMBERS_CHANGED" or 
	event == "GROUP_JOINED" or
	event == "GROUP_LEFT" or
	event == "PLAYER_FLAGS_CHANGED" or
	event == "RAID_TARGET_UPDATE" or
	event == "UNIT_OTHER_PARTY_CHANGED" or --idk what this is exactly
	event == "PLAYER_ROLES_ASSIGNED" or
	event == "PLAYER_SPECIALIZATION_CHANGED" or
	event == "PLAYER_ENTERING_WORLD" or
	event == "RAID_INSTANCE_WELCOME" or
	event == "PLAYER_LOGIN"
	then
	local grouptype = (pull_location()=="arena") and "party" or IsInRaid() and "raid" or "party"
	local groupnumber = ((pull_location()=="arena") or (IsInRaid()==false)) and (GetNumGroupMembers()-1) or GetNumGroupMembers()
	if groupnumber>0 then
		-- building initial health values to work off of
		for i=1, groupnumber do
			--
			MW_LastHealth[grouptype..i] = (CalculateHPRAW(grouptype..i)) or 0 -- UnitHealth
			if MW_HealthUsedData[grouptype..i] == nil then 
				MW_HealthUsedData[grouptype..i] = {}
				MW_HealthUsedData[grouptype..i].t = {} 
			end
		end
	end
	-- cleaning/deleting old data
	for v = 1, 40 do
		for k in pairs(MW_LastHealth) do
			if pull_location()=="arena" then
				if k=="raid"..v then -- arena uses PARTY, so clearing raid stuff from table
					MW_LastHealth[k]=nil
					MW_HealthUsedData[k]=nil
				end 
				elseif IsInRaid() then -- Raid uses RAID, so clearing party stuff from table
				if k=="party"..v then
					MW_LastHealth[k]=nil
					MW_HealthUsedData[k]=nil
				end
				elseif IsInGroup() then -- group uses party, so clearing raid stuff
				if k=="raid"..v then
					MW_LastHealth[k]=nil
					MW_HealthUsedData[k]=nil
				end
				elseif k=="raid"..v or k=="party"..v then -- if not in party or not in raid, clear everything, leave only player
				MW_LastHealth[k]=nil
				MW_HealthUsedData[k]=nil
			end
		end
	end
	
	-- player management
	if (pull_location()=="arena") or (not IsInRaid()) then
		if MW_LastHealth["player"]==nil then 
			MW_LastHealth["player"]=(CalculateHPRAW("player"))
			if MW_HealthUsedData["player"] == nil then 
				MW_HealthUsedData["player"] = {}
				MW_HealthUsedData["player"].t = {} 
			end
		end
		else MW_LastHealth["player"]=nil
		MW_HealthUsedData["player"]=nil
	end
end
--=
if event == "UNIT_HEALTH" then
	for k in pairs(MW_LastHealth) do
		if firstArg==k then
			UnitHealthHandler(firstArg)
		end
	end
end
end)
function PlayerHealthChanged(unit, Current, Max, Usage)
	local uptime = GetTime()
	MW_HealthUsedData[unit].healthUsed = 0
	MW_HealthUsedData[unit].t[uptime] = Usage
	for Time, Health in pairs(MW_HealthUsedData[unit].t) do
		if uptime - Time > MW_HealthAnalyzedTimespan then
			table.remove(MW_HealthUsedData[unit].t, Time)
			else
			--if Health<0 then
			MW_HealthUsedData[unit].healthUsed = MW_HealthUsedData[unit].healthUsed + Health
			--end
		end
	end
	MW_HealthUsedData[unit].avgHDelta = (MW_HealthUsedData[unit].healthUsed / MW_HealthAnalyzedTimespan)
	MW_HealthUsedData[unit].avgHDeltaPercent = (MW_HealthUsedData[unit].avgHDelta * 100)/Max
end
function UnitHealthHandler(unitID)
	local currentHealth = (CalculateHPRAW(unitID))
	if MW_LastHealth[unitID]~=currentHealth then -- this can introduce slight inaccuracies! but I think it's more consistant
		PlayerHealthChanged(unitID, currentHealth, CalculateHPRAWMAX(unitID), currentHealth - MW_LastHealth[unitID])
	end
	MW_LastHealth[unitID] = currentHealth -- this makes it 0 sometimes...
end

--======================================================================
local function averageHPv2()
	local sum = 0
	local num = 0
	if next(MW_HealthUsedData)==nil then
		return 0
		else
		for k in pairs(MW_HealthUsedData) do
			if MW_HealthUsedData[k]~=nil then
				if next(MW_HealthUsedData[k])~=nil then
					if MW_HealthUsedData[k].avgHDeltaPercent~=nil then 	
						--if ((CalculateHPRAW(k))<CalculateHPRAWMAX(k) or pull_location=="raid" or pull_location=="party" or pull_location()=="none")  then -- not accounting full hp
						if CalculateHPRAW(k)<CalculateHPRAWMAX(k) then -- this LOWERS avg hp (only accounting people missing hp) but there has to be a better way
							--if MW_HealthUsedData[k].avgHDeltaPercent<0 then -- only accounting for people that are losing HP
							if CanHeal(k) then
								num = num + 1
								sum = sum + MW_HealthUsedData[k].avgHDeltaPercent
								return sum/num
							end
						end
					end
				end
			end
		end
	end
	return 0
end

local function healthdelapercent(uuu)
	if next(MW_HealthUsedData)==nil then
		return 0
		else
		for k in pairs(MW_HealthUsedData) do
			if UnitIsUnit(uuu, k)==1 then
				if MW_HealthUsedData[k]~=nil then
					if next(MW_HealthUsedData[k])~=nil then
						if MW_HealthUsedData[k].avgHDelta~=nil then 	
							return MW_HealthUsedData[k].avgHDelta
						end
					end
				end
			end
		end
	end
	return 0
end

function _A.manaengine() -- make it so it's tied with group hp
	--if modifier_alt() then return true end
	if
		--((averageHPv2())<0) and 
		(avgDeltaPercent>=(averageHPv2())) --and secondsTillOOM>=15
		-- -1 >= -2
		then return true
	end
	return false
end
_A.DSL:Register('canafford', function()
    return _A.manaengine()
end)
_A.DSL:Register('chifix', function()
    return _A.UnitPower("player", 12)
end)
_A.DSL:Register('chifixmax', function()
    return _A.UnitPowerMax("player", 12)
end)

local function unitDD(unit)
	local UnitExists = UnitExists
	local UnitGUID = UnitGUID
	if UnitExists(unit) then
		return tonumber((UnitGUID(unit)):sub(-13, -9), 16)
		else return -1
	end
end

local bossestoavoid = { 69427, 68065, 69017, 69465, 71454 }
local function donotdispell()
	if unitDD("boss1") == nil then
		return true
		else
		for i = 1, #bossestoavoid do
			if unitDD("boss1") == bossestoavoid[i] then
				return false
			end
		end
	end
	return true
end
_A.DSL:Register('dispellcheck', function()
    return donotdispell()
end)

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

local function dispellablestuff(unit)
for i = 1, 40 do
if 	(select(5,UnitDebuff(unit,i)))=="Magic" or (select(5,UnitDebuff(unit,i)))=="Poison" or (select(5,UnitDebuff(unit,i)))=="Disease" then
return true
end
end
return false
end

_A.DSL:Register('dispellablefr', function(unit)
return dispellablestuff(unit)
end)

_A.DSL:Register('unitisimmobile', function()
return GetUnitSpeed(unit)==0 
end)

function _A.isthishuman(unit)
if _A.UnitIsPlayer(unit)==1
then return true
end
return false
end

immunebuffs = {
"Deterrence",
"Hand of Protection",
"Dematerialize",
-- "Smoke Bomb",
"Cloak of Shadows",
"Ice Block",
"Divine Shield"
}
immunedebuffs = {
"Cyclone"
-- "Smoke Bomb"
}

healimmunebuffs = {
}
healimmunedebuffs = {
"Cyclone"
}

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


function _A.nothealimmune(unit)
local player = Object("player")
if unit then 
if unit:DebuffAny("Cyclone") then return false end
end
return true
end
--
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



_A.FakeUnits:Add('soothingmisttarget', function()
for _, Obj in pairs(_A.OM:Get('Roster')) do
if Obj:Buff("Rejuvenation")then
return Obj.guid
end
end
end)

_A.FakeUnits:Add('detoxtarget', function()
for _, Obj in pairs(_A.OM:Get('Roster')) do
if Obj:Range() < 40 then
if Obj:los() and _A.UnitCanCooperate("player",Obj.guid) then
if Obj.isplayer then
if Obj:DebuffType("Magic") or Obj:DebuffType("Poison") or Obj:DebuffType("Disease") then
return Obj.guid
end				
end
end
end
end
end)


_A.DSL:Register('UnitCastID', function(t)
if t=="player" then
t = U.playerGUID
end
return _A.UnitCastID(t) -- castid, channelid, guid, pointer
end)


_A.FakeUnits:Add('stuntarget', function()
for _, Obj in pairs(_A.OM:Get('Enemy')) do
if Obj:UnitCastID() then
if Obj:IscastingAnySpell() then
if not Obj:immune("all") then
if Obj:range()<5 then
if Obj:los() then
return Obj.guid
end
end
end
end
end
end
end)

_A.FakeUnits:Add('oxwavetarget', function()
for _, Obj in pairs(_A.OM:Get('Enemy')) do
if Obj:UnitCastID() then
if Obj:IscastingAnySpell() then
if Obj:Infront() then
if not Obj:immune("all") then
if Obj:range()<5 then
if Obj:los() then
return Obj.guid
end
end
end
end
end
end
end
end)

_A.FakeUnits:Add('paralysistarget', function()
for _, Obj in pairs(_A.OM:Get('Enemy')) do
if Obj:UnitCastID() then
if Obj:IscastingAnySpell() then
if Obj:range()<35 then
if Obj:infront() then
if not Obj:immune("all") then
if Obj:los() then
return Obj.guid
end
end
end
end
end
end
end
end)	

_A.FakeUnits:Add('kicktarget', function()
for _, Obj in pairs(_A.OM:Get('Enemy')) do
if Obj:UnitCastID() then
if Obj:caninterrupt() then
if Obj:range()<4 then
if not Obj:immune("all") then
if Obj:castsecond() < 0.3 or Obj:chanpercent()<=90 then
if Obj:Infront() then
if Obj:los() then
return Obj.guid
end
end
end
end
end
end
end
end
end)					


function _A.enemiesinrangeofspin()
local tempnumber = 0
for _, Obj in pairs(_A.OM:Get('Enemy')) do
--if Obj:los() then
if Obj:range()<=8 and Obj:alive() then
if not Obj:immune("all") then
tempnumber = tempnumber + 1
end
end
--end
end
return tempnumber
end

function _A.alliesinrangeofspin()
local tempnumber = 0
for _, Obj in pairs(_A.OM:Get('Friendly')) do
--if Obj:los() then
if Obj:range()<=8 then
if not Obj:immune("all") then
tempnumber = tempnumber + 1
end
end
--end
end
return tempnumber
end

_A.DSL:Register('spinnumber', function()
return _A.enemiesinrangeofspin()
end)

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

_A.DSL:Register('kegcheck', function()
return (power("player")+(manaregen()*cdRemains(121253)))>=80
end)

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


_A.FakeUnits:Add('mostTargetedRosterPVP', function()
local targets = {}
local most, mostGuid = 0
for _, enemy in pairs(_A.OM:Get('Enemy')) do
if enemy then
if enemy.isplayer then
local tguid = UnitTarget(enemy.guid)
if tguid then
targets[tguid] = targets[tguid] and targets[tguid] + 1 or 1
end
end
end
end
for guid, count in pairs(targets) do
if count > most then
most = count
mostGuid = guid
end
end
return mostGuid
end)



_A.FakeUnits:Add('dispellunit', function(num)
local tempTable = {}
for _, roster in pairs(_A.OM:Get('Roster')) do
if roster 
and roster.player then
-- and roster.player or roster:ispet() then
if roster:DebuffType("Magic") or roster:DebuffType("Disease") or roster:DebuffType("Poison") then
if _A.notimmune(roster) and roster:los() then
tempTable[#tempTable+1] = {
guid = roster.guid,
health = roster:Health()
}
end
end
end
end
if #tempTable > 1 then
table.sort(tempTable, function(a, b) return a.health < b.health end)
end
return tempTable[num] and tempTable[num].guid
end)

-- _A.FakeUnits:Add('lowestall', function(num)
-- local tempTable = {}
-- for _, roster in pairs(_A.OM:Get('Friendly')) do
-- if roster 
-- and roster.player then
-- tempTable[#tempTable+1] = {
-- guid = roster.guid,
-- health = roster:Health()
-- }
-- end
-- end
-- if #tempTable > 1 then
-- table.sort(tempTable, function(a, b) return a.health < b.health end)
-- end
-- return tempTable[num] and tempTable[num].guid
-- end)


local badhealdebuffs = 
{"Parasitic Growth",
"Dissonance Field"
}
_A.FakeUnits:Add('lowestall', function()
local lowestHP, lowestHPguid = 100
local location = pull_location()
for _, fr in pairs(_A.OM:Get('Friendly')) do
-- if fr.isplayer then
if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (location=="arena" and fr:ispet()) then
if _A.nothealimmune(fr) then
for _,v in ipairs(badhealdebuffs) do
if not fr:DebuffAny(v) then
local hp = fr:health()
if hp < lowestHP then
lowestHP = hp
lowestHPguid = fr.guid
end
end
end
end
end
end
return lowestHPguid
end)

--[[_A.FakeUnits:Add('targetingme', function()
for _, enemy in pairs(_A.OM:Get('Enemy')) do
if enemy then
if _A.UnitIsPlayer(enemy.guid) then
local tguid = UnitTarget(enemy.guid)
if tguid then
targets[tguid] = targets[tguid] and targets[tguid] + 1 or 1
end
end
end
end
for guid, count in pairs(targets) do
if count > most then
most = count
mostGuid = guid
end
end
return mostGuid
end)--]]


