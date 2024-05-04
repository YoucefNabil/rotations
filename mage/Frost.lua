local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local player
local frost = {}
local immunebuffs = {
	"Deterrence",
	"Anti-Magic Shell",
	"Cloak of Shadows",
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
local types_i_dont_need = {
	[0] = true, -- unknown
	[10] = true, -- not specified
	[11] = true, -- totems
	[12] = true, -- non combat pets
	[13] = true -- gas cloud
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

local function pull_location()
	local whereimi = string.lower(select(2, GetInstanceInfo()))
	return string.lower(select(2, GetInstanceInfo()))
end
--
--

local frozen_debuffs = {
	"Frost Nova",
	"Freeze",
	"Deep Freeze",
	"Ring of Frost",
	"Frostjaw",
	"Ice Ward",
	33395,
	122
}

local usableitems = { -- item slots
	13, --first trinket
	14 --second trinket
}
local magedots = {
}
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
	
	function _A.attackable(unit)
		if _A.pull_location and _A.pull_location ~= "arena" and _A.pull_location ~= "pvp" then return true end
		if unit then 
			if unit:CreatureType()==nil then return false end
			if types_i_dont_need[unit:CreatureType()] then return false end
			return true
		end	
	end	
	
	function _A.myscore()
		local ap = GetSpellBonusDamage(6) -- shadowdamage
		local mastery = GetCombatRating(26)
		local crit = GetCombatRating(9)
		local haste = GetCombatRating(18)
		return (ap + mastery + crit + haste)
	end
	
	
	_A.Listener:Add("dotstables", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
		if guidsrc == UnitGUID("player") then -- only filter by me
			-- testing
			-- if (idd==27243) then
			-- print(subevent.." "..idd)
			-- end
			--
			if (idd==44457) then -- Corruption
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					magedots[guiddest]=_A.myscore() 
				end
				-- if ( subevent=="SPELL_AURA_REFRESH" and ijustexhaled == false ) -- Incase you use soulburn seed of corruption
				-- then
				-- print("that thing fired")
				-- corruptiontbl[guiddest]=_A.myscore() 
				-- end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					magedots[guiddest]=nil
				end
			end
		end
	end
	)
	
	function _A.unitfrozen(unit)
		local player = player or Object("player")
		if player and player:BuffAny(44544) then return true end
		if unit then 
			for _,debuffs in ipairs(frozen_debuffs) do
				if unit:DebuffAny(debuffs) then return true
				end
			end
		end
		return false
	end
	--
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
		if player then
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end end
		return false
	end
	
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then
			-- print(subevent.." "..idd)
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[idd] = _A.GetTime()
			end
		end
	end)
	function _A.castdelay(idd, delay)
		if delay == nil then return true end
		if _A.casttimers[idd]==nil then return true end
		return (_A.GetTime() - _A.casttimers[idd])>=delay
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
		if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.attackable(target) and  _A.notimmune(target) and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
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
	
	_A.FakeUnits:Add('lowestEnemyFrozen', function(num, spell)
		local tempTable = {}
		local player = player or Object("player")
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			-- if Obj:spellRange(spell) and  Obj:Infront() and (Obj:SpellUsable("Deep Freeze") or player:BuffAny(44544) or Obj:DebuffAny(33395) or Obj:DebuffAny(122)) and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
			if ((_A.pull_location=="pvp" and Obj.isplayer) or _A.pull_location~="pvp") and Obj:spellRange(spell) and  Obj:Infront() and _A.unitfrozen(Obj) and _A.attackable(Obj)
				and _A.notimmune(Obj)  and Obj:los() then
				-- if Obj:spellRange(spell) and  Obj:Infront() and Obj:SpellUsable("Deep Freeze") and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
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
	
	_A.FakeUnits:Add('lowestEnemyNONFrozen', function(num, spell)
		local tempTable = {}
		local player = player or Object("player")
		for _, Obj in pairs(_A.OM:Get('Enemy')) do --Enemy
			if Obj:spellRange(spell) and  Obj:Infront() and (not _A.unitfrozen(Obj)) and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
				-- if Obj:spellRange(spell) and  Obj:Infront() and (not Obj:SpellUsable("Deep Freeze") and not player:BuffAny(44544)) and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
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
	
	_A.FakeUnits:Add('lowestEnemyInRangeNONFrozen', function(num, range_target)
		local tempTable = {}
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if ((_A.pull_location=="pvp" and Obj.isplayer) or _A.pull_location~="pvp") and Obj:rangefrom(target)<=range and (not _A.unitfrozen(Obj)) and _A.attackable(Obj)
				and _A.notimmune(Obj)  and Obj:los() then
				-- if Obj:rangefrom(target)<=range and (not Obj:SpellUsable("Deep Freeze") and not player:BuffAny(44544)) and _A.attackable(Obj) and  _A.notimmune(Obj)  and Obj:los() then
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
	
	_A.FakeUnits:Add('lowestEnemyInRange', function(num, range_target)
		local tempTable = {}
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:rangefrom(target)<=range and Obj:Infront() and _A.attackable(Obj) and  _A.notimmune(Obj)  and Obj:los() then
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
end
local exeOnUnload = function()
end

frost.rot = {
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
	
	activetrinket = function()
		if player:buff("Surge of Dominance") and player:combat() then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 then 
							_A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i])))
						end
					end
				end
			end
		end
	end,
	
	icebarrier = function()
		if not player:buffany("Ice Barrier") and not player:buff("Ice Barrier") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Ice Barrier")
		end
	end,
	
	incanters = function()
		if player:SpellCooldown("Incanter's Ward")<.3 and player:combat() and player:health()<=80 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Incanter's Ward")
		end
	end,
	
	OrbOrb = function()
		if player:combat() and player:SpellCooldown("Frozen Orb")<.3 then
			if player:buff("Call of Dominance") then
				player:cast("Frozen Orb")
			end
		end
	end,
	
	IcyVeins = function()
		if player:combat() and player:SpellCooldown("Icy Veins")==0 then
			if player:buff("Call of Dominance") then
				player:cast("Icy Veins")
			end
		end
	end,
	
	MirrorImage = function()
		if player:combat() and player:SpellCooldown("Mirror Image")==0 then
			if player:buff("Call of Dominance") then
				player:cast("Mirror Image")
			end
		end
	end,
	
	AlterTime = function()
		if player:SpellCooldown(108978)<.3 and _A.castdelay(108978,6) then
			if player:buff("Call of Dominance") or player:buff("Surge of Dominance") or player:buff("Icy Veins") then 
				local Dominance =  (player:buffduration("Call of Dominance")~= 0) and player:buffduration("Call of Dominance") or 9999
				local Surge = (player:buffduration("Surge of Dominance")~= 0) and player:buffduration("Surge of Dominance") or 9999
				local ic = (player:buffduration("Icy Veins")~= 0) and player:buffduration("Icy Veins") or 9999
				if math.min(Dominance, Surge, ic)<=6 then
					player:cast(108978)
				end
			end
		end
	end,
	
	iceward = function()
		if player:talent("Ice Ward") and player:SpellCooldown("Ice Ward")<.3 and not player:buffany("Ice Ward") then
			return player:cast("Ice Ward")
		end
	end,
	
	Silencing = function()
		if player:SpellCooldown("Counterspell")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Counterspell") and obj:infront()
					and obj:caninterrupt() 
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Counterspell")
					end
				end
			end
		end,
		
		frostfirebolt_proc = function()
			if player:buff("Brain Freeze") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Ice Lance)")
				if lowestmelee then
					return lowestmelee:Cast("frostfire bolt")
				end
				end
			end,
	
	deepfreeze_frozen = function()
		if player:SpellCooldown("Deep Freeze")<.3 then
			local lowestmelee = Object("lowestEnemyFrozen(Deep Freeze)")
			if lowestmelee then
				return lowestmelee:cast("Deep Freeze")
			end
		end
	end,
	
	
	icelance_frozen = function()
		local lowestmelee = Object("lowestEnemyFrozen(Ice Lance)")
		if lowestmelee then
			-- if (lowestmelee:SpellUsable("Deep Freeze") and player:buff("Call of Dominance")) or (not player:keybind("E")) then
			return lowestmelee:cast("ice lance")
			-- end
		end
	end,
	
	magedot = function()
		local lowestmelee = Object("lowestEnemyInSpellRange(Ice Lance)")
		if lowestmelee then
			--if player:Talent("Nether Tempest") and not lowestmelee:debuff("Nether Tempest") then
			--return lowestmelee:Cast("Nether Tempest")
			if not lowestmelee:debuff("Living Bomb") or (magedots[lowestmelee.guid] and _A.myscore()>magedots[lowestmelee.guid]) then --player:Talent("Living Bomb") and
				return lowestmelee:Cast("Living Bomb")
			end
		end
	end,
	
	frostbolt = function()
		--if player:keybind("E") then
		if not player:Moving() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Ice Lance)")
			if lowestmelee  then
				return lowestmelee:Cast("frostbolt")
			end
		end
		--end
	end,
	
	icelance = function()
		if not player:keybind("E") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Ice Lance)")
			if lowestmelee then
				return lowestmelee:Cast("Ice Lance")
			end
		end
	end,
	
	playerfreeze = function()
		if player:SpellCooldown("Frost Nova")<.3 then
			local lowestmelee = Object("lowestEnemyInRangeNONFrozen(12)")
			if lowestmelee then
				return lowestmelee:cast("Frost Nova")
			end
		end
	end,
	
	coneofcold = function()
		if player:SpellCooldown("Cone of Cold")<.3 then
			local lowestmelee = Object("lowestEnemyInRange(8)")
			if lowestmelee then
				return lowestmelee:cast("Cone of Cold")
			end
		end
	end,
	
	pet_freeze = function()
		if _A.UnitExists("pet")
			and not _A.UnitIsDeadOrGhost("pet") then
			local pet = Object("pet")
			if pet and pet:SpellCooldown("Freeze")==0 then
				local lowestmelee = Object("lowestEnemyNONFrozen(Ice Lance)")
				if pet:rangefrom(lowestmelee)<=40 and pet:losfrom(lowestmelee)  then
					lowestmelee:castground(33395)
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
	player = player or Object("player")
	if not player then return end
	_A.latency = (select(3, GetNetStats())) and ((select(3, GetNetStats()))/1000) or 0
	_A.interrupttreshhold = math.max(_A.latency, .1) 
	if _A.buttondelayfunc()  then return end
	if player:mounted() then return end
	frost.rot.pet_freeze()
	if player:isCastingAny() then return end
	frost.rot.Silencing()
	frost.rot.activetrinket()
	frost.rot.AlterTime()
	frost.rot.icebarrier()
	frost.rot.incanters()
	frost.rot.OrbOrb()
	frost.rot.IcyVeins()
	frost.rot.MirrorImage()
	frost.rot.playerfreeze()
	frost.rot.deepfreeze_frozen()
	frost.rot.icelance_frozen()
	frost.rot.iceward()
	frost.rot.coneofcold()
	frost.rot.frostfirebolt_proc()
	frost.rot.magedot()
	frost.rot.frostbolt()
	frost.rot.icelance()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(64, {
	name = "Youcef's frost mage",
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