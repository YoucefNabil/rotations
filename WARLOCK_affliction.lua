local _,class = UnitClass("player")
if class~="WARLOCK"  then return end
local media, _A, _Y = ...
local DSL = function(api) return _A.DSL:Get(api) end
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local spell_name = function(idd) return _A.Core:GetSpellName(idd) end
local spell_ID = function(idd) return _A.Core:GetSpellID(idd) end
local cdcd = .3
local hooksecurefunc =_A.hooksecurefunc
local Listener = _A.Listener
local enteredworldat
local proccing
-- top of the CR
local player
local CallWowApi = _A.CallWowApi
local affliction = {}
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
local warriorspecs = {
	[71]=true,
	[72]=true,
	[73]=true
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
local function modifier_shift()
	local modkeyb = _A.IsShiftKeyDown()
	if modkeyb then return true
	end
	return false
end
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--snapshottable
local corruptiontbl = {}
local agonytbl = {}
local unstabletbl = {}
local seeds = {}
local swap_seeds = {}
local swap_unstabletbl = {}
local swap_agonytbl = {}
local swap_corruptiontbl = {}
local soulswaporigin = nil
local Ijustexhaled = false
local IjustTriple = false
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
--============================================
local GUI = {
}
local exeOnLoad = function()
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
		-- [64]="Mage Frost",
	}
	_A.Interface:AddToggle({
		key = "aoetoggle", 
		name = "AOE Seed of corruption swaps mode", 
		text = "ON : Seed of corruption swapping || OFF: 3 dot swapping (agony unstable affli corrpution)",
		icon = select(3,GetSpellInfo(27243)),
	})
	_A.Interface:AddToggle({
		key = "eye_demon", 
		name = "Observer pet", 
		text = "ON : Observer pet (good for bgs) || OFF: Void pet (good against physical in arena for disarms)",
		icon = select(3,GetSpellInfo(691)),
	})
	_A.Interface:AddToggle({
		key = "dontdps_ccdhealer", 
		name = "Do not dot or dps ccd healers", 
		text = "so to not break their cc, useful with hunters and stuff",
		icon = select(3,GetSpellInfo(5782)),
	})
	_A.Interface:AddToggle({
		key = "petchasetarget", 
		name = "send pet to target", 
		text = "ON : pet goes to target if exists OFF : pet always goes to lowest enemy within 40y",
		icon = select(3,GetSpellInfo(108482)),
	})
	_A.Interface:AddToggle({
		key = "ccheals", 
		name = "focus your stun talent on heals", 
		text = "ON : CCs heals only OFF : CCs anyone",
		icon = select(3,GetSpellInfo(1120)),
	})
	_A.Interface:AddToggle({
		key = "exhaleplayers", 
		name = "exhale players only", 
		text = "ON : exhale players only as a prio OFF : exhale everything",
		icon = select(3,GetSpellInfo(74434)),
	})
	_A.pull_location = pull_location()
	Listener:Add("Entering_timerPLZ", "PLAYER_ENTERING_WORLD", function(event)
		enteredworldat = _A.GetTime()
		local stuffsds = pull_location()
		_A.pull_location = stuffsds
		-- print("HEY HEY HEY HEY")
	end
	)
	enteredworldat = enteredworldat or _A.GetTime()
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
				-- local target = Object("target")
				-- if target then print(target:spec()) end
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
	
	function _A.modifier_ctrl()
		local modkeyb = IsControlKeyDown()
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
	
	local function caststart(unit)
		local givetime = GetTime()
		local tempvar = select(5, UnitCastingInfo(unit))
		local timetimetime15687
		if unit == nil
			then 
			unit = "target"
		end
		if UnitCastingInfo(unit)~=nil
			then timetimetime15687 = abs(givetime - (tempvar/1000)) 
		end
		return timetimetime15687 or 0
	end
	
	_A.DSL:Register('caststart', function(unit)
		return caststart(unit)
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
			if Obj.isplayer  and Obj:spellRange(spell) and Obj:Infront() and _A.isthisahealer(Obj) and _A.notimmune(Obj) 
				and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not healerspecid[Obj:spec()]) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
				and Obj:los() then
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
	
	_Y.seedtarget = {}
	
	Listener:Add("seedtargets", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		if guidsrc == UnitGUID("player") then
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				if spell_name(idd) == "Seed of Corruption"  then
					-- print(subevent, guiddest)
					if not _Y.seedtarget[guiddest] then _Y.seedtarget[guiddest]=true end
					C_Timer.After(5, function()
						if _Y.seedtarget[guiddest] then
							-- print("DELETE")
							_Y.seedtarget[guiddest]=nil
						end
					end)
				end
			end
			if subevent == "SPELL_AURA_APPLIED" then 
				if spell_name(idd) == "Seed of Corruption" then
					if _Y.seedtarget[guiddest] then
						-- print("DELETE")
						_Y.seedtarget[guiddest]=nil
					end
				end
			end
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
		local tempTable = {}
		local target = Object("target")
		if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.attackable and _A.notimmune(target) 
			and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not healerspecid[Obj:spec()]) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
			and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and Obj:Infront() and _A.notimmune(Obj) 
				and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not healerspecid[Obj:spec()]) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
				and Obj:los() then
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
			if Obj:spellRange(spell) and Obj:Infront() and  _A.notimmune(Obj) 
				and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not healerspecid[Obj:spec()]) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
				and Obj:los() then
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
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTARNOFACE', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if (Obj.isplayer or (_A.pull_location~="pvp" and _A.pull_location~="arena"))
				and Obj:spellRange(spell) and _A.notimmune(Obj) 
				and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not healerspecid[Obj:spec()]) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
				and Obj:los() then
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
	_A.Interface:ShowToggle("cooldowns", false)
	_A.Interface:ShowToggle("interrupts", false)
	_A.Interface:ShowToggle("aoe", false)
	local cusflags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
	function _A.groundpositionv2(unit)
		if unit then
			local x, y, z = _A.ObjectPosition(unit.guid)
			if x and y and z then
				local los, cx, cy, cz = _A.TraceLine(x, y, z + 5, x, y, z - 200, cusflags)
				if not los then
					return cx, cy, cz
				end
			end
		end
	end
	function _A.clickcastv2(unit, spell)
		local px, py, pz = _A.groundpositionv2(unit)
		if px then
			_A.CallWowApi("CastSpellByName", spell)
			if player:SpellIsTargeting() then
				_A.ClickPosition(px, py, pz)
				_A.CallWowApi("SpellStopTargeting")
			end
		end
	end
	--Cleaning
	_A.Listener:Add("lock_cleantbls", {"PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD"}, function(event)
		-- _A.Listener:Add("lock_cleantbls", "PLAYER_ENTERING_WORLD", function(event) -- better for testing, combat checks breaks with dummies
		if next(corruptiontbl)~=nil then
			for k in pairs(corruptiontbl) do
				corruptiontbl[k]=nil
			end
		end	
		if next(agonytbl)~=nil then
			for k in pairs(agonytbl) do
				agonytbl[k]=nil
			end
		end	
		if next(unstabletbl)~=nil then
			for k in pairs(unstabletbl) do
				unstabletbl[k]=nil
			end
		end
		if next(seeds)~=nil then
			for k in pairs(seeds) do
				seeds[k]=nil
			end
		end
		soulswaporigin = nil
	end)
	-- dots
	_Y.internalcooldown = (GetTime() - 50)
	_Y.chantarget = nil
	_A.Listener:Add("dotstables", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
		if guidsrc == UnitGUID("player") then -- only filter by me
			-------------- internal cooldown part
			if subevent == "SPELL_AURA_APPLIED" and spell_name(idd)=="Surge of Dominance" then _Y.internalcooldown = _A.GetTime() end -- 50 sec from the moment it procced
			-------------- STUFF
			if (spell_name(idd)=="Malefic Grasp" or spell_name(idd)=="Drain Soul") then 
				if (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_CAST_SUCCESS") then
					_Y.chantarget = guiddest
				end
				-- if subevent == "SPELL_AURA_REMOVED" then
				-- _Y.chantarget = nil
				-- end
			end
			-------------- dots part
				if (idd==146739) or (idd==172) then -- Corruption
					if (Ijustexhaled==false and IjustTriple == false) and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_CAST_SUCCESS")
						then
						print("CORRUPTION")
						corruptiontbl[guiddest]=_A.myscore() 
					end
					if subevent=="SPELL_AURA_REMOVED" 
						then
						corruptiontbl[guiddest]=nil
					end
				end
				if (idd==980) then -- AGONY
					if (Ijustexhaled==false and IjustTriple == false) and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_CAST_SUCCESS")
						then
						print("AGONY")
						agonytbl[guiddest]=_A.myscore()
					end
					if subevent=="SPELL_AURA_REMOVED" 
						then
						agonytbl[guiddest]=nil
					end
				end
				if (idd==30108) then -- Unstable Affli
					if (Ijustexhaled==false and IjustTriple == false) and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_CAST_SUCCESS")
						then
						print("UNSABLE AFFLI")
						unstabletbl[guiddest]=_A.myscore() 
					end
					if subevent=="SPELL_AURA_REMOVED" 
						then
						unstabletbl[guiddest]=nil
					end
				end

			if (idd==27243) then -- seed of corruption
				if (Ijustexhaled==false and IjustTriple == false) and subevent == "SPELL_CAST_SUCCESS"
					then
					print("SNEEDING")
					seeds[guiddest]= player:buff("Mannoroth's Fury") and _A.myscore()*5 or _A.myscore()
				end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					seeds[guiddest]=nil
				end
			end
			if (idd==119678) then -- Soulburn soul swap (applies all three)
				if subevent == "SPELL_CAST_SUCCESS"
					then
					print("TRIPLE DOT")
					IjustTriple = true
					C_Timer.After(.2, function()
						if IjustTriple then IjustTriple = false end
					end)
					corruptiontbl[guiddest]=_A.myscore() 
					unstabletbl[guiddest]=_A.myscore() 
					agonytbl[guiddest]=_A.myscore()
					-- ONLY APPLIES THESE 3 (and nothing else)
				end
			end
		end
	end
	)
	_Y.proc_check = function()
		-- if player and player:BuffDuration("Surge of Dominance")>=3 then return true end
		if player and player:Buff("Surge of Dominance") then return true end
		if _Y.internalcooldown and (_A.GetTime() - _Y.internalcooldown) >=50 then return true end
		return false
	end
	_Y.exitedvehicleat = GetTime()
	_A.Listener:Add("EXITING_VEHICLE", "UNIT_EXITING_VEHICLE", function(event, arg1)
		if arg1=="player" then
			_Y.exitedvehicleat = GetTime()
			-- print(event, arg1)
		end
	end)
	local soulswaptimer = nil
	-- Soul Swap
	_A.Listener:Add("soulswaprelated", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then -- only filter by me
			if subevent =="SPELL_CAST_SUCCESS" then -- accuracy needs to improve
				if idd==86121 then -- Soul Swap 86213
					print("SOULSWAP")
					if soulswaptimer then soulswaptimer:Cancel() soulswaptimer = nil end
					soulswaporigin = guiddest -- remove after 3 seconds or after exhalings
					swap_unstabletbl[guiddest]=unstabletbl[guiddest]
					swap_agonytbl[guiddest]=agonytbl[guiddest]
					swap_corruptiontbl[guiddest]=corruptiontbl[guiddest]
					swap_seeds[guiddest]=seeds[guiddest]
					soulswaptimer = C_Timer.NewTimer(3, function()
						if not player:buff("Soul Swap") then
							if swap_unstabletbl[guiddest] then swap_unstabletbl[guiddest]=nil end
							if swap_agonytbl[guiddest] then swap_agonytbl[guiddest]=nil end
							if swap_corruptiontbl[guiddest] then swap_corruptiontbl[guiddest]=nil end
							if swap_seeds[guiddest] then swap_seeds[guiddest]=nil end
							if soulswaporigin  then soulswaporigin = nil end
							print("DELETED DATA (ran out of time)")
						end
					end)
				end
				if idd==86213 then -- exhale
					print("EXHALE!!")
					if soulswaptimer then soulswaptimer:Cancel() soulswaptimer = nil end
					Ijustexhaled = true
					C_Timer.After(.2, function()
						if Ijustexhaled then Ijustexhaled = false end
					end)
					-- TEST PART
					unstabletbl[guiddest] = swap_unstabletbl[soulswaporigin]
					agonytbl[guiddest] = swap_agonytbl[soulswaporigin]
					corruptiontbl[guiddest] = swap_corruptiontbl[soulswaporigin]
					seeds[guiddest]=swap_seeds[soulswaporigin]
					print(unstabletbl[guiddest], agonytbl[guiddest], corruptiontbl[guiddest])
					swap_unstabletbl[guiddest]=nil
					swap_agonytbl[guiddest]=nil
					swap_corruptiontbl[guiddest]=nil
					swap_seeds[guiddest]=nil
					-- CLASSIC PART
					-- unstabletbl[guiddest]=unstabletbl[soulswaporigin]
					-- agonytbl[guiddest]=agonytbl[soulswaporigin]
					-- corruptiontbl[guiddest]=corruptiontbl[soulswaporigin]
					-- seeds[guiddest]=seeds[soulswaporigin]
					soulswaporigin = nil
				end
			end
		end
	end)
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then
			-- print(subevent.." "..idd)
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[spell_name(idd)] = _A.GetTime()
			end
		end
	end)
	function _A.castdelay(idd, delay)
		local ID = spell_name(idd)
		if delay == nil then return true end
		if _A.casttimers[ID]==nil then return true end
		return (_A.GetTime() - _A.casttimers[ID])>=delay
	end
	-------------------------
	-------------------------
	-------------------------
	-------------------------
	local badtotems = {
		"Mana Tide",
		"Wild Mushroom",
		"Mana Tide Totem",
		"Healing Stream Totem",
		"Healing Tide",
		"Spirit Link Totem",
		"Healing Tide Totem",
		"Lightning Surge Totem",
		"Earthgrab Totem",
		"Earthbind Totem",
		"Grounding Totem",
		"Stormlash Totem",
		"Psyfiend",
		"Lightwell",
		"Tremor Totem",
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
	_A.FakeUnits:Add('HealingStreamTotemNOLOS', function(num)
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
	_A.FakeUnits:Add('HealingStreamTotemPLAYER', function(num,spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			for _,totems in ipairs(badtotems) do
				if Obj.name==totems then
					if 	Obj:spellRange(spell) and  Obj:InConeOf(player, 170) and Obj:los() then
						tempTable[#tempTable+1] = {
							guid = Obj.guid,
							range = Obj:range(),
						}
					end
				end
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return a.range < b.range end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		return nil
	end)
	_A.PetGUID  = nil
	local function attacktotem()
		local htotem = Object("HealingStreamTotemNOLOS")
		if htotem and (_A.pull_location=="arena" or (toggle("pet_attacktotem") and htotem:range()<=60)) then
			if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=htotem.guid) then
				_A.PetAttack(htotem.guid)
				return true
			end
			return true
		end
	end
	_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKCNOLOS', function(num)
		local tempTable = {}
		local target = Object("target")
		local pet = Object("pet")
		if not pet then return end
		if pet and not pet:alive() then return end
		if pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
		--
		if toggle("petchasetarget") and target and target:enemy() and target:exists() and target:alive() and _A.notimmune(target)
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") then
			return target and target.guid -- this is good
		end
		local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
		if lowestmelee then
			return lowestmelee.guid
		end
		return nil
	end)
	local function attacklowest()
		local target = Object("lowestEnemyInSpellRangePetPOVKCNOLOS")
		if target then
			if (_A.pull_location~="party" and _A.pull_location~="raid") or target:combat() then -- avoid pulling shit by accident
				if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=target.guid) then
					_A.PetAttack(target.guid)
					return true
					elseif _A.UnitTarget(_A.PetGUID) and _A.UnitTarget(_A.PetGUID)==target.guid then
					local pet = Object("pet")
					-- XELETH SECTION
					if pet and UnitCreatureFamily("pet") == "Observer" then
						-- purge
						if target:bufftype("Magic") and target:rangefrom(pet)<=30 and pet:losfrom(target) and UnitPower("pet")>=40 and player:spellcooldown("Clone Magic(Special Ability)")<1.5 then 
						_A.CastSpellByName("Clone Magic(Special Ability)", target.guid) end
						-- lick
						if target:rangefrom(pet)<=6 and pet:losfrom(target) and UnitPower("pet")>=100 then _A.CastSpellByName("Tongue Lash(Basic Attack)", target.guid) end
					end
					--
				end
			end
			return true
		end
	end
	local function petfollow() -- when pet target has a breakable cc
		if _A.PetGUID and _A.UnitTarget(_A.PetGUID)~=nil then
			local target = Object(_A.UnitTarget(_A.PetGUID))
			if target and target:alive() and target:enemy() and target:exists() and target:stateYOUCEF("incapacitate || disorient || charm || misc || sleep ||fear") then
				_A.CallWowApi("RunMacroText", "/petfollow")
				return true
			end
		end
	end
	local function petsilencesnipe()
		local pet = Object("pet")
		local temptable = {}
		local pettargetguid = _A.UnitTarget("pet") or nil
		if pet and UnitCreatureFamily("pet") == "Observer" then
			if player:SpellCooldown("Optical Blast(Special Ability)")==0 and UnitPower("pet")>=20
				then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:range()<=80
						and _A.isthisahealer(obj)
						and not obj:buffany("Bear Form")
						and not obj:state("incapacitate || fear || disorient || charm || misc || sleep")
						and _A.notimmune(obj)
						then
						if 
							(obj:caninterrupt() and obj:isCastingAny() and (obj:caststart()>=0.15 or obj:chanpercent()<=92))
							or _Y.someoneisuperlow() 
							then
							temptable[#temptable+1] = {
								OBJ = obj,
								GUID = obj.guid,
								range = obj:range()
							}
						end
					end
				end
				if #temptable>1 then
					table.sort(temptable, function(a,b) return a.range < b.range end )
				end
				if temptable[1] then 
					if pet
						and pet:rangefrom(temptable[1].OBJ)<=40
						and temptable[1].OBJ:stateduration("stun || incapacitate || fear || disorient || charm || misc || sleep || silence")<1.5
						and pet:losfrom(temptable[1].OBJ)
						then 
						_A.CastSpellByName("Optical Blast(Special Ability)", temptable[1].GUID)
						return true
					end
					if _A.PetGUID and (not pettargetguid or pettargetguid~=temptable[1].GUID)
						then
						_A.PetAttack(temptable[1].GUID)
						return true
					end
					return true
				end
				return false
			end
			return false
		end
		return false
	end
	local function petdisarmsnipe()
		local pet = Object("pet")
		local temptable = {}
		local pettargetguid = _A.UnitTarget("pet") or nil
		if pet and UnitCreatureFamily("pet") == "Voidlord" then
			if player:SpellCooldown("Disarm(Special Ability)")==0 and UnitPower("pet")>=30
				then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:range()<=80
						and not _A.isthisahealer(obj)
						and not obj:buffany("Bear Form")
						and obj:BuffAny("Call of Victory || Call of Conquest || Call of Dominance")
						and not obj:state("incapacitate || fear || disorient || charm || misc || sleep")
						and not obj:BuffAny("Bladestorm")
						and _A.notimmune(obj)
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
					if pet
						and pet:rangefrom(temptable[1].OBJ)<=4
						and temptable[1].OBJ:stateduration("stun || incapacitate || fear || disorient || charm || misc || sleep || silence || disarm")<1.5
						and pet:losfrom(temptable[1].OBJ)
						then 
						_A.CastSpellByName("Disarm(Special Ability)", temptable[1].GUID)
						return true
					end
					if _A.PetGUID and (not pettargetguid or pettargetguid~=temptable[1].GUID)
						then
						_A.PetAttack(temptable[1].GUID)
						return true
					end
					return true
				end
				return false
			end
			return false
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
			return _A.CallWowApi("RunMacroText", "/petpassive"), 4
		end
	end
	function _Y.petengine_affli() -- REQUIRES RELOAD WHEN SWITCHING SPECS
		if not _A.Cache.Utils.PlayerInGame then return end
		if not player then return true end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then return true end
		if player:mounted() then return end
		if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return end
		if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") or not _A.HasPetUI() then if _A.PetGUID then _A.PetGUID = nil end return true end
		_A.PetGUID = _A.PetGUID or _A.UnitGUID("pet")
		if _A.PetGUID == nil then return end
		-- Pet Rotation
		if petpassive() then return end
		if petsilencesnipe() then return end
		if petdisarmsnipe() then return end
		if attacklowest() then return end
		if petfollow() then return end
	end
end
local exeOnUnload = function()
	Listener:Remove("Entering_timerPLZ")
	Listener:Remove("lock_cleantbls")
	Listener:Remove("EXITING_VEHICLE")
	Listener:Remove("soulswaprelated")
	Listener:Remove("delaycasts")
	Listener:Remove("dotstables")
	Listener:Remove("seedtargets")
end
local FLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}
local usableitems= { -- item slots
	13, --first trinket
	14 --second trinket
}
_A.temptabletbl = {}
affliction.rot = {
	blank = function()
	end,
	
	caching= function()
		-- _A.reflectcheck = false
		_A.shards = player:SoulShards()
		if not player:BuffAny(86211) and soulswaporigin ~= nil then soulswaporigin = nil end
		-- snapshot engine
		_A.temptabletbl = {}
		_A.temptabletblsoulswap = {}
		_A.temptabletblexhale = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and not Obj:charmed()
				and (not toggle("dontdps_ccdhealer") or (toggle("dontdps_ccdhealer") and not _A.isthisahealer(Obj)) or not Obj:state("incapacitate || fear || disorient || charm || misc || sleep"))
				and Obj:los() 
				then
				-- backup cleaning, for when spell aura remove event doesnt fire for some reason
				if corruptiontbl[Obj.guid]~=nil and not Obj:Debuff("Corruption") and corruptiontbl[Obj.guid] then corruptiontbl[Obj.guid]=nil end
				if agonytbl[Obj.guid]~=nil and not Obj:Debuff("Agony") and agonytbl[Obj.guid] then agonytbl[Obj.guid]=nil end
				if unstabletbl[Obj.guid]~=nil and not Obj:Debuff("Unstable Affliction") and unstabletbl[Obj.guid] then unstabletbl[Obj.guid]=nil end
				-- if unstabletbl[Obj.guid]~=nil and not Obj:Debuff("Seed of Corruption") and seeds[Obj.guid] then seeds[Obj.guid]=nil end
				local unstabledur, corruptiondur, agonydur, seedsdur, range_cache, healthraww =  Obj:DebuffDuration("Unstable Affliction"), Obj:DebuffDuration("Corruption"), Obj:DebuffDuration("Agony"), Obj:DebuffDuration("Seed of Corruption"), Obj:range(2) or 40, Obj:HealthActual() or 0
				--
				_A.temptabletbl[#_A.temptabletbl+1] = {
					obj = Obj,
					score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0), -- ALWAYS ORDER THIS BY SCORE FIRST
					agonyscore = (agonytbl[Obj.guid] or 0),
					unstablescore = (unstabletbl[Obj.guid] or 0),
					corruptionscore = (corruptiontbl[Obj.guid] or 0),
					seedscore = (seeds[Obj.guid] or 0),
					range = range_cache,
					health = healthraww,
					isplayer = Obj.isplayer and 1 or 0
				}
				if Obj.guid ~= soulswaporigin then -- can't exhale on the soulswap
					_A.temptabletblexhale[#_A.temptabletblexhale+1] = {
						obj = Obj,
						rangedis = range_cache,
						isplayer = Obj.isplayer and 1 or 0,
						health = healthraww,
						duration = unstabledur or 0, -- duration for unstable only, best solution to spread it to as many units as possible, always order by this first
						durationSEED = seedsdur or 0, -- duration, best solution to spread it to as many units as possible, always order by this first
					}
				end
				_A.temptabletblsoulswap[#_A.temptabletblsoulswap+1] = { -- dictates who to copy dots from, doing all dots duration in a cascade like this is important (keeps soul swapping even if unstable affli drops)
					obj = Obj,
					isplayer = Obj.isplayer and 1 or 0,
					duration = unstabledur or agonydur or corruptiondur or 0, -- DEFAULT 
					durationSEED = seedsdur or 0, -- DEFAULT 
				}
			end -- end of enemy filter
			if player:talent("Blood Horror") and warriorspecs[_A.UnitSpec(Obj.guid)] and Obj:range()<20 and _A.UnitTarget(Obj.guid)==player.guid then
				_A.reflectcheck = true
			end
		end -- end of iteration
		-- table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) end )
	end,
	
	
	everyman = function()
		if _A.pull_location ~= "arena" and not player:debuffany("Solar Beam") then
			if player:BuffAny(86211) and player:state("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") then
				if player:health()>=60 and player:talent("Unbound Will") and player:SpellCooldown("Unbound Will") == 0 and not player:IsCurrentSpell(108482)  then 
					return player:cast("Unbound Will")
				end
				if player:SpellCooldown("Every Man for Himself") == 0 and not player:IsCurrentSpell(59752) 
					and ((player:talent("Unbound Will") and player:SpellCooldown("Unbound Will") > 0 and player:SpellCooldown("Unbound Will") < 58) or not player:talent("Unbound Will"))   then 
					return player:cast("Every Man for Himself")
				end
			end
		end
	end,
	
	
	-- snare_curse = function() -- rework this
	-- if _A.flagcarrier ~=nil then 
	-- if not player:buff(74434) and not _A.flagcarrier:DebuffAny("Curse of Exhaustion") then
	-- return _A.flagcarrier:cast("Curse of Exhaustion")
	-- end
	-- end
	-- end,
	
	items_healthstone = function()
		if player:health() <= 54 then
			if player:ItemCooldown(5512) == 0
				and player:ItemCount(5512) > 0
				and player:ItemUsable(5512) 
				-- and (player:Buff("Dark Regeneration") or not player:talent("Dark regeneration"))
				then
				player:useitem("Healthstone")
			end
		end
	end,
	
	Darkregeneration = function()
		if player:health() <= 55 and player:talent("Dark Regeneration") then
			if player:SpellCooldown("Dark Regeneration") == 0 and not player:IsCurrentSpell(108359)
				then
				player:cast("Dark Regeneration")
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
	
	stop_chan_on_dead = function()
		if player:isChanneling("Drain Soul") or player:isChanneling("Malefic Grasp") then
			if _Y.chantarget and _A.UnitIsDeadOrGhost(_Y.chantarget) then
				_A.CallWowApi("RunMacroText", "/stopcasting")
				_Y.chantarget = nil
			end
		end
	end,
	--============================================
	--============================================
	summ_healthstone = function()
		if (player:ItemCount(5512) == 0 and player:ItemCooldown(5512) < 2.55 ) or (player:ItemCount(5512) < 3 and not player:combat()) then
			if not player:moving() and not player:Iscasting("Create Healthstone") and _A.castdelay(6201, 1.5) then
				if _A.enoughmana(6201) then
					player:cast("Create Healthstone")
				end
			end
		end
	end,
	--============================================
	activetrinket = function()
		local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
		if proccing and lowest and not player:state("silence || disarm") then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 then 
							if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
								player:cast("Lifeblood") -- 2 min
								player:useitem("Potion of the Jade Serpent") -- 3min
								player:cast("Dark Soul: Misery") -- 2min x2
								else
								return _A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i]))) --1min
							end
						end
					end
				end
			end
		end
	end,
	
	hasteburst = function()
		if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
			if player:buff("Call of Dominance") then
				player:cast("Lifeblood")
				player:useitem("Potion of the Jade Serpent")
				player:cast("Dark Soul: Misery")
			end
		end
	end,
	
	items_intpot = function()
		if not player:isCastingAny() and player:ItemCooldown(76093) == 0
			and player:ItemCount(76093) > 0
			and player:ItemUsable(76093)
			and player:Buff("Dark Soul: Misery")
			then
			player:cast("Lifeblood")
			player:useitem("Potion of the Jade Serpent")
		end
	end,
	
	--============================================
	--============================================
	--============================================
	
	petres = function()
		if player:talent("Grimoire of Sacrifice") and not player:Buff("Grimoire of Sacrifice") and player:SpellCooldown("Grimoire of Sacrifice")==0 then
			if 
				-- not _A.UnitExists("pet")
				-- or _A.UnitIsDeadOrGhost("pet")
				-- or 
				not _A.HasPetUI()
				then 
				if not player:moving() and not player:iscasting("Summon Imp") then
					return player:cast("Summon Imp")
				end
			end
		end
	end,
	
	petres_supremacy = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112866)<.3 and _A.castdelay(112866, 1.5) and not player:iscasting(112866) and _A.enoughmana(112866)  then
				local petobj = UnitCreatureFamily("pet")
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Fel Imp")
					then 
					if (not player:buff(74434) and not player:IsCurrentSpell(74434) and player:SpellCooldown(74434)==0 and _A.shards>=1 )
						then player:cast(74434) -- shadowburn
						return player:cast(112866)
					end	
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112866)
					end
				end
			end
		end
	end,
	
	petres_supremacy2 = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112869)<.3 and _A.castdelay(112869, 1.5) and not player:iscasting(112869) and _A.enoughmana(112869)  then
				local petobj = UnitCreatureFamily("pet")
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Observer")
					then 
					if (not player:buff(74434) and not player:IsCurrentSpell(74434) and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
						then player:cast(74434) -- shadowburn
						return player:cast(112869)
					end	
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112869)
					end
				end
			end
		end
	end,
	
	petres_supremacy3 = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112867)<.3 and _A.castdelay(112867, 1.5) and not player:iscasting(112867) and _A.enoughmana(112867)  then
				local petobj = UnitCreatureFamily("pet") 
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Voidlord")
					then 
					if (not player:buff(74434) and not player:IsCurrentSpell(74434) and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
						then player:cast(74434) -- shadowburn
						return player:cast(112867)
					end	
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112867)
					end
				end
			end
		end
	end,
	
	healthfunnel = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy") then
				if 
					_A.UnitExists("pet")
					and not _A.UnitIsDeadOrGhost("pet")
					and _A.HasPetUI()
					then
					local pet = Object("pet")
					if  player:glyph("Glyph of Health Funnel") and player:SpellCooldown("Health Funnel")<.3 and player:SpellUsable("Health Funnel") and pet and pet:health()<85 and pet:los() then
						return player:cast("Health Funnel")
					end
				end
			end
		end
	end,
	
	CauterizeMaster = function()
		if player:health() <= 85 then
			if player:SpellUsable("Cauterize Master") and player:SpellCooldown("Cauterize Master") == 0  then
				player:cast("Cauterize Master")
			end
		end
	end,
	
	MortalCoil = function()
		if player:health() <= 85 then
			if player:Talent("Mortal Coil") and player:SpellCooldown("Mortal Coil")<.3  then
				local lowest = Object("lowestEnemyInSpellRangeNOTAR(Mortal Coil)")
				if lowest then
					return lowest:cast("Mortal Coil")
				end
			end
		end
	end,
	
	Buffbuff = function()
		if player:talent("Grimoire of Sacrifice") and player:SpellCooldown("Grimoire of Sacrifice")==0 and _A.HasPetUI() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Grimoire of Sacrifice")
		end
	end,
	
	darkintent = function()
		if not player:buffany("Dark Intent") and _A.enoughmana(109773) then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Dark Intent")
		end
	end,
	
	twilightward = function()
		if player:SpellCooldown("Twilight Ward")<.3 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Twilight Ward")
		end
	end,
	
	bloodhorror = function()
		if _A.reflectcheck == false and player:Talent("Blood Horror") and player:SpellCooldown("Blood Horror")<.3 and player:health()>10 and not player:buff("Blood Horror") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Blood Horror")
		end
	end,
	
	bloodhorrorremovalopti = function() -- rework this
		if _A.reflectcheck == true and player:talent("Blood Horror") then
			-- print("REMOVING REMOVING REMOVING")
			_A.RunMacroText("/cancelaura Blood Horror")
		end
	end,
	
	snare_curse = function() -- rework this
		local flagcarry = nil
		if _A.pull_location == "pvp" and not player:buff(74434) then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.attackable(Obj) and (Obj:BuffAny("Alliance Flag") or Obj:BuffAny("Horde Flag")) and not Obj:Debuff("Curse of Exhaustion") and _A.notimmune(Obj) and Obj:los() then
					flagcarry = Obj
				end
			end
			return flagcarry and flagcarry:cast("Curse of Exhaustion")
		end
	end,
	
	lifetap_delayed = function()
		if player:health()>=35
			and player:Mana()<=80
			and soulswaporigin ~= nil
			and (_A.castdelay(1454, 30) or player:Mana()<=12)  -- 35sec delay
			then return player:cast("Life Tap")
		end
	end,
	
	lifetap= function()
		if 	player:health()>=35
			and player:Mana()<=80
			then
			return player:cast("life tap")
		end
	end,
	
	ccstun = function()
		if player:talent("Shadowfury") and player:SpellCooldown("Shadowfury") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=30
					and obj:infront()
					and (not toggle("ccheals") or toggle("ccheals") and _A.isthisahealer(obj))
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
					and (obj:drState("Shadowfury") == 1 or obj:drState("Shadowfury") == -1)
					and _A.notimmune(obj)
					and not obj:immune("stun")
					and obj:los() then
					return _A.clickcastv2(obj, "Shadowfury")
				end
			end
		end
	end,
	
	ccfear = function()
		if player:SpellCooldown("Howl of Terror") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=10
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
					and (obj:drState("Howl of Terror") == 1 or obj:drState("Howl of Terror") == -1)
					and _A.notimmune(obj)
					and not obj:immune("fear")
					and obj:los() then
					return player:cast("Howl of Terror")
				end
			end
		end
	end,
	
	fearkeybind = function()
		if not player:moving() and not player:isCastingAny() then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=30
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
					and (obj:drState("Fear") == 1 or obj:drState("Fear") == -1)
					and _A.notimmune(obj)
					and obj:los() then
					return obj:cast("Fear")
				end
			end
		end
	end,
	
	ccstun_def = function()
		if player:talent("Shadowfury") and player:SpellCooldown("Shadowfury") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=30
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
					and (obj:BuffAny("Call of Victory || Call of Conquest || Call of Dominance") or obj:isCastingAny())
					and (obj:drState("Shadowfury") == 1 or obj:drState("Shadowfury") == -1)
					and _A.notimmune(obj)
					and obj:los() then
					return _A.clickcastv2(obj, "Shadowfury")
				end
			end
		end
	end,
	--- SEEEEEEEEEEEEEED
	soulswapoptiSEED = function()
		if  #_A.temptabletbl>1 and soulswaporigin == nil and _A.enoughmana(86121) then
			if #_A.temptabletblsoulswap > 1 then
				table.sort(_A.temptabletblsoulswap, function(a,b)
					return a.durationSEED > b.durationSEED -- always by highest duration
				end)
			end
			return _A.temptabletblsoulswap[1] and _A.temptabletblsoulswap[1].obj:debuff("Seed of Corruption") and _A.temptabletblsoulswap[1].obj:Cast(86121)
		end
	end,
	
	exhaleoptiSEED = function()
		if soulswaporigin ~= nil then
			if #_A.temptabletblexhale > 1 then
				table.sort(_A.temptabletblexhale, function(a,b)
					if 	
						toggle("exhaleplayers") and a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer -- Never change these
						elseif
						a.durationSEED ~= b.durationSEED then return a.durationSEED < b.durationSEED
						else return
						a.health > b.health
					end
				end)
				
			end
			return _A.temptabletblexhale[1] and _A.temptabletblexhale[1].obj:Cast(86213)
		end
	end,
	
	corruptionsSEED = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.corruptionscore ~= b.corruptionscore then return a.corruptionscore > b.corruptionscore
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
		if proccing and lowest and not player:state("silence || disarm") then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 and (player:spellcooldown("Mannoroth's Fury")==0 or not player:talent("Mannoroth's Fury")) then 
							if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
								player:cast("Lifeblood") -- 2 min
								player:useitem("Potion of the Jade Serpent") -- 3min
								player:cast("Dark Soul: Misery") -- 2min x2
								else
								player:cast(108508)
								_A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i]))) --1min
							end
						end
					end
				end
			end
		end
		if _A.temptabletbl[1] and _A.enoughmana(172)  then 
			if _A.myscore()>_A.temptabletbl[1].corruptionscore then return _A.temptabletbl[1].obj:Cast("Corruption")
			end
		end
	end,
	
	Sneedofcorruption = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.seedscore ~= b.seedscore then return a.seedscore > b.seedscore
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
		if proccing and lowest and not player:state("silence || disarm") then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 and (player:spellcooldown("Mannoroth's Fury")==0 or not player:talent("Mannoroth's Fury")) then 
							if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
								player:cast("Lifeblood") -- 2 min
								player:useitem("Potion of the Jade Serpent") -- 3min
								player:cast("Dark Soul: Misery") -- 2min x2
								else
								player:cast(108508)
								_A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i]))) --1min
							end
						end
					end
				end
			end
		end
		if _A.temptabletbl[1] and not _Y.seedtarget[_A.temptabletbl[1].obj.guid] and _A.enoughmana(27243) and not player:buff(74434) 
			-- and not _A.temptabletbl[1].obj:debuff("Seed of Corruption") 
			then
			if player:talent("Mannoroth's Fury") and player:spellcooldown("Mannoroth's Fury")==0 and not player:IsCurrentSpell(108508) then player:cast(108508) end
			if _A.myscore()>_A.temptabletbl[1].seedscore then return _A.temptabletbl[1].obj:cast("Seed of Corruption") end
		end
	end,
	
	SneedofcorruptionHIGHPRIO = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.corruptionscore ~= b.corruptionscore then return a.corruptionscore > b.corruptionscore
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
		if proccing and lowest and not player:state("silence || disarm") then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 and (player:spellcooldown("Mannoroth's Fury")==0 or not player:talent("Mannoroth's Fury")) then 
							if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
								player:cast("Lifeblood") -- 2 min
								player:useitem("Potion of the Jade Serpent") -- 3min
								player:cast("Dark Soul: Misery") -- 2min x2
								else
								player:cast(108508)
								_A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i]))) --1min
							end
						end
					end
				end
			end
		end
		if _A.temptabletbl[1] and not _Y.seedtarget[_A.temptabletbl[1].obj.guid] and _A.enoughmana(27243) and not player:buff(74434) 
			and player:buff("Mannoroth's Fury") and _A.castdelay(27243, 12)
			then
			if player:talent("Mannoroth's Fury") and player:spellcooldown("Mannoroth's Fury")==0 and not player:IsCurrentSpell(108508) then player:cast(108508) end
			if _A.myscore()>_A.temptabletbl[1].seedscore then return _A.temptabletbl[1].obj:cast("Seed of Corruption") end
		end
	end,
	
	------------------
	
	
	corruptionsnap = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.score ~= b.score then return a.score > b.score
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and _A.enoughmana(172)  then 
			if _A.myscore()>_A.temptabletbl[1].corruptionscore then return _A.temptabletbl[1].obj:Cast("Corruption")
			end
		end
	end,
	
	
	
	agonysnap = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.score ~= b.score then return a.score > b.score
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and _A.myscore()>_A.temptabletbl[1].agonyscore and _A.enoughmana(980) 
			then return _A.temptabletbl[1].obj:Cast("Agony")
		end
	end,
	
	unstablesnapinstant = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.score ~= b.score then return a.score > b.score
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and  _A.myscore()> _A.temptabletbl[1].unstablescore and player:SpellCooldown("Unstable Affliction")<.3 then 
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 and proccing then 
							if (player:SpellCharges("Dark Soul: Misery")>=1 or player:SpellCooldown("Dark Soul: Misery")==0) and not player:IsCurrentSpell(113860) then
								player:cast("Lifeblood")
								player:useitem("Potion of the Jade Serpent")
								player:cast("Dark Soul: Misery")
								else
								return _A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i])))
							end
						end
					end
				end
			end
			--
			if  _A.shards>=1 and not player:buff(74434) and player:SpellCooldown(74434)==0  and not player:IsCurrentSpell(74434)--or player:buff("Shadow Trance")
				then player:cast(74434) -- shadowburn
				return _A.temptabletbl[1].obj:Cast(119678)
			end
			if player:buff(74434) then
				return _A.temptabletbl[1].obj:Cast(119678)
			end
		end -- improved soul swap (dots instead)
	end,
	
	unstablesnap = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.score ~= b.score then return a.score > b.score
					elseif 
					-- a.range ~= b.range then return a.range < b.range
					a.health ~= b.health then return a.health > b.health
					-- a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					-- else return 
					-- a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and not player:buff(74434) and _A.myscore()>_A.temptabletbl[1].unstablescore  then 
			if not player:moving() and not player:Iscasting("Unstable Affliction") 
				-- and _A.shards==0 
				then
				return _A.temptabletbl[1].obj:Cast("Unstable Affliction")
			end
		end
	end,
	
	haunt = function()
		if _A.castdelay(48181, 1.5) and _A.shards>=1 and not player:isCastingAny() and not player:moving()  then
			local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
			if lowest and lowest:exists() and not lowest:debuff(48181) then
				return lowest:cast("haunt")
			end
		end
	end,
	
	grasp = function()
		if not player:isCastingAny() and not player:isChanneling("Malefic Grasp")  and (not player:moving() or player:talent("Kil'jaeden's Cunning")) and _A.enoughmana(103103)  then
			local lowest = Object("lowestEnemyInSpellRangeNOTARNOFACE(Corruption)")
			if lowest and lowest:exists() and (lowest:health()>20 or (player:talent("Kil'jaeden's Cunning") and player:moving())) then
				return lowest:FaceCast("Malefic Grasp", true)
			end
		end
	end,
	
	felflame = function()
		if not player:isCastingAny() and _A.enoughmana(77799) then
			local lowest = Object("lowestEnemyInSpellRangeNOTARNOFACE(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:FaceCast("fel flame")
			end
		end
	end,
	
	drainsoul = function()
		if not player:moving() 
			and not player:isChanneling("Drain Soul")
			and _A.enoughmana(1120)
			then
			local lowest = Object("lowestEnemyInSpellRangeNOTARNOFACE(Corruption)")
			if lowest and lowest:exists() and lowest:health()<=20 then
				return lowest:FaceCast("Drain Soul", true)
			end
		end
	end,
	
	drainsoul_exec = function()
		if not player:moving() 
			and not player:isChanneling("Drain Soul")
			and _A.enoughmana(1120)
			-- and _A.shards<=1
			then
			local lowest = Object("lowestEnemyInSpellRangeNOTARNOFACE(Corruption)")
			if lowest and lowest:exists() then
				return lowest:FaceCast("Drain Soul", true)
			end
		end
	end,
	
	soulswapopti = function()
		if  #_A.temptabletbl>1 and soulswaporigin == nil and _A.enoughmana(86121) then
			if #_A.temptabletblsoulswap > 1 then
				table.sort(_A.temptabletblsoulswap, function(a,b)
					return a.duration > b.duration -- always by highest duration
				end)
			end
			return _A.temptabletblsoulswap[1] and _A.temptabletblsoulswap[1].obj:Cast(86121)
		end
	end,
	
	exhaleopti = function()
		if soulswaporigin ~= nil then
			if #_A.temptabletblexhale > 1 then
				table.sort(_A.temptabletblexhale, function(a,b)
					if 	
						toggle("exhaleplayers") and a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer -- Never change these
						elseif
						a.duration ~= b.duration then return a.duration < b.duration
						else return
						a.health > b.health
					end
				end)
				
			end
			return _A.temptabletblexhale[1] and _A.temptabletblexhale[1].obj:Cast(86213)
		end
	end,
	
	items_intflask = function()
		if player:ItemCooldown(76085) == 0 and not player:isCastingAny() 
			and player:ItemCount(76085) > 0
			and player:ItemUsable(76085)
			and not player:Buff(105691)
			then
			if pull_location()=="pvp" then
				return player:useitem("Flask of the Warm Sun")
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
	if not _A.Cache.Utils.PlayerInGame then return true end
	if not enteredworldat then return true end
	if enteredworldat and ((GetTime()-enteredworldat)<(3)) then return true end
	player = Object("player")
	if not player then return end
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
	if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat<= 1 then return true end
	if player:Mounted() then return true end
	proccing = _Y.proc_check()
	--
	--
	_Y.petengine_affli()
	affliction.rot.stop_chan_on_dead()
	-- CTRL MODE (Beams)
	if _A.modifier_ctrl() then
		if affliction.rot.drainsoul() then return true end
		if affliction.rot.grasp()  then return true end
	end
	if affliction.rot.everyman() then return true end
	--bursts
	-- shift mode (haunt)
	--HEALS
	affliction.rot.Darkregeneration()
	affliction.rot.items_healthstone()
	if not _A.BUTTONHOOK_RELATED and _A.buttondelayfunc() then return true end -- pausing for manual casts
	-- if player:lostcontrol() then return end 
	--delayed lifetap
	if affliction.rot.lifetap_delayed() then return true end
	--exhale
	affliction.rot.caching()
	if player:spellcooldown("Corruption")>cdcd*2 then return true end
	affliction.rot.activetrinket()
	if _A.modifier_shift() then
		if affliction.rot.haunt()  then return true end
	end
	if toggle("aoetoggle") then
		if affliction.rot.exhaleoptiSEED() then return true end
		if affliction.rot.corruptionsSEED() then return true end
		if affliction.rot.SneedofcorruptionHIGHPRIO() then return true end
		if affliction.rot.soulswapoptiSEED() then return true end
		if affliction.rot.Sneedofcorruption() then return true end
		return true
	end
	if affliction.rot.exhaleopti()  then return true end
	--stuff
	if affliction.rot.Buffbuff()  then return true end
	affliction.rot.items_intflask()
	if affliction.rot.petres()  then return true end
	if not toggle("eye_demon") and affliction.rot.petres_supremacy3() then return true end
	if toggle("eye_demon") and affliction.rot.petres_supremacy2() then return true end
	-- if affliction.rot.summ_healthstone() then return true end
	if affliction.rot.CauterizeMaster()  then return true end
	if affliction.rot.MortalCoil()  then return true end
	if affliction.rot.twilightward()  then return true end
	--utility 
	if affliction.rot.bloodhorrorremovalopti()  then return true end
	if affliction.rot.bloodhorror() then return true end
	if affliction.rot.ccfear() then return true end	
	if affliction.rot.ccstun()  then return true end	
	if affliction.rot.snare_curse()  then return true end
	-- Heal pet
	if affliction.rot.healthfunnel() then return true end
	-- DOT DOT
	if not proccing then
		if affliction.rot.agonysnap()  then return true end
		if affliction.rot.corruptionsnap()  then return true end
		if affliction.rot.unstablesnap()  then return true end
	end
	if affliction.rot.unstablesnapinstant() then return true end
	if affliction.rot.agonysnap()  then return true end
	if affliction.rot.corruptionsnap()  then return true end
	if affliction.rot.unstablesnap()  then return true end
	-- SOUL SWAP
	if affliction.rot.soulswapopti()  then return true end
	--buff
	if affliction.rot.darkintent() then return true end
	--fills
	if affliction.rot.lifetap()  then return true end
	if affliction.rot.drainsoul() then return true end
	if affliction.rot.grasp()  then return true end
	if affliction.rot.felflame() then return true end
end 
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(265, {
	name = "Youcef's Affliction",
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