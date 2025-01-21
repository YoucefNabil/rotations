local _,class = UnitClass("player")
if class~="HUNTER" then return end
local HarmonyMedia, _A, _Y = ...
-- local _, class = UnitClass("player");
-- if class ~= "WARRIOR" then return end;
local DSL = function(api) return _A.DSL:Get(api) end
local hooksecurefunc =_A.hooksecurefunc
local Listener = _A.Listener
-- top of the CR
local player
local enemytreshhold = 3
local survival = {}
-- local ENEMIES_OM = {}
local MISSILES_OM = {}
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
local meleespecs = {
	[250]="Blood",
	[251]="Frost",
	[252]="Unholy",
	[103]="Feral",
	[102]="balance",
	[105]="resto",
	[269]="WW",
	[70]="Ret",
	[66]="Prot",
	[259]="Assassin",
	[260]="Outlaw",
	[261]="Sub",
	[263]="Enh",
	[71]="Arms",
	[72]="Fury",
	[73]="Prot",
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
}

local function kickcheck(unit)
	if unit then
		for k,v in pairs(spelltable) do
			if v==2 then
				if unit:iscasting(k) or unit:channeling(k) then
					return true
				end
			end
		end
	end
	return false
end
local function manaregen()
	local regen = GetPowerRegen()
	return tonumber(regen)
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

local cobraid = _A.Core:GetSpellID("Cobra Shot")
local steadyid = _A.Core:GetSpellID("Steady Shot") 
local ESid = _A.Core:GetSpellID("Explosive Shot") 
local gtID = _A.Core:GetSpellID("Glaive Toss") 
local baID = _A.Core:GetSpellID("Black Arrow") 
local amocID = _A.Core:GetSpellID("A Murder of Crows") 
local GUI = {
}
local scatter_x
local scatter_y
local scatter_z
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
	
	_A.casttimers = {}
	_A.scattertargets = {}
	
	_A.Listener:Add("delaycasts_HUNT_BM", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		if player and player.guid and guidsrc == player.guid then
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				if idd == 19503 or idd==19386 then -- add wyvern sting
					if not _A.scattertargets[guiddest] then _A.scattertargets[guiddest]= true end
					C_Timer.After(2, function()
						if _A.scattertargets[guiddest] then
							_A.scattertargets[guiddest]=nil
						end
					end)
				end
			end
			-- if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
			if subevent == "SPELL_AURA_APPLIED" then -- doesnt work with channeled spells
				_A.casttimers[idd] = _A.GetTime()
				--
				if idd == 19503 then
					scatter_x, scatter_y, scatter_z = _A.ObjectPosition(guiddest)
					print("SCATTERING!!!!!!!!!!!!!!!!!!!!!!!")
					C_Timer.After(10, function()
						if scatter_x then
							print("DELETING")
							scatter_x = nil
							scatter_y = nil
							scatter_z = nil
						end
					end)
				end
				if idd == 19503 or idd==19386 then
					if _A.scattertargets[guiddest] then
						_A.scattertargets[guiddest]=nil
					end
				end
			end
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				if idd == 60192 then
					print("FREEZING!!!")
					print("DELETING")
					scatter_x = nil
					scatter_y = nil
					scatter_z = nil
					end
				end
			end
	end)
	function _A.castdelay(idd, delay)
		local spellid = idd and _A.Core:GetSpellID(idd)
		if delay == nil then return true end
		if _A.casttimers[spellid]==nil then return true end
		return (_A.GetTime() - _A.casttimers[spellid])>=delay
	end
	function _A.castdelaytarget(idd, delay)
		local spellid = idd and _A.Core:GetSpellID(idd)
		if delay == nil then return true end
		if _A.casttimers[spellid]==nil then return true end
		return (_A.GetTime() - _A.casttimers[spellid])>=delay
	end
	function _A.castwhen(idd)
		local spellid = idd and _A.Core:GetSpellID(idd)
		if _A.casttimers[spellid]==nil then return 9999 end
		return (_A.GetTime() - _A.casttimers[spellid])
	end
	--
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		local player = Object("player")
		if slot==STARTSLOT then 
			_A.pressedbuttonat = 0
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
				_A.Interface:toggleToggle("mastertoggle", true)
				-- _A.print("ON")
				return true
			end
		end
		if slot==STOPSLOT then 
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			-- TEST STUFF
			-- print(player:stance())
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				-- _A.print("OFF")
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
	--
	_A.clusteredenemy = function()
		local targets = {}
		local most, mostGuid = 0
		for _, enemy in pairs(_A.OM:Get('Enemy')) do
			if enemy:InConeOf(player, 170) and (_A.pull_location=="none" or enemy:combat()) and not enemy:state("incapacitate || fear || disorient || charm || misc || sleep") 
				and _A.notimmune(enemy) and enemy:los()  then
				for _, enemy2 in pairs(_A.OM:Get('Enemy')) do
					if enemy:rangefrom(enemy2)<=13  then
						targets[enemy.guid] = targets[enemy.guid] and targets[enemy.guid] + 1 or 1
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
		return most, mostGuid
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
	
	function _A.modifier_alt()
		local modkeyb = IsAltKeyDown()
		if modkeyb then
			return true
			else
			return false
		end
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
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and  Obj:combat()  and _A.notimmune(Obj) 
				and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
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
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKC', function(num)
		local tempTable = {}
		local target = Object("target")
		local pet = Object("pet")
		if not pet then return end
		if pet and not pet:alive() then return end
		if pet:state("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:exists() and target:alive() and target:rangefrom(pet)<=24 and _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") and pet:losFrom(target) then
			return target and target.guid -- this is good
		end
		-- for _, Obj in pairs(_A.OM:Get('Enemy')) do
		-- if Obj:rangefrom(pet)<24 and  Obj:InConeOf(player, 170) and  Obj:combat()  and _A.notimmune(Obj) 
		-- and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and pet:losFrom(Obj) then
		-- tempTable[#tempTable+1] = {
		-- guid = Obj.guid,
		-- health = Obj:health(),
		-- range = Obj:range(),
		-- isplayer = Obj.isplayer and 1 or 0
		-- }
		-- end
		-- end
		-- if #tempTable>1 then
		-- table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.range < b.range) end )
		-- end
		-- if #tempTable>=1 then
		-- return tempTable[num] and tempTable[num].guid -- not sure about this (pet can get lost) find a better solution
		-- end
		local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
		if lowestmelee and lowestmelee:rangefrom(pet)<=24 and pet:losFrom(lowestmelee) then
			return lowestmelee.guid
		end
		return nil
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKCNOLOS', function(num)
		local tempTable = {}
		local target = Object("target")
		local pet = Object("pet")
		if not pet then return end
		if pet and not pet:alive() then return end
		if pet:state("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:exists() and target:alive() and _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") then
			return target and target.guid -- this is good
		end
		-- for _, Obj in pairs(_A.OM:Get('Enemy')) do
		-- if Obj:rangefrom(pet)<24 and  Obj:InConeOf(player, 170) and  Obj:combat()  and _A.notimmune(Obj) 
		-- and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and pet:losFrom(Obj) then
		-- tempTable[#tempTable+1] = {
		-- guid = Obj.guid,
		-- health = Obj:health(),
		-- range = Obj:range(),
		-- isplayer = Obj.isplayer and 1 or 0
		-- }
		-- end
		-- end
		-- if #tempTable>1 then
		-- table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.range < b.range) end )
		-- end
		-- if #tempTable>=1 then
		-- return tempTable[num] and tempTable[num].guid -- not sure about this (pet can get lost) find a better solution
		-- end
		local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
		if lowestmelee and lowestmelee:rangefrom(pet)<=24 and pet:losFrom(lowestmelee) then
			return lowestmelee.guid
		end
		return nil
	end)
	
	_A.FakeUnits:Add('enemyplayercc', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			-- if Obj.isplayer and Obj:spellRange("Arcane Shot") and Obj:state("incapacitate || disorient || charm || misc || sleep || stun") and _A.notimmune(Obj) and Obj:los() then
			if Obj.isplayer and Obj:spellRange("Arcane Shot") and _A.notimmune(Obj) 
				and Obj:stateduration("stun")>=1 and not Obj:moving() and Obj:los() then
				tempTable[#tempTable+1] = {
					range = Obj:range(),
					guid = Obj.guid,
					health = Obj:health(),
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.range < b.range) end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('meleeunitstobindshot', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:spellRange("Arcane Shot") and meleespecs[Obj:spec()] and _A.notimmune(Obj) and not Obj:immune("stun") and Obj:los() then
				tempTable[#tempTable+1] = {
					range = Obj:range(),
					guid = Obj.guid,
					health = Obj:health(),
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.range < b.range) end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('simpletarget', function(num, spell)
		local target = Object("target")
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and Obj:combat() and _A.notimmune(Obj)  
				and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
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
		local target = Object("target")
		if target and target:enemy() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)  
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
		end
	end)
	
	_A.FakeUnits:Add('highestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and Obj:combat() and _A.notimmune(Obj)  
				and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:HealthActual(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health > b.health) end )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		local target = Object("target")
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
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
	
	
	_A.castchecktbl = {}
	_A.Listener:Add("steadycasting", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then
			if idd == cobraid or idd == steadyid then
				-- print(subevent.." "..idd)
				if subevent == "SPELL_CAST_START" then
					_A.castchecktbl[idd] = true
				end
				if subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_CAST_FAILED" then
					_A.castchecktbl[idd] = false
				end
			end
		end
	end)
	----------------------------- MISSILES
	function _A.MissileExists(ID)
		local ID_CORE = _A.Core:GetSpellID(ID)
		local missiles = _A.GetMissiles()
		for _, missile in ipairs(missiles) do
			local spellid, _, _, _, caster, _, _, _, target, _, _, _ = unpack(missile) -- prior Legion
			if caster == player.guid and spellid==ID_CORE then
				return true
			end
		end
		return false
	end
	
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	--=========================== SPELL CHECKS
	-- Helper to compute required focus with time-based regeneration
	local function required_focus(spell, elapsed)
		-- if not player:spellknown(spell) then return 0 end
		local cd = player:SpellCooldown(spell) -- Cooldown remaining
		local regen = manaregen() * math.max(0, cd - elapsed) -- Regen focus during cooldown after elapsed time
		local cost,_ = player:spellcost(spell)
		return -cost + regen
	end
	
	
	_A.lowpriocheck = function(spellid)
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		-- Define abilities with cooldowns and conditions
		-- Arcane Shot Specific
		local spells = {
			{ name = "Kill Command", ready = _A.UnitExists("pet") and not _A.UnitIsDeadOrGhost("pet") and _A.HasPetUI()},
			{ name = "Glaive Toss", ready = player:talent("Glaive Toss") },
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table.sort(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end)
		end
		
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost(spellid)
		
		-- Simulate focus pooling without loops (nested conditions)
		local focus_cost, cooldown
		
		-- First spell
		if spells[1].ready then
			cooldown = player:SpellCooldown(spells[1].name)
			focus_cost = required_focus(spells[1].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		if spells[2].ready then
			cooldown = player:SpellCooldown(spells[2].name)
			focus_cost = required_focus(spells[2].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		if spells[3].ready then
			cooldown = player:SpellCooldown(spells[3].name)
			focus_cost = required_focus(spells[3].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		-- If all focus checks pass, Arcane Shot can be cast
		return true
	end
	------------------------------
	------------------------------
	------------------------------
	_A.glaivetosscheck = function()
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		-- Define abilities with cooldowns and conditions
		if not player:talent("Glaive Toss") then return false end
		local spells = {
			{ name = "Kill Command", ready = _A.UnitExists("pet") and not _A.UnitIsDeadOrGhost("pet") and _A.HasPetUI() },
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table.sort(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end)
		end
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost("Glaive Toss")
		
		-- Simulate focus pooling without loops (nested conditions)
		local focus_cost, cooldown
		
		-- First spell
		if spells[1].ready then
			cooldown = player:SpellCooldown(spells[1].name)
			focus_cost = required_focus(spells[1].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		if spells[2].ready then
			cooldown = player:SpellCooldown(spells[2].name)
			focus_cost = required_focus(spells[2].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		-- If all focus checks pass, Arcane Shot can be cast
		return true
	end
	-------------------------------------------
	-------------------------------------------
	-------------------------------------------
	------------------------------------------------------------------
	_A.KCcheck = function()
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		-- Define abilities with cooldowns and conditions
		local spells = {
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table.sort(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end)
		end
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost("Kill Command")
		
		-- Simulate focus pooling without loops (nested conditions)
		local focus_cost, cooldown
		
		-- First spell
		if spells[1].ready then
			cooldown = player:SpellCooldown(spells[1].name)
			focus_cost = required_focus(spells[1].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		
		-- If all focus checks pass, Arcane Shot can be cast
		return true
	end
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	_A.multishotcheck = function()
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		-- Check if spell exists
		if not player:talent("Barrage") then return true end
		
		-- Define abilities with cooldowns and conditions
		local spells = {
			{ name = "Barrage", ready = true }
		}
		
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table.sort(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end)
		end
		
		
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost("Multi-Shot")
		
		-- Simulate focus pooling without loops (nested conditions)
		local focus_cost, cooldown
		
		-- First spell
		if spells[1].ready then
			cooldown = player:SpellCooldown(spells[1].name)
			focus_cost = required_focus(spells[1].name, time_elapsed)
			if current_focus < -focus_cost then return false end
			current_focus = current_focus + focus_cost
			time_elapsed = cooldown -- Update elapsed time
		end
		-- If all focus checks pass, Arcane Shot can be cast
		return true
	end
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	_A.CobraCheck = function() -- we only want to cast Cobra Shot if not enough ressources by the time important cds come up (Idk if this is necessary just yet)
		if player:Spellusable("Cobra Shot") or player:spellusable("Steady Shot") then
			local ct = player:level()<81 and player:SpellCasttime("Steady Shot") or player:SpellCasttime("Cobra Shot")
			if player:focus()+((player:spellcooldown("Kill Command"))*manaregen())<player:spellcost("Kill Command") then return true end
			return ct<=player:spellcooldown("Kill Command")
		end
	end
	-------------------------------------------------------
	-------------------------------------------------------
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
				-- _A.CallWowApi("SpellStopTargeting")
			end
		end
	end
	function _A.clickcastdetail(x, y, z, spell)
		local px,py,pz = _A.groundpositiondetail(x, y, z)
		if px then
			_A.CallWowApi("CastSpellByName", spell)
			if player:SpellIsTargeting() then
				_A.ClickPosition(px, py, pz)
				_A.CallWowApi("SpellStopTargeting")
				-- _A.CallWowApi("SpellStopTargeting")
			end
		end
	end	
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	------------------------------------------------------- PET
	------------------------------------------------------- ENGINE
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
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
	}
	_A.FakeUnits:Add('HealingStreamTotem', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			for _,totems in ipairs(badtotems) do
				if Obj.name==totems and Obj:los() then
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
		if htotem then
			if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=htotem.guid) then
				return _A.CallWowApi("PetAttack", htotem.guid), 1
			end
			return 1
		end
	end
	local function attackfocus()
		local _focus = Object("focus")
		local htotem = Object("HealingStreamTotem")
		if not htotem and _focus then
			if _focus:alive() and _focus:enemy() and _focus:exists() and not _focus:state("incapacitate || disorient || charm || misc || sleep || fear") then
				if (_A.pull_location~="party" and _A.pull_location~="raid") or _focus:combat() then -- avoid pulling shit by accident
					if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=_focus.guid) then
						return _A.CallWowApi("PetAttack", _focus.guid), 2
					end
				end
				return 2
			end
		end
	end
	local function attacklowest()
		local target = Object("lowestEnemyInSpellRangePetPOVKCNOLOS")
		if target then
			if (_A.pull_location~="party" and _A.pull_location~="raid") or target:combat() then -- avoid pulling shit by accident
				if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=target.guid) then
					return _A.CallWowApi("PetAttack", target.guid), 3
				end
			end
			return 3
		end
	end
	local function petfollow_whenselftargeting() -- when pet target has a breakable cc
		local target = Object("target")
		if target and target.guid == player.guid then
			if _A.PetGUID and _A.UnitTarget(_A.PetGUID)~=nil then
				return _A.CallWowApi("RunMacroText", "/petfollow"), 4
			end
		end
	end
	local function petfollow() -- when pet target has a breakable cc
		if _A.PetGUID and _A.UnitTarget(_A.PetGUID)~=nil then
			local target = Object(_A.UnitTarget(_A.PetGUID))
			if target and target:alive() and target:enemy() and target:exists() and target:state("incapacitate || disorient || charm || misc || sleep ||fear") then
				return _A.CallWowApi("RunMacroText", "/petfollow"), 4
			end
		end
	end
	local function petengine()
		if not _A.Cache.Utils.PlayerInGame then return end
		if not player then return true end
		-- print(player:spec())
		if player:spec()~=253 then return true end
		-- print("working")
		-- if not player:combat() then return true end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then return true end
		if player:mounted() then return end
		if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return end
		if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") or not _A.HasPetUI() then if _A.PetGUID then _A.PetGUID = nil end return true end
		_A.PetGUID = _A.UnitGUID("pet")
		if _A.PetGUID == nil then return end
		-- print("working")
		if attacktotem() then return end
		-- if petfollow_whenselftargeting() then return end
		if attacklowest() then return end
		if petfollow() then return end
		-- return _A.CallWowApi("RunMacroText", "/petfollow")
		-- if attacktarget() then return true end
	end
	C_Timer.NewTicker(.1, petengine, false, "petengineengine2")
end
local exeOnUnload = function()
end

local dontdispell = {
    ["Clearcasting"] = true,
    ["Backdraft"] = true,
}
local function canpurge(target)
    for i = 1, 40 do
        local name,_,_,_,atype = _A.UnitBuff(target, i)
        if not name then
            break -- No more buffs
		end
        if name and atype and (atype == "Magic" or atype == "Enrage") and not dontdispell[name] then
            return true
		end
	end
    return false
end

survival.rot = {
	-- flasks
	items_agiflask = function()
		if player:ItemCooldown(76084) == 0  
			and player:ItemCount(76084) > 0
			and player:ItemUsable(76084)
			and not player:Buff(105689)
			then
			if pull_location()=="pvp" and player:combat() then
				return player:useitem("Flask of Spring Blossoms")
			end
		end
	end,
	
	items_healthstone = function()
		if player:health() <= 35    then
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
	-- defs
	deterrence = function()
		if player:health() <= 25 and not player:buffany("Horde Flag") and not player:buffany("Alliance Flag") then
			if player:SpellCooldown("Deterrence") == 0 and not player:buff("Deterrence") and _A.castdelay("Deterrence", 1.5) and player:spellusable("Deterrence")
				then
				-- cancel cast
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")
					else
					return player:cast("Deterrence")
				end
			end
		end
	end,
	masterscall = function()
		if player:SpellCooldown("Master's Call")==0 and player:state("root") then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:state("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:range()<40 and pet:los() then
				-- cancel cast
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  
					else return player:cast("Master's Call")
				end
			end
		end
	end,
	roarofsac = function()
		if player:SpellCooldown("Roar of Sacrifice(Cunning Ability)")==0 and player:health()<65 and player:combat() and not player:buff("Deterrence") and _A.castdelay("Deterrence",(5+player:gcd())) then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:state("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:range()<40 and pet:los() then
				-- return player:cast("Roar of Sacrifice(Cunning Ability)")
				return _A.CallWowApi("RunMacroText","/cast [@player] Roar of Sacrifice(Cunning Ability)")
			end
		end
	end,
	spiritmend = function()
		if player:SpellCooldown("Spirit Mend(Exotic Ability)")==0 
			and player:health()<75
			then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and pet.name == "Spirit Beast" and not pet:state("incapacitate || fear || disorient || charm || misc || sleep || stun") 
				and pet:range()<25 and pet:focus()>=5 and pet:los() then
				-- return player:cast("Spirit Mend(Exotic Ability)")
				return _A.CallWowApi("RunMacroText","/cast [@player] Spirit Mend(Exotic Ability)")
			end
		end
	end,
	mendpet =  function()
		if	_A.UnitExists("pet") and not _A.UnitIsDeadOrGhost("pet") and _A.HasPetUI() and _A.castdelay("Mend Pet", (2*player:gcd())) and player:spellcooldown("Mend Pet")<.3
			and player:spellusable("Mend Pet")
			then
			local pet = Object("pet")
			if pet and pet:range()<=40 and pet:health()<90 and pet:combat() and not pet:buff("Mend Pet") and pet:los() then 
				return player:cast("Mend Pet") 
			end
		end
	end,
	-- Misc
	autoattackmanager = function()
		local target = Object("target")
		if target and target.isplayer and target:enemy() and target:alive() and target:InConeOf(player, 180) and target:los() then
			if target:state("incapacitate || fear || disorient || charm || misc || sleep") and player:autoattack() then _A.CallWowApi("RunMacroText", "/stopattack") 
				elseif not target:state("incapacitate || fear || disorient || charm || misc || sleep") and not player:autoattack() then  _A.CallWowApi("RunMacroText", "/startattack") 
			end
		end
	end,
	kick = function()
		if player:SpellCooldown("Counter Shot")==0 and player:spellusable("Counter Shot") then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Arcane Shot") and obj:InConeOf("player", 170)
					and obj:caninterrupt() 
					and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=90
					)
					and _A.notimmune(obj)
					then
					if kickcheck(obj) then
						obj:Cast("Counter Shot", true)
					end
				end
			end
		end
	end,
	pet_misdirect = function()
		if player:Spellcooldown("Misdirection")==0 and _A.castdelay("Misdirection", 1.5)
			and player:combat() and _A.pull_location=="none" and not player:isCastingAny() and player:spellusable("Misdirection")
			then
			local pet = Object("pet")
			if pet and pet:alive() and pet:exists() and not player:buff("Misdirection") and pet:SpellRange("Misdirection") and pet:los() then
				return pet:Cast("Misdirection")
			end
		end
	end,
	-- Traps and CC
	concussion = function()
		if player:spellcooldown("Concussive Shot")<.3 and player:spellusable("Concussive Shot") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and lowestmelee:stateduration("snare")<1.5 and not lowestmelee:immune("snare") then
				return lowestmelee:Cast("Concussive Shot")
			end
		end
	end,
	traps = function()
		if player:buff("Trap Launcher")
			and player:spellusable("Ice Trap") then
			local lowestmelee = Object("enemyplayercc")
			if lowestmelee then
				if (player:Spellcooldown("Ice Trap")<.3 and _A.castdelay("Snake Trap", 6))
					or (player:Spellcooldown("Snake Trap")<.3 and _A.castdelay("Ice Trap", 6))
					-- or player:Spellcooldown("Explosive Trap")<.3
					then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting") end
					if not player:isCastingAny() then
						if player:Spellcooldown("Ice Trap")<.3 and _A.castdelay("Snake Trap", 6) then
							return _A.clickcast(lowestmelee, "Ice Trap")
							elseif player:Spellcooldown("Snake Trap")<.3 and _A.castdelay("Ice Trap", 6) then
							return _A.clickcast(lowestmelee, "Snake Trap")					
							-- elseif player:Spellcooldown("Explosive Trap")<.3 then
							-- return _A.clickcast(lowestmelee, "Explosive Trap")
						end
					end					
				end 
			end 
		end
	end,
	scatter = function()
		if player:SpellCooldown("Scatter Shot")<.3 and player:SpellCooldown("Freezing Trap")<.3 and player:glyph("Glyph of Solace") and player:buff("Trap Launcher") 
			and player:spellusable("Scatter Shot") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:spellRange("Scatter Shot") and healerspecid[Obj:spec()] and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
					and _A.notimmune(Obj) and not Obj:immune("disorient") and Obj:InConeOf("player", 170) 
					and (Obj:drstate("Freezing Trap")==1 or Obj:drstate("Freezing Trap")==-1) 
					and (Obj:drstate("Scatter Shot")==1 or Obj:drstate("Scatter Shot")==-1)
					and Obj:los() then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
					if not player:isCastingAny() then  return Obj:cast("Scatter Shot") end
				end
			end
		end
	end,
	scatter_focus = function()
		if player:SpellCooldown("Scatter Shot")<.3 and player:SpellCooldown("Freezing Trap")<.3 and player:glyph("Glyph of Solace") and player:buff("Trap Launcher")
			and player:spellusable("Scatter Shot") then
			local focus = Object("focus")
			if focus and focus:enemy() and focus:alive() and focus.isplayer and focus:spellRange("Scatter Shot") and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and _A.notimmune(focus) and not focus:immune("disorient") and focus:InConeOf("player", 170) 
				and (focus:drstate("Freezing Trap")==1 or focus:drstate("Freezing Trap")==-1) 
				and (focus:drstate("Scatter Shot")==1 or focus:drstate("Scatter Shot")==-1)
				and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not player:isCastingAny() then  return focus:cast("Scatter Shot") end
			end
		end
	end,
	freezing = function()
		if player:SpellCooldown("Freezing Trap")<.3 and player:buff("Trap Launcher") and player:glyph("Glyph of Solace") and player:spellusable("Freezing Trap") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:spellRange("Arcane Shot") and healerspecid[Obj:spec()] 
					and (Obj:debuff("Scatter Shot") or (Obj:stateduration("disorient || charm || sleep || stun")>1 and Obj:stateduration("disorient || charm || sleep || stun")<4)) 
					and (Obj:drstate("Freezing Trap")==1 or Obj:drstate("Freezing Trap")==-1) 
					and not Obj:debuffany("Wyvern Sting") and _A.notimmune(Obj) and Obj:los() then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
					if not  player:isCastingAny()  then
						return scatter_x and Obj:debuff("Scatter Shot") and _A.clickcastdetail(scatter_x, scatter_y, scatter_z, "Freezing Trap") or _A.clickcast(Obj, "Freezing Trap")
						-- return _A.clickcast(Obj, "Freezing Trap")
					end
				end
			end
		end
	end,
	freezing_focus = function()
		if player:SpellCooldown("Freezing Trap")<.3 and player:buff("Trap Launcher") and player:glyph("Glyph of Solace") and player:spellusable("Freezing Trap") then
			local focus = Object("focus")
			if focus and focus:enemy() and focus:alive() and focus.isplayer and focus:spellRange("Arcane Shot") 
				and (focus:debuff("Scatter Shot") or (focus:stateduration("disorient || charm || sleep || stun")>1 and focus:stateduration("disorient || charm || sleep || stun")<4)) 
				and (focus:drstate("Freezing Trap")==1 or focus:drstate("Freezing Trap")==-1) 
				and not focus:debuffany("Wyvern Sting") and _A.notimmune(focus) and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not  player:isCastingAny()  then
					return scatter_x and focus:debuff("Scatter Shot") and _A.clickcastdetail(scatter_x, scatter_y, scatter_z, "Freezing Trap") or _A.clickcast(focus, "Freezing Trap")
					-- return _A.clickcast(focus, "Freezing Trap")
				end
			end
		end
	end,
	sleep = function()
		if player:Talent("Wyvern Sting") and player:SpellCooldown("Wyvern Sting")<.3  and player:spellusable("Wyvern Sting") and player:SpellCooldown("Scatter Shot")>player:gcd()
			and _A.castdelay("Freezing Trap",3) and _A.castdelay("Scatter Shot",3) 
			then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:spellRange("Arcane Shot") and Obj:InConeOf("player", 170) and healerspecid[Obj:spec()] 
					and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
					and not Obj:state("dot") and _A.notimmune(Obj) and Obj:los() then
					return Obj:cast("Wyvern Sting")
				end
			end
		end
	end,
	sleep_focus = function()
		if player:Talent("Wyvern Sting") and player:SpellCooldown("Wyvern Sting")<.3  and player:spellusable("Wyvern Sting") and player:SpellCooldown("Scatter Shot")>player:gcd()
			and _A.castdelay("Freezing Trap",3) and _A.castdelay("Scatter Shot",3)
			then
			local focus = Object("focus")
			if focus and focus:enemy() and focus:alive() and focus.isplayer and focus:spellRange("Arcane Shot") and focus:InConeOf("player", 170)
				and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and not focus:state("dot") and _A.notimmune(focus) and focus:los() then
				return focus:cast("Wyvern Sting")
			end
		end
	end,
	bindingshot = function()
		if player:talent("Binding Shot") and player:SpellCooldown("Binding Shot")==0 and player:SpellUsable("Binding Shot") and not player:buff("Deterrence") 
			and player:spellusable("Binding Shot")
			then
			if (player:SpellCooldown("Ice Trap")<(player:gcd()*2)) or (player:SpellCooldown("Snake Trap")<(player:gcd()*2)) then
				local lowestmelee = Object("meleeunitstobindshot")
				if lowestmelee then
					return _A.clickcast(lowestmelee, "Binding Shot")
				end
			end
		end
	end,
	-- Burst
	activetrinket = function()
		if player:combat() and player:buff("Surge of Conquest") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
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
	bursthunt = function()
		if player:combat() and player:buff("Call of Conquest") and player:SpellCooldown("Rapid Fire")==0 and player:spellusable("Rapid Fire") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and lowestmelee.isplayer
				-- and lowestmelee:health()>=35
				then 
				return player:cast("Rapid Fire")
			end
		end
	end,
	fervor = function()
		if player:combat() and player:Talent("Fervor") and player:SpellCooldown("Fervor")==0 and player:spellusable("Fervor") and player:focus()<=40 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and lowestmelee.isplayer
				-- and lowestmelee:health()>=35
				then 
				return player:cast("Fervor")
			end
		end
	end,
	stampede = function()
		if player:combat() and player:buff("Rapid Fire") and player:SpellCooldown("Stampede")<.3 and player:spellusable("Stampede") then
			local lowestmelee = Object("simpletarget(Arcane Shot)")
			if lowestmelee and lowestmelee.isplayer
				-- and lowestmelee:health()>=35
				then 
				return lowestmelee:cast("Stampede")
			end
		end
	end,
	bestialwrath = function()
		local pet = Object("pet")
		if pet and pet:alive() and player:combat() and player:SpellCooldown("Bestial Wrath")==0
			and player:buff("Call of Conquest")
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee
				-- and lowestmelee:health()>=35
				then 
				return player:cast("Bestial Wrath")
			end
		end
	end,
	frenzy = function()
		local pet = Object("pet")
		if pet and pet:alive() and player:combat() and player:BuffStackAny("Frenzy")==5 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee
				then 
				return player:cast("Focus Fire")
			end
		end
	end,
	direbeast = function()
		if player:combat() and player:talent("Dire Beast") and player:SpellCooldown("Dire Beast")<.3 and player:combat() then
			local lowestmelee = Object("simpletarget(Arcane Shot)")
			if lowestmelee
				then 
				return lowestmelee:cast("Dire Beast")
			end
		end
	end,
	-- ROTATION
	killcommand = function()
		if _A.KCcheck() and player:SpellUsable("Kill Command") and player:SpellCooldown("Kill Command")<.3 and player:Spellusable("Kill Command") then
			local lowestmelee = Object("lowestEnemyInSpellRangePetPOVKC")
			if lowestmelee then
				return lowestmelee:Cast("Kill Command")
			end
		end
	end,
	amoc = function()
		if player:talent("A Murder of Crows") and player:SpellCooldown("A Murder of Crows")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("A Murder of Crows") then
					return lowestmelee:Cast("A Murder of Crows")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot") 
				end
			end
		end
	end,
	serpentsting = function()
		if _A.MissileExists("Serpent Sting")==false and player:spellcooldown("Serpent Sting")<.3  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and not lowestmelee:debuff(118253) 
				and (lowestmelee.isplayer or _A.pull_location=="none")
				then
				if player:SpellUsable("Serpent Sting") then
					return lowestmelee:Cast("Serpent Sting")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	serpentsting_check = function()
		if _A.MissileExists("Serpent Sting")==false and player:spellcooldown("Serpent Sting")<.3  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and not lowestmelee:debuff(118253) and lowestmelee:health()>50
				and (lowestmelee.isplayer or _A.pull_location=="none")
				then
				if player:SpellUsable("Serpent Sting") and _A.lowpriocheck("Serpent Sting") then
					return lowestmelee:Cast("Serpent Sting")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	multishot = function()
		if player:spellcooldown("Multi-Shot")<.3  then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("Multi-Shot") and _A.multishotcheck() then 
					return lowestmelee:Cast("Multi-Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	barrage = function()
		if player:Talent("Barrage") and player:spellcooldown("Barrage")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("Barrage") then
					return lowestmelee:Cast("Barrage")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	arcaneshot = function() --player:buff("Thrill of the Hunt")
		if player:spellcooldown("Arcane Shot")<.3 then
			local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if _A.lowpriocheck("Arcane Shot") and player:SpellUsable("Arcane Shot") then
					return lowestmelee:Cast("Arcane Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	tranquillshot_highprio = function()
		if player:spellcooldown("Tranquilizing Shot")<.3
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Tranquilizing Shot)")
			if lowestmelee and canpurge(lowestmelee.guid) then
				if player:SpellUsable("Tranquilizing Shot") then
					return lowestmelee:Cast("Tranquilizing Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	tranquillshot_midprio = function()
		if player:spellcooldown("Tranquilizing Shot")<.3 
			-- and _A.MissileExists("Tranquilizing Shot")==false
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Tranquilizing Shot)")
			if lowestmelee and canpurge(lowestmelee.guid) then
				if player:SpellUsable("Tranquilizing Shot") and _A.lowpriocheck("Tranquilizing Shot") then
					return lowestmelee:Cast("Tranquilizing Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	tranq_hop = function()
		if player:SpellCooldown("Tranquilizing Shot")<.3 then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:spellRange("Tranquilizing Shot") and not Obj:state("incapacitate || disorient || charm || misc || sleep || fear")
					and not Obj:BuffAny("Divine Shield") and Obj:InConeOf("player", 170)
					and Obj:BuffAny("Hand of Protection")
					and Obj:los() then
					if player:SpellUsable("Tranquilizing Shot") then
						return Obj:Cast("Tranquilizing Shot")
						elseif _A.CobraCheck() then 
						local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
						if lowestmelee then return lowestmelee and player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")	end
					end
				end
			end
		end
	end,
	venom = function()
		if _A.MissileExists("Widow Venom")==false and player:spellcooldown("Widow Venom")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Widow Venom)")
			if lowestmelee and lowestmelee.isplayer and not lowestmelee:debuff("Widow Venom") then
				if player:SpellUsable("Widow Venom") and _A.lowpriocheck("Widow Venom") then
					return lowestmelee:Cast("Widow Venom")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	glaivetoss = function()
		if player:talent("Glaive Toss") and player:SpellCooldown("Glaive Toss")<.3 then
			local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if _A.glaivetosscheck() and player:SpellUsable("Glaive Toss") then
					return lowestmelee:Cast("Glaive Toss")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	killshot = function()
		if player:Spellcooldown("Kill Shot")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Kill Shot)")
			if lowestmelee and lowestmelee:health()<=20 then
				return lowestmelee:Cast("Kill Shot")
			end
		end
	end,
}
local function AOEcheck()
	if _A.modifier_shift() then return true end
	-- if (_A.clumpcount>=enemytreshhold) then return true end
	return false
end
---========================
---========================
---========================
---========================
---========================
local testtbl = {
	"snare"
}
_A.totemtar = nil
local inCombat = function()
	if not _A.Cache.Utils.PlayerInGame then return true end
	player = Object("player")
	if not player then return true end
	local focus = Object("focus")
	--debug
	-- print(player:immuneduration("snare || all"))
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	_A.totemtar = Object("HealingStreamTotemPLAYER(Arcane Shot)")
	if not _A.pull_location then return true end
	if player:mounted() then return true end
	if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return true end
	if player:isChanneling("Barrage") then return true end
	-------------------------- UTILITY
	survival.rot.roarofsac()
	survival.rot.killcommand()
	survival.rot.spiritmend()
	-- if player:lostcontrol() then return true end
	if player:buff("Camouflage") then return true end
	-- Defs
	survival.rot.deterrence()
	survival.rot.masterscall()
	-- no gcd
	if not player:isCastingAny() then
		-- if survival.rot.pet_misdirect() then return end -- bugged
		survival.rot.items_healthstone()
	end
	-- Traps
	if not player:buff("Deterrence") then
		survival.rot.bindingshot()
	end
	if survival.rot.freezing_focus() then return true end
	if _A.pull_location=="arena" then
		if survival.rot.freezing() then return true end
	end
	if _A.pull_location~="arena" then
		if survival.rot.traps() then return end
	end
	-------------------------- MAIN ROTATION
	if player:buff("Deterrence") then return true end
	survival.rot.autoattackmanager()
	if not (not player:isCastingAny() or player:CastingRemaining() < 0.3) then return true end
	-- Burst
	survival.rot.items_agiflask()
	survival.rot.activetrinket()
	survival.rot.bursthunt()
	survival.rot.fervor()
	survival.rot.frenzy()
	survival.rot.bestialwrath()
	survival.rot.direbeast()
	survival.rot.stampede()
	survival.rot.kick()
	if AOEcheck() and survival.rot.barrage() then return end -- make a complete aoe check function
	if AOEcheck() and survival.rot.multishot() then return end -- make a complete aoe check function
	-- Important Spells
	if survival.rot.scatter_focus() then return end
	if survival.rot.sleep_focus() then return end
	if _A.pull_location=="arena" then -- on healer
		if survival.rot.scatter() then return end
		if survival.rot.sleep() then return end
	end
	survival.rot.killshot()
	if not _A.modifier_ctrl() and _A.pull_location=="arena" and  survival.rot.tranquillshot_midprio() then return end -- only worth it in arena
	if _A.modifier_alt() then survival.rot.concussion() end
	-- important spells
	if player:buff("Thrill of the Hunt") and player:buffduration("Arcane Intensity")<1.5 and _A.MissileExists("Arcane Shot")==false and survival.rot.arcaneshot() then return end
	if survival.rot.tranq_hop() then return end
	if survival.rot.serpentsting_check() then return end
	if survival.rot.amoc() then return end
	if survival.rot.glaivetoss() then return end
	-- excess focus priority
	if survival.rot.venom() then return end
	-- heal Pet
	survival.rot.mendpet()
	-- fill
	if survival.rot.arcaneshot() then return end
	-- Fills
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(253, {
	name = "Youcef's BM Hunter",
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