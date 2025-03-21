local HarmonyMedia, _A, _Y = ...
local DSL = function(api) return _A.DSL:Get(api) end
local Listener = _A.Listener
local C_Timer = _A.C_Timer
local looping = C_Timer.NewTicker
local spell_name = function(idd) return _A.Core:GetSpellName(idd) end
local spell_ID = function(idd) return _A.Core:GetSpellID(idd) end
local cdcd
_A.FaceAlways = true
-- top of the CR
local player
local enteredworldat
local unholy = {}
local healerspecid = {
	-- [265]="Lock Affli",
	-- [266]="Lock Demono",
	-- [267]="Lock Destro",
	[105]="Druid Resto",
	-- [102]="Druid Balance",
	[270]="monk mistweaver",
	[65]="Paladin Holy",
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
local speedbuffs = {
	"Tiger's lust",
	"Blazing Speed",
	"Displacer Beast",
	"Dash",
	"Angelic Feather"
}
local function hasspeedbuff(unit)
	if unit then
		for _,v in pairs(speedbuffs) do
			if unit:BuffAny(v) then return true
			end
		end
	end
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
local grabthisfuck = {
}
local rootthisfuck = {
	["Chi Torpedo"]=true,
	["Roll"]=true,
	["Disengage"]=true,
}
local spelltable = {
	[5782] = 2,     -- Fear
	[1120] = 1,     -- Drain Soul
	[689] = 1,      -- Drain Life
	[30108] = 1,    -- Unstable Affliction
	[1454] = 1,     -- Life Tap
	[33786] = 2,    -- Cyclone
	[28272] = 2,    -- Polymorph (Pig)
	[118] = 2,      -- Polymorph
	[61305] = 2,    -- Polymorph (Black Cat)
	[61721] = 2,    -- Polymorph (Rabbit)
	[61780] = 2,    -- Polymorph (Turkey)
	[28271] = 2,    -- Polymorph (Turtle)
	[51514] = 2,    -- Hex
	[339] = 1,      -- Entangling Roots
	[30451] = 1,    -- Arcane Blast
	[20066] = 2,    -- Repentance
	[116858] = 2,   -- Chaos Bolt
	[113092] = 1,   -- Frost Bomb
	[8092] = 1,     -- Mind Blast
	[11366] = 1,    -- Pyroblast
	[48181] = 1,    -- Haunt
	[102051] = 1,   -- Frostjaw
	[1064] = 1,     -- Chain Heal
	[77472] = 2,    -- Greater Healing Wave
	[8004] = 2,     -- Healing Surge
	[73920] = 1,    -- Healing Rain
	[51505] = 1,    -- Lava Burst
	[8936] = 2,     -- Regrowth
	[2061] = 2,     -- Flash Heal
	[2060] = 2,     -- Heal
	[2006] = 1,     -- Resurrection
	[5185] = 2,     -- Healing Touch
	[19750] = 2,    -- Flash of Light
	[635] = 1,      -- Holy Light
	[7328] = 1,     -- Redemption
	[2008] = 1,     -- Ancestral Spirit
	[50769] = 1,    -- Revive
	[2812] = 1,     -- Holy Wrath
	[82327] = 1,    -- Holy Radiance
	[10326] = 2,    -- Turn Evil
	[82326] = 2,    -- Divine Light
	[116694] = 2,   -- Surging Mist
	[124682] = 1,   -- Enveloping Mist
	[115151] = 1,   -- Renewing Mist
	[115310] = 1,   -- Revival
	-- [126201] = 1,   -- Frostbolt (Water Elemental)
	[44614] = 1,    -- Frostfire Bolt
	[133] = 1,      -- Fireball
	[1513] = 1,     -- Scare Beast
	[982] = 2,      -- Revive Pet
	[111771] = 2,   -- Demonic Gateway
	-- [118297] = 1,   -- Immolate (Fel Imp)
	[29722] = 1,    -- Incinerate
	[124465] = 1,   -- Vampiric Touch
	[32375] = 2,    -- Mass Dispel
	[2948] = 1,     -- Scorch
	[12051] = 2,    -- Evocation
	[90337] = 2,    -- Bad Manner (Monkey Pet)
	[47540] = 2,    -- Penance
	[115268] = 2,   -- Mesmerize (Shivarra)
	[6358] = 2,     -- Seduction (Succubus)
	[51963] = 2,    -- Pain Suppression
	[78674] = 1,    -- Starsurge
	[113792] = 1,   -- Psychic Terror (Psyfiend)
	[115175] = 2,   -- Soothing Mist
	["Soothing Mist"] = 2,   -- Soothing Mist
	[115750] = 2,   -- Blinding Light
	[103103] = 1,   -- Drain Soul
	[113724] = 2,   -- Ring of Frost
	[117014] = 1,   -- Elemental Blast
	[605] = 1,      -- Mind Control
	[740] = 2,      -- Tranquility
	[32546] = 2,    -- Binding Heal
	[113506] = 2,   -- Cyclone (Symbiosis)
	[31687] = 2,    -- Summon Water Elemental
	[119996] = 1,   -- Transcendence: Transfer
	[117952] = 1,    -- Crackling Jade Lightning
	[116] = 1,      -- Frostbolt
	[50464] = 1,   -- Nourish
	[331] = 1,      -- Healing Wave
	[724] = 1,      -- Lightwell
	[129197] = 1,   -- Insanity
	[113656] = 2,   -- Fists of Fury
	[9484] = 2,   -- Shackle Undead
	["Polymorph"] = 2,     -- Drain Life
	["Cyclone"] = 2,   -- Shackle Undead
	["Shackle Undead"] = 2,   -- Shackle Undead
	["Hex"] = 2,   -- Shackle Undead
}

local function kickcheck(unit)
	if unit then
		for k,_ in pairs(spelltable) do
			if _A.Core:GetSpellName(k)~=nil then
				if unit:iscasting(k) or unit:channeling(k) then
					return true
				end
			end
		end
	end
	return false
end

local function kickcheck_nomove(unit)
	if unit then
		for k,_ in pairs(spelltable) do
			if _A.Core:GetSpellName(k)~=nil then
				if not unit:moving() and (unit:iscasting(k) or unit:channeling(k)) then
					return true
				end
			end
		end
	end
	return false
end

local function kickcheck_nomove_highprio(unit)
	if unit then
		for k,v in pairs(spelltable) do
			if _A.Core:GetSpellName(k)~=nil then
				if v==2 and not unit:moving() and (unit:iscasting(k) or unit:channeling(k)) then
					return true
				end
			end
		end
	end
	return false
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
	-- print("HEY HEY HEY HEY")
end
)
enteredworldat = enteredworldat or _A.GetTime()
_A.pull_location = _A.pull_location or pull_location()
local exeOnLoad = function()
	player = Object("player")
	_A.pressedbuttonat = 0
	_A.buttondelay = 0.5
	_A.STARTSLOT = 1
	_A.STOPSLOT = 8
	_A.GRABKEY = "R"
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
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
	_A.hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		--print(slot)
		Type, id, subType = _A.GetActionInfo(slot)
		if slot ~= _A.STARTSLOT and slot ~= _A.STOPSLOT and clickType~=nil
			then
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
	
	function _Y.depletedrune()
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
	
	function _Y.runes()
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
	_A.casttimers = {}
	_A.Listener:Add("delaycasts_DK", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
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
		end
	end)
	function _A.castdelay(idd, delay)
		if delay == nil then return true end
		if _A.casttimers[idd]==nil then return true end
		return (_A.GetTime() - _A.casttimers[idd])>=delay
	end
	-- dot snapshorring
	_A.enemyguidtab = {}
	local ijustdidthatthing = false
	local ijustdidthatthingtime = 0
	Listener:Add("DK_STUFF", {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED"} ,function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		player = Object("player")
		if not _A.Cache.Utils.PlayerInGame then return true end
		if event == "PLAYER_ENTERING_WORLD"
			or event == "PLAYER_REGEN_ENABLED"
			then
			if next(_A.enemyguidtab)~=nil then
				for k in pairs(_A.enemyguidtab) do
					if _A.enemyguidtab[k] then _A.enemyguidtab[k]=nil end
				end
			end
		end
		if event == "COMBAT_LOG_EVENT_UNFILTERED" --or event == "COMBAT_LOG_EVENT"
			then
			-- non player related
			--
			if subevent=="SPELL_CAST_SUCCESS" and player and guidsrc and guidsrc ~= UnitGUID("player") then -- only filter by me
				-- if UnitCanAttack(guidsrc) then
				-- local unit_event = guidsrc and _A.Object(guidsrc)
				local unit_event = _A.OM["Enemy"][guidsrc]
				if unit_event and unit_event.isplayer and unit_event:enemy() and rootthisfuck[spell_name(idd)] then
					-- print("HEY IM WORKING")
					C_Timer.NewTicker(.1, function()
						if (player:RuneCount("Frost")>=1 or player:RuneCount("Death")>=1)
							then 
							if unit_event:SpellRange("Chains of Ice") 
								and not unit_event:state("stun || incapacitate || fear || disorient || charm || misc || sleep || root") 
								and not unit_event:Debuffany("Chains of Ice || Hand of Freedom || Bladestorm")
								and not unit_event:buffany(45524)
								and not unit_event:buffany(48707)							
								and not unit_event:buffany(50435)	
								and _Y.notimmune(unit_event)
								-- and not unit:immune("snare")
								and not unit_event:buffany(1044)
								and unit_event:los() 
								then
								return unit_event:Cast("Chains of Ice")
							end
						end
					end, 10, "responsecast")
				end
			end
			--]]
			-- player related
			if guidsrc == UnitGUID("player") then -- only filter by me
				if subevent =="SPELL_CAST_SUCCESS" then
					if idd==85948 then --festering strike, refreshes dot duration but not stats
						ijustdidthatthing = true -- when true, means I just used FS
						ijustdidthatthingtime = GetTime()
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
					end
					if subevent=="SPELL_AURA_REMOVED" 
						then
						_A.enemyguidtab[guiddest]=nil
					end
				end	
			end
			--
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
			if Obj.isplayer  and Obj:spellRange(spell) 
				-- and Obj:Infront()
				and _A.isthisahealer(Obj) 
				and _Y.notimmune(Obj) and Obj:los() then
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
	_A.FakeUnits:Add('lowestEnemyInRangeNOTAR', function(num, spell)
		local tempTable = {}
		local target = Object("target")
		local tGUID = target and target.guid or " "
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and _Y.notimmune(Obj) 
				-- and not Obj:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") 
				and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					target = (Obj.guid==tGUID) and 1 or 0,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				if a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end)
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	_A.FakeUnits:Add('ClosestEnemyHealer', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:range()<=40 and healerspecid[Obj:spec()]
				and not Obj:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") 
				then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					range = Obj:range()
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				return a.range < b.range
			end)
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	--
	_A.FakeUnits:Add('lowestEnemyInRangeNOTARNOFACE', function(num, range_target)
		local tempTable = {}
		local range, target = _A.StrExplode(range_target)
		range = tonumber(range) or 40
		target = target or "player"
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:rangefrom(target)<=range  and  _Y.notimmune(Obj) and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				if a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end)
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
		local tGUID = target and target.guid or " "
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and _Y.notimmune(Obj) 
				and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					target = (Obj.guid==tGUID) and 1 or 0,
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
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangePETPOVPOV', function(num)
		local tempTable = {}
		local target = Object("target")
		if target and target:enemy() and target:alive()
			-- and  _Y.notimmune(target) 
			then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _Y.notimmune(Obj) 
				and Obj:range()<=40
				-- and  Obj:Infront()  
				then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				if a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end)
		end
		return tempTable[num] and tempTable[num].guid or nil
	end)
	--
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) 
				-- and Obj:Infront() 
				and _Y.notimmune(Obj) 
				and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort(tempTable, function(a,b)
				if a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end)
		end
		return tempTable[num] and tempTable[num].guid
	end)
	--========================
	
	
	function _Y.notimmune(unit) -- needs to be object
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
	
	function _Y.someoneisuperlow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:range()<40  then
				if Obj:Health()<35 then
					return true
				end
			end
		end
		return false
	end
	
	function _Y.enemyhealerexists()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _A.isthishuman(Obj.guid) and healerspecid[Obj:spec()]
				and Obj:range()<=40
				then
				return true
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
		-- local newDuration = math.random(5,15)/10
		-- local newDuration = .1
		-- local updatedDuration = ticker:UpdateTicker(newDuration)
		-- print(newDuration)
	end
	C_Timer.NewTicker(.1, MyTickerCallback, false, "dkstuff")
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	local badtotems = {
		"Mana Tide",
		"Lightwell",
		"Mana Tide Totem",
		"Healing Stream Totem",
		"Healing Tide",
		"Healing Tide Totem",
		"Lightning Surge Totem",
		"Earthgrab Totem",
		"Earthbind Totem",
		"Grounding Totem",
	}
	_A.FakeUnits:Add('HealingStreamTotem', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			for _,totems in ipairs(badtotems) do
				if Obj.name==totems then
					tempTable[#tempTable+1] = {
						guid = Obj.guid,
						range = Obj:range(),
					}
				end
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return a.range < b.range end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	_A.FakeUnits:Add('HealingStreamTotemPLAYUH', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			for _,totems in ipairs(badtotems) do
				if Obj.name==totems and Obj:range()<=29 and Obj:los() then
					tempTable[#tempTable+1] = {
						guid = Obj.guid,
						range = Obj:range(),
					}
				end
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return a.range < b.range end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	_A.PetGUID  = nil
	local function attacktotem()
		local htotem = Object("HealingStreamTotem")
		local pettargetguid = _A.UnitTarget("pet") or nil
		if htotem then
			if _A.PetGUID and (not pettargetguid or pettargetguid~=htotem.guid) then
				_A.PetAttack(htotem.guid)
				return true
			end
			return true
		end
		return false
	end
	local function attacklowest()
		local target = Object("lowestEnemyInSpellRangePETPOVPOV")
		local pettargetguid = _A.UnitTarget("pet") or nil
		if target then
			if (_A.pull_location~="party" and _A.pull_location~="raid") or target:combat() then -- avoid pulling shit by accident
				if _A.PetGUID and (not pettargetguid or pettargetguid~=target.guid) then
					_A.PetAttack(target.guid)
					return true
				end
			end
			return true
		end
		return false
	end
	function _Y.GetPetStance()
		local STANCE_ICONS = {
			"PET_MODE_PASSIVE",
			"PET_MODE_ASSIST",
			"PET_MODE_DEFENSIVE"
		}
		-- Check each pet action slot (1-10)
		for i = 1, 10 do
			local icon, _, _, _, isActive = GetPetActionInfo(i)
			if icon and isActive then
				-- Determine which stance is active based on the icon
				for _, stanceName in pairs(STANCE_ICONS) do
					if icon == stanceName then
						return stanceName
					end
				end
			end
		end
		return " " -- No active stance found
	end
	local function petpassive() -- when pet target has a breakable cc
		if _Y.GetPetStance() ~= "PET_MODE_PASSIVE" then
			_A.CallWowApi("RunMacroText", "/petpassive")
			return true
		end
	end
	local function petfollow() -- when pet target has a breakable cc
		if _A.PetGUID and _A.UnitTarget("pet")~=nil then
			local target = Object(_A.UnitTarget("pet"))
			if target and target:alive() and target:enemy() and target:exists() and target:stateYOUCEF("incapacitate || disorient || charm || misc || sleep ||fear") then
				_A.CallWowApi("RunMacroText", "/petfollow")
				return true
			end
		end
		return false
	end
	local function petfollow2() -- when pet target has a breakable cc
		if _A.PetGUID and _A.UnitTarget("pet")~=nil then
			_A.CallWowApi("RunMacroText", "/petfollow")
			return true
		end
		return false
	end
	local function petstunsnipe()
		local temptable = {}
		local pettargetguid = _A.UnitTarget("pet") or nil
		if player:SpellCooldown("Gnaw")==0
			and _Y.someoneisuperlow() then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=40 
					and _A.isthisahealer(obj)
					and not obj:buffany("Bear Form")
					and not obj:state("incapacitate || fear || disorient || charm || misc || sleep")
					and _Y.notimmune(obj)
					then
					temptable[#temptable+1] = {
						OBJ = obj,
						GUID = obj.guid,
						range = obj:range()
					}
				end
			end
			if #temptable>1 then
				table.sort(temptable, function(a,b) return a.range < b.range end )
			end
			if temptable[1] then 
				local pet = Object("pet")
				if pet
					and pet:rangefrom(temptable[1].OBJ)<=4
					and temptable[1].OBJ:stateduration("stun || incapacitate || fear || disorient || charm || misc || sleep || silence")<1.5 then 
					print("GNAW ON HEALER")
					temptable[1].OBJ:cast("Gnaw")
					return true
				end
				if _A.PetGUID and (not pettargetguid or pettargetguid~=temptable[1].GUID) then
					_A.PetAttack(temptable[1].GUID)
					return true
				end
				return true
			end
			return false
		end
		return false
	end
	function _Y.petengine()
		if not _A.Cache.Utils.PlayerInGame then return end
		if not player then return true end
		if not player:alive() then return true end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then return true end
		if player:mounted() then return true end
		if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return true end
		if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") or not _A.HasPetUI() then if _A.PetGUID then _A.PetGUID = nil end return true end
		_A.PetGUID = _A.PetGUID or _A.UnitGUID("pet")
		if _A.PetGUID == nil then return true end
		local pettargetguid_test = _A.UnitTarget("pet") or nil
		-- if pettargetguid_test then --print(UnitName(pettargetguid_test))
		-- end
		petpassive()
		-- Rotation
		if not IsCurrentSpell(47476) and not IsCurrentSpell(47481) and unholy.rot.strangulatesnipe() then return true end
		if not IsCurrentSpell(47476) and not IsCurrentSpell(47481) and petstunsnipe() then return true end
		if attacktotem() then return true end
		if attacklowest() then return true end
		if petfollow() then return true end
		if petfollow2() then return true end
	end
end
local exeOnUnload = function()
	Listener:Remove("Entering_timerPLZ")
	Listener:Remove("delaycasts_DK")
	Listener:Remove("DK_STUFF")
end
unholy.rot = {
	items_healthstone = function()
		if player:health() <= 35 then
			if player:ItemCooldown(5512) == 0
				and player:ItemCount(5512) > 0
				and player:ItemUsable(5512) then
				player:useitem("Healthstone")
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
			and player:combat()
			then
			if _A.pull_location=="pvp" then
				player:useitem("Flask of Winter's Bite")
			end
		end
	end,
	
	activetrinket = function()
		if player:combat() and player:buff("Surge of Victory") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee and lowestmelee.isplayer
				-- and lowestmelee:health()>=35
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
	
	bloodtap = function()
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
			and player:SpellCooldown("Summon Gargoyle")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Summon Gargoyle)")
			if lowestmelee 
				then 
				return lowestmelee:Cast("Summon Gargoyle")
			end
		end
	end,
	
	hasteburst = function()
		if (player:Buff("Unholy Frenzy")) 
			and player:SpellCooldown("Lifeblood")==0
			then 
			player:Cast("Lifeblood")
		end
	end,
	
	Empowerruneweapon = function()
		if player:SpellCooldown("Empower Rune Weapon")==0 and (player:Buff("Unholy Frenzy")) and _Y.depletedrune()>=3
			then 
			player:Cast("Empower Rune Weapon")
		end
	end,
	
	
	MindFreeze = function()
		if player:SpellCooldown("Mind Freeze")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Death Strike") 
					and obj:caninterrupt() 
					and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=90
					or (obj:spec()==270 and obj:chi()>=3)
					)
					and _Y.notimmune(obj)
					then
					if kickcheck(obj) then
						obj:Cast("Mind Freeze")
					end
				end
			end
		end
	end,
	
	
	GrabGrab = function()
		if player:SpellCooldown("Death Grip")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if (_A.pull_location ~= "arena") or (_A.pull_location == "arena" and not hunterspecs[_A.UnitSpec(obj.guid)]) then
					if obj.isplayer and obj:isCastingAny() and obj:SpellRange("Death Grip") 
						and (player:SpellCooldown("Mind Freeze")>0 or not obj:caninterrupt() or not obj:SpellRange("Death Strike"))
						and not obj:State("root")
						and _A.castdelay(45524 ,1.5)
						and _Y.notimmune(obj)
						and ( not _A.castdelay(49576,3) or ((obj:castsecond() < _A.interrupttreshhold) or obj:chanpercent()<=95 or (obj:spec()==270 and obj:chi()>=3)))
						
						then 
						if (kickcheck_nomove_highprio(obj) or  ( not _A.castdelay(49576,3) and kickcheck_nomove(obj))) or (healerspecid[obj:spec()] and obj:health()<=40 and kickcheck_nomove(obj)) then
							if obj:los() then
								obj:Cast("Death Grip")
							end
						end
					end
				end
			end
		end
	end,
	
	GrabGrabHunter = function()
		if _A.pull_location == "arena" then
			local roster = Object("party1")
			if player:SpellCooldown("Death Grip")==0 then
				if roster and roster:DebuffAny("Scatter Shot") then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if 	obj.isplayer and hunterspecs[_A.UnitSpec(obj.guid)] and obj:SpellRange("Death Grip") 
							and not obj:State("root")
							and _A.castdelay(45524 ,1.5)
							and _Y.notimmune(obj)
							and obj:los() then
							obj:Cast("Death Grip")
						end
					end
				end
			end
		end
	end,
	
	strangulatesnipe = function()
		if (player:RuneCount("Blood")>=1 or player:RuneCount("Death")>=1)  then
			if not player:talent("Asphyxiate") and player:SpellCooldown("Strangulate")==0 and _Y.someoneisuperlow() then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer  and _A.isthisahealer(obj) and obj:SpellRange("Strangulate")  
						and not obj:buffany("Bear Form")
						and obj:stateduration("stun || incapacitate || fear || disorient || charm || misc || sleep || silence")<1.5
						and (obj:drState("Strangulate") == 1 or obj:drState("Strangulate")==-1)
						and _Y.notimmune(obj)
						and obj:los() then
						obj:Cast("Strangulate")
					end
				end
			end
		end
	end,
	
	manual_deathgrip = function()
		if player and player:SpellReady("Death Grip") and player:SpellUsable("Death Grip")
			then
			local target = Object("target")
			if target
				and target:exists()
				and target:enemy()
				and target:spellRange("Death Grip")
				and target:alive()
				and not IsCurrentSpell(49576)
				and not target:State("root")
				and _A.castdelay(45524,0.5)
				and _A.isthishuman(target.guid)
				and _Y.notimmune(target)
				and target:los() then
				return target:Cast("Death Grip")
			end
		end
	end,
	
	Asphyxiatesnipe = function()
		if player:talent("Asphyxiate") and player:SpellCooldown("Asphyxiate")<cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Asphyxiate")  
					and not obj: state("stun || incapacitate || fear || disorient || charm || misc || sleep") 
					and not obj:DebuffAny("Asphyxiate")
					and not obj:State("silence")
					and (obj:drState("Asphyxiate") == 1 or obj:drState("Asphyxiate")==-1)
					and _Y.notimmune(obj)
					and _Y.someoneisuperlow()
					and obj:los() then
					return obj:Cast("Asphyxiate")
				end
			end
		end
	end,
	
	AsphyxiateBurst = function()
		if player:talent("Asphyxiate") and player:SpellCooldown("Asphyxiate")<cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer  and not _A.isthisahealer(obj)  and obj:SpellRange("Asphyxiate")  
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest"))
					and not obj: state("stun || incapacitate || fear || disorient || charm || misc || sleep") 
					and not obj:DebuffAny("Asphyxiate")
					and not obj:BuffAny("bladestorm")
					and not obj:BuffAny("Anti-Magic Shell")
					and not obj:State("silence")
					and (obj:drState("Asphyxiate") == 1 or obj:drState("Asphyxiate")==-1)
					and _Y.notimmune(obj)
					and obj:los() then
					return obj:Cast("Asphyxiate")
				end
			end
		end
	end,
	
	darksimulacrum = function()
		if player:RunicPower()>=20 and player and player:SpellCooldown("Dark Simulacrum")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer then
					if darksimulacrumspecsBGS[_A.UnitSpec(obj.guid)] or darksimulacrumspecsARENA[_A.UnitSpec(obj.guid)] 
						then
						if obj:SpellRange("Dark Simulacrum") 
							and not obj:State("silence") 
							and not obj: state("stun || incapacitate || fear || disorient || charm || misc || sleep") 
							and _Y.notimmune(obj)
							and obj:los() 
							then
							obj:Cast("Dark Simulacrum")
						end
					end
				end
			end
		end
	end,
	
	root_buff = function()
		if (player:RuneCount("Frost")>=1 or player:RuneCount("Death")>=1)
			and _A.castdelay(49576 ,1.5)
			and not IsCurrentSpell(49576) 
			then 
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:SpellRange("Chains of Ice") 
					and not obj: state("stun || incapacitate || fear || disorient || charm || misc || sleep || root || snare") 
					and not obj:Debuffany("Chains of Ice")
					and not obj:buffany("Hand of Freedom")
					and not obj:buffany(45524)
					and not obj:buffany(48707)							
					and not obj:buffany(50435)	
					and not obj:buffany("Bladestorm")
					and _Y.notimmune(obj)
					and not obj:buffany(1044)
					and hasspeedbuff(obj)
					and obj:los() 
					then
					return obj:Cast("Chains of Ice")
				end
			end
		end
	end,
	
	root = function()
		if (player:RuneCount("Frost")>=1 or player:RuneCount("Death")>=1) and _A.castdelay(49576 ,1.5) and not IsCurrentSpell(49576) then
			local target = Object("target")
			if target  
				and target.isplayer
				and not target:spellRange("Death Strike") 
				and target:spellRange("Chains of Ice") 
				and target:exists()
				and target:enemy() 
				and not target:buffany(50435)
				and not target:buffany(1044)
				and not target:buffany("Hand of Freedom")
				and not target:buffany(45524)
				and not target:buffany(48707)
				and not target:buffany("Bladestorm")
				and not target:Debuff("Chains of Ice") -- remove this
				and not target:state("root")
				and _Y.notimmune(target)
				then if target:los()
					then 
					return target:Cast("Chains of Ice")
				end
			end
		end
	end,
	
	
	dotsnapshotOutBreak = function()
		local target = Object("target")
		if player:SpellCooldown("Outbreak")<cdcd then 
			if target and target:exists()
				and target:enemy()
				and target:SpellRange("Outbreak")
				and _Y.notimmune(target)
				then
				if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
					if  target:los() then
						return target:Cast("Outbreak")
					end
				end
			end
		end
	end,
	
	dotsnapshotPS = function()
		local target = Object("target")
		if player:RuneCount("Death")>=1 or player:RuneCount("Unholy")>=1 then 
			if target and target:exists()
				and target:enemy()
				and target:SpellRange("Plague Strike")
				and _Y.notimmune(target)
				then
				if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
					if target:los() then
						return target:Cast("Plague Strike")
					end
				end
			end
		end
	end,
	
	petres = function()
		if player:SpellCooldown("Raise Dead")<cdcd then
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
				player:Cast("Anti-Magic Shell")
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
					player:cast("Lichborne")
				end
			end
		end
	end,
	
	dkuhaoe = function()
		local pestcheck = false
		if player:RuneCount("Blood")>=1 or player:RuneCount("Death")>=1 then
			if player:Talent("Roiling Blood") then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj:range()<=10 then
						if _A.modifier_shift() then
							return player:Cast("Blood Boil")
						end
						if (Obj:Debuff("Frost Fever") and Obj:Debuff("Blood Plague")) then
							if  _Y.notimmune(Obj) then
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
								if not _Y.notimmune(Obj) then
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
			if player:RuneCount("Frost")>=1 or player:RuneCount("Death")>=1 then
				player:cast("path of frost")
			end
		end
	end,
	
	outbreak = function()
		if player:SpellCooldown("Outbreak")<cdcd --OUTBREAK
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
		if (player:RuneCount("Unholy")>=1 or player:RuneCount("Death")>=1)
			then 
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) then
					return lowestmelee:Cast("Plague Strike")
				end
			end
		end
	end,
	
	remorselesswinter = function()
		if player:Talent("Remorseless Winter") and player:SpellCooldown("Remorseless Winter")<cdcd --Remorseless Winter
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if _A.numplayerenemies(8) >= 2 then
					return player:Cast("Remorseless Winter")
				end
			end
		end
	end,
	
	massgrip = function()
		if player:Talent("Gorefiend's Grasp") and player:SpellCooldown("Gorefiend's Grasp")<cdcd --Remorseless Winter
			then
			if _A.numplayerenemies(20) >= 3 then
				return player:Cast("Gorefiend's Grasp")
			end
		end
	end,
	
	pettransform = function()
		if player:BuffStack("Shadow Infusion")==5
			and (player:RuneCount("Unholy")>=1 or player:RuneCount("Death")>=1) -- default just unholy check
			and HasPetUI()
			then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and pet:range()<90 and pet:los() then
				return player:cast("Dark Transformation") -- pet transform -- NEED DOING
			end
		end
	end,
	
	DeathcoilDump = function()
		if player:RunicPower() >= 85 then
			if player:SpellCooldown("Death Coil")<cdcd
				and not player:BuffAny("Runic Corruption") then
				local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
				if lowestmelee then
					if not player:Buff("Lichborne") then
						return lowestmelee:Cast("Death Coil")
						else return player:Cast("Death Coil")
					end
				end
			end
		end
	end,
	
	DeathcoilHEAL = function()
		if player:SpellCooldown("Death Coil")<cdcd and player:Buff("Lichborne") 
			then
			if _A.enoughmana(47541) then
				return player:Cast("Death Coil")
			end
		end
	end,
	
	SoulReaper = function()
		if (player:RuneCount("Death")>=1 or player:RuneCount("Unholy")>=1) and player:SpellCooldown("Soul Reaper")<cdcd
			then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Soul Reaper)")
			if lowestmelee then
				if lowestmelee:health()<35 then
					return lowestmelee:Cast("Soul Reaper")
				end
			end
		end
	end,
	
    NecroStrike = function()
        if  player:RuneCount("Death")>=1
            then
            local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
            if lowestmelee then
				return lowestmelee:Cast("Necrotic Strike")
			end
		end
	end,
	
	icytouchdispell = function() -- BAD IDEA
		if player:RuneCount("Frost")>=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Icy Touch)")
			if lowestmelee and lowestmelee:exists() and lowestmelee:bufftype("Magic") then
				return lowestmelee:Cast("Icy Touch")
			end
		end
	end,
	
	icytouch = function()
		if player:RuneCount("Frost")>=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Icy Touch)")
			if lowestmelee  then
				return lowestmelee:Cast("Icy Touch")
			end
		end
	end,
	
	bloodboil_blood = function()
		if player:RuneCount("Blood")>=1
			then
			local lowestmelee = Object("lowestEnemyInRangeNOTARNOFACE(9)")
			if lowestmelee then
				return player:Cast("Blood Boil")
			end
		end
	end,
	
	festeringstrike = function()
		if player:RuneCount("Blood") >= 1 and player:RuneCount("Frost")>= 1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if not lowestmelee.isplayer then
					return lowestmelee:Cast("Festering Strike")
				end
			end
		end
	end,
	
	Deathcoil = function()
		if player:SpellCooldown("Death Coil")<cdcd and (player:buff("Sudden Doom") or player:RunicPower()>=32)
			and not player:BuffAny("Runic Corruption")  
			then 
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
			if lowestmelee then
				return lowestmelee:Cast("Death Coil")
			end
		end
	end,
	
	Deathcoil_totems = function()
		if player:SpellCooldown("Death Coil")<cdcd and (player:buff("Sudden Doom") or player:RunicPower()>=32)
			and not player:BuffAny("Runic Corruption")  
			then 
			local lowestmelee = Object("HealingStreamTotemPLAYUH")
			if lowestmelee then
				return lowestmelee:Cast("Death Coil")
			end
		end
	end,
	
	DeathcoilRefund = function()
		if player:RunicPower()<=80 
			and not player:BuffAny("Runic Corruption") 
			then
			if player:Glyph("Glyph of Death's Embrace") and player:SpellCooldown("Death Coil")<cdcd and player:buff("Sudden Doom") then 
				local lowestmelee = Object("pet")
				if lowestmelee and lowestmelee:exists() and lowestmelee:alive() and lowestmelee:SpellRange("Death Coil") and lowestmelee:los() then
					return lowestmelee:Cast("Death Coil")
				end
			end
		end
	end,
	
    scourgestrike = function()
        if player:RuneCount("Unholy")>=1 then
            local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Strike)")
            if lowestmelee then
				if (lowestmelee:health()>35 or player:level()<87 or player:SpellCooldown("Soul Reaper") > player:gcd()+1)
					then
					return lowestmelee:Cast("Scourge Strike")
				end
			end
		end
	end,
	
    plaguestrike = function()
        if player:RuneCount("Unholy")>=1 then
            local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Strike)")
            if lowestmelee then
				if (lowestmelee:health()>35 or player:level()<87 or player:SpellCooldown("Soul Reaper") > player:gcd()+1)
					then
					return lowestmelee:Cast("Plague Strike")
				end
			end
		end
	end,
	
	Buffbuff = function()
		if player:SpellCooldown("Horn of Winter")<cdcd and player:RunicPower() <= 90 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Horn of Winter")
		end
	end,
	
	pet_cower = function()
		if player:SpellCooldown("Huddle")==0 then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:health()<30 then
				return _A.CallWowApi("RunMacroText","/cast Huddle")
			end
		end
	end,
}
---========================
---========================
---======================== -- casting pet spells when pet is too far from spell target causes spell to stutter
---========================
---========================
local inCombat = function()
	if not _A.Cache.Utils.PlayerInGame then return true end
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
	if not enteredworldat then return true end
	if enteredworldat and ((GetTime()-enteredworldat)<(3)) then return true end
	player = Object("player")
	if not player then return true end
	local mylevel = player:level()
	_Y.petengine()
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .2 + _A.latency
	if not _A.latency and not _A.interrupttreshhold then return true end
	if not _A.pull_location then return true end
	-- if _A.buttondelayfunc()  then return true end
	if  player:isCastingAny() then return true end
	if player:mounted() then
		-- if unholy.rot.pathoffrost() then return true end
		return true
	end
	if UnitInVehicle("player") then return true end
	---------------------- NON GCD SPELLS
	-- Grabs
	unholy.rot.GrabGrab()
	unholy.rot.GrabGrabHunter()
	-- pet
	unholy.rot.pet_cower()
	-- unholy.rot.gnaw_TEST()
	-- Bursts
	unholy.rot.items_strpot()
	unholy.rot.items_strflask()
	unholy.rot.hasteburst()
	-- utility
	unholy.rot.icbf()
	unholy.rot.items_healthstone()
	unholy.rot.activetrinket()
	unholy.rot.Frenzy()
	unholy.rot.Empowerruneweapon()
	unholy.rot.MindFreeze()
	-- Defs
	unholy.rot.antimagicshell()
	unholy.rot.deathpact()
	unholy.rot.Lichborne()
	---------------------- GCD SPELLS
	-- BINDS
	if player:keybind("T") and unholy.rot.massgrip() then return true end
	if player:keybind("X") and unholy.rot.root() then return true end
	if player:keybind("R") and unholy.rot.manual_deathgrip() then return true end
	-- if not player:IsCurrentSpell(47476) and not player:IsCurrentSpell(47481) and unholy.rot.strangulatesnipe() then return true end
	--
	if mylevel>=74 and unholy.rot.gargoyle() then return true end
	if unholy.rot.remorselesswinter() then return true end
	-- PVP INTERRUPTS AND CC
	if player:SpellCooldown("Death Coil")>cdcd then return true end
	if unholy.rot.Asphyxiatesnipe() then return true end
	if unholy.rot.AsphyxiateBurst() then return true end
	-- if unholy.rot.darksimulacrum() then return true end -- causes jams maybe
	if mylevel>=74 and unholy.rot.root_buff() then return true end
	-- DEFS
	if unholy.rot.petres() then return true end
	-- rotation
	if unholy.rot.DeathcoilDump() then return true end
	if unholy.rot.dkuhaoe() then return true end
	if mylevel>=81 and unholy.rot.outbreak() then return true end
	if unholy.rot.dotapplication() then return true end
	if mylevel>=70 and unholy.rot.pettransform() then return true end
	if unholy.rot.BonusDeathStrike() then return true end
	if unholy.rot.DeathcoilHEAL() then return true end
	if mylevel>=87 and unholy.rot.SoulReaper() then return true end
	----pve part
	if _A.pull_location == "party" or _A.pull_location == "raid" then
		if mylevel>=81 and unholy.rot.dotsnapshotOutBreak() then return true end
		if unholy.rot.dotsnapshotPS() then return true end
		if mylevel>=62 and unholy.rot.festeringstrike() then return true end
	end
	----pvp part
	if _A.pull_location ~= "party" and _A.pull_location ~= "raid" then
		-- this always keeps one rune of each type regenning all the time
		if mylevel>=62 and unholy.rot.festeringstrike() then return true end
		if player:RuneCount("Blood")>= 2 and unholy.rot.bloodboil_blood() then return true end
		if player:RuneCount("Frost")>=2 and unholy.rot.icytouch() then return true end
		if player:RuneCount("Unholy")>=2 and mylevel>=58 and unholy.rot.scourgestrike() then return true end
		--
		if unholy.rot.bloodboil_blood() then return true end
		if unholy.rot.icytouch() then return true end
		if mylevel>=83 and unholy.rot.NecroStrike() then return true end
		if mylevel<83 and mylevel>=58 and unholy.rot.scourgestrike() then return true end
		if mylevel<83 and unholy.rot.plaguestrike() then return true end
	end
	----filler
	if unholy.rot.Deathcoil_totems() then return true end
	if unholy.rot.Deathcoil() then return  true end
	if mylevel>=62 and unholy.rot.festeringstrike() then return true end
	if mylevel>=58 and unholy.rot.scourgestrike() then return true end
	if unholy.rot.Buffbuff() then return true end
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(252, {
	name = "Youcef's Unholy DK",
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
