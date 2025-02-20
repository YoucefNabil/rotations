local _, class = UnitClass("player")
if class ~= "MONK" then return end
local _, _A, _Y = ...
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
local UnitCanCooperate, UnitHealthMax, GetTime, UnitIsPlayer, string_find = UnitCanCooperate, UnitHealthMax, GetTime,
UnitIsPlayer, string.find
local manamodifier = 1
local ENEMY_OM = {}
local cdcd = .3
local FRIEND_OM = {}
local tlp = _A.Tooltip
local UnitBuff = UnitBuff
local function blank()
end
local function runthese(...)
	local runtable = { ... }
	return function()
		for i = 1, #runtable do
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
		else
		return -1
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
	local shield = select(15, _A.UnitDebuff(t, SPELL_SHIELD_LOW)) or select(15, _A.UnitDebuff(t, SPELL_SHIELD_MEDIUM)) or
	select(15, _A.UnitDebuff(t, SPELL_SHIELD_FULL)) or
	0 -- or ((select(15, UnitDebuff(t, SPELL_SHIELD_FULL)))~=nil and UnitHealthMax(t))
	if shield ~= 0 then return shield else return _A.UnitHealth(t) end
end
local function CalculateHPRAWMAX(t)
	return (_A.UnitHealthMax(t))
end
local function CalculateHP(t)
	return 100 * (CalculateHPRAW(t)) / CalculateHPRAWMAX(t)
end
local blacklistSS = {
	-- ["Kimpackabowl"] = true,
	-- ["Rauteeins"] = true,
	-- ["Jimmyiwnl"] = true,
	-- ["Tdot"] = true,
	-- [] = true,
	-- [] = true,
	-- [] = true,
}
--
local donthealtheseguys = {
}
--
local healerspecid = {
	-- HEALERS
	[105] = "Druid Resto",
	[270] = "monk mistweaver",
	[65] = "Paladin Holy",
	[257] = "Priest Holy",
	[256] = "Priest discipline",
	[264] = "Sham Resto",
	--DRUIDS
	-- [102]="Druid Balance",
	-- [103]="Druid Balance",
	-- LOCKS
	-- [265]="Lock Affli",
	-- [266]="Lock Demono",
	-- [267]="Lock Destro",
	--PALADINS
	-- [66]="Paladin prot",
	-- [70]="Paladin retri",
	-- PRIEST
	-- [258]="Priest shadow",
	-- SHAM
	-- [262]="Sham Elem",
	-- [263]="Sham enh",
	-- MAGE
	-- [62]="Mage Arcane",
	-- [63]="Mage Fire",
	-- [64]="Mage Frost",
	-- Hunter
	-- [253] = "hunter",
	-- [254] = "hunter",
	-- [255] = "hunter",
	-- ROGUE
	-- [259] = "rogue",
	-- [260] = "rogue",
	-- [261] = "rogue",
	-- MONK
	-- [269] = "ww monk",
}
--
local spelltable = {
	[5782] = 2,          -- Fear
	[30108] = 1,         -- Unstable Affliction
	[1454] = 1,          -- Life Tap
	[33786] = 2,         -- Cyclone
	[28272] = 2,         -- Polymorph (Pig)
	[118] = 2,           -- Polymorph
	[61305] = 2,         -- Polymorph (Black Cat)
	[61721] = 2,         -- Polymorph (Rabbit)
	[61780] = 2,         -- Polymorph (Turkey)
	[28271] = 2,         -- Polymorph (Turtle)
	[51514] = 2,         -- Hex
	[339] = 1,           -- Entangling Roots
	[30451] = 1,         -- Arcane Blast
	[20066] = 2,         -- Repentance
	[116858] = 2,        -- Chaos Bolt
	[113092] = 1,        -- Frost Bomb
	[8092] = 1,          -- Mind Blast
	[11366] = 1,         -- Pyroblast
	[48181] = 1,         -- Haunt
	[102051] = 1,        -- Frostjaw
	[1064] = 1,          -- Chain Heal
	[77472] = 2,         -- Greater Healing Wave
	[8004] = 2,          -- Healing Surge
	[73920] = 1,         -- Healing Rain
	[51505] = 1,         -- Lava Burst
	[8936] = 2,          -- Regrowth
	[2061] = 2,          -- Flash Heal
	[2060] = 2,          -- Heal
	[2006] = 1,          -- Resurrection
	[5185] = 2,          -- Healing Touch
	[19750] = 2,         -- Flash of Light
	[635] = 1,           -- Holy Light
	[7328] = 1,          -- Redemption
	[2008] = 1,          -- Ancestral Spirit
	[50769] = 1,         -- Revive
	[2812] = 1,          -- Holy Wrath
	[82327] = 1,         -- Holy Radiance
	[10326] = 2,         -- Turn Evil
	[82326] = 2,         -- Divine Light
	[116694] = 2,        -- Surging Mist
	[124682] = 1,        -- Enveloping Mist
	[115151] = 1,        -- Renewing Mist
	[115310] = 1,        -- Revival
	-- [126201] = 1,   -- Frostbolt (Water Elemental)
	[44614] = 1,         -- Frostfire Bolt
	[133] = 1,           -- Fireball
	[1513] = 1,          -- Scare Beast
	[982] = 2,           -- Revive Pet
	[111771] = 2,        -- Demonic Gateway
	-- [118297] = 1,   -- Immolate (Fel Imp)
	[29722] = 1,         -- Incinerate
	[124465] = 1,        -- Vampiric Touch
	[32375] = 2,         -- Mass Dispel
	[2948] = 1,          -- Scorch
	[12051] = 2,         -- Evocation
	[90337] = 2,         -- Bad Manner (Monkey Pet)
	[47540] = 2,         -- Penance
	[115268] = 2,        -- Mesmerize (Shivarra)
	[6358] = 2,          -- Seduction (Succubus)
	[51963] = 2,         -- Pain Suppression
	[78674] = 1,         -- Starsurge
	[113792] = 1,        -- Psychic Terror (Psyfiend)
	[115175] = 2,        -- Soothing Mist
	[115750] = 2,        -- Blinding Light
	[103103] = 1,        -- Drain Soul
	[113724] = 2,        -- Ring of Frost
	[117014] = 1,        -- Elemental Blast
	[605] = 1,           -- Mind Control
	[740] = 2,           -- Tranquility
	[32546] = 2,         -- Binding Heal
	[113506] = 2,        -- Cyclone (Symbiosis)
	[31687] = 2,         -- Summon Water Elemental
	[119996] = 1,        -- Transcendence: Transfer
	[117952] = 1,        -- Crackling Jade Lightning
	[116] = 1,           -- Frostbolt
	[50464] = 1,         -- Nourish
	[331] = 1,           -- Healing Wave
	[724] = 1,           -- Lightwell
	[129197] = 1,        -- Insanity
	[1120] = 1,          -- Drain Soul
	[689] = 1,           -- Drain Life
	["Polymorph"] = 2,   -- Drain Life
	["Fists of Fury"] = 2, -- fists of fury
	["Shackle Undead"] = 2, -- fists of fury
	["Cyclone"] = 2,     -- fists of fury
	["Hex"] = 2,         -- fists of fury
}

local function kickcheck(unit)
	if unit then
		for k, _ in pairs(spelltable) do
			if _A.Core:GetSpellName(k) ~= nil then
				if unit:iscasting(k) or unit:channeling(k) then
					return true
				end
			end
		end
	end
	return false
end
local function kickcheck_highprio(unit)
	if unit then
		for k, v in pairs(spelltable) do
			if _A.Core:GetSpellName(k) ~= nil then
				if v == 2 and unit:iscasting(k) or unit:channeling(k) then
					return true
				end
			end
		end
	end
	return false
end

local function FlexIcon(SpellID, width, height, bool)
	local var = " \124T" ..
	(select(3, GetSpellInfo(SpellID)) or select(3, GetSpellInfo(24720))) ..
	":" .. (height or 25) .. ":" .. (width or 25) .. "\124t ";
	if bool then
		ico = var .. GetSpellInfo(SpellID)
		else
		ico = var
	end
	return ico
end

local header_tsize = 18
local checkbox_tsize = 15
local input_tsize = 15
local info_tsize = 15
local button_tsize = 15
local spacer_size = 3
local hpdeltas = {
	{ key = "1", text = "Low" },
	{ key = "2", text = "Normal" },
	{ key = "0", text = "Intensive" },
}
local GUI = {
	{ type = "spacer", size = spacer_size },
	{ type = "header", size = header_tsize, text = "|cFFffd000Info|r",                                             align = "center" },
	{ type = "spacer", size = spacer_size },
	{ type = 'text',   size = info_tsize,   text = 'Spotted lua errors?' },
	{ type = 'text',   size = info_tsize,   text = 'Send screenshots to me at discord! \nDiscord: @ .youcef' },
	{ type = 'spacer', size = spacer_size },
	{ type = 'text',   size = info_tsize,   text = 'Hardcoded keybinds:' },
	{ type = 'text',   size = info_tsize,   text = '|cFFffd000Hold CTRL|r: |cFFffd000Burst Single Target Healing|r' },
	{ type = 'text',   size = info_tsize,   text = '|cFFffd000Hold Shift|r: |cFFffd000Manaengine Bypass (turbo mode/spam spheres)|r' },
	{ type = 'text',   size = info_tsize,   text = '|cFFffd000Hold R|r: |cFFffd000DPS Rotation Mode|r' },
	{ type = "spacer", size = spacer_size },
	
	{ type = "spacer", size = spacer_size },
	{ type = "header", size = header_tsize, text = _A.Core:GetSpellIcon(115399, 16, 16) .. " |cFFffd000Utility|r", align = "center" },
	{ type = "spacer", size = spacer_size },
	{
		key = "hpdeltas",
		type = "dropdown",
		cw = 15,
		ch = 15,
		size = input_tsize,
		text = _A.Core:GetSpellIcon(123761, 15, 15) .. "Mana Usage: ",
		default = "0",
		list = hpdeltas
	},
	{ type = "spacer",   size = spacer_size },
	{ type = "checkbox", size = checkbox_tsize, text = "Use DPS leveling Rotation " .. _A.Core:GetSpellIcon(100787, 15, 15) .. " (R)", key = "leveling", default = false },
	{ type = "checkbox", size = checkbox_tsize, text = "Alert on Statue out of range " .. _A.Core:GetSpellIcon(115313, 15, 15),        key = "draw_statue_range", default = false },
	{ type = "spacer",   size = spacer_size },
	{ type = "spacer",   size = spacer_size },
	{ type = 'text',     size = info_tsize,     text = '© .youcef & _2related (UI)' },
}

local exeOnLoad = function()
	_A.Listener:Add("Entering_timerPLZ2", "PLAYER_ENTERING_WORLD", function(event)
		enteredworldat = _A.GetTime()
		local stuffsds = pull_location()
		_A.pull_location = stuffsds
	end
	)
	_A.pull_location = _A.pull_location or pull_location()
	enteredworldat = enteredworldat or _A.GetTime()
	_A.DSL:Register('healthmonk', function(unit)
		return CalculateHP(unit)
	end)
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats())) / 100)) / 10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	_A.pressedbuttonat = 0
	_A.buttondelay = 0.6
	local STARTSLOT = 97
	local STOPSLOT = 104
	function _A.groundposition(unit)
		if unit then
			local x, y, z = _A.ObjectPosition(unit.guid)
			local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
			local los, cx, cy, cz = _A.TraceLine(x, y, z + 5, x, y, z - 200, flags)
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
	
	function _A.groundpositiondetail(x, y, z)
		local flags = bit.bor(0x100000, 0x10000, 0x100, 0x10, 0x1)
		local los, cx, cy, cz = _A.TraceLine(x, y, z + 5, x, y, z - 200, flags)
		if not los then
			return cx, cy, cz
		end
	end
	
	_A.hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		player = player or Object("player")
		if slot == STARTSLOT then
			_A.pressedbuttonat = 0
			if _A.DSL:Get("toggle")(_, "MasterToggle") ~= true then
				_A.Interface:toggleToggle("mastertoggle", true)
				-- _A.print("ON")
				return true
			end
		end
		if slot == STOPSLOT then
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			-- _A.print(_A.groundposition(player))
			-- TEST STUFF
			-- local target = Object("target")
			-- if target then print(target:creatureType()) end
			if _A.DSL:Get("toggle")(_, "MasterToggle") ~= false then
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
	-----------------------------------
	-----------------------------------
	-----------------------------------	-----------------------------------
	-----------------------------------
	function _A.guid_distance(unit1, unit2)
		local x1, y1, z1 = unit1 and _A.ObjectPosition(unit1)
		local x2, y2, z2 = unit2 and _A.ObjectPosition(unit2)
		if x1 and x2 and y1 and y2 and z1 and z2 then
			return _A.GetDistanceBetweenPositions(x1, y1, z1, x2, y2, z2)
			else
			return 9999
		end
	end
	
	function _A.someoneislow()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer then
				if Obj:Health() <= 35 then
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
			local los, cx, cy, cz = _A.TraceLine(px, py, pz + 5, px, py, pz - 200, flags)
			if not los then
				print("Distance to ground ", pz - cz)
				else
				print("interception not found within the specified distance.")
			end
		end
	end
	-----------------------------------
	function _Y.rushing_number()
		local numnum = 0
		local numnum2 = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:range() < 8 and _A.notimmune(Obj) and Obj:los() then
				numnum = numnum + 1
			end
		end
		for _, Obj in pairs(_A.OM:Get('Friendly')) do
			if Obj.isplayer and Obj:range() < 8 and Obj:health() < 90 and _A.nothealimmune(Obj) and Obj:los() then
				numnum2 = numnum2 + 1
			end
		end
		return math.max(numnum, numnum2)
	end
	
	-----------------------------------
	_A.buttondelayfunc = function()
		if player:stance() ~= 1 then return false end
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end
		return false
	end
	_A.FakeUnits:Add('lowestall', function(num, spell)
		local tempTable = {}
		local location = _A.pull_location
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer
				or string.lower(fr.name) == "ebon gargoyle"
				or fr.name == "Vanndar Stormpike"
				or fr.name == "Overlord Agmar"
				or (location == "arena" and fr:ispet()) then
				if fr:SpellRange("Renewing Mist")
					and _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable + 1] = {
						HP = fr:health(),
						guid = fr.guid
					}
				end
			end
		end
		if #tempTable > 1 then
			table.sort(tempTable, function(a, b) return (a.HP < b.HP) end)
		end
		if #tempTable >= 1 then
			return tempTable[1] and tempTable[1].guid
			else
			return
		end
	end)
	_A.FakeUnits:Add('lowestallNOHOT', function(num, spell)
		local tempTable = {}
		local location = pull_location()
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" or (location == "arena" and fr:ispet()) then
				if not fr:Buff(132120)
					and fr:SpellRange("Renewing Mist") and _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable + 1] = {
						HP = fr:health(),
						guid = fr.guid
					}
				end
			end
		end
		if #tempTable > 1 then
			table.sort(tempTable, function(a, b) return (a.HP < b.HP) end)
		end
		if #tempTable >= 1 then
			return tempTable[1] and tempTable[1].guid
			else
			return
		end
	end)
	_A.FakeUnits:Add('lowestEnemyInSpellRangeMINIMAL', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if _A.notimmune(Obj) and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and Obj:spellRange(spell) then
				tempTable[#tempTable + 1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable > 1 then
			table.sort(tempTable,
			function(a, b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end)
		end
		if #tempTable >= 1 then
			return tempTable[num] and tempTable[num].guid
			else
			return
		end
	end)
	_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
		local tempTable = {}
		local target = Object("target")
		if target and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and _A.notimmune(target)
			and not target:state("incapacitate || fear || disorient || charm || misc || sleep")
			and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and _A.notimmune(Obj) and Obj:InConeOf(player, 170) and not Obj:state("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable + 1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable > 1 then
			table.sort(tempTable,
			function(a, b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end)
		end
		if #tempTable >= 1 then
			return tempTable[num] and tempTable[num].guid
			else
			return
		end
	end)
	-- disarm
	--[[
		burstdisarm = function()
		if player:Stance() == 1   then
		if player:SpellCooldown("Grapple Weapon")<cdcd then
		for _, obj in pairs(_A.OM:Get('Enemy')) do
		if obj.isplayer
		and obj:SpellRange("Grapple Weapon")
		and obj:InConeOf(player, 170)
		and not healerspecid[obj:spec()]
		-- and (_A.pull_location=="arena" or UnitTarget(obj.guid)==player.guid)
		and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest"))
		and not obj:BuffAny("Bladestorm")
		and not obj:state("incapacitate || fear || disorient || charm || misc || sleep || disarm")
		and (obj:drState("Grapple Weapon") == 1 or obj:drState("Grapple Weapon")==-1)
		and obj:range()<10
		and (_A.pull_location=="arena" or _A.UnitTarget(obj.guid)==player.guid)
		and _A.notimmune(obj)
		and obj:los() then
		return obj:Cast("Grapple Weapon")
		end
		end
		end
		end
	--]]
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
	_Y.healingspheretime = nil
	_A.SMguid = nil
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts_Monk_and_misc", "COMBAT_LOG_EVENT_UNFILTERED",
		function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd, _, _, amount)
			-- Testing
			-- if subevent == "SWING_DAMAGE" or subevent == "RANGE_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "SPELL_BUILDING_DAMAGE" or subevent == "ENVIRONMENTAL_DAMAGE"  then
			-- print(subevent.." "..amount) -- too much voodoo
			-- end
			if guidsrc == UnitGUID("player")
				then
				-- DEBUG
				-- if subevent == "SPELL_CAST_SUCCESS" then
				-- if idd==115460 then
				-- _Y.healingspheretime = GetTime()
				-- end
				-- if idd==115464 then
				-- if _Y.healingspheretime then
				-- print(GetTime()-_Y.healingspheretime)
				-- _Y.healingspheretime = nil
				-- end
				-- end
				-- end
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
				----------------------
			end
		end)
		function _A.castdelay(idd, delay)
			if delay == nil then return true end
			if _A.casttimers[idd] == nil then return true end
			return (_A.GetTime() - _A.casttimers[idd]) >= delay
		end
		
		local function someonebursting()
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer
					and not healerspecid[obj:spec()]
					and obj:BuffAny("Call of Victory || Call of Conquest || Call of Dominance")
					and obj:range() < 40
					and not obj:state("incapacitate || fear || disorient || charm || misc || sleep || disarm || stun")
					and obj:los() then
					return true
				end
			end
			return false
		end
		
		-- ====
		local MW_HealthUsedData = {}
		local MW_LastHealth = {}
		local MW_HealthAnalyzedTimespan_fixed = 18
		local MW_HealthAnalyzedTimespan = MW_HealthAnalyzedTimespan_fixed
		--====================================================== Testing
		_A.Listener:Add("Health_change_track", "COMBAT_LOG_EVENT_UNFILTERED",
			function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
				if string_find(subevent, "_DAMAGE") or string_find(subevent, "_HEAL") then -- does this work with absorbs? I don't remember testing this
					if UnitIsPlayer(guiddest) then                                -- only players
						-- all subevent susceptible of causing health changes
						-- print("picked up")
						if MW_HealthUsedData[guiddest] == nil then
							MW_HealthUsedData[guiddest] = {}
							MW_HealthUsedData[guiddest].t = {}
							MW_LastHealth[guiddest] = CalculateHPRAW(guiddest)
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
			if MW_LastHealth[unitID] and MW_LastHealth[unitID] ~= currentHealth then -- needed otherwise will just feed the next function zeroes
				PlayerHealthChanged(unitID, currentHealth, UnitHealthMax(unitID), currentHealth - MW_LastHealth[unitID])
			end
			MW_LastHealth[unitID] = currentHealth --
		end
		
		function PlayerHealthChanged(unit, Current, Max, Usage)
			local uptime = GetTime()
			-- Fixed
			if someonebursting() then
				MW_HealthAnalyzedTimespan = MW_HealthAnalyzedTimespan_fixed * 0.7
				else
				MW_HealthAnalyzedTimespan =
				MW_HealthAnalyzedTimespan_fixed
			end
			--
			if MW_HealthUsedData[unit] then
				MW_HealthUsedData[unit].healthUsed = 0
				MW_HealthUsedData[unit].healthnegative = 0
				MW_HealthUsedData[unit].healthpositive = 0
				MW_HealthUsedData[unit].t[uptime] = Usage
				for Time, Health in pairs(MW_HealthUsedData[unit].t) do
					if uptime - Time > MW_HealthAnalyzedTimespan then
						MW_HealthUsedData[unit].t[Time] = nil
						else
						MW_HealthUsedData[unit].healthUsed = MW_HealthUsedData[unit].healthUsed + Health
						if Health < 0 then
							MW_HealthUsedData[unit].healthnegative = MW_HealthUsedData[unit].healthnegative + Health
							else
							MW_HealthUsedData[unit].healthpositive = MW_HealthUsedData[unit].healthpositive + Health
						end
					end
				end
				MW_HealthUsedData[unit].avgHDelta = (MW_HealthUsedData[unit].healthUsed / MW_HealthAnalyzedTimespan)
				MW_HealthUsedData[unit].avgHDeltaPercent = (MW_HealthUsedData[unit].avgHDelta * 100) / Max
				--
				MW_HealthUsedData[unit].healthnegativepercent = (MW_HealthUsedData[unit].healthnegative * 100) / Max
				--
				MW_HealthUsedData[unit].healthpositivepercent = (MW_HealthUsedData[unit].healthpositive * 100) / Max
			end
		end
		
		--====================================================== MANA
		--====================================================== MANA
		--====================================================== MANA
		--====================================================== MANA
		--====================================================== MANA
		local function effectivemanaregen()
			local basemanaregen = GetManaRegen()
			return (basemanaregen * 100) / UnitPowerMax("player", 0)
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
		local MW_AnalyzedTimespan = 30
		local avgDelta = 0
		_A.avgDeltaPercent = 0
		local secondsTillOOM = 99999
		_A.Listener:Add("holy_mana", { "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_POWER" },
			function(event, firstArg, secondArg)
				if event == "UNIT_POWER" and firstArg == "player" and secondArg == "MANA" then
					if MW_LastMana == nil then MW_LastMana = UnitPower("player", 0) end
					_A.UnitManaHandler(firstArg)
				end
			end)
			function _A.UnitManaHandler(unitID)
				if unitID == "player" then
					local currentMana = UnitPower(unitID, 0)
					if MW_LastMana and currentMana ~= MW_LastMana then
						_A.PlayerManaChanged(currentMana, UnitPowerMax(unitID, 0), MW_LastMana - currentMana)
					end
					MW_LastMana = currentMana
				end
			end
			
			function _A.PlayerManaChanged(Current, Max, Usage)
				local uptime = GetTime()
				-- FIXED
				local manaUsed = 0
				MW_ManaUsedData[uptime] = Usage
				for Time, Mana in pairs(MW_ManaUsedData) do
					if uptime - Time > MW_AnalyzedTimespan then
						MW_ManaUsedData[Time] = nil
						else
						manaUsed = manaUsed + Mana
					end
				end
				avgDelta = -(manaUsed / MW_AnalyzedTimespan)
				_A.avgDeltaPercent = (avgDelta * 100 / Max)
				if avgDelta < 0 then
					secondsTillOOM = Current / (-avgDelta)
					else
					secondsTillOOM = 99999
				end
			end
			
			--====================================================================== -- Cleaning on Deaths
			_A.Listener:Add("DeathCleaning", "COMBAT_LOG_EVENT_UNFILTERED",
				function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
					if subevent == "UNIT_DIED" then
						if MW_HealthUsedData[guiddest] ~= nil then
							MW_HealthUsedData[guiddest] = nil
							MW_LastHealth[guiddest] = nil
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
			-- HEALTH
			function averageHPv2()
				local sum = 0
				local num = 0
				if next(MW_HealthUsedData) == nil then
					return 0
					else
					for k in pairs(MW_HealthUsedData) do
						if MW_HealthUsedData[k] ~= nil then
							if next(MW_HealthUsedData[k]) ~= nil then
								if MW_HealthUsedData[k].avgHDeltaPercent ~= nil then
									if UnitIsDeadOrGhost(k) == nil then
										if UnitHealth(k) < UnitHealthMax(k) then
											local unitObject = Object(k)
											if unitObject and unitObject:alive() and unitObject:friend() and unitObject:combat() and unitObject:SpellRange("Renewing Mist") then
												num = num + 1
												sum = sum + MW_HealthUsedData[k].avgHDeltaPercent
											end
										end
									end
								end
							end
						end
					end
				end
				return num > 0 and sum / num or 0
			end
			
			function maxHPv2()
				local maxx = 999
				if next(MW_HealthUsedData) == nil then
					return 0
					else
					for k in pairs(MW_HealthUsedData) do
						if MW_HealthUsedData[k] ~= nil then
							if next(MW_HealthUsedData[k]) ~= nil then
								if MW_HealthUsedData[k].avgHDeltaPercent ~= nil then
									if UnitIsDeadOrGhost(k) == nil then
										-- if UnitHealth(k)<UnitHealthMax(k) then
										local unitObject = Object(k)
										if unitObject and unitObject:alive() and unitObject:friend() and unitObject:combat() and unitObject:SpellRange("Renewing Mist") then
											if MW_HealthUsedData[k].avgHDeltaPercent < maxx then
												maxx = MW_HealthUsedData[k].avgHDeltaPercent
											end
											-- end
										end
									end
								end
							end
						end
					end
				end
				return maxx
			end
			
			function hybridHPv2()
				local maxmodifier = maxHPv2() * 0.7
				local avgmodifier = averageHPv2() * 0.3
				return maxmodifier + avgmodifier
			end
			
			function _A.manaengine() -- make it so it's tied with group hpF
				player = player or Object("player")
				if player:buff("Lucidity") or player:mana() >= 95 then return true end
				local hpdeltas = player:ui("hpdeltas")
				if hpdeltas == "1" then
					hpDelta = averageHPv2()
					elseif hpdeltas == "2" then
					hpDelta = hybridHPv2()
					elseif hpdeltas == "0" then
					hpDelta = maxHPv2()
				end
				local manaBudget = _A.avgDeltaPercent + effectivemanaregen()
				return manaBudget >= hpDelta
			end
			
			--------------------------------------------------------
			function _A.manaengine_highprio()
				player = player or Object("player")
				if player:buff("Lucidity") or player:mana() >= 95 then return true end
				local hpdeltas = player:ui("hpdeltas")
				if hpdeltas == "1" then
					hpDelta = averageHPv2()
					elseif hpdeltas == "2" then
					hpDelta = hybridHPv2()
					elseif hpdeltas == "0" then
					hpDelta = maxHPv2()
				end
				local manaBudget = _A.avgDeltaPercent + effectivemanaregen()
				return (manaBudget - hpDelta > 1.5)
			end
			
			function _A.enoughmana(id)
				local cost, _, powertype = select(4, _A.GetSpellInfo(id))
				if powertype then
					local currentmana = _A.UnitPower("player", powertype)
					if currentmana >= cost then
						return true
						else
						return false
					end
				end
				return true
			end
			
			function _A.enoughmana(id)
				local cost, _, powertype = select(4, _A.GetSpellInfo(id))
				if powertype then
					local currentmana = _A.UnitPower("player", powertype)
					if currentmana >= cost then
						return true
						else
						return false
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
			
			function _A.modifier_alt()
				local modkeyb = IsAltKeyDown()
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
					if not unit:InConeOf(player, 170) then
						_A.FaceDirection(unit.guid, true)
					end
				end
			end
			-------------------------------------------------------
			-------------------------------------------------------
			local function IsPStr() -- player only, but more accurate
				local _, strafeleftkey = _A.GetBinding(7)
				local _, straferightkey = _A.GetBinding(8)
				local moveLeft = _A.IsKeyDown(strafeleftkey)
				local moveRight = _A.IsKeyDown(straferightkey)
				if moveLeft then
					return "left"
					elseif moveRight then
					return "right"
					else
					return "none"
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
				-- local latencyy = ((select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10) or 0
				local latencyy = (select(3, GetNetStats())) and ((select(3, GetNetStats())) / 1000) or 0
				local speed = speed_raw * latencyy
				-- local speed = speed_raw
				-- local mindistances = speed * .2
				
				-- local distance = math.max(mindistances, math.min(maxDistance, speed + latencyy)) -- old is speed - 4.5
				local distance = -speed
				-- local distance = 0
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
				local px, py, pz = _A.groundposition(unit)
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
				if UnitCastingInfo(unit) ~= nil
					then
					timetimetime15687 = abs(givetime - (tempvar / 1000))
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
				if UnitChannelInfo(unit) ~= nil
					then
					local maxcasttime = abs(tempvar1 - tempvar2) / 1000
					local remainingcasttimeinsec = abs(givetime - (tempvar2 / 1000))
					local percentageofthis = (remainingcasttimeinsec * 100) / maxcasttime
					return percentageofthis
				end
				return 999
			end
			
			_A.DSL:Register('chanpercent', function(unit)
				return chanpercent(unit)
			end)
			
			
			local function interruptable(unit)
				if unit == nil
					then
					unit = "target"
				end
				local intel5 = (select(9, UnitCastingInfo(unit)))
				local intel6 = (select(8, UnitChannelInfo(unit)))
				if intel5 == false
					or intel6 == false
					then
					return true
					else
					return false
				end
				return false
			end
			_A.DSL:Register('caninterrupt', function(unit)
				return interruptable(unit)
			end)
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
				"Lightwell",
				"Tremor Totem",
			}
			_A.FakeUnits:Add('HealingStreamTotem', function(num)
				local tempTable = {}
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					for _, totems in ipairs(badtotems) do
						if Obj.name == totems then
							tempTable[#tempTable + 1] = {
								guid = Obj.guid,
								range = Obj:range(),
							}
						end
					end
				end
				if #tempTable > 1 then
					table.sort(tempTable, function(a, b) return a.range < b.range end)
				end
				if #tempTable >= 1 then
					return tempTable[num] and tempTable[num].guid
				end
			end)
			_A.FakeUnits:Add('HealingStreamTotemNOLOS', function(num)
				local tempTable = {}
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					for _, totems in ipairs(badtotems) do
						if Obj.name == totems then
							tempTable[#tempTable + 1] = {
								guid = Obj.guid,
								range = Obj:range(),
							}
						end
					end
				end
				if #tempTable > 1 then
					table.sort(tempTable, function(a, b) return a.range < b.range end)
				end
				if #tempTable >= 1 then
					return tempTable[num] and tempTable[num].guid
				end
			end)
			_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKCNOLOS', function(num)
				local tempTable = {}
				local target = Object("target")
				local pet = Object("pet")
				if not pet then return end
				if pet and not pet:alive() then return end
				if pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
				--
				if target and target:enemy() and target:exists() and target:alive() and _A.notimmune(target)
					and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") then
					return target and target.guid -- this is good
				end
				local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
				if lowestmelee then
					return lowestmelee.guid
				end
				return nil
			end)
			_A.PetGUID = nil
			local function attacktotem()
				local htotem = Object("HealingStreamTotemNOLOS")
				if htotem and (_A.pull_location == "arena" or htotem:range() <= 60) then
					if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID) ~= htotem.guid) then
						return _A.CallWowApi("PetAttack", htotem.guid), 1
					end
					return 1
				end
			end
			local function attacklowest()
				local target = Object("lowestEnemyInSpellRangePetPOVKCNOLOS")
				if target then
					if (_A.pull_location ~= "party" and _A.pull_location ~= "raid") or target:combat() then -- avoid pulling shit by accident
						if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID) ~= target.guid) then
							return _A.CallWowApi("PetAttack", target.guid), 3
						end
					end
					return 3
				end
			end
			local function petfollow() -- when pet target has a breakable cc
				if _A.PetGUID and _A.UnitTarget(_A.PetGUID) ~= nil then
					local target = Object(_A.UnitTarget(_A.PetGUID))
					if target and target:alive() and target:enemy() and target:exists() and target:stateYOUCEF("incapacitate || disorient || charm || misc || sleep ||fear") then
						return _A.CallWowApi("RunMacroText", "/petfollow"), 4
					end
				end
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
			
			function _Y.petengine_MONK() -- REQUIRES RELOAD WHEN SWITCHING SPECS
				if not _A.Cache.Utils.PlayerInGame then return end
				if not player then return true end
				if _A.DSL:Get("toggle")(_, "MasterToggle") ~= true then return true end
				if player:mounted() then return end
				if UnitInVehicle(player.guid) and UnitInVehicle(player.guid) == 1 then return end
				if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") then
					if _A.PetGUID then _A.PetGUID = nil end
					return true
				end
				_A.PetGUID = _A.UnitGUID("pet")
				if _A.PetGUID == nil then return end
				-- print(_A.PetGUID)
				-- print(_Y.GetPetStance())
				-------- PET ROTATION
				-- if petpassive() then return end
				-- if attacktotem() then return end
				if attacklowest() then return end
				-- if petfollow() then return end
			end
			
			function _Y.cancelbuff(spellid)
				local player = Object("player")
				local SPELLIDD = (tonumber(spellid) and spellid or _A.Core:GetSpellID(spellid))
				if SPELLIDD and player:buffany(spellid) then
					for buff = 1, 40 do
						local name, _, _, _, _, _, _, _, _, _, id = _A.UnitBuff("player", buff)
						if not name then break end
						if id == SPELLIDD then
							_A.CancelUnitBuff("player", buff)
						end
					end
				end
			end
			
			local function statueInRange()
				for _, obj in pairs(_A.OM:Get('Friendly')) do
					if obj.id == 60849 then
						return obj:Distance() <= 20
					end
				end
				return false
			end
end
local exeOnUnload = function()
	Listener:Remove("DeathCleaning")
	Listener:Remove("Entering_timerPLZ2")
	Listener:Remove("delaycasts_Monk_and_misc")
	Listener:Remove("Health_change_track")
	Listener:Remove("holy_mana")
end
local usableitems = { -- item slots
	13,               --first trinket
	14                --second trinket
}
local function cditemRemains(itemid)
	local itempointerpoint;
	if itemid ~= nil
		then
		if tonumber(itemid) ~= nil
			then
			if itemid <= 23
				then
				itempointerpoint = (select(1, GetInventoryItemID("player", itemid)))
			end
			if itemid > 23
				then
				itempointerpoint = itemid
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
local dangerousdebuffs = {
	"Soul Reaper",
	"Paralytic Poison",
	"Deep Freeze",
	"Ring of Frost",
	"Freeze",
	"Denounce",
	"Frost Nova",
	"Execution Sentence",
	-- "Corruption",
	"Touch of Karma"
}
local mw_rot = {
	turtletoss = function()
		local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable = UnitCastingInfo("boss1");
		local channelName, _, _, _, channelStartTime, channelEndTime, _, channelInterruptable = UnitChannelInfo("boss1");
		if channelName ~= nil then
			castName = channelName
		end
		if unitDD("boss1") == 67977 then    -- tortos id
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
		if target and target.isplayer and target:enemy() and target:alive() and target:InConeOf(player, 180) and target:los() then
			if (target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep")) and player:autoattack() then
				_A.CallWowApi("RunMacroText", "/stopattack")
				elseif not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and not player:autoattack() then
				_A.CallWowApi("RunMacroText", "/startattack")
			end
		end
	end,
	activetrinket = function()
		if player:combat() and player:buff("Surge of Dominance") then
			for i = 1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i]))) ~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i]))) ~= "PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i])) == 0 then
							return _A.CallWowApi("RunMacroText", (string.format(("/use %s "), usableitems[i])))
						end
					end
				end
			end
		end
	end,
	Xuen = function()
		if player:combat() and player:talent("Invoke Xuen, the White Tiger") and player:SpellCooldown("Invoke Xuen, the White Tiger") == 0 then
			if player:buff("Call of Dominance") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
				if lowestmelee then
					lowestmelee:cast("Invoke Xuen, the White Tiger")
					return C_Timer.After(2, function()
						_A.RunMacroText("/petpassive")
					end)
				end
			end
		end
	end,
	items_intflask = function()
		if player:ItemCooldown(76085) == 0
			and player:ItemCount(76085) > 0
			and player:ItemUsable(76085)
			and not IsCurrentItem(76085)
			and not player:Buff(105691)
			then
			if pull_location() == "pvp" and player:combat() then
				return player:useitem("Flask of the Warm Sun")
			end
		end
	end,
	
	items_healthstone = function()
		if player:health() <= 35 then
			if player:ItemCooldown(5512) == 0
				and player:ItemCount(5512) > 0
				and not IsCurrentItem(5512)
				and player:ItemUsable(5512) then
				return player:useitem("Healthstone")
			end
		end
	end,
	
	cancel_badnoggen = function()
		if player:buffany("16591") and player:buffany("16595") then --16593
			for buff = 1, 40 do
				local name, _, _, _, _, _, _, _, _, _, id = UnitBuff("player", buff)
				if not name then break end
				if id == 16591 then
					CancelUnitBuff("player", buff)
				end
			end
		end
	end,
	
	items_noggenfogger = function()
		if player:ItemCooldown(8529) == 0
			and player:ItemCount(8529) > 0
			and player:ItemUsable(8529)
			and not IsCurrentItem(8529)
			-- and (not player:BuffAny(16591) or not player:BuffAny(16595))
			and (not player:BuffAny(16595))
			then
			if pull_location() == "pvp" then
				return player:useitem("Noggenfogger Elixir")
			end
		end
	end,
	
	arena_legsweep = function()
		local arenatar = 0
		if player:Stance() == 1 then
			if pull_location() == "arena" then
				if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep") < cdcd then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if obj.isplayer and obj:range() < 4
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
		if player:Stance() == 1 then
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
		if player:Stance() == 1 and pull_location() ~= "arena" then
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
		if player:Stance() == 1 then
			if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep") < cdcd then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:isCastingAny()
						and obj:range() < 5
						and _A.notimmune(obj)
						and (kickcheck_highprio(obj) or (_A.pull_location == "raid" or _A.pull_location == "party"))
						and obj:los() then
						return player:Cast("Leg Sweep")
					end
				end
			end
		end
	end,
	
	stun_legsweep = function()
		local enemycount = 0
		if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range() < 5
					and (obj:drstate("Leg Sweep") == -1 or obj:drstate("Leg Sweep") == 1)
					and _A.notimmune(obj)
					and obj:los() then
					enemycount = enemycount + 1
					if healerspecid[obj:spec()] then
						return player:cast("Leg Sweep")
					end
				end
			end
			if enemycount >= 2 or (enemycount >= 1 and _A.modifier_alt()) then return player:cast("Leg Sweep") end
		end
	end,
	kick_chargingox = function()
		if player:Stance() == 1 then
			if player:Talent("Charging Ox Wave") and player:SpellCooldown("Charging Ox Wave") < cdcd then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:range() < 30
						and obj:InConeOf(player, 90)
						and _A.notimmune(obj)
						and (kickcheck(obj) or (_A.pull_location == "raid" or _A.pull_location == "party"))
						and obj:los() then
						return player:Cast("Charging Ox Wave")
					end
				end
			end
		end
	end,
	kick_paralysis = function()
		if player:SpellCooldown("Paralysis") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer
					and obj:isCastingAny()
					and obj:SpellRange("Paralysis")
					and not obj:iscasting("Frostbolt")
					and (player:SpellCooldown("Spear Hand Strike") > _A.interrupttreshhold or not obj:caninterrupt() or not obj:SpellRange("Blackout Kick"))
					and obj:InConeOf(player, 170)
					and obj:infront()
					and _A.notimmune(obj)
					and (kickcheck_highprio(obj) or (_A.pull_location == "raid" or _A.pull_location == "party"))
					and obj:los() then
					return obj:Cast("Paralysis")
				end
			end
		end
	end,
	
	sapsnipe = function()
		if player:Stance() == 1 and player:SpellCooldown("Paralysis") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:SpellRange("Paralysis") then
					if
						-- (healerspecid[obj:spec()]) or
						(healerspecid[obj:spec()] and _A.pull_location ~= "arena") or
						(_A.pull_location == "arena" and UnitExists("party1") and UnitTarget("party1") ~= obj.guid)
						then
						if obj:stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 1.5
							and obj:InConeOf(player, 170)
							and obj:infront()
							and (obj:drState("Paralysis") == -1 or obj:drState("Paralysis") == 1)
							and _A.notimmune(obj)
							and obj:los() then
							return obj:Cast("Paralysis")
						end
					end
				end
			end
		end
	end,
	
	sapsextendcc = function()
		if player:Stance() == 1 and player:SpellCooldown("Paralysis") < cdcd then
			local check = UnitExists("focus")
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:SpellRange("Paralysis")
					and (_A.pull_location == "arena" and UnitExists("party1") and UnitTarget("party1") ~= obj.guid)
					-- and (healerspecid[obj:spec()])
					and obj:InConeOf(player, 170)
					and obj:infront()
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") > 0
					and obj:Stateduration("silence || incapacitate || fear || disorient || charm || misc || sleep || stun") < 2.5
					and _A.notimmune(obj)
					and obj:los() then
					return obj:Cast("Paralysis")
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
						if player:Chi() >= 3 and SMobj:los() then return SMobj:cast("Enveloping Mist", true) end
						if player:SpellUsable(116694) and player:Chi() < 3 and SMobj:los() then
							return SMobj:cast(
							"Surging Mist", true)
						end
					end
				end
				if not player:isChanneling("Soothing Mist") and player:SpellUsable(115175) and lowest then
					return lowest
					:cast("Soothing Mist")
				end
			end
			else
			if player:isChanneling("Soothing Mist") then _A.CallWowApi("SpellStopCasting") end
		end
	end,
	
	burstdisarm = function() -- should be arena only
		if player:SpellCooldown("Grapple Weapon") < cdcd then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer
					and obj:SpellRange("Grapple Weapon")
					and obj:InConeOf(player, 170)
					and not healerspecid[obj:spec()]
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest") or obj:BuffAny("Call of Dominance"))
					and not obj:BuffAny("Bladestorm")
					and not obj:state("incapacitate || fear || disorient || charm || misc || sleep || disarm || stun")
					and (obj:drState("Grapple Weapon") == 1 or obj:drState("Grapple Weapon") == -1)
					and (_A.pull_location == "arena" or (UnitTarget(obj.guid) == player.guid and obj:range() < 10))
					and _A.notimmune(obj)
					and obj:los() then
					return obj:Cast("Grapple Weapon")
				end
			end
		end
	end,
	
	kick_spear = function()
		if player:SpellCooldown("Spear Hand Strik") == 0 and not IsCurrentSpell(116705) then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj:isCastingAny()
					and obj:SpellRange("Blackout Kick")
					and obj:InConeOf(player, 170)
					and not obj:State("silence")
					and not obj:iscasting("Frostbolt")
					and obj:caninterrupt()
					and not obj:state("stun || silence || incapacitate || fear || disorient || charm || misc || sleep")
					and ((obj:castsecond() < _A.interrupttreshhold) or obj:chanpercent() <= 95)
					and (kickcheck(obj) or (_A.pull_location == "raid" or _A.pull_location == "party"))
					and _A.notimmune(obj)
					then
					obj:Cast("Spear Hand Strike")
				end
			end
		end
	end,
	
	everyman = function()
		if _A.pull_location ~= "arena" and not player:State("incapacitate || fear || disorient || charm || misc || sleep || stun") and not player:debuffany("Solar Beam") then
			if player:SpellCooldown("Every Man for Himself") == 0 and player:Stateduration("silence") >= 3 and not IsCurrentSpell(59752) then
				return player:cast("Every Man for Himself")
			end
		end
	end,
	
	nimble = function()
		if _A.pull_location ~= "arena" and not player:State("incapacitate || fear || disorient || charm || misc || sleep") then
			if player:SpellCooldown("Nimble Brew") == 0 and not IsCurrentSpell(137562) and player:health() <= 70 and not player:buff("Dematerialize") and player:Stateduration("stun") >= 3.5 then
				return player:cast("Nimble Brew")
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
	
	pvp_disable_target = function()
		if player:Stance() == 1 --and pull_location()=="arena"
			then
			local lowestmelee = Object("target")
			if lowestmelee and lowestmelee.isplayer and lowestmelee:enemy() and lowestmelee:alive() and lowestmelee:infront() and lowestmelee:SpellRange("Disable") 
				and not lowestmelee:state("incapacitate || fear || disorient || charm || misc || sleep") 
				and _A.notimmune(lowestmelee) 
				then
				if not lowestmelee:BuffAny("Bladestorm || Divine Shield || Die by the Sword || Hand of Protection || Hand of Freedom || Deterrence")
					and not lowestmelee:Debuff("Disable") and not lowestmelee:state("snare") and lowestmelee:los()  then
					----------------------------------
					return lowestmelee:Cast("Disable")
				end
			end
		end
	end,
	
	pvp_disable_keybind = function()
		if player:Stance() == 1 --and pull_location()=="arena"
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and not lowestmelee:BuffAny("Bladestorm || Divine Shield || Die by the Sword || Hand of Protection || Hand of Freedom || Deterrence") then
				----------------------------------
				return lowestmelee:Cast("Disable")
			end
		end
	end,
	
	pvp_disable_root = function()
		if player:Stance() == 1 --and pull_location()=="arena"
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee and not lowestmelee:immune("all || snare") and not lowestmelee:state("stun || root")
				and not lowestmelee:BuffAny("Bladestorm || Divine Shield || Die by the Sword || Hand of Protection || Hand of Freedom || Deterrence") then
				if lowestmelee:drState(116706) == 1 or lowestmelee:drState(116706) == -1 then
					return lowestmelee:Cast("Disable")
				end
			end
		end
	end,
	
	ringofpeace = function()
		if player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace") < cdcd then
			local peacetarget = Object("mostTargetedRosterPVP")
			if peacetarget then
				if peacetarget:SpellRange("Ring of Peace") and peacetarget:health() <= 85 and not peacetarget:BuffAny("Ring of Peace") then
					if (peacetarget:areaEnemies(6) >= 3) or (peacetarget:areaEnemies(6) >= 1 and peacetarget:health() < 75) then
						if peacetarget:los() then
							return peacetarget:Cast("Ring of Peace")
						end
					end
				end
			end
		end
	end,
	
	
	ringofpeacev2 = function()
		if player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace") < cdcd then
			local targets = {}
			local targetsall = {}
			local peacetarget = nil
			local most, mostGuid = 0
			local mostall, mostallGuid = 0
			
			-- Version 1: Only enemies targeting
			for _, enemy in pairs(_A.OM:Get('Enemy')) do
				if enemy.isplayer and not enemy:BuffAny("Bladestorm || Divine Shield || Deterrence") and _A.notimmune(enemy) and not enemy:state("Disarm")
					and not enemy:state("stun || incapacitate || fear || disorient || charm || misc || sleep")
					and not healerspecid[enemy:spec()] then
					local tguid = UnitTarget(enemy.guid)
					if tguid then
						local tobj = Object(tguid)
						if tobj and _A.nothealimmune(tobj) and tobj:Distancefrom(enemy) < 7 and _A.nothealimmune(tobj) then
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
			
			if mostGuid then
				peacetarget = Object(mostGuid)
				if peacetarget then
					if peacetarget:SpellRange("Ring of Peace") and not peacetarget:BuffAny("Ring of Peace") then
						if (most >= 2) or (most >= 1 and (peacetarget:health() < 45 or (_A.pull_location == "arena" and peacetarget:health() < 65))) then
							if peacetarget:los() then
								return peacetarget:Cast("Ring of Peace")
							end
						end
					end
				end
			end
			-- Version 2: All valid enemies in range
			for _, friend in pairs(_A.OM:Get('Friendly')) do
				if friend.isplayer and _A.nothealimmune(friend) then
					for _, enemy in pairs(_A.OM:Get('Enemy')) do
						if enemy.isplayer and friend:Distancefrom(enemy) < 7 and not enemy:BuffAny("Bladestorm || Divine Shield || Deterrence") and _A.notimmune(enemy)
							and not enemy:state("stun || incapacitate || fear || disorient || charm || misc || sleep")
							and not enemy:state("Disarm") then
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
			
			if mostallGuid then
				peacetarget = Object(mostallGuid)
				if peacetarget then
					if peacetarget:SpellRange("Ring of Peace") and not peacetarget:BuffAny("Ring of Peace") then
						if (mostall >= 3) then
							if peacetarget:los() then
								return peacetarget:Cast("Ring of Peace")
							end
						end
					end
				end
			end
			-- version 3: interrupt high prio casts
			for _, friend in pairs(_A.OM:Get('Friendly')) do
				if friend and friend.isplayer and _A.nothealimmune(friend) then
					for _, enemy in pairs(_A.OM:Get('Enemy')) do
						if enemy and enemy.isplayer and friend:Distancefrom(enemy) < 7 and kickcheck_highprio(enemy)
							and (player:SpellCooldown("Spear Hand Strike") > _A.interrupttreshhold or not enemy:caninterrupt() or not enemy:SpellRange("Blackout Kick"))
							and _A.notimmune(enemy) and friend:los() then
							return friend:Cast("Ring of Peace")
						end
					end
				end
			end
			--
			-- Version 4: Silence healers if someone is low
			-- if _A.pull_location and _A.pull_location=="arena" then
			if _A.someoneislow() then -- iterates through enemy players to find if a low hp enemy player exists
				for _, friend in pairs(_A.OM:Get('Friendly')) do
					if friend and friend.isplayer and _A.nothealimmune(friend) then
						for _, enemy in pairs(_A.OM:Get('Enemy')) do
							if enemy and enemy.isplayer and friend:Distancefrom(enemy) < 7 and healerspecid[enemy:spec()] and _A.notimmune(enemy) and not enemy:state("silence")
								and (enemy:drState(137460) == 1 or enemy:drState(137460) == -1)
								and not enemy:state("stun || incapacitate || fear || disorient || charm || misc || sleep || silence")
								and friend:los() then
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
			and player:SpellCooldown("Chi Wave") < cdcd then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then
					if lowest:SpellRange("Chi Wave")
						then
						return lowest:Cast("Chi Wave")
					end
				end
			end
		end
	end,
	
	manatea = function()
		if player:Stance() == 1 then
			if player:SpellCooldown("Mana Tea") < cdcd
				and player:Glyph("Glyph of Mana Tea")
				and player:mana() <= 92
				and player:BuffStack("Mana Tea") >= 2
				then
				return player:Cast("Mana Tea")
				-- _A.CastSpellByName("Mana Tea")
			end
		end
	end,
	
	manatea_HealthRegen = function()
		if player:Stance() == 1 and player:talent("Healing Elixirs") and player:buff("Healing Elixirs") then
			if player:SpellCooldown("Mana Tea") < cdcd
				and player:Glyph("Glyph of Mana Tea")
				and player:mana() <= 92
				and player:health() <= 85
				and player:BuffStack("Mana Tea") >= 2
				then
				local lowest = Object("lowestall")
				if lowest and lowest.guid == player.guid then
					return player:Cast("Mana Tea")
					-- _A.CastSpellByName("Mana Tea")
				end
			end
		end
	end,
	
	chibrew = function()
		if player:Stance() == 1 and not IsCurrentSpell(115399) then
			if player:Talent("Chi Brew")
				and player:SpellCooldown("Chi Brew") == 0
				and player:Chi() <= 2
				then
				player:Cast("Chi Brew")
			end
		end
	end,
	
	fortifyingbrew = function()
		if player:Stance() == 1 then
			if player:SpellCooldown("Fortifying Brew") == 0
				and not IsCurrentSpell(115203)
				and player:health() < 40
				then
				player:Cast("Fortifying Brew")
			end
		end
	end,
	
	thunderfocustea = function()
		if player:Stance() == 1 and player:Chi() >= 1 then
			if player:SpellCooldown("Thunder Focus Tea") == 0 and player:SpellUsable("Thunder Focus Tea") and not IsCurrentSpell(116680)
				and not player:state("incapacitate || fear || disorient || charm || misc || sleep || stun || silence") then
				if _A.thunderbrewremovedat == nil or (_A.thunderbrewremovedat and (GetTime() - _A.thunderbrewremovedat) >= 45)
					then
					return player:Cast("Thunder Focus Tea")
				end
			end
		end
	end,
	
	tigerslust = function()
		if player:Talent("Tiger's Lust") and player:SpellCooldown("Tiger's Lust") < cdcd then
			if player:Stance() == 1 then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr:SpellRange("Tiger's Lust") then
						if fr.isplayer then
							if _A.nothealimmune(fr) then
								if not fr:state("incapacitate || fear || disorient || charm || misc || sleep") and fr:State("root || snare") and fr:los()
									then
									if fr.guid ~= player.guid then
										return fr:Cast("Tiger's Lust")
										-- elseif
										-- _A.pull_location~=arena then
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
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" or (_A.pull_location == "arena" and fr:ispet()) then
						if fr:SpellRange("Detox")
							and not fr:DebuffAny("Unstable Affliction || Vampiric Touch")
							and fr:DebuffType("Magic || Poison || Disease") then
							if fr:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence") or _A.pull_location == "party" or _A.pull_location == "raid"
								-- annoying
								or fr:DebuffAny("Entangling Roots ||  Freezing Trap || Denounce || Flame Shock || Moonfire || Sunfire")
								then
								if _A.nothealimmune(fr) and fr:los() then
									temptabletbl2[#temptabletbl2 + 1] = {
										HP = fr:health(),
										obj = fr
									}
								end
							end
						end
					end
				end
				if #temptabletbl2 > 1 then
					table.sort(temptabletbl2, function(a, b) return (a.HP < b.HP) end)
				end
				return temptabletbl2[1] and temptabletbl2[1].obj:Cast("Detox")
			end
		end
	end,
	
	diffusemagic = function()
		if player:talent("Diffuse Magic") and player:SpellCooldown("Diffuse Magic") == 0 and not IsCurrentSpell(122783) then
			-- add the stuff that hurts
			if
				player:health() < 30 or player:DebuffAny("Moonfire || Sunfire || Unstable Affliction || Touch of Karma") or player:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence")
				then
				return player:cast("Diffuse Magic")
			end
		end
	end,
	
	dispellplzany = function()
		local temptabletbl1 = {}
		-- if player:Stance() == 1 and _A.pull_location ~="pvp"   then
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" then
						if fr:SpellRange("Detox") and fr:statepurge("Detox")
							and _A.nothealimmune(fr)
							and not fr:DebuffAny("Unstable Affliction") then
							-- and not fr:DebuffAny("Unstable Affliction || Vampiric Touch")  then
							if fr:los() then
								temptabletbl1[#temptabletbl1 + 1] = {
									count = fr:debuffCountType("Magic || Poison || Disease") or 0,
									obj = fr
								}
							end
						end
					end
				end
			end
			if #temptabletbl1 > 1 then
				table.sort(temptabletbl1, function(a, b) return (a.count > b.count) end)
			end
			return temptabletbl1[1] and temptabletbl1[1].count >= 1 and temptabletbl1[1].obj:Cast("Detox")
		end
	end,
	
	dispellself = function()
		if player:Stance() == 1 and _A.pull_location ~= "arena" then
			-- if player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") then
				if player:SpellRange("Detox") and player:statepurge("Detox")
					and _A.nothealimmune(player)
					and not player:DebuffAny("Unstable Affliction") then
					-- and not player:DebuffAny("Unstable Affliction || Vampiric Touch")  then
					return player:cast("Detox")
				end
			end
		end
	end,
	
	dispellunCC = function()
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") and not player:state("silence") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" then
						if fr:SpellRange("Detox")
							and fr:statepurgecheck("stun || sleep || charm || disorient || incapacitate || fear || silence || misc || root")
							-- and (not fr:DebuffAny("Unstable Affliction") or _A.pull_location=="arena")
							and not fr:DebuffAny("Unstable Affliction")
							and _A.nothealimmune(fr)
							and fr:los()
							then
							print("UNCCING")
							return fr:cast("Detox")
						end
					end
				end
			end
		end
	end,
	
	dispellunSLOW = function()
		if not player:lostcontrol() and player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" then
						if fr:SpellRange("Detox") and fr:statepurgecheck("snare")
							and _A.nothealimmune(fr)
							and not fr:DebuffAny("Unstable Affliction")
							-- and (not fr:debuffany("Unstable Affliction") or _A.pull_location=="arena")
							and fr:los() then
							print("UNSLOWING")
							return fr:cast("Detox")
						end
					end
				end
			end
		end
	end,
	
	dispellDANGEROUS = function()
		local temptabletbl1 = {}
		if not player:lostcontrol() and player:Stance() == 1 then
			if player:SpellCooldown("Detox") < cdcd and player:SpellUsable("Detox") then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer or string.lower(fr.name) == "ebon gargoyle" then
						if fr:SpellRange("Detox") and fr:statepurge("Detox")
							and (not fr:debuffany("Unstable Affliction") or _A.pull_location == "arena")
							then
							for _, v in ipairs(dangerousdebuffs) do
								if fr:DebuffAny(v) and _A.nothealimmune(fr) and fr:los() then
									print("REMOVING DANGEROUS")
									return fr:cast("Detox")
								end
							end
						end
					end
				end
			end
		end
	end,
	
	lifecocoon = function()
		if player:SpellCooldown("Life Cocoon") < cdcd and player:SpellUsable(116849) then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:SpellRange("Life Cocoon") and lowest:combat() then
					--]]
					if
						-- (lowest:health()<40 or (pull_location()=="pvp" and lowest:health()<40))
						lowest:health() < 30
						then
						return lowest:Cast("Life Cocoon")
					end
				end
			end
		end
	end,
	
	surgingmist = function()
		if player:BuffStack("Vital Mists") >= 5
			and player:Chi() < player:ChiMax() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:SpellRange("Surging Mist") then
					--]]
					
					if
						lowest:health() <= 85
						
						then
						return lowest:Cast("Surging Mist")
					end
				end
			end
		end
	end,
	
	renewingmist = function()
		if player:SpellCooldown("Renewing Mist") < cdcd and player:SpellUsable(115151) then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:SpellRange("Renewing Mist") then
					return lowest:Cast("Renewing Mist")
				end
			end
		end
	end,
	
	healstatue = function()
		if not player:combat() then
			return
		end
		if player:Stance() == 1 then
			local statueInRange = function()
				for _, obj in pairs(_A.OM:Get('Friendly')) do
					if obj.id == 60849 and _A.ObjectCreator(obj.guid) == player.guid then
						return obj:Distance() <= 20
					end
				end
				return false
			end
			if player:SpellCooldown("Summon Jade Serpent Statue") < cdcd and player:SpellUsable(115313) and not IsSwimming() and not statueInRange()
				then
				return _A.clickcast(player, "Summon Jade Serpent Statue")
			end
		end
	end,
	
	healingsphere_keybind = function()
		local target
		if player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if player:SpellUsable(115460) then
					if _A.pull_location == "pvp"
						then
						target = Object("player")
						elseif _A.pull_location == "arena"
						then
						target = Object("lowestall")
						else
						target = Object("target")
					end
					if target then
						if target:Distance() < 40 then
							if target:los() then
								return _A.clickcast(target, "Healing Sphere")
							end
						end
					end
				end
			end
		end
	end,
	
	healingsphere = function()
		if player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if player:SpellUsable(115460) then
					if _A.modifier_shift() or _A.manaengine() or _A.manaengine_highprio() then
						--- ORBS
						local lowest = Object("lowestall")
						if lowest then
							if (lowest:health() < 85) then
								return _A.clickcast(lowest, "Healing Sphere")
							end
						end
					end
				end
			end
		end
	end,
	
	healingsphere_nocombat = function()
		if player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if player:SpellUsable(115460) then
					--- ORBS
					if _A.modifier_shift() or _A.manaengine() or _A.manaengine_highprio() then
						local lowest = Object("lowestall")
						if lowest then
							if (lowest:health() < 92) then
								return _A.clickcast(lowest, "Healing Sphere")
							end
						end
					end
				end
			end
		end
	end,
	
	healingsphere_superlow = function()
		if player:SpellUsable("Healing Sphere") then
			if player:Stance() == 1 then
				if player:SpellUsable(115460) then
					local lowest = Object("lowestall")
					if lowest and lowest:health() < 22 then
						-- return _A.CastPredictedPos(lowest.guid, "Healing Sphere", 88)
						return _A.clickcast(lowest, "Healing Sphere")
					end
				end
			end
		end
	end,
	
	blackout_mm = function()
		if player:Stance() == 1 then
			if player:Chi() >= 2 then
				if player:Buff("Muscle Memory") then
					----------------------------------
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						----------------------------------
						return lowestmelee:Cast("Blackout Kick")
					end
				end
				--------------------------------- damage based
			end
		end
	end,
	
	tigerpalm_mm = function()
		if player:Stance() == 1 then
			if player:Chi() >= 1 then
				if player:Buff("Muscle Memory") then
					----------------------------------
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						----------------------------------
						return lowestmelee:Cast("Tiger Palm")
					end
				end
				--------------------------------- damage based
			end
		end
	end,
	
	bk_buff = function()
		if player:Stance() == 1 then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory")
				if player:Chi() >= 2
					and not player:Buff("Serpent's Zeal") -- and player:Buff("Muscle Memory")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						return lowestmelee:Cast("Blackout Kick")
					end
				end
			end
		end
	end,
	
	tp_buff = function()
		if player:Stance() == 1 then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory")
				if player:Chi() >= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						return lowestmelee:Cast("Tiger Palm")
					end
				end
			end
		end
	end,
	
	tp_buff_keybind = function()
		if player:Stance() == 1 then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory")
				if player:Chi() >= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						return lowestmelee:Cast("Tiger Palm", true)
					end
				end
			end
		end
	end,
	
	uplift = function()
		if player:Stance() == 1 then
			if player:SpellUsable("Uplift")
				and player:Chi() >= 2
				then
				return player:Cast("Uplift")
			end
		end
	end,
	
	expelharm = function()
		if player:Stance() == 1 then
			if player:Chi() < player:ChiMax()
				and player:SpellCooldown("Expel Harm") < cdcd
				and player:SpellUsable(115072)
				then
				return player:Cast("Expel Harm")
			end
		end
	end,
	
	tigerpalm_filler = function()
		if player:Stance() == 1 then
			if player:Chi() == 1 then
				if player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						return lowestmelee:Cast("Tiger Palm")
					end
				end
			end
		end
	end,
	
	blackout_keybind = function()
		if player:Stance() == 1 then
			if player:Chi() >= 2 then
				-- if player:Buff("Muscle Memory") then
				----------------------------------
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					----------------------------------
					return lowestmelee:Cast("Blackout Kick", true)
				end
			end
			--------------------------------- damage based
		end
	end,
	
	jab_filler = function()
		if player:Stance() == 1 then
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
		if player:Stance() ~= 1 and not player:buff("Rushing Jade Wind") then
			if not player:Buff("Muscle Memory")
				or (player:chi() <= 1 and not player:talent("Rushing Jade Wind"))
				then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					return lowestmelee:Cast("Jab")
				end
			end
		end
	end,
	
	spin_rjw = function()
		if (player:Stance() == 1)
			and player:buffany("Lucidity") then
			if player:Talent("Rushing Jade Wind")
				and player:SpellCooldown("Rushing Jade Wind") < cdcd
				then
				return player:Cast("Rushing Jade Wind")
			end
		end
		-- add friendly finder on top
	end,
	
	
	jab_keybind_buff = function()
		if player:Stance() == 1 and player:mana() >= 9
			-- and (not player:buff("Muscle Memory"))  -- former logic
			and player:chi() == 1
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee then
				return lowestmelee:Cast("Jab", true)
			end
		end
	end,
	
	lightning_keybind = function()
		if player:Stance() == 1 and (player:Keybind("R") or player:ui("leveling")) and player:mana() >= 9 and not player:moving() then
			if not player:isChanneling("Crackling Jade Lightning") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if not lowestmelee then
					local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
					if lowestmelee then
						return lowestmelee:Cast("Crackling Jade Lightning")
					end
				end
			end
			else
			if player:isChanneling("Crackling Jade Lightning") then _A.CallWowApi("SpellStopCasting") end
		end
	end,
	
	autotarget = function()
		if _A.UnitExists("pet") then
			local _target = Object("target")
			local lowestmelee = Object("lowestEnemyInSpellRangeMINIMAL(Crackling Jade Lightning)")
			if lowestmelee then
				if _target and _target.guid ~= lowestmelee.guid then _A.CallWowApi("TargetUnit", lowestmelee.guid) end
				if not _target then _A.CallWowApi("TargetUnit", lowestmelee.guid) end
			end
		end
	end,
	
	detargetcc = function()
		local _target = Object("target")
		if _A.pull_location == "arena" and _target and _target:enemy() and (_target:range() < 10 or _A.UnitExists("pet")) and _A.dontbreakcc(_target) == false then
			_A.CallWowApi("ClearTarget")
		end
	end,
	
	autofocus = function()
		if _A.UnitExists("pet") then
			local _focus = Object("focus")
			local lowestmelee = Object("lowestEnemyInSpellRangeMINIMAL(Crackling Jade Lightning)")
			if lowestmelee then
				if not _focus then _A.CallWowApi("FocusUnit", lowestmelee.guid) end
				if _focus and _focus.guid ~= lowestmelee.guid then _A.CallWowApi("FocusUnit", lowestmelee.guid) end
				if _focus then _A.CallWowApi("RunMacroText", "/petattack focus") end
				else
				_A.CallWowApi("RunMacroText", "/petfollow")
			end
			elseif _focus then
			_A.CallWowApi("ClearFocus")
		end
	end,
	dpsstance_spin = function()
		if player:Stance() ~= 1 and (player:keybind("R") or _A.pull_location ~= "pvp" or player:ui("leveling")) then
			if player:Talent("Rushing Jade Wind")
				and player:SpellCooldown("Rushing Jade Wind") < cdcd
				then
				return player:Cast("Rushing Jade Wind")
			end
		end
	end,
	dpsstance_spin_musclememory = function()
		if player:Stance() ~= 1 and player:Talent("Rushing Jade Wind") and not player:buff("Muscle Memory")
			and player:SpellCooldown("Rushing Jade Wind") < cdcd
			and (_Y.rushing_number() >= 3) then
			return player:Cast("Rushing Jade Wind")
		end
	end,
	dpsstance_healstance = function()
		if player:Stance() ~= 1 then
			if player:SpellCooldown("Stance of the Wise Serpent") < cdcd
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	dpsstance_healstance_special = function()
		if player:Stance() ~= 1 then
			if player:SpellCooldown("Stance of the Wise Serpent") < cdcd
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	dpsstance_healstance_keybind = function()
		-- if player:Stance() ~= 1 and (_A.modifier_shift() or _A.manaengine_highprio() or player:buff("Rushing Jade Wind")) and (player:manaraw()>=17550 or player:buff("Rushing Jade Wind")) then
		if player:Stance() ~= 1 and (_A.modifier_shift() or player:buff("Rushing Jade Wind")) and (player:manaraw() >= 17550 or player:buff("Rushing Jade Wind")) then
			if player:SpellCooldown("Stance of the Wise Serpent") < cdcd
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	
	dpsstanceswap = function()
		if player:Stance() ~= 2 then
			if player:SpellCooldown("Stance of the Fierce Tiger") < cdcd
				and not player:Buff("Rushing Jade Wind")
				and not player:Buff("lucidity")
				then
				if player:Talent("Rushing Jade Wind") and (player:keybind("R") or _A.pull_location ~= "pvp" or _Y.rushing_number() >= 3 or player:ui("leveling")) then
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
	if not enteredworldat then return true end
	if enteredworldat and ((GetTime() - enteredworldat) < (3)) then return end
	if not _A.pull_location then return true end
	player = player or Object("player")
	if not player then return true end
	local mylevel = player:level()
	cdcd = _A.Parser.frequency and _A.Parser.frequency * 3 or .3
	-- print(player:combat())
	-- print(GetManaRegen())
	if not player:alive() then return true end
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats())) / 100)) / 10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	if player:mounted() then return true end
	if player:isChanneling("Crackling Jade Lightning") then return true end -- ¨pausing when casting this
	-- Out of GCD
	mw_rot.autoattackmanager()
	_Y.petengine_MONK()
	if player:combat() then mw_rot.thunderfocustea() end
	mw_rot.kick_spear()
	mw_rot.activetrinket()
	mw_rot.diffusemagic()
	mw_rot.everyman()
	mw_rot.nimble()
	if player:combat() then mw_rot.chibrew() end
	_Y.cancelbuff(16593)
	mw_rot.items_healthstone()
	mw_rot.fortifyingbrew()
	mw_rot.cancel_badnoggen()
	mw_rot.items_noggenfogger()
	mw_rot.items_intflask()
	if _A.buttondelayfunc() then return true end -- pausing for manual casts
	------------------------------------------------ Rotation Proper
	------------------ High Prio
	-- KEYBINDS
	--if mylevel >= 64 and player:keybind("E") and mw_rot.healingsphere_keybind() then return true end -- SUPER PRIO
	if player:keybind("R") or player:ui("leveling") then
		if mylevel >= 56 and mw_rot.manatea() then return true end
		if mylevel >= 28 and mw_rot.pvp_disable_target() then return true end
		if mylevel >= 3 and mw_rot.tp_buff_keybind() then return true end
		if mylevel >= 7 and mw_rot.blackout_keybind() then return true end
		if mw_rot.dpsstanceswap() then return true end
	end
	if mylevel >= 28 and player:keybind("X") and mw_rot.pvp_disable_keybind() then return true end
	if mylevel >= 34 and mw_rot.ctrl_mode() then return true end -- ctrl
	-- healing spheres don't get you in combat lol (increased mana regen)
	if not player:combat() and (_A.pull_location =="pvp" or _A.pull_location =="arena") then
		if mw_rot.dpsstance_healstance() then return true end
		if mylevel >= 64 and mw_rot.healingsphere_nocombat() then return true end
		return true
	end
	--
	-- GCD CDS
	if mylevel >= 50 and mw_rot.lifecocoon() then return true end
	if mylevel >= 68 and mw_rot.burstdisarm() then
		print("DISARMING")
		return true
	end
	-- OH SHIT ORBS
	if mylevel >= 64 and _A.modifier_shift() and mw_rot.healingsphere() then return true end
	--------------------- dispells and root freedom
	if mylevel >= 20 then
		if mw_rot.dispellunCC() then return true end
		if mw_rot.dispellDANGEROUS() then return true end
		-- if mw_rot.dispellunSLOW() then return end
	end
	if mw_rot.tigerslust() then return true end
	--------------------- high prio
	if mylevel >= 3 and mw_rot.tigerpalm_mm() then return true end
	if mylevel >= 34 and mw_rot.surgingmist() then return true end
	if mylevel >= 42 and mw_rot.renewingmist() then return true end -- KEEP THESE OFF CD
	if mylevel >= 62 and mw_rot.uplift() then return true end    -- really important
	-- OH SHIT ORBS
	if _A.manaengine_highprio() then                             -- HIGH PRIO
		-- print("HIGH PRIO")
		if mylevel >= 64 and mw_rot.healingsphere() then return true end
	end
	if mw_rot.chi_wave() then return true end -- KEEP THESE OFF CD
	if mw_rot.Xuen() then return true end
	--------------------- CC
	if mw_rot.ringofpeacev2() then return true end
	if mw_rot.kick_legsweep() then return true end
	if mw_rot.stun_legsweep() then return true end
	if mylevel >= 44 then
		if mw_rot.kick_paralysis() then return true end
		if mw_rot.sapsnipe() then return true end
		if mw_rot.sapsextendcc() then return true end
	end
	------------------ Rotation Proper
	if mylevel >= 56 and mw_rot.manatea() then return true end
	if mylevel >= 64 and mw_rot.healingsphere() then return true end
	if mw_rot.spin_rjw() then return true end
	if mylevel >= 70 and mw_rot.healstatue() then return true end
	if mylevel >= 26 and mw_rot.expelharm() then return true end
	------------------ STANCE SWAP FILL
	if not (player:keybind("R") or player:ui("leveling")) and mw_rot.dpsstance_healstance_keybind() then return true end -- holding shift or high prio check
	if mw_rot.dpsstance_spin_musclememory() then return true end
	if mw_rot.dpsstance_jab() then return true end
	if mw_rot.dpsstance_spin() then return true end
	if mw_rot.dpsstance_healstance() then return true end
	if not _A.modifier_shift() and mw_rot.dpsstanceswap() then return true end
end
local spellIds_Loc = function()
end
local blacklist = function()
end

-- alert when out of statue range
local statueAlertShown = false -- Track alert state

local function alertStatueRange()
	player = player or Object("player")
	if not player then return true end
	if player:spec()~=270 then return true end
	if not player:ui("draw_statue_range") then return true end
	for _, statue in pairs(_A.OM:Get('Friendly')) do
		if statue.id == 60849 and _A.ObjectCreator(statue.guid) == player.guid then
			if statue:distance() > 20 then
				if not statueAlertShown then -- Only show if we haven't shown it yet
					_A.ui:alert({
						text = " Statue out of range",
						icon = 115313,
						size = 25
					})
					statueAlertShown = true -- Mark as shown
				end
			else
				statueAlertShown = false -- Reset when back in range
			end
			break
		end
	end
end

C_Timer.NewTicker(.1, alertStatueRange, false, "alertStatueRange")

_A.CR:Add(270, {
	name = "Monk Heal EFFICIENT",
	ic = inCombat,
	ooc = inCombat,
	use_lua_engine = true,
	gui = GUI,
	gui_st = { title = "CR Settings", color = "87CEFA", width = "315", height = "370" },
	wow_ver = "5.4.8",
	apep_ver = "1.1",
	-- ids = spellIds_Loc,
	-- blacklist = blacklist,
	-- pooling = false,
	load = exeOnLoad,
	unload = exeOnUnload
})
