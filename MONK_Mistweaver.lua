local _,class = UnitClass("player")
if class~="MONK" then return end
local HarmonyMedia, _A, Harmony = ...
local DSL = function(api) return _A.DSL:Get(api) end
local player
local enteredworldat
local bossestoavoid = { 69427, 68065, 69017, 69465, 71454 }
local MyAddon = "niceAddon"
_A.RegisterAddonMessagePrefix(MyAddon)
local CallWowApi = _A.CallWowApi
local ClickToMove = _A.ClickToMove
local ObjectPosition = _A.ObjectPosition
local CalculatePath = _A.CalculatePath
local FaceDirection = _A.FaceDirection
local UnitCanCooperate, UnitHealthMax, GetTime, UnitIsPlayer, string_find = UnitCanCooperate, UnitHealthMax, GetTime, UnitIsPlayer, string.find
local manamodifier = 0.5
local function blank()
end
local function runthese(...)
	local runtable = {...}
	return function()
		for i=1, #runtable do
			if runtable[i]() then
				break
			end
		end
	end
end
local next = next
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
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
local SPELL_SHIELD_LOW    = GetSpellInfo(142863)
local SPELL_SHIELD_MEDIUM = GetSpellInfo(142864)
local SPELL_SHIELD_FULL   = GetSpellInfo(142865)
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
local blacklist = {
}
--
--
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
local GUI = {
}
_A.Listener:Add("Entering_timerPLZ2", "PLAYER_ENTERING_WORLD", function(event)
	enteredworldat = _A.GetTime()
	local stuffsds = pull_location()
	_A.pull_location = stuffsds
end
)
_A.pull_location = _A.pull_location or pull_location()
enteredworldat = enteredworldat or _A.GetTime()
local exeOnLoad = function()
	_A.DSL:Register('healthmonk', function(unit)
		return CalculateHP(unit)
	end)
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .2 + _A.latency
	_A.pressedbuttonat = 0
	_A.buttondelay = 0.6
	local STARTSLOT = 97
	local STOPSLOT = 104
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
	function _A.tbltostr(tbl)
		local result = {}
		for _, value in ipairs(tbl) do
			table.insert(result, tostring(value))
		end
		return table.concat(result, " || ")
	end
	function _A.dontbreakcc(unit)
		if unit then
			if unit:state("charm || sleep || disorient || fear || incapacitate || misc") then return false end
		end
		return true
	end
	function _A.groundpositiondetail(x,y,z)
		local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
		local los, cx, cy, cz = _A.TraceLine(x, y, z+5, x, y, z-200, flags)
		if not los then
			return cx, cy, cz
		end
	end
	
	_A.hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		player = player or Object("player")
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
			-- _A.print(_A.groundposition(player))
			-- TEST STUFF
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
	-----------------------------------
	-----------------------------------
	-----------------------------------	-----------------------------------
	-----------------------------------
	function _A.guid_distance(unit1, unit2)
		local x1, y1, z1 = unit1 and _A.ObjectPosition(unit1)
		local x2, y2, z2 = unit2 and _A.ObjectPosition(unit2)
		if x1 and x2 and y1 and y2 and z1 and z2 then return _A.GetDistanceBetweenPositions(x1,y1,z1,x2,y2,z2)
			else return 9999
		end
	end
	function _A.someoneislow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer then
				if Obj:Health()<55 then
					return true
				end
			end
		end
		return false
	end
	-----------------------------------	-----------------------------------
	-----------------------------------
	-----------------------------------
	
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
	
	-- function _A.notimmune(unit) -- needs to be object
	-- if unit then 
	-- if unit:immune("all") then return false end
	-- end
	-- for _,v in ipairs(immunebuffs) do
	-- if unit:BuffAny(v) then return false end
	-- end
	-- for _,v in ipairs(immunedebuffs) do
	-- if unit:DebuffAny(v) then return false end
	-- end
	-- return true
	-- end
	
	function _A.notimmune(unit) -- needs to be object
		if unit then 
			if unit:immune("all") then return false end
			if unit:BuffAny(_A.tbltostr(immunebuffs)) then return false end
			if unit:DebuffAny(_A.tbltostr(immunedebuffs)) then return false end
		end
		return true
	end
	
	
	
	function _A.nothealimmune(unit)
		player = Object("player")
		if unit then 
			if unit:DebuffAny("Cyclone || Spirit of Redemption || Beast of Nightmares") then return false end
			if unit:BuffAny("Spirit of Redemption") then return false end
		end
		return true
	end 
	-----------------------------------
	-----------------------------------
	local function fall()
		player = player or Object("player")
		local px, py, pz = _A.ObjectPosition("player")
		local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
		if player:Falling() then
			local  los, cx, cy, cz = _A.TraceLine(px, py, pz+5, px, py, pz - 200, flags)
			if not los then print("Distance to ground ", pz - cz)
				else print("interception not found within the specified distance.")
			end
		end
	end
	-----------------------------------
	_A.buttondelayfunc = function()
		if player:stance()~=1  then return false end
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
		return false
	end
	_A.FakeUnits:Add('lowestall', function(num, spell)
		local tempTable = {}
		local location = _A.pull_location
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (location=="arena" and fr:ispet()) then
				if _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable+1] = {
						HP = fr:healthmonk(),
						guid = fr.guid
					}
				end
			end
		end
		table.sort( tempTable, function(a,b) return ( a.HP < b.HP ) end )
		return tempTable[1] and tempTable[1].guid
	end)
	_A.FakeUnits:Add('lowestallNOHOT', function(num, spell)
		local tempTable = {}
		local location = pull_location()
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (location=="arena" and fr:ispet()) then
				if not fr:Buff(132120) 
					and _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable+1] = {
						HP = fr:healthmonk(),
						guid = fr.guid
					}
				end
			end
		end
		table.sort( tempTable, function(a,b) return ( a.HP < b.HP ) end )
		return tempTable[1] and tempTable[1].guid
	end)
	_A.FakeUnits:Add('lowestEnemyInSpellRangeMINIMAL', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _A.notimmune(Obj) and _A.dontbreakcc(Obj) then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:healthmonk(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end)
	_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
		local tempTable = {}
		local target = Object("target")
		-- if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.dontbreakcc(target) and _A.notimmune(target)  and target:los() then
		if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.notimmune(target) and _A.dontbreakcc(target) and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			-- if Obj:spellRange(spell) and _A.dontbreakcc(Obj) and _A.notimmune(Obj) and  Obj:Infront() and Obj:los() then
			if Obj:spellRange(spell) and _A.notimmune(Obj) and  Obj:Infront() and _A.dontbreakcc(Obj) and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:healthmonk(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end)
	_A.FakeUnits:Add('mostTargetedRosterPVP', function()
		local targets = {}
		local most, mostGuid = 0
		for _, enemy in pairs(_A.OM:Get('Enemy')) do
			if enemy then
				if enemy.isplayer and not enemy:BuffAny("Bladestorm || Divine Shield || Deterrence") then
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
	_A.SMguid = nil
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts_Monk_and_misc", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		-- Testing
		-- if subevent == "SWING_DAMAGE" or subevent == "RANGE_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "SPELL_BUILDING_DAMAGE" or subevent == "ENVIRONMENTAL_DAMAGE"  then
		-- print(subevent.." "..amount) -- too much voodoo
		-- end
		if guidsrc == UnitGUID("player") then
			-- print(subevent)
			-- Delay Cast Function
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[idd] = _A.GetTime()
			end
			-- soothing mist guid capture
			if idd == 115175 then
				if subevent == "SPELL_CAST_SUCCESS" then 
					_A.SMguid = guiddest
				end
				if subevent == "SPELL_AURA_REMOVED" then
					-- print("nilled")
					_A.SMguid = nil
				end
			end
			-- thunder focus tea capture
			if subevent == "SPELL_AURA_REMOVED" then
				if idd == 116680 then
					_A.thunderbrewremovedat = GetTime()
					-- print("RE MO V E D")
				end
			end
		end
	end)
	function _A.castdelay(idd, delay)
		if delay == nil then return true end
		if _A.casttimers[idd]==nil then return true end
		return (_A.GetTime() - _A.casttimers[idd])>=delay
	end
	
	-- ====
	local MW_HealthUsedData = {}
	local MW_LastHealth = {}
	local startedcombat_at
	local minimum_MW_HealthAnalyzedTimespan = 30
	local MW_HealthAnalyzedTimespan = minimum_MW_HealthAnalyzedTimespan
	--====================================================== Testing
	_A.Listener:Add("COMBAT_TRACK", {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, function(event, firstArg, secondArg)
		if event == "PLAYER_REGEN_DISABLED" then
			startedcombat_at = GetTime()
		end
		if event == "PLAYER_REGEN_ENABLED" then
			MW_HealthAnalyzedTimespan = minimum_MW_HealthAnalyzedTimespan
		end
	end)
	_A.Listener:Add("Health_change_track", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if string_find(subevent,"_DAMAGE") or string_find(subevent,"_HEAL") then -- does this work with absorbs? I don't remember testing this
			if UnitIsPlayer(guiddest) then
				-- all subevent susceptible of causing health changes
				-- print("picked up")
				if MW_HealthUsedData[guiddest]==nil then
					MW_HealthUsedData[guiddest]={}
					MW_HealthUsedData[guiddest].t={}
					MW_LastHealth[guiddest]=CalculateHPRAW(guiddest)
				end
				UnitHealthHandler(guiddest)
				-- print(subevent)
			end
		end
	end
	)
	--
	function UnitHealthHandler(unitID)
		local currentHealth = CalculateHPRAW(unitID)
		if MW_LastHealth[unitID] and MW_LastHealth[unitID]~=currentHealth then -- needed otherwise will just feed the next function zeroes
			PlayerHealthChanged(unitID, currentHealth, UnitHealthMax(unitID), currentHealth - MW_LastHealth[unitID])
		end
		MW_LastHealth[unitID] = currentHealth --
	end
	function PlayerHealthChanged(unit, Current, Max, Usage)
		local uptime = GetTime()
		-- Variable MW_HealthAnalyzedTimespan
		if startedcombat_at and (uptime - startedcombat_at)>minimum_MW_HealthAnalyzedTimespan then
			MW_HealthAnalyzedTimespan = (uptime - startedcombat_at)
			elseif MW_HealthAnalyzedTimespan ~= minimum_MW_HealthAnalyzedTimespan then MW_HealthAnalyzedTimespan = minimum_MW_HealthAnalyzedTimespan
		end
		-- Fixed
		-- if MW_HealthAnalyzedTimespan ~= minimum_MW_HealthAnalyzedTimespan then MW_HealthAnalyzedTimespan = minimum_MW_HealthAnalyzedTimespan end
		--
		if MW_HealthUsedData[unit] then
			MW_HealthUsedData[unit].healthUsed = 0
			MW_HealthUsedData[unit].healthnegative = 0
			MW_HealthUsedData[unit].healthpositive = 0
			MW_HealthUsedData[unit].t[uptime] = Usage
			for Time, Health in pairs(MW_HealthUsedData[unit].t) do
				if uptime - Time > MW_HealthAnalyzedTimespan then
					table.remove(MW_HealthUsedData[unit].t, Time)
					else
					MW_HealthUsedData[unit].healthUsed = MW_HealthUsedData[unit].healthUsed + Health			
					if Health<0 then
						MW_HealthUsedData[unit].healthnegative = MW_HealthUsedData[unit].healthnegative + Health
						else MW_HealthUsedData[unit].healthpositive = MW_HealthUsedData[unit].healthpositive + Health
					end
				end
			end
			MW_HealthUsedData[unit].avgHDelta = (MW_HealthUsedData[unit].healthUsed / MW_HealthAnalyzedTimespan)
			MW_HealthUsedData[unit].avgHDeltaPercent = (MW_HealthUsedData[unit].avgHDelta * 100)/Max
			--
			MW_HealthUsedData[unit].healthnegativepercent = (MW_HealthUsedData[unit].healthnegative * 100)/Max
			--
			MW_HealthUsedData[unit].healthpositivepercent = (MW_HealthUsedData[unit].healthpositive * 100)/Max
		end
	end
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	local function effectivemanaregen()
		local basemanaregen=GetManaRegen()
		return (basemanaregen*100)/UnitPowerMax("player",0)
	end
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	--====================================================== MANA
	local MW_ManaUsedData = {}
	local MW_LastMana = UnitPower("player", 0)
	local minimumMW_AnalyzedTimespan = 30
	local manacombatstart
	local MW_AnalyzedTimespan = minimumMW_AnalyzedTimespan
	local avgDelta = 0
	_A.avgDeltaPercent = 0
	local secondsTillOOM = 99999
	_A.Listener:Add("holy_mana", {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_POWER"}, function(event, firstArg, secondArg)
		if event == "UNIT_POWER" and firstArg == "player" and secondArg == "MANA" then
			if MW_LastMana == nil then MW_LastMana = UnitPower("player", 0) end
			_A.UnitManaHandler(firstArg)
		end
		if event == "PLAYER_REGEN_DISABLED" then
			manacombatstart = GetTime()
		end
		if event == "PLAYER_REGEN_ENABLED" then
			MW_AnalyzedTimespan = minimumMW_AnalyzedTimespan
		end
	end)
	function _A.UnitManaHandler(unitID)
		if unitID == "player" then
			local currentMana = UnitPower(unitID, 0)
			if MW_LastMana and currentMana~=MW_LastMana then
				_A.PlayerManaChanged(currentMana, UnitPowerMax(unitID, 0), MW_LastMana - currentMana)
			end
			MW_LastMana = currentMana
		end
	end
	function _A.PlayerManaChanged(Current, Max, Usage)
		local uptime = GetTime()
		-- Variable MW_AnalyzedTimespan
		if manacombatstart and (uptime - manacombatstart)>minimumMW_AnalyzedTimespan then
			MW_AnalyzedTimespan = (uptime - manacombatstart)
			elseif MW_AnalyzedTimespan~=minimumMW_AnalyzedTimespan then MW_AnalyzedTimespan = minimumMW_AnalyzedTimespan
		end
		-- fixed 
		-- if MW_AnalyzedTimespan~=minimumMW_AnalyzedTimespan then MW_AnalyzedTimespan = minimumMW_AnalyzedTimespan end
		
		local manaUsed = 0
		MW_ManaUsedData[uptime] = Usage
		for Time, Mana in pairs(MW_ManaUsedData) do
			if uptime - Time > MW_AnalyzedTimespan then
				table.remove(MW_ManaUsedData, Time)
				else
				manaUsed = manaUsed + Mana
			end
		end
		avgDelta = -(manaUsed / MW_AnalyzedTimespan)
		_A.avgDeltaPercent = (avgDelta * 100 / Max)
		if avgDelta < 0 then
			secondsTillOOM = Current / (-avgDelta)
			else secondsTillOOM = 99999
		end
	end
	--====================================================================== -- Cleaning on Deaths
	_A.Listener:Add("DeathCleaning", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if subevent == "UNIT_DIED" then
			if UnitIsPlayer(guiddest) then
				if MW_HealthUsedData[guiddest]~=nil then
					MW_HealthUsedData[guiddest] = nil
					MW_LastHealth[guiddest] = nil
				end
			end
			if guiddest == UnitGUID("player") then
				MW_ManaUsedData = {}
				MW_LastMana = nil
			end
		end
	end
	)
	--======================================================================
	--======================================================================
	--======================================================================
	--====================================================================== 
	--======================================================================
	--======================================================================
	--======================================================================
	--======================================================================
	--======================================================================
	--======================================================================
	--======================================================================
	-- HEALTH
	function averageHPv2()
		local sum = 0
		local num = 0
		if next(MW_HealthUsedData)==nil then
			return 0
			else
			for k in pairs(MW_HealthUsedData) do
				if MW_HealthUsedData[k]~=nil then
					if next(MW_HealthUsedData[k])~=nil then
						if MW_HealthUsedData[k].avgHDeltaPercent~=nil then 	
							if UnitIsDeadOrGhost(k)==nil then
								-- if UnitHealth(k)<UnitHealthMax(k) then
								local unitObject = Object(k)
								if unitObject and unitObject:alive() and unitObject:friend() and unitObject:combat() and unitObject:distance()<=45 then
									num = num + 1
									sum = sum + MW_HealthUsedData[k].avgHDeltaPercent
									return sum/num
								end
								-- end
							end
						end
					end
				end
			end
		end
		return 0
	end 
	function _A.manaengine() -- make it so it's tied with group hp
		player = player or Object("player")
		if player:buff("Lucidity") then return true end
		-- mana based
		if ((_A.avgDeltaPercent/1)>=(averageHPv2()-(effectivemanaregen()*manamodifier))) then return true end -- new method (less mana hungry)
		-- if ((_A.avgDeltaPercent/1)>=(averageHPv2()-(effectivemanaregen()))) then return true end -- new method (more mana hungry)
		-- if ((_A.avgDeltaPercent/1)>=(averageHPv2())) then return true end -- new method (more mana hungry)
		-- HEALTH BASED (mana not taken into account, best for pvp)
		return false
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
	
	-- _A.DSL:Register("debuff.count.type", function(target, args)
	-- local count = 0
	-- local fno_filter = target .. '-no_filter'
	-- if next(_A.unit_debuffs)==nil or _A.unit_debuffs[fno_filter]==nil then
	-- _ = DSL("debuff")(target, "dummy")
	-- end  
	-- local tbl = {_A.StrExplode(args, "||")}
	-- for _,typeDB in ipairs(tbl) do
	-- if type(unit_debuffs[fno_filter])=="table" then
	-- typeDB = typeDB:lower()
	-- for name in pairs(unit_debuffs[fno_filter]) do
	-- local bt = unit_debuffs[fno_filter][name][5]
	-- if bt and bt:lower()==typeDB then
	-- count = count + unit_debuffs[fno_filter][name][2]
	-- end
	-- end
	-- end
	-- end
	-- return count
	-- end)
	
	_A.DSL:Register('canafford', function()
		return _A.manaengine()
	end)
	_A.DSL:Register('chifix', function()
		return _A.UnitPower("player", 12)
	end)
	_A.DSL:Register('chifixmax', function()
		return _A.UnitPowerMax("player", 12)
	end)
	
	_A.faceunit = function(unit)
		if unit then
			if not unit:infront() then
				_A.FaceDirection(unit.guid, true)
			end
		end
	end
	-------------------------------------------------------
	-------------------------------------------------------
	local function IsPStr() -- player only, but more accurate
		local _,strafeleftkey = _A.GetBinding(7)
		local _,straferightkey = _A.GetBinding(8)
		local moveLeft =  _A.IsKeyDown(strafeleftkey)
		local moveRight = _A.IsKeyDown(straferightkey)
		if moveLeft then return "left"
			elseif moveRight then return "right"
			else return "none"
		end
	end
	local function pSpeed(unit, maxDistance)
		local munit = Object(unit)
		--local unitGUID = unit.guid
		local x, y, z = _A.ObjectPosition(unit)
		-- Check if the unit is standing still or moving backward
		if not munit:Moving() or _A.UnitIsMovingBackward(unit) then
			return x, y, z
		end
		-- Determine the dynamic distance, with a minimum of 2 units for moving units
		local facing = _A.ObjectFacing(unit)
		local speed_raw = _A.GetUnitSpeed(unit)
		local speed = speed_raw - 4.5
		local distance = math.max(2, math.min(maxDistance, speed)) -- old is speed - 4.5
		-- UNIT IS PLAYER
		player = player or Object("player")
		if munit:is(player) then
			local strafeDirection = IsPStr()
			if strafeDirection == "left" then
				facing = facing + math.pi / 2
				elseif strafeDirection == "right" then
				facing = facing - math.pi / 2
			end
			local newX = x + distance * math.cos(facing)
			local newY = y + distance * math.sin(facing)
			return newX, newY, z
		end
		-- UNIT IS NOT PLAYER
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
		player = player or Object("player")
		local px, py, pz = _A.groundpositiondetail(pSpeed(unit, distance))
		if px then
			_A.CallWowApi("CastSpellByName", spell)
			if player:SpellIsTargeting() then
				_A.ClickPosition(px, py, pz)
				_A.CallWowApi("SpellStopTargeting")
			end
		end
	end
	-------------------------------------------------------
	-------------------------------------------------------
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
	-------------------------------------------------------
	-------------------------------------------------------
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
	
	-- 116680
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
end
local exeOnUnload = function()
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
local mw_rot = {
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
						-- print("passed all checks")
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
	
	autoattackmanager = function()
		local target = Object("target")
		if target and target.isplayer and target:enemy() and target:alive() and target:inmelee() and target:infront() and target:los() then
			if target:lostcontrol() and not target:state("stun")
				then return player:autoattack() and _A.CallWowApi("RunMacroText", "/stopattack")
				else return not player:autoattack() and _A.CallWowApi("RunMacroText", "/startattack")
			end
		end
	end,
	
	activetrinket = function()
		if player:combat() and player:buff("Surge of Dominance") then
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
	end,
	
	Xuen = function()
		if player:combat() and player:talent("Invoke Xuen, the White Tiger") and player:SpellCooldown("Invoke Xuen, the White Tiger")==0 then
			if player:buff("Call of Dominance") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
				if lowestmelee then
				return	lowestmelee:cast("Invoke Xuen, the White Tiger") end
			end
		end
	end,
	
	
	items_intflask = function()
		if player:ItemCooldown(76085) == 0  
			and player:ItemCount(76085) > 0
			and player:ItemUsable(76085)
			and not player:Buff(105691)
			then
			if pull_location()=="pvp" and player:combat() then
				return player:useitem("Flask of the Warm Sun")
			end
		end
	end,
	
	items_healthstone = function()
		if player:healthmonk() <= 35    then
			if player:ItemCooldown(5512) == 0
				and player:ItemCount(5512) > 0
				and player:ItemUsable(5512) then
				return player:useitem("Healthstone")
			end
		end
	end,
	
	items_noggenfogger = function()
		if player:ItemCooldown(8529) == 0  
			and player:ItemCount(8529) > 0
			and player:ItemUsable(8529)
			and (not player:BuffAny(16591) or not player:BuffAny(16595))
			then
			if pull_location()=="pvp" then
				return player:useitem("Noggenfogger Elixir")
			end
		end
	end,
	
	arena_legsweep = function()
		local arenatar = 0
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if pull_location()=="arena" then
				if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3 then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if 	obj.isplayer and obj:range()<4
							and _A.notimmune(obj)
							and obj:los() then
							arenatar = arenatar + 1
						end 
					end
					if arenatar >= 2 then
						return obj:Cast("Leg Sweep")
					end
				end
			end
		end
	end,
	
	statbuff = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if not player:BuffAny("Legacy of the Emperor") then
				return player:cast("Legacy of the Emperor")
			end
			local roster = Object("roster")
			-- BUFFS
			if roster then
				if not roster:enemy()
					and not roster:charmed()
					and roster:alive()
					and roster:exists()
					and roster.isplayer
					then 
					if not roster:BuffAny("Legacy of the Emperor")
						and roster:SpellRange("Legacy of the Emperor")
						then 
						if roster:los() then
							return player:Cast("Legacy of the Emperor")
						end
					end
				end
			end
		end
	end,
	
	statbuff_noarena = function()
		--if not player:LostControl() then
		if player:Stance() == 1 and pull_location()~="arena"   then
			local roster = Object("roster")
			-- BUFFS
			if roster then
				if not roster:enemy()
					and not roster:charmed()
					and roster:alive()
					and roster:exists()
					and roster.isplayer
					then 
					if not roster:BuffAny("Legacy of the Emperor")
						and roster:SpellRange("Legacy of the Emperor")
						then 
						if roster:los() then
							return roster:Cast("Legacy of the Emperor")
						end
					end
				end
			end
		end
	end,
	
	kick_legsweep = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3   then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:range()<5
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Leg Sweep")
					end 
				end
			end
		end
	end,
	
	kick_chargingox = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Charging Ox Wave") and player:SpellCooldown("Charging Ox Wave")<0.3   then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:range()<30
						and obj:Infront()
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Charging Ox Wave")
					end 
				end
			end
		end
	end,
	
	kick_paralysis = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:SpellCooldown("Paralysis")<.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer 
						and obj:isCastingAny()
						and obj:SpellRange("Paralysis") 
						and not obj:iscasting("Frostbolt")
						and obj:Infront()
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Paralysis")
					end
				end
			end
		end
	end,
	
	ctrl_mode = function()
		-- if _A.modifier_ctrl() and _A.castdelay(124682, 6) then
		if _A.modifier_ctrl() then
			if not player:moving() then
				-- local lowest = Object("lowestall")
				local lowest = Object("lowestallNOHOT")
				if player:isChanneling("Soothing Mist") and _A.SMguid then
					local SMobj = Object(_A.SMguid)
					if SMobj and SMobj:SpellRange("Renewing Mist") then
						if SMobj:buff(132120) then _A.CallWowApi("SpellStopCasting") end
						if player:Chi()>= 3 and SMobj:los() then return SMobj:cast("Enveloping Mist", true) end
						if player:SpellUsable(116694) and player:Chi()< 3 and SMobj:los() then return SMobj:cast("Surging Mist", true) end
					end
				end
				if not player:isChanneling("Soothing Mist") and player:SpellUsable(115175) and lowest and lowest:exists() then return lowest:cast("Soothing Mist") end 
			end
			else if player:isChanneling("Soothing Mist") then _A.CallWowApi("SpellStopCasting") end
		end
	end,
	
	burstdisarm = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:SpellCooldown("Grapple Weapon")<.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer 
						and obj:SpellRange("Grapple Weapon") 
						and obj:Infront()
						and not healerspecid[_A.UnitSpec(obj.guid)] 
						-- and (_A.pull_location=="arena" or UnitTarget(obj.guid)==player.guid)
						and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest"))
						and not obj:BuffAny("Bladestorm")
						and not obj:LostControl()
						and not obj:state("disarm")
						and (obj:drState("Grapple Weapon") == 1 or obj:drState("Grapple Weapon")==-1)
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Grapple Weapon")
					end
				end
			end
		end
	end,
	
	kick_spear = function()
		--if not player:LostControl() then
		if player:SpellCooldown("Spear Hand Strik")==0   then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj:isCastingAny()
					and obj:SpellRange("Blackout Kick") 
					and obj:infront()
					and not obj:State("silence")
					and not obj:iscasting("Frostbolt")
					and obj:caninterrupt() 
					and not obj:LostControl()
					and obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=95
					and _A.notimmune(obj)
					then
					obj:Cast("Spear Hand Strike")
				end
			end
		end
	end,
	
	pvp_disable = function()
		if player:Stance() == 1 --and pull_location()=="arena" 
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and not lowestmelee:BuffAny("Bladestorm || Divine Shield || Die by the Sword || Hand of Protection || Hand of Freedom || Deterrence")
				and not lowestmelee:Debuff("Disable") then
				---------------------------------- 
				return lowestmelee:Cast("Disable")
			end
		end
	end,
	
	pvp_disable_keybind = function()
		if player:keybind("X") then
			if player:Stance() == 1 --and pull_location()=="arena" 
				then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee and not lowestmelee:BuffAny("Bladestorm || Divine Shield || Die by the Sword || Hand of Protection || Hand of Freedom || Deterrence") then
					---------------------------------- 
					return lowestmelee:Cast("Disable")
				end
			end
		end
	end,
	
	ringofpeace = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace")<0.3 then
				local peacetarget = Object("mostTargetedRosterPVP")
				if peacetarget and peacetarget:exists()  then
					if peacetarget:SpellRange("Ring of Peace") and peacetarget:healthmonk()<=85 and not peacetarget:BuffAny("Ring of Peace") then
						if ( peacetarget:areaEnemies(6) >= 3 ) or ( peacetarget:areaEnemies(6) >= 1 and peacetarget:healthmonk()<75 ) then
							if peacetarget:los() then
								return peacetarget:Cast("Ring of Peace")
							end
						end
					end
				end
			end
		end
	end,
	
	ringofpeacev2 = function()
		if player:Stance() == 1 and player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace") < 0.3 then
			local targets = {}
			local targetsall = {}
			local peacetarget = nil
			local most, mostGuid = 0
			local mostall, mostallGuid = 0
			
			-- Version 1: Only enemies targeting
			for _, enemy in pairs(_A.OM:Get('Enemy')) do
				if enemy and enemy.isplayer and not enemy:BuffAny("Bladestorm || Divine Shield || Deterrence") and _A.notimmune(enemy) and not enemy:state("Disarm") and not healerspecid[_A.UnitSpec(enemy.guid)] then
					local tguid = UnitTarget(enemy.guid)
					if tguid then
						local tobj = Object(tguid)
						if tobj and _A.nothealimmune(tobj) and tobj:Distancefrom(enemy) < 8 and _A.nothealimmune(tobj) then
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
			
			if mostGuid then peacetarget = Object(mostGuid)
				if peacetarget and peacetarget:exists() then
					if peacetarget:SpellRange("Ring of Peace") and not peacetarget:BuffAny("Ring of Peace") then
						if (most >= 2) or (most >= 1 and (peacetarget:healthmonk() < 45 or (_A.pull_location == "arena" and peacetarget:healthmonk() < 65))) then
							if peacetarget:los() then
								print("targets only")
								return peacetarget:Cast("Ring of Peace")
							end
						end
					end
				end
			end
			-- Version 2: All valid enemies in range
			for _, friend in pairs(_A.OM:Get('Friendly')) do
				if friend and friend.isplayer and _A.nothealimmune(friend) then
					for _, enemy in pairs(_A.OM:Get('Enemy')) do
						if enemy and enemy.isplayer and friend:Distancefrom(enemy) < 8 and not enemy:BuffAny("Bladestorm || Divine Shield || Deterrence") and _A.notimmune(enemy) and not enemy:state("Disarm")  then
							targetsall[friend.guid] = targetsall[friend.guid] and targetsall[friend.guid] + 1 or 1
						end
					end
				end
			end
			
			for guid, count in pairs(targetsall) do
				if count > mostall then
					mostall = count
					mostallGuid = guid
				end
			end
			
			if mostallGuid then peacetarget = Object(mostallGuid)
				if peacetarget and peacetarget:exists() then
					if peacetarget:SpellRange("Ring of Peace") and not peacetarget:BuffAny("Ring of Peace") then
						if (mostall >= 3) then
							if peacetarget:los() then
								print("any")
								return peacetarget:Cast("Ring of Peace")
							end
						end
					end
				end
			end
			
			-- if _A.pull_location and _A.pull_location=="arena" then
			
			-- Version 3: Silence healers if someone is low
			if _A.someoneislow() then -- iterates through enemy players to find if a low hp enemy player exists
				for _, friend in pairs(_A.OM:Get('Friendly')) do
					if friend and friend.isplayer and _A.nothealimmune(friend) then
						for _, enemy in pairs(_A.OM:Get('Enemy')) do
							if enemy and enemy.isplayer and friend:Distancefrom(enemy) < 8 and healerspecid[_A.UnitSpec(enemy.guid)]  and _A.notimmune(enemy) and not enemy:state("silence") and friend:los() then
								print("enemy healer silence - low enemy in range")
								return friend:Cast("Ring of Peace")
							end
						end
					end
				end
			end
			-- end
		end
	end,
	
	
	chi_wave = function()
		if player:Talent("Chi Wave")  
			and player:SpellCooldown("Chi Wave")<.3 then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then
					if lowest:exists() and lowest:SpellRange("Chi Wave")
						then 
						return lowest:Cast("Chi Wave")
					end
				end
			end
		end
	end,
	
	manatea = function()
		if player:Stance() == 1   then
			if player:SpellCooldown("Mana Tea")<.3
				and player:Glyph("Glyph of Mana Tea")
				and player:mana()<= 92
				and player:BuffStack("Mana Tea")>=2
				then
				return player:Cast("Mana Tea")
				-- _A.CastSpellByName("Mana Tea")
			end
		end
	end,
	
	chibrew = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			
			if player:Talent("Chi Brew")
				and player:SpellCooldown("Chi Brew")==0
				and player:Chi()<=2
				then
				player:Cast("Chi Brew")
			end
		end
	end,
	
	fortifyingbrew = function()
		if player:Stance() == 1   then
			if	player:SpellCooldown("Fortifying Brew")==0
				and player:healthmonk()<50
				then
				player:Cast("Fortifying Brew")
			end
		end
	end,
	
	thunderfocustea = function()
		if player:Stance() == 1 and player:Chi()>=1 then
			if	player:SpellCooldown("Thunder Focus Tea")==0 and player:SpellUsable("Thunder Focus Tea") then
				if _A.thunderbrewremovedat==nil or (_A.thunderbrewremovedat and (GetTime() - _A.thunderbrewremovedat)>=45)
					then
					player:Cast("Thunder Focus Tea")
				end
			end
		end
	end,
	
	tigerslust = function()
		if player:Talent("Tiger's Lust") and player:SpellCooldown("Tiger's Lust")<.3   then
			if player:Stance() == 1 then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr:SpellRange("Tiger's Lust") then
						if fr.isplayer then
							if _A.nothealimmune(fr) then
								if (not fr:LostControl()) and (fr:State("root") or fr:State("snare")) and fr:los()
									then
									if fr.guid ~= player.guid then
										return fr:Cast("Tiger's Lust")
										else
										return fr:Cast("Tiger's Lust")
									end
								end
							end
						end	
					end
				end
			end	
		end
	end,
	
	dispellplzarena = function()
		local temptabletbl2 = {}
		if player:Stance() == 1   then
			if player:SpellCooldown("Detox")<.3 and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (_A.pull_location=="arena" and fr:ispet()) then
						if fr:SpellRange("Detox")
							and not fr:DebuffAny("Unstable Affliction || Vampiric Touch")
							and fr:DebuffType("Magic || Poison || Disease") then
							if fr:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence") or fr:LostControl() or _A.pull_location == "party" or _A.pull_location == "raid"
								-- annoying
								or fr:DebuffAny("Entangling Roots ||  Freezing Trap || Denounce || Flame Shock || Moonfire || Sunfire") 
								then
								if _A.nothealimmune(fr) and fr:los() then
									temptabletbl2[#temptabletbl2+1] = {
										HP = fr:healthmonk(),
										obj = fr
									}
								end
							end
						end	
					end
				end
				if #temptabletbl2>1 then
					table.sort( temptabletbl2, function(a,b) return ( a.HP < b.HP ) end )
				end
				return temptabletbl2[1] and temptabletbl2[1].obj:Cast("Detox")
			end
		end
	end,
	
	diffusemagic = function()
		if player:talent("Diffuse Magic") and player:SpellCooldown("Diffuse Magic")==0 then
			-- add the stuff that hurts
			if 
				player:healthmonk()<30 or player:DebuffAny("Moonfire || Sunfire || Unstable Affliction || Touch of Karma")
				then 
			return player:cast("Diffuse Magic") end
		end
	end,
	
	dispellplzany = function()
		local temptabletbl1 = {}
		-- if player:Stance() == 1 and _A.pull_location ~="pvp"   then
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox")<.3 and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" then
						if fr:SpellRange("Detox")
							and _A.nothealimmune(fr)
							and not fr:DebuffAny("Unstable Affliction")  then
							-- and not fr:DebuffAny("Unstable Affliction || Vampiric Touch")  then
							if fr:los() then
								temptabletbl1[#temptabletbl1+1] = {
									count = fr:debuffCountType("Magic || Poison || Disease") or 0,
									obj = fr
								}
							end
						end
					end	
				end
			end
			if #temptabletbl1>1 then
				table.sort( temptabletbl1, function(a,b) return ( a.count > b.count ) end )
			end
			return temptabletbl1[1] and temptabletbl1[1].count>=1 and temptabletbl1[1].obj:Cast("Detox")
		end
	end,
	
	lifecocoon = function()
		if player:SpellCooldown("Life Cocoon")<.3 and player:SpellUsable(116849)   then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:exists() and lowest:SpellRange("Life Cocoon") then 			
					--]]
					if 
						-- (lowest:healthmonk()<40 or (pull_location()=="pvp" and lowest:healthmonk()<40))
						lowest:healthmonk()<40
						then
						return lowest:Cast("Life Cocoon")
					end
				end
			end
		end
	end,
	
	surgingmist = function()
		if player:BuffStack("Vital Mists")>=5  
			and player:Chi() < player:ChiMax() then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:SpellRange("Surging Mist") then 	
					--]]
					
					if  
						lowest:healthmonk()<=85
						
						then
						return lowest:Cast("Surging Mist")
					end
				end
			end
		end
	end,
	
	renewingmist = function()
		if player:SpellCooldown("Renewing Mist")<.3 and player:SpellUsable(115151)   then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:exists() and lowest:SpellRange("Renewing Mist") then 
					return lowest:Cast("Renewing Mist")
				end
			end
		end
	end,
	
	healstatue = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			
			if	player:SpellCooldown("Summon Jade Serpent Statue")<.3
				then
				-- return player:CastGround("Summon Jade Serpent Statue")
				return _A.clickcast(player,"Summon Jade Serpent Statue")
			end
		end
	end,
	
	healingsphere_shift = function()
		if player:SpellCooldown("Healing Sphere")<.3  and  player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if _A.modifier_shift() then
					if player:SpellUsable(115460) then
						local lowest = Object("lowestall")
						if lowest and lowest:exists() then
							if (lowest:healthmonk() < 99) then
								if lowest:Distance() < 40 then
									-- if lowest:los() then
									-- return lowest:CastGround("Healing Sphere")
									-- return _A.clickcast(lowest,"Healing Sphere")
									return _A.CastPredictedPos(lowest.guid, "Healing Sphere", 8)
									-- end
								end
							end
						end
					end
				end
			end
		end
	end,
	
	healingsphere_keybind = function()
		if player:SpellCooldown("Healing Sphere")<.3  and  player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if player:keybind("E") then
					if player:SpellUsable(115460) then
						local target = Object("target")
						if target and target:exists() then
							if target:Distance() < 40 then
								if target:los() then
									-- return target:CastGround("Healing Sphere")
									-- return _A.clickcast(target,"Healing Sphere")
									return _A.CastPredictedPos(target.guid, "Healing Sphere", 8)
								end
							end
						end
					end
				end
			end
		end
	end,
	
	healingsphere = function()
		--if not player:LostControl() then
		if player:SpellCooldown("Healing Sphere")<.3  and  player:SpellUsable("Healing Sphere")  then
			if player:Stance() == 1 then
				if player:SpellUsable(115460) then
					if _A.manaengine()==true or _A.modifier_shift() then
						--- ORBS
						local lowest = Object("lowestall")
						if lowest then
							if lowest:exists() then
								if (lowest:healthmonk() < 85) then
									-- if lowest:los() then
									-- return lowest:CastGround("Healing Sphere", true)
									-- return _A.clickcast(lowest,"Healing Sphere")
									return _A.CastPredictedPos(lowest.guid, "Healing Sphere", 8)
									-- end
								end
							end
						end
					end
				end
			end
		end
	end,
	
	blackout_mm = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:Chi()>=2 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							---------------------------------- 
							return lowestmelee:Cast("Blackout Kick")
						end
					end
					--------------------------------- damage based
				end
			end
		end
	end,
	
	tigerpalm_mm = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Chi()>=1 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							---------------------------------- 
							return lowestmelee:Cast("Tiger Palm")
						end
					end
					--------------------------------- damage based
				end
			end
		end
	end,
	
	bk_buff = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 2
					and not player:Buff("Serpent's Zeal") -- and player:Buff("Muscle Memory") 
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Blackout Kick")
						end
					end
				end
			end
		end
	end,
	
	tp_buff = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm")
						end
					end
				end
			end
		end
	end,
	
	tp_buff_keybind = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm", true)
						end
					end
				end
			end
		end
	end,
	
	uplift = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if	player:SpellUsable("Uplift")
				and player:Chi()>= 2 
				then
				return player:Cast("Uplift")
			end
		end
	end,
	
	expelharm = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if	player:Chi()<player:ChiMax()
				and player:SpellCooldown("Expel Harm")<.3
				and player:SpellUsable(115072)
				then
				return player:Cast("Expel Harm")
			end
		end
	end,
	
	tigerpalm_filler = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:Chi() == 1 then
				if player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm")
						end
					end
				end
			end
		end
	end,
	
	blackout_keybind = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:Chi()>=2 then
				-- if player:Buff("Muscle Memory") then
				
				---------------------------------- 
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					if lowestmelee:exists() then
						---------------------------------- 
						return lowestmelee:Cast("Blackout Kick", true)
					end
				end
				--------------------------------- damage based
			end
		end
	end,
	
	jab_filler = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if _A.manaengine() then
				if player:Buff("Rushing Jade Wind") and not player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						return lowestmelee:Cast("Jab")
					end
				end
			end
			-- {"Summon Jade Serpent Statue", "spell.cooldown<1 && stance == 1", "player.ground"},
		end -- stance 1
	end,
	
	dpsstance_jab = function()
		if player:Stance() ~= 1 then
			if not player:Buff("Muscle Memory")
				-- or player:Chi()==0 then
				or player:Chi()<=1 then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					return lowestmelee:Cast("Jab")
				end
			end
		end
	end,
	
	spin_keybind = function()
		if player:Stance() == 1 and not _A.modifier_shift() then
			if	player:Talent("Rushing Jade Wind") 
				and player:SpellCooldown("Rushing Jade Wind")<.3
				and player:SpellUsable(116847)
				then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					return player:Cast("Rushing Jade Wind")
				end
			end
		end
	end,
	
	spin_rjw = function()
		if (player:Stance() == 1)
			and player:buffany("Lucidity") then
			if	player:Talent("Rushing Jade Wind") 
				and player:SpellCooldown("Rushing Jade Wind")<.3
				then
				return player:Cast("Rushing Jade Wind")
			end
		end
		-- add friendly finder on top
	end,
	
	
	jab_keybind_buff = function()
		if player:Stance() == 1 and player:mana()>=9 
			-- and (not player:buff("Muscle Memory"))  -- former logic
			and player:chi()==1
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Jab", true)
				end
			end
		end
	end,
	
	lightning_keybind = function()
		if player:Stance() == 1 and player:Keybind("R") and player:mana()>=9 and not player:moving() then
			if not player:isChanneling("Crackling Jade Lightning") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if not lowestmelee then
					local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
					if lowestmelee then
						return lowestmelee:Cast("Crackling Jade Lightning")
					end
				end
			end
			else if player:isChanneling("Crackling Jade Lightning") then _A.CallWowApi("SpellStopCasting") end
		end
	end,
	
	autotarget = function()
		if _A.UnitExists("pet") then
			local _target = Object("target")
			local lowestmelee = Object("lowestEnemyInSpellRangeMINIMAL(Crackling Jade Lightning)")
			if lowestmelee then
				if _target and _target.guid ~= lowestmelee.guid  then _A.CallWowApi("TargetUnit", lowestmelee.guid) end
				if not _target then _A.CallWowApi("TargetUnit", lowestmelee.guid) end
			end
		end
	end,
	
	detargetcc = function()
		local _target = Object("target")
		if _A.pull_location == "arena" and _target and _target:enemy() and ( _target:range()<10 or _A.UnitExists("pet") )  and _A.dontbreakcc(_target)==false then _A.CallWowApi("ClearTarget") end
	end,
	
	autofocus = function()
		if _A.UnitExists("pet") then
			local _focus = Object("focus")
			local lowestmelee = Object("lowestEnemyInSpellRangeMINIMAL(Crackling Jade Lightning)")
			if lowestmelee then
				if not _focus then _A.CallWowApi("FocusUnit", lowestmelee.guid) end
				if _focus and _focus.guid ~= lowestmelee.guid  then _A.CallWowApi("FocusUnit", lowestmelee.guid) end
				if _focus then _A.CallWowApi("RunMacroText", "/petattack focus") end
			end
			elseif _focus then _A.CallWowApi("ClearFocus")
		end
	end,
	
	
	dpsstance_spin = function()
		if player:Stance() ~= 1 and (player:keybind("R") or _A.pull_location~="pvp") then
			if	player:Talent("Rushing Jade Wind") 
				and player:SpellCooldown("Rushing Jade Wind")<.3
				then
				return player:Cast("Rushing Jade Wind")
			end
		end
	end,
	
	dpsstance_healstance = function()
		if player:Stance() ~= 1 then
			if	player:SpellCooldown("Stance of the Wise Serpent")<.3
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	dpsstance_healstance_keybind = function()
		if player:Stance() ~= 1 and _A.modifier_shift() then
			if	player:SpellCooldown("Stance of the Wise Serpent")<.3
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	dpsstanceswap = function()
		--if not player:LostControl() then
		if player:Stance() ~= 2 then
			if player:SpellCooldown("Stance of the Fierce Tiger")<.3
				and not player:Buff("Rushing Jade Wind") 
				and not player:Buff("lucidity") 
				then
				if player:Talent("Rushing Jade Wind") and (player:keybind("R") or _A.pull_location~="pvp") then
					return player:Cast("Stance of the Fierce Tiger")
				end
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					return player:Cast("Stance of the Fierce Tiger")
				end
			end
		end
	end,
	
	dpsstanceswap_keybind = function()
		--if not player:LostControl() then
		if player:Stance() ~= 2
			then
			if player:SpellCooldown("Stance of the Fierce Tiger")<.3
				and not player:Buff("Rushing Jade Wind") 
				and not player:Buff("lucidity") 
				then
				if player:Talent("Rushing Jade Wind") then
					return player:Cast("Stance of the Fierce Tiger")
				end
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					return player:Cast("Stance of the Fierce Tiger")
				end
			end
		end
	end,
}
local inCombat = function()
	if not enteredworldat then return end
	if enteredworldat and ((GetTime()-enteredworldat)<(3)) then return end
	if not _A.pull_location then return end
	player = player or Object("player")
	if not player then return end
	if not player:alive() then return end
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .2 + _A.latency
	if _A.buttondelayfunc()  then return end
	if player and player:mounted() then return end
	if player and player:isChanneling("Crackling Jade Lightning") then return end
	-- ProcessItemsCoroutine()
	-- if player and player:isChanneling("Mana Tea") then return end
	-- mw_rot.detargetcc()
	mw_rot.autofocus()
	mw_rot.autoattackmanager()
	if mw_rot.healingsphere_keybind() then return end
	if mw_rot.items_healthstone() then return end 
	if mw_rot.items_noggenfogger() then return end
	if mw_rot.items_intflask() then return end
	if mw_rot.activetrinket() then return end
	if mw_rot.Xuen() then return end
	if mw_rot.turtletoss() then return end
	if mw_rot.kick_legsweep() then return end
	if mw_rot.ringofpeacev2() then return end
	if mw_rot.renewingmist() then return end
	if mw_rot.healingsphere_shift() then return end
	if not player:keybind("R") then
		if mw_rot.tigerpalm_mm() then return end
	end
	-- if mw_rot.dispellplzarena() then return end
	if mw_rot.dispellplzany() then return end
	if mw_rot.diffusemagic() then return end
	if mw_rot.spin_rjw() then return end
	if mw_rot.kick_paralysis() then return end
	if mw_rot.kick_spear() then return end
	-- if mw_rot.ringofpeace() then return end
	if mw_rot.burstdisarm()  then return end
	if mw_rot.chi_wave()  then return end
	if mw_rot.chibrew()  then return end
	if mw_rot.fortifyingbrew() then return end
	if mw_rot.tigerslust()  then return end
	if mw_rot.lifecocoon()  then return end
	if mw_rot.pvp_disable_keybind() then return end
	if player:keybind("R") or ((_A.pull_location=="none" and not player:isparty() and not player:israid()) or _A.pull_location=="party")  then
		if mw_rot.manatea() then return end
		if mw_rot.tp_buff_keybind() then return end
		if mw_rot.blackout_keybind()  then return end
		if mw_rot.dpsstanceswap_keybind()  then return end
	end
	if mw_rot.tigerpalm_mm() then return end
	if mw_rot.surgingmist() then return end
	-- if mw_rot.renewingmist() then return end
	if mw_rot.manatea() then return end
	if mw_rot.ctrl_mode() then return end
	if mw_rot.healstatue() then return end
	if mw_rot.healingsphere() then return end
	-- old pvp slot
	-- mw_rot.lightning_keybind()
	if mw_rot.thunderfocustea() then return end
	if mw_rot.uplift() then return end
	if mw_rot.expelharm() then return end
	if mw_rot.jab_filler() then return end
	if mw_rot.statbuff() then return end
	if mw_rot.dpsstance_healstance_keybind() then return end
	if not _A.modifier_shift() then
		if mw_rot.dpsstance_jab() then return end
		if mw_rot.dpsstance_spin()  then return end
	end
	if mw_rot.dpsstance_healstance()  then return end
	if not _A.modifier_shift() then
		if mw_rot.dpsstanceswap()  then return end
	end
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(270, {
	name = "Monk Heal EFFICIENT",
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
