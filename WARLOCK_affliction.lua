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
-- top of the CR
local player
local CallWowApi = _A.CallWowApi
local affliction = {}
local healerspecid = {
	-- [265]="Lock Affli",
	-- [266]="Lock Demono",
	-- [267]="Lock Destro",
	[105]="Druid Resto",
	[102]="Druid Balance",
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
	[64]="Mage Frost",
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
local soulswaporigin = nil
local ijustsoulswapped = false
local ijustsoulswappedattime = 0
local ijustexhaled = false
local ijustexhaledattime = 0
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
	_A.Interface:AddToggle({
		key = "eye_demon", 
		name = "Observer", 
		text = "Observer pet",
		icon = select(3,GetSpellInfo(691)),
	})
	_A.Interface:AddToggle({
		key = "def_cc", 
		name = "Defensive CCS", 
		text = "Only CC bursting and casting enemies",
		icon = select(3,GetSpellInfo(5782)),
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
		ijustsoulswapped = false
	end)
	-- dots
	_A.Listener:Add("dotstables", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
		if guidsrc == UnitGUID("player") then -- only filter by me
			if (idd==146739) or (idd==172) then -- Corruption
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					corruptiontbl[guiddest]=_A.myscore() 
				end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					corruptiontbl[guiddest]=nil
				end
			end
			if (idd==980) then -- AGONY
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					agonytbl[guiddest]=_A.myscore()
				end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					agonytbl[guiddest]=nil
				end
			end
			if (idd==30108) then -- Unstable Affli
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					unstabletbl[guiddest]=_A.myscore() 
				end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					unstabletbl[guiddest]=nil
				end
			end
			if (idd==27243) then -- seed of corruption
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					seeds[guiddest]=_A.myscore() 
				end
				if subevent=="SPELL_AURA_REMOVED" 
					then
					seeds[guiddest]=nil
				end
			end
			if (idd==119678) then -- Soulburn soul swap (applies all three)
				if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
					then
					corruptiontbl[guiddest]=_A.myscore() 
					unstabletbl[guiddest]=_A.myscore() 
					agonytbl[guiddest]=_A.myscore()
					-- ONLY APPLIES THESE 3 (and nothing else)
				end
			end
		end
	end
	)
	_Y.exitedvehicleat = GetTime()
	_A.Listener:Add("EXITING_VEHICLE", "UNIT_EXITING_VEHICLE", function(event, arg1)
		if arg1=="player" then
			_Y.exitedvehicleat = GetTime()
			print(event, arg1)
		end
	end)
	-- Soul Swap
	_A.Listener:Add("soulswaprelated", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then -- only filter by me
			if subevent =="SPELL_CAST_SUCCESS" then
				if idd==86121 then -- Soul Swap 86213
					soulswaporigin = guiddest -- remove after 3 seconds or after exhalings
					ijustsoulswapped = true
					ijustsoulswappedattime = GetTime() -- time at which I used soulswap
				end
				if idd==86213 then -- exhale
					unstabletbl[guiddest]=unstabletbl[soulswaporigin]
					agonytbl[guiddest]=agonytbl[soulswaporigin]
					corruptiontbl[guiddest]=corruptiontbl[soulswaporigin]
					seeds[guiddest]=seeds[soulswaporigin]
					ijustsoulswapped = false
					ijustexhaled = true
					ijustexhaledattime = _A.GetTime()
					soulswaporigin = nil -- remove after 3 seconds or after exhaling
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
		if target and target:enemy() and target:exists() and target:alive() and target:range()<=42 and _A.notimmune(target)
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and pet:losFrom(target) then
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
					if pet and pet.name == "Xeleth" then
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
		if pet and pet.name == "Xeleth" then
			if player:SpellCooldown("Optical Blast(Special Ability)")==0 and UnitPower("pet")>=20
				then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:range()<=80
						and healerspecid[obj:spec()]
						and not obj:buffany("Bear Form")
						and obj:caninterrupt()
						and not obj:state("incapacitate || fear || disorient || charm || misc || sleep")
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
						and pet:rangefrom(temptable[1].OBJ)<=20
						and temptable[1].OBJ:stateduration("stun || incapacitate || fear || disorient || charm || misc || sleep || silence")<1.5
						and pet:losfrom(temptable[1].OBJ)
						then 
						-- temptable[1].OBJ:cast(115781)
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
		if pet and pet.name == "Korronix" then
			if player:SpellCooldown("Disarm(Special Ability)")==0 and UnitPower("pet")>=30
				then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:range()<=80
						and not healerspecid[obj:spec()]
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
		if petsilencesnipe() then return end
		if petdisarmsnipe() then return end
		if attacklowest() then return end
		if petfollow() then return end
	end
end
local timerframe = CreateFrame("Frame")
local timerframeinterval = 0.1 -- default
timerframe.TimeSinceLastUpdate2 = 0
timerframe:SetScript("OnUpdate", function(self,elapsed)
	self.TimeSinceLastUpdate2 = self.TimeSinceLastUpdate2 + elapsed;
	if self.TimeSinceLastUpdate2 >= timerframeinterval then
		if ijustsoulswapped == true and GetTime()-ijustsoulswappedattime>=3 then
			soulswaporigin = nil
			ijustsoulswapped=false -- so I wouldn't overwrite stats wrongfully
		end
		if ijustexhaled == true and GetTime() - ijustexhaledattime >= .3 then
			ijustexhaled = false
		end
		self.TimeSinceLastUpdate2 = self.TimeSinceLastUpdate2 - timerframeinterval
	end
end)
local exeOnUnload = function()
	Listener:Remove("lock_cleantbls")
	Listener:Remove("EXITING_VEHICLE")
	Listener:Remove("soulswaprelated")
	Listener:Remove("delaycasts")
	Listener:Remove("dotstables")
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
		_A.reflectcheck = false
		_A.shards = _A.UnitPower("player", 7)
		_A.pull_location = pull_location()
		if not player:BuffAny(86211) and soulswaporigin ~= nil then soulswaporigin = nil end
		-- snapshot engine
		_A.temptabletbl = {}
		_A.temptabletblsoulswap = {}
		_A.temptabletblexhale = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and not Obj:charmed() and Obj:los() then
				-- backup cleaning, for when spell aura remove event doesnt fire for some reason
				if corruptiontbl[Obj.guid]~=nil and not Obj:Debuff("Corruption") and corruptiontbl[Obj.guid] then corruptiontbl[Obj.guid]=nil end
				if agonytbl[Obj.guid]~=nil and not Obj:Debuff("Agony") and agonytbl[Obj.guid] then agonytbl[Obj.guid]=nil end
				if unstabletbl[Obj.guid]~=nil and not Obj:Debuff("Unstable Affliction") and unstabletbl[Obj.guid] then unstabletbl[Obj.guid]=nil end
				--
				_A.temptabletbl[#_A.temptabletbl+1] = {
					obj = Obj,
					score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0), -- ALWAYS ORDER THIS BY SCORE FIRST
					agonyscore = (agonytbl[Obj.guid] or 0),
					unstablescore = (unstabletbl[Obj.guid] or 0),
					corruptionscore = (corruptiontbl[Obj.guid] or 0),
					-- seedscore = (seeds[Obj.guid] or 0),
					range = Obj:range(2) or 40,
					health = Obj:HealthActual() or 0,
					isplayer = Obj.isplayer and 1 or 0
				}
				if Obj.guid ~= soulswaporigin then -- can't exhale on the soulswap
					_A.temptabletblexhale[#_A.temptabletblexhale+1] = {
						obj = Obj,
						rangedis = Obj:range(2) or 40,
						isplayer = Obj.isplayer and 1 or 0,
						health = Obj:HealthActual() or 0,
						-- duration = Obj:DebuffDuration("Unstable Affliction") or Obj:DebuffDuration("Corruption") or Obj:DebuffDuration("Agony") or 0 -- duration, best solution to spread it to as many units as possible, always order by this first
						duration = Obj:DebuffDuration("Unstable Affliction") or 0 -- duration, best solution to spread it to as many units as possible, always order by this first
					}
				end
				_A.temptabletblsoulswap[#_A.temptabletblsoulswap+1] = {
					obj = Obj,
					isplayer = Obj.isplayer and 1 or 0,
					duration = Obj:DebuffDuration("Unstable Affliction") or Obj:DebuffDuration("Corruption") or Obj:DebuffDuration("Agony") or 0
				}
			end -- end of enemy filter
			if warriorspecs[_A.UnitSpec(Obj.guid)] and Obj:range()<20 and _A.UnitTarget(Obj.guid)==player.guid then
				_A.reflectcheck = true
			end
		end -- end of iteration
		-- table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) end )
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
			if player:SpellCooldown("Dark Regeneration") == 0 and not IsCurrentSpell(108359)
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
	
	items_intpot = function()
		if not player:isCastingAny() and player:ItemCooldown(76093) == 0
			and player:ItemCount(76093) > 0
			and player:ItemUsable(76093)
			and player:Buff("Dark Soul: Misery")
			and player:combat()
			then
			if _A.pull_location=="pvp" then
				player:useitem("Potion of the Jade Serpent")
			end
		end
	end,
	
	items_strflask = function()
		if not player:isCastingAny() and player:ItemCooldown(76088) == 0
			and player:combat()
			and player:ItemCount(76088) > 0
			and player:ItemUsable(76088)
			and not player:Buff(105696)
			then
			if _A.pull_location=="pvp" then
				player:useitem("Flask of Winter's Bite")
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
		if player:combat() and player:buff("Surge of Dominance") then
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
	
	hasteburst = function()
		if player:combat() and player:SpellCooldown("Dark Soul: Misery")==0 and not player:buff("Dark Soul: Misery") and _A.enoughmana(113860) and not IsCurrentSpell(113860) then
			if player:buff("Call of Dominance") then
				player:cast("Lifeblood")
				player:cast("Dark Soul: Misery")
			end
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
				local petobj = UnitName("pet")
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Fizrik")
					then 
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112866)
					end
					if (not player:buff(74434) and not IsCurrentSpell(74434) and player:combat() and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
						then player:cast(74434) -- shadowburn
					end	
				end
			end
		end
	end,
	
	petres_supremacy2 = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112869)<.3 and _A.castdelay(112869, 1.5) and not player:iscasting(112869) and _A.enoughmana(112869)  then
				local petobj = UnitName("pet") 
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Xeleth")
					then 
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112869)
					end
					if (not player:buff(74434) and not IsCurrentSpell(74434) and player:combat() and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
						then player:cast(74434) -- shadowburn
					end	
				end
			end
		end
	end,
	
	petres_supremacy3 = function()
		if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat>= 2 then
			if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112867)<.3 and _A.castdelay(112867, 1.5) and not player:iscasting(112867) and _A.enoughmana(112867)  then
				local petobj = UnitName("pet") 
				if 
					not _A.UnitExists("pet")
					or _A.UnitIsDeadOrGhost("pet")
					or not _A.HasPetUI()
					or (petobj and petobj~="Korronix")
					then 
					if player:buff(74434) or ( not player:moving() ) then
						return player:cast(112867)
					end
					if (not player:buff(74434) and not IsCurrentSpell(74434) and player:combat() and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
						then player:cast(74434) -- shadowburn
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
				if lowest and lowest:exists() then
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
		if player:SpellCooldown("Twilight Ward")<.3 and player:combat() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Twilight Ward")
		end
	end,
	
	bloodhorror = function()
		if _A.reflectcheck == false and player:Talent("Blood Horror") and player:SpellCooldown("Blood Horror")<.3 and player:health()>10 and not player:buff("Blood Horror") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Blood Horror")
		end
	end,
	
	bloodhorrorremovalopti = function() -- rework this
		if _A.reflectcheck == true then
			print("REMOVING REMOVING REMOVING")
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
		-- if soulswaporigin == nil 
		if soulswaporigin ~= nil -- only lifetap when you can exhale, you benefit from exhaling late since you save the stats (including duration) the moment you soulswap (not when you exhale)
			and player:SpellCooldown("life tap")<=.3 
			and player:health()>=35
			and player:Mana()<=80
			and _A.castdelay(1454, 35) -- 35sec delay
			then
			return player:cast("life tap")
		end
	end,
	
	lifetap= function()
		if player:SpellCooldown("life tap")<=.3 
			and player:health()>=35
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
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
					and (obj:drState("Shadowfury") == 1 or obj:drState("Shadowfury") == -1)
					and _A.notimmune(obj)
					and obj:los() then
					return _A.clickcastv2(obj, "Shadowfury")
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
	
	corruptionsnap = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					elseif 
					a.score ~= b.score then return a.score > b.score
					else return 
					a.range < b.range
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
					a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					elseif 
					a.score ~= b.score then return a.score > b.score
					else return 
					a.range < b.range
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
					a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					elseif 
					a.score ~= b.score then return a.score > b.score
					else return 
					a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and  _A.myscore()> _A.temptabletbl[1].unstablescore and player:SpellCooldown("Unstable Affliction")<.3 then 
			if player:buff(74434) then
				return _A.temptabletbl[1].obj:Cast(119678)
			end
			if  _A.shards>=1 and not player:buff(74434) and player:SpellCooldown(74434)==0  and not IsCurrentSpell(74434)--or player:buff("Shadow Trance")
				then player:cast(74434) -- shadowburn
			end
		end -- improved soul swap (dots instead)
	end,
	
	unstablesnap = function()
		if #_A.temptabletbl>1 then
			table.sort(_A.temptabletbl, function(a,b)
				if 	
					a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					elseif 
					a.score ~= b.score then return a.score > b.score
					else return 
					a.range < b.range
				end
			end)
		end
		if _A.temptabletbl[1] and not player:buff(74434) and _A.myscore()>_A.temptabletbl[1].unstablescore  then 
			if not player:moving() and not player:Iscasting("Unstable Affliction") and _A.shards==0 then
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
		if not player:isCastingAny() and not player:isChanneling("Malefic Grasp")  and not player:moving() and _A.enoughmana(103103)  then
			local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
			if lowest and lowest:exists() and lowest:health()>30 then
				return lowest:cast("Malefic Grasp", true)
			end
		end
	end,
	
	felflame = function()
		if not player:isCastingAny() and _A.enoughmana(77799) then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("fel flame")
			end
		end
	end,
	
	drainsoul = function()
		if not player:moving() 
			and not player:isChanneling("Drain Soul")
			and _A.enoughmana(1120)
			then
			local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
			if lowest and lowest:exists() and lowest:health()<=30 then
				return lowest:cast("Drain Soul", true)
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
						a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer -- by default comes second
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
			and player:combat()
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
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
	player = Object("player")
	if not player then return end
	-- if not _Y.exitedvehicleat then return true end
	if _Y.exitedvehicleat and GetTime()-_Y.exitedvehicleat<= 1 then return true end
	-- print(player:spellcooldown("Clone Magic(Special Ability)"))
	-- print(spell_name(115284))
	affliction.rot.caching()
	_Y.petengine_affli()
	if player:Mounted() then return end
	--bursts
	affliction.rot.activetrinket()
	affliction.rot.hasteburst()
	--HEALS
	affliction.rot.Darkregeneration()
	affliction.rot.items_healthstone()
	if not _A.BUTTONHOOK_RELATED and _A.buttondelayfunc() then return true end -- pausing for manual casts
	-- if player:lostcontrol()  then return end 
	--delayed lifetap
	if affliction.rot.lifetap_delayed() then return end
	--exhale
	if affliction.rot.exhaleopti()  then return end
	--stuff
	if affliction.rot.Buffbuff()  then return end
	affliction.rot.items_intflask()
	affliction.rot.items_intpot()
	if affliction.rot.petres()  then return end
	-- if not toggle("eye_demon") and affliction.rot.petres_supremacy() then return end
	if not toggle("eye_demon") and affliction.rot.petres_supremacy3() then return end
	if toggle("eye_demon") and affliction.rot.petres_supremacy2() then return end
	if affliction.rot.summ_healthstone() then return end
	if affliction.rot.CauterizeMaster()  then return end
	if affliction.rot.MortalCoil()  then return end
	if affliction.rot.twilightward()  then return end
	--utility
	if affliction.rot.bloodhorrorremovalopti()  then return end
	if affliction.rot.bloodhorror()  then return end
	if not toggle("def_cc") and affliction.rot.ccstun()  then return end	
	if toggle("def_cc") and affliction.rot.ccstun_def()  then return end
	if player:keybind("T") and affliction.rot.fearkeybind()  then return end
	if affliction.rot.snare_curse()  then return end
	-- shift
	if modifier_shift()==true then
		if affliction.rot.haunt()  then return end
		if affliction.rot.drainsoul() then return end
		if affliction.rot.grasp()  then return end
		if affliction.rot.felflame()  then return end
	end
	-- Heal pet
	if affliction.rot.healthfunnel() then return end
	-- DOT DOT
	if affliction.rot.unstablesnapinstant() then return end
	if affliction.rot.agonysnap()  then return end
	if affliction.rot.corruptionsnap()  then return end
	-- if affliction.rot.sneedofcorruption()  then return end
	if affliction.rot.unstablesnap()  then return end
	-- SOUL SWAP
	if affliction.rot.soulswapopti()  then return end
	--buff
	affliction.rot.darkintent()
	--fills
	if affliction.rot.lifetap()  then return end
	if affliction.rot.drainsoul() then return end
	if _A.pull_location=="arena" and affliction.rot.haunt() then return end
	if affliction.rot.grasp()  then return end
	if affliction.rot.felflame() then return end
end 
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(265, {
	name = "Youcef's Affliction",
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