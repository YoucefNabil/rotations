local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
local Listener = _A.Listener
local C_Timer = _A.C_Timer
local looping = C_Timer.NewTicker
-- top of the CR
local player
local enteredworldat
local unholy = {}
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
Listener:Add("Entering_timerPLZ", "PLAYER_ENTERING_WORLD", function(event)
	enteredworldat = _A.GetTime()
	local stuffsds = pull_location()
	_A.pull_location = stuffsds
	print("HEY HEY HEY HEY")
end
)
local exeOnLoad = function()
	
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
	function _A.isthishuman(unit)
		if _A.UnitIsPlayer(unit)==1
			then return true
		end
		return false
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
				-- _A.print("ON")
				return true
			end
		end
		if slot==_A.STOPSLOT then 
			-- print(player:stance())
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				-- _A.print("OFF")
				return true
			end
		end
	end)
	_A.buttondelayfunc = function()
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
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
	
	
	-- dot snapshorring
	_A.enemyguidtab = {}
	local ijustdidthatthing = false
	local ijustdidthatthingtime = 0
	Listener:Add("DK_STUFF", {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED"} ,function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if event == "PLAYER_ENTERING_WORLD"
			or event == "PLAYER_REGEN_ENABLED"
			then
			if next(_A.enemyguidtab)~=nil then
				for k in pairs(_A.enemyguidtab) do
					_A.enemyguidtab[k]=nil
				end
			end
		end
		if event == "COMBAT_LOG_EVENT_UNFILTERED" --or event == "COMBAT_LOG_EVENT"
			then
			if guidsrc == UnitGUID("player") then -- only filter by me
				if subevent =="SPELL_CAST_SUCCESS" then
					if idd==85948 then --festering strike, refreshes dot duration but not stats
						ijustdidthatthing = true -- when true, means I just used FS
						ijustdidthatthingtime = GetTime()
						-- print(ijustdidthatthingtime)
					end
				end
				if (idd==45462) or (idd==77575) -- or (idd==50842) -- outbreak -- Plague Strike -- pestilence(doesnt work because it only works on the target, and not on everyone else)
					or 
					(idd==55078) or (idd==55095)  -- debuffs, I think
					then 
					if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS" and not idd==85948) or (subevent=="SPELL_PERIODIC_DAMAGE" and _A.enemyguidtab[guiddest]==nil) or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
						-- every spell aura refresh of dk refreshes both stats and duration, EXCEPT festering strike (only duration), that's what that check is for
						then
						_A.enemyguidtab[guiddest]=_A.myscore()
						-- print(_A.enemyguidtab[guiddest])
					end
					if subevent=="SPELL_AURA_REMOVED" 
						then
						_A.enemyguidtab[guiddest]=nil
					end
				end	
			end
		end
	end)
	
	function _A.usablelite(spellid)
		if spellcost(spellid)~=nil then
			if power("player")>=spellcost(spellid)
				then return true
				else return false
			end
			else return false
		end
	end
	
	
	
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
	
	function _A.numplayerenemies(range)
		local numenemies = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer then
				if Obj:range()<=range then
					numenemies = numenemies + 1
				end
			end
		end
		return numenemies
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
	--=======================
	--=======================
	--=======================
	--=======================
	local function MyTickerCallback(ticker)
		if GetTime()-ijustdidthatthingtime>=.2 then
			ijustdidthatthing=false
		end
		--
		local player = player or Object("player")
		
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

unholy.rot = {
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
	
	stance_dance = function()
		if not _A.IsForeground() then
			if player:SpellCooldown(48263)<.3 then
				if player:stance()~=1 and player:health()<50 then return player:cast(48263)
				end
				if player:buff("Horde Flag") or player:buff("Alliance Flag") then return player:cast(48263)
				end
			end
			if player:SpellCooldown(48265)<.3 then
				if player:stance()~=3 and player:health()>65 and not player:buff("Horde Flag") and not player:buff("Alliance Flag") then return player:cast(48265) -- unholy
				end
			end
		end
	end,
	
	icbf = function()
		if player:health() <= 30 then
			if player:SpellCooldown("Icebound Fortitude") == 0
				then
				player:cast("Gift of the Naaru")
				player:cast("Icebound Fortitude")
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
		if player:combat() and player:buff("Surge of Victory") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee 
				and lowestmelee:health()>=65
				then 
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
		end
	end,
	
	Frenzy = function()
		if player:combat() and player:buff("Call of Victory") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee
				and lowestmelee:health()>=65
				then 
				if player:SpellCooldown("Unholy Frenzy")==0 then 
					player:Cast("Unholy Frenzy")
				end
			end
		end
	end,
	
	gargoyle = function()
		if (player:Buff("Unholy Frenzy")) 
			and player:SpellCooldown("Summon Gargoyle")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Summon Gargoyle)")
			if lowestmelee 
				and lowestmelee:exists() 
				then 
				return lowestmelee:Cast("Summon Gargoyle")
			end
		end
	end,
	
	hasteburst = function()
		if (player:Buff("Unholy Frenzy")) 
			and player:SpellCooldown("Lifeblood")==0
			then 
			player:Cast("Lifeblood", true)
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
					and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=90
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Mind Freeze", true)
				end
			end
		end
	end,
	
	
	GrabGrab = function()
		if player:SpellCooldown("Death Grip")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if (_A.pull_location ~= "arena") or (_A.pull_location == "arena" and not hunterspecs[_A.UnitSpec(obj.guid)]) then
					if obj.isplayer and obj:isCastingAny() and obj:SpellRange("Death Grip") and obj:infront() 
						and (player:SpellCooldown("Mind Freeze")>_A.interrupttreshhold or not obj:caninterrupt() or not obj:SpellRange("Death Strike"))
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
			if not player:talent("Asphyxiate") and player:SpellCooldown("Strangulate")==0 and _A.someoneisuperlow() then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Strangulate")  and obj:infront() 
						-- and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and not obj:DebuffAny("Strangulate")
						and not obj:State("silence")
						and not obj:lostcontrol()
						and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and _A.notimmune(obj)
						and obj:los() then
						obj:Cast("Strangulate", true)
					end
				end
			end
		end
	end,
	
	strangulatesnipe_new = function()
		local lowhpcheck = false
		if (_A.blood>=1 or _A.death>=1)  then
			if not player:talent("Asphyxiate") and player:SpellCooldown("Strangulate")==0 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:range()<=40 and obj:health()<=35 then 
						if lowhpcheck ~= true then lowhpcheck = true end 
					end
					if lowhpcheck == true and obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Strangulate")  and obj:infront() 
						-- and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and not obj:DebuffAny("Strangulate")
						and not obj:State("silence")
						and not obj:lostcontrol()
						and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and _A.notimmune(obj)
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
	
	dotsnapshotOutBreak = function()
		local target = Object("target")
		if player:SpellCooldown("Outbreak")<.3 then 
			if target and target:exists()
				and target:enemy()
				and target:SpellRange("Outbreak")
				and target:infront()
				and _A.notimmune(target)
				then
				if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
					if  target:los() then
						-- print("refreshing dot")
						return target:Cast("Outbreak")
					end
				end
			end
		end
	end,
	
	dotsnapshotPS = function()
		local target = Object("target")
		if  player:SpellCooldown("Plague Strike")<.3 then 
			if target and target:exists()
				and target:enemy()
				and target:SpellRange("Plague Strike")
				and target:infront()
				and _A.notimmune(target)
				then
				if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
					if target:los() then
						-- print("refreshing dot")
						return target:Cast("Plague Strike")
					end
				end
			end
		end
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
	
	dkuhaoe = function()
		local pestcheck = false
		if _A.blood>=1 or _A.death>=1 then
			if player:Talent("Roiling Blood") then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj:range()<=10 then
						if _A.modifier_shift() then
							return player:Cast("Blood Boil")
						end
						if (Obj:Debuff("Frost Fever") and Obj:Debuff("Blood Plague")) then
							if  _A.notimmune(Obj) then
								pestcheck = true
							end
						end
					end
				end
				if pestcheck == true then
					for _, Obj in pairs(_A.OM:Get('Enemy')) do
						if (Obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid") and Obj:range()<10 then
							-- if  Obj:range()<10 then
							if (not Obj:Debuff("Frost Fever") and not Obj:Debuff("Blood Plague")) then
								if not _A.notimmune(Obj) then
									return player:Cast("Blood Boil")
								end
							end
						end
					end
				end
				
			end
		end
	end,
	
	pathoffrost = function()
		if _A.pull_location~="arena" and not player:combat() and not player:buffany("Path of Frost") then
			if _A.frost>=1 or _A.death>=1 then
				player:cast("path of frost")
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
	
	dotapplication = function()
		if player:SpellCooldown("Plague Strike")<.3
			then 
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) then
						return lowestmelee:Cast("Plague Strike")
					end
				end
			end
		end
	end,
	
	remorselesswinter = function()
		if player:Talent("Remorseless Winter") and player:SpellCooldown("Remorseless Winter")<.3 --Remorseless Winter
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if _A.numplayerenemies(8) >= 2 then
						return player:Cast("Remorseless Winter")
					end
				end
			end
		end
	end,
	
	massgrip = function()
		if player:Talent("Gorefiend's Grasp") and player:SpellCooldown("Gorefiend's Grasp")<.3 --Remorseless Winter
			then
			if _A.numplayerenemies(20) >= 3 then
				return player:Cast("Gorefiend's Grasp")
			end
		end
	end,
	
	pettransform = function()
		if player:BuffStack("Shadow Infusion")==5
			and (_A.unholy>=1 or _A.death>=1) -- default just unholy check
			and HasPetUI()
			then player:cast("Dark Transformation") -- pet transform -- NEED DOING
		end
	end,
	
	DeathcoilDump = function()
		if _A.dkenergy >= 85 then
			if player:SpellCooldown("Death Coil")<.3 
				and not player:BuffAny("Runic Corruption") 
				then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
				local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
				-- local lowestmelee = Object("lowestEnemyInSpellRange(Death Coil)")
				if lowestmelee then
					if lowestmelee:exists() then
						if not player:Buff("Lichborne") then
							return lowestmelee:Cast("Death Coil")
							else return player:Cast("Death Coil")
						end
					end
				end
			end
		end
	end,
	
	DeathcoilHEAL = function()
		if player:SpellCooldown("Death Coil")<.3 and player:Buff("Lichborne") 
			-- and not player:BuffAny("Runic Corruption") 
			then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			if _A.enoughmana(47541) then
				return player:Cast("Death Coil")
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
	
	NecroStrike = function()
		if  player:SpellCooldown("Necro Strike")<.3
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if lowestmelee.isplayer and player:buff("Unholy Strength || Surge of Victory || Call of Victory || Unholy Frenzy") then
						return lowestmelee:Cast("Necrotic Strike")
						else return lowestmelee:Cast("Scourge Strike")
					end
				end
			end
		end
	end,
	
	icytouchdispell = function()
		if player:SpellCooldown("Icy Touch")<.3 then
			-- if _A.frost>=1 or not player:buff("Unholy Strength || Surge of Victory || Call of Victory || Unholy Frenzy") then
			-- if _A.frost>=1 or not player:buff("Unholy Frenzy") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Icy Touch)")
			if lowestmelee and lowestmelee:exists() and lowestmelee:bufftype("Magic") then
				return lowestmelee:Cast("Icy Touch")
			end
			-- end
		end
	end,
	
	icytouch = function()
		-- if (_A.frost>_A.blood and _A.frost>=1) then
		if _A.frost>=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Icy Touch)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Icy Touch")
			end
		end
	end,
	
	bloodboilorphanblood = function()
		-- if ((_A.blood>_A.frost and _A.blood>=1))
		if _A.blood>=1
			then
			local lowestmelee = Object("lowestEnemyInRangeNOTARNOFACE(9)")
			if lowestmelee and lowestmelee:exists() then
				return player:Cast("Blood Boil")
			end
		end
	end,
	
	festeringstrike = function()
		if player:SpellCooldown("Festering Strike")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if not lowestmelee.isplayer then
					if lowestmelee:exists() then
						return lowestmelee:Cast("Festering Strike")
					end
				end
			end
		end
	end,
	
	
	Deathcoil = function()
		if player:SpellCooldown("Death Coil")<.3 and (player:buff("Sudden Doom") or _A.dkenergy>=32)
			and not player:BuffAny("Runic Corruption")  
			then 
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
			-- local lowestmelee = Object("lowestEnemyInSpellRange(Death Coil)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Death Coil")
			end
		end
	end,
	
	DeathcoilRefund = function()
		if _A.dkenergy<=80 
			and not player:BuffAny("Runic Corruption") 
			then
			if player:Glyph("Glyph of Death's Embrace") and player:SpellCooldown("Death Coil")<.3 and player:buff("Sudden Doom") then 
				if  _A.UnitExists("pet")
					and not _A.UnitIsDeadOrGhost("pet")
					and _A.HasPetUI() then
					local lowestmelee = Object("pet")
					if lowestmelee and lowestmelee:exists() and lowestmelee:SpellRange("Death Coil") and lowestmelee:los() then
						return lowestmelee:Cast("Death Coil")
					end
				end
			end
		end
	end,
	
	scourgestrike = function()
		if _A.unholy>=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if lowestmelee:health()>35
						then
						return lowestmelee:Cast("Scourge Strike")
					end
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
	if not enteredworldat then return end
	if enteredworldat and ((GetTime()-enteredworldat)<(3)) then return end
	player = Object("player")
	if not player then return end
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .2 + _A.latency
	if not _A.latency and not _A.interrupttreshhold then return end
	if not _A.pull_location then return end
	if _A.buttondelayfunc()  then return end
	if  player:isCastingAny() then return end
	if player:mounted() then return end
	if UnitInVehicle("player") then return end
	-- if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return end
	-- if player:lostcontrol()  then return end 
	unholy.rot.GrabGrab()
	unholy.rot.GrabGrabHunter()
	-- utility
	unholy.rot.caching()
	-- Burst and utility
	unholy.rot.items_strpot()
	unholy.rot.items_strflask()
	unholy.rot.hasteburst()
	unholy.rot.stance_dance()
	unholy.rot.icbf()
	unholy.rot.items_healthstone()
	unholy.rot.activetrinket()
	unholy.rot.Frenzy()
	unholy.rot.gargoyle()
	unholy.rot.Empowerruneweapon()
	unholy.rot.remorselesswinter()
	unholy.rot.massgrip()
	unholy.rot.pathoffrost()
	-- PVP INTERRUPTS AND CC
	unholy.rot.MindFreeze()
	unholy.rot.strangulatesnipe()
	unholy.rot.Asphyxiatesnipe()
	unholy.rot.AsphyxiateBurst()
	-- unholy.rot.darksimulacrum()
	unholy.rot.root()
	-- DEFS
	unholy.rot.antimagicshell()
	unholy.rot.petres()
	unholy.rot.deathpact()
	unholy.rot.Lichborne()
	-- rotation
	unholy.rot.DeathcoilDump()
	unholy.rot.dkuhaoe()
	unholy.rot.outbreak()
	unholy.rot.dotapplication()
	unholy.rot.pettransform()
	unholy.rot.BonusDeathStrike()
	unholy.rot.DeathcoilHEAL()
	unholy.rot.SoulReaper()
	----pve part
	if _A.pull_location == "party" or _A.pull_location == "raid" then
		unholy.rot.dotsnapshotOutBreak()
		unholy.rot.dotsnapshotPS()
		unholy.rot.festeringstrike()
	end
	----pvp part
	if _A.pull_location ~= "party" and _A.pull_location ~= "raid" then
		unholy.rot.icytouchdispell()
		unholy.rot.NecroStrike()
		unholy.rot.bloodboilorphanblood()
		unholy.rot.icytouch()
	end
	----filler
	unholy.rot.Deathcoil()
	unholy.rot.festeringstrike()
	unholy.rot.scourgestrike()
	unholy.rot.Buffbuff()
	unholy.rot.blank()
end
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(252, {
	name = "Youcef's Unholy DK",
	ic = inCombat,
	ooc = outCombat,
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
