local _,class = UnitClass("player")
if class~="HUNTER" then return end
local mediaPath, _A, _Y = ...
-- local _, class = UnitClass("player");
-- if class ~= "WARRIOR" then return end;
local DSL = function(api) return _A.DSL:Get(api) end
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local spell_name = function(idd) return _A.Core:GetSpellName(idd) end
local spell_ID = function(idd) return _A.Core:GetSpellID(idd) end
local hooksecurefunc =_A.hooksecurefunc
local Listener = _A.Listener
local function table_sortoptimized(arr, comp, k)
    local n = #arr
	local best_idx = nil
    local best_val = nil
	local current_val = nil
    k = k or 1  -- Default to find top 1 element
    if k > 5 or k >= n then
        table.sort(arr, comp)
        return
	end
	
    for i = 1, k do
        best_idx = i
        best_val = arr[i]
        
        -- Single pass with cached values and reduced table accesses
        for j = i + 1, n do
            current_val = arr[j]
            if comp(current_val, best_val) then
                best_idx, best_val = j, current_val  -- Update in one step
			end
		end
		
        if best_idx ~= i then
            arr[i], arr[best_idx] = best_val, arr[i]
		end
	end
end
local cdcd = .3
-- top of the CR
local player
local enemytreshhold = 6
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
	-- HEALERS
	[105]="Druid Resto",
	[270]="monk mistweaver",
	[65]="Paladin Holy",
	[257]="Priest Holy",
	[256]="Priest discipline",
	[264]="Sham Resto",
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

local cobraid = spell_ID("Cobra Shot")
local steadyid = spell_ID("Steady Shot") 
local ESid = spell_ID("Explosive Shot") 
local gtID = spell_ID("Glaive Toss") 
local baID = spell_ID("Black Arrow") 
local amocID = spell_ID("A Murder of Crows") 
local GUI = {
}
local scatter_x
local scatter_y
local scatter_z
local exeOnLoad = function()
	_A.Interface:AddToggle({
		key = "WyvernEnable", 
		name = "Wyern Setup", 
		text = "ON = Wyvern Sting into trap (need talent) | OFF = Scatter into trap",
		icon = "Interface\\Icons\\INV_SPEAR_02",
	})
	_A.Interface:AddToggle({
		key = "TrapEnable", 
		name = "Enable Freezing Trap", 
		text = "ON = Scatter/freeze/sleep | OFF = Ice (good for bgs)",
		icon = select(3,GetSpellInfo("Freezing Trap")),
	})
	_A.Interface:AddToggle({
		key = "pet_attacktotem", 
		name = "Enable Pet Attacking Totem", 
		text = "ON = Pet attacks totem if in range | OFF = Pet doesnt (unless in arena where it always does)",
		icon = select(3,GetSpellInfo("Scare Beast")),
	})
	_A.Interface:AddToggle({
		key = "enable_tranq", 
		name = "Enable Auto Tranq Shotting", 
		text = "ON = Purges magic effects | OFF = Do not purge automatically",
		icon = select(3,GetSpellInfo("Tranquilizing Shot")),
	})
	_A.Interface:ShowToggle("cooldowns", false)
	_A.Interface:ShowToggle("interrupts", false)
	_A.Interface:ShowToggle("aoe", false)
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
	local oldfacing
	_A.casttimers = {}
	_A.scattertargets = {}
	_Y.needtocorrectfacing = false
	-- _A.Listener:Add("nofacev2", "UNIT_SPELLCAST_SENT", function(event, unit, spell, _, tname)
	-- if unit == "player" then
	-- if event == "UNIT_SPELLCAST_SENT" then
	-- local target = Object("target")
	-- player = player or Object("player")
	-- if not target:InConeOf("player", 170) and player:SpellCooldown(spell)<.15 then 
	-- if _Y.needtocorrectfacing == false then 
	-- oldfacing = _A.ObjectFacing("player")  
	-- _Y.needtocorrectfacing = true
	-- end
	-- _A.FaceDirection(target.guid, false) 
	-- _A.ClickToMove(_A.ObjectPosition("player"))
	-- end
	-- end
	-- end
	-- end)
	_A.Listener:Add("delaycasts_HUNT_SURV", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		if guidsrc == UnitGUID("player") then
			-- if spell_name(idd) == spell_name(53301) then
			-- if subevent == "SPELL_CAST_SUCCESS" then
			-- _A.FaceDirection(oldfacing, false) 
			-- _A.ClickToMove(_A.ObjectPosition("player"))
			-- _Y.needtocorrectfacing = false
			-- end
			-- end
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[spell_name(idd)] = _A.GetTime()
				if idd == 19503 or idd==19386 then -- add wyvern sting
					if not _A.scattertargets[guiddest] then _A.scattertargets[guiddest]= true end
					C_Timer.After(2, function()
						if _A.scattertargets[guiddest] then
							_A.scattertargets[guiddest]=nil
						end
					end)
				end
			end
			if subevent == "SPELL_AURA_APPLIED" then -- doesnt work with channeled spells
				_A.casttimers[spell_name(idd)] = _A.GetTime()
				if spell_name(idd) == spell_name(19503) then
					scatter_x, scatter_y, scatter_z = _A.ObjectPosition(guiddest)
					C_Timer.After(10, function()
						if scatter_x then
							scatter_x = nil
							scatter_y = nil
							scatter_z = nil
						end
					end)
				end
				if spell_name(idd) == spell_name(19503) or spell_name(idd)==spell_name(19386) then
					if _A.scattertargets[guiddest] then
						_A.scattertargets[guiddest]=nil
					end
				end
			end
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				if spell_name(idd) == spell_name(60192) then
					scatter_x = nil
					scatter_y = nil
					scatter_z = nil
				end
			end
		end
	end)
	function _A.castdelay(idd, delay)
		local spellid = idd and spell_name(idd)
		if delay == nil then return true end
		if _A.casttimers[spellid]==nil then return true end
		return (_A.GetTime() - _A.casttimers[spellid])>=delay
	end
	function _A.castdelaytarget(idd, delay)
		local spellid = idd and spell_name(idd)
		if delay == nil then return true end
		if _A.casttimers[spellid]==nil then return true end
		return (_A.GetTime() - _A.casttimers[spellid])>=delay
	end
	function _A.castwhen(idd)
		local spellid = idd and spell_name(idd)
		if _A.casttimers[spellid]==nil then return 9999 end
		return (_A.GetTime() - _A.casttimers[spellid])
	end
	--
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		if slot then
			Type, id, subType = _A.GetActionInfo(slot)
			if id == 77767 then
				print("HEY")
				player = player or Object("player")
				local target = Object("target")
				if player:SpellCooldown(77767)<.3 then
					return target:cast(77767)
				end
			end
		end
		-- print(slot)
		player = Object("player")
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
			if unit:immuneYOUCEF("all") then return false end
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
		local tGUID = target and target.guid or " "
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and _A.notimmune(Obj) 
				and not Obj:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					target = (Obj.guid==tGUID) and 1 or 0,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table_sortoptimized(tempTable, function(a,b)
				if a.target ~= b.target then return a.target > b.target
					elseif a.isplayer ~= b.isplayer then return a.isplayer > b.isplayer
					else return a.health < b.health
				end
			end, 1)
		end
		if #tempTable>=1 then
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
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:exists() and target:alive()
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") then
			return target and target.guid -- this is good
		end
		local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
		if lowestmelee then
			return lowestmelee.guid
		end
		return nil
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKCNOLOSfocus', function(num)
		local tempTable = {}
		local target = Object("target")
		local pet = Object("pet")
		if not pet then return end
		if pet and not pet:alive() then return end
		if pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
		--
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:exists() and target:alive() 
			-- and _A.notimmune(target)
			-- and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") 
			then
			return target and target.guid -- this is good
		end
	end)
	
	_A.FakeUnits:Add('enemyplayercc', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			-- if Obj.isplayer and Obj:spellRange("Arcane Shot") and Obj:stateYOUCEF("incapacitate || disorient || charm || misc || sleep || stun") and _A.notimmune(Obj) and Obj:los() then
			if Obj.isplayer and Obj:spellRange("Arcane Shot") and _A.notimmune(Obj) 
				and Obj:stateduration("stun || root")>=1 and not Obj:moving() and Obj:los() then
				tempTable[#tempTable+1] = {
					range = Obj:range(),
					guid = Obj.guid,
					health = Obj:health(),
				}
			end
		end
		if #tempTable>1 then
			table_sortoptimized( tempTable, function(a,b) return (a.range < b.range) end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('meleeunitstobindshot', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj.isplayer and Obj:spellRange("Arcane Shot") and (meleespecs[Obj:spec()] or Obj:BuffAny("Horde Flag") or Obj:BuffAny("Alliance Flag")) and _A.notimmune(Obj) and not Obj:immuneYOUCEF("stun") and Obj:los() then
				tempTable[#tempTable+1] = {
					range = Obj:range(),
					guid = Obj.guid,
					health = Obj:health(),
				}
			end
		end
		if #tempTable>1 then
			table_sortoptimized( tempTable, function(a,b) return (a.range < b.range) end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	
	_A.FakeUnits:Add('simpletarget', function(num, spell)
		local target = Object("target")
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
		end
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and Obj:combat() and _A.notimmune(Obj)  
				and not Obj:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table_sortoptimized( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		local target = Object("target")
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)  
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
			return target and target.guid
		end
	end)
	
	_A.FakeUnits:Add('highestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and not _A.scattertargets[Obj.guid] and  Obj:InConeOf(player, 170) and Obj:combat() and _A.notimmune(Obj)  
				and not Obj:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:HealthActual(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table_sortoptimized( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health > b.health) end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		local target = Object("target")
		if target and not _A.scattertargets[target.guid] and target:enemy() and target:alive() and target:spellRange(spell) and target:InConeOf(player, 170) and  _A.notimmune(target)
			and not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and target:los() then
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
		local ID_CORE = spell_ID(ID)
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
			{ name = "Explosive Shot", ready = true },
			{ name = "Glaive Toss", ready = player:talent("Glaive Toss") },
			{ name = "Black Arrow", ready = _A.IsSpellKnown(3674) },
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table_sortoptimized(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end, 1)
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
		
		if spells[4].ready then
			cooldown = player:SpellCooldown(spells[4].name)
			focus_cost = required_focus(spells[4].name, time_elapsed)
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
			{ name = "Explosive Shot", ready = true },
			{ name = "Black Arrow", ready = _A.IsSpellKnown(3674) },
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		-- Sort spells by cooldown (shortest first)
		if #spells>1 then
			table_sortoptimized(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end, 1)
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
	-------------------------------------------
	-------------------------------------------
	-------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	_A.EScheck = function()
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		if player:buff("Lock and Load") then return true end
		
		-- Define abilities with cooldowns and conditions
		local spells = {
			{ name = "Black Arrow", ready = _A.IsSpellKnown(3674) },
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		
		-- Sort spells by cooldown (shortest first)
		table_sortoptimized(spells, function(a, b)
			return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
		end, 1)
		
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost("Explosive Shot")
		
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
	------------------------------------------------------------------
	------------------------------------------------------------------
	------------------------------------------------------------------
	_A.BAcheck = function()
		-- Avoid focus capping
		-- if player:focus() >= (player:FocusMax() - 5) then return true end
		-- Check if spell exists
		if not _A.IsSpellKnown(3674) then return false end
		
		-- Define abilities with cooldowns and conditions
		local spells = {
			{ name = "A Murder of Crows", ready = player:talent("A Murder of Crows") }
		}
		
		-- Sort spells by cooldown (shortest first)
		table_sortoptimized(spells, function(a, b)
			return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
		end, 1)
		
		
		-- Track elapsed time and current focus
		local time_elapsed = 0
		local current_focus = player:focus() - player:spellcost("Black Arrow")
		
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
			table_sortoptimized(spells, function(a, b)
				return player:SpellCooldown(a.name) < player:SpellCooldown(b.name)
			end, 1)
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
			if player:focus()+((player:spellcooldown("Explosive Shot"))*manaregen())<player:spellcost("Explosive Shot") then return true end
			return ct<=player:spellcooldown("Explosive Shot")
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
	--]]
	
	local floor, abs, min = math.floor, math.abs, math.min
	
	function _Y.mostclumpedenemy(Range, Radius)
		local radius = Radius and (Radius + 1.5) or 10
		local range = Range or 40
		local most, mostGuid = 0, nil
		local radiusSq = radius * radius
		
		-- Phase 1: Pre-filter with fail-fast conditions
		local enemies, x, y, count = {}, {}, {}, {}
		local n = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if not _A.scattertargets[Obj.guid]        -- Common failure case first
				and Obj:range() < range 
				and Obj:InConeOf(player, 170) 
				and _A.notimmune(Obj) 
				and Obj:los() then
				n = n + 1
				enemies[n] = Obj
				x[n], y[n] = _A.ObjectPosition(Obj.guid)
				count[n] = 1
			end
		end
		
		-- Phase 2: Spatial grid using precalculated cell keys
		local grid, cell_size = {}, radius * 1.05  -- 5% larger to reduce edge cases
		local r_reciprocal = 1 / cell_size
		for i = 1, n do
			local cx = floor(x[i] * r_reciprocal)
			local cy = floor(y[i] * r_reciprocal)
			local key = cx * 131 + cy  -- Fast hash for grid cells
			grid[key] = grid[key] or {}
			grid[key][#grid[key]+1] = i
		end
		
		-- Phase 3: Optimized neighbor checks with branch ordering
		for i = 1, n do
			local xi, yi = x[i], y[i]
			local cx = floor(xi * r_reciprocal)
			local cy = floor(yi * r_reciprocal)
			
			-- Check 3x3 grid cells with spatial coherence
			for dx = -1, 1 do
				local cell_key = (cx + dx) * 131
				for dy = -1, 1 do
					local cell = grid[cell_key + (cy + dy)]
					if cell then
						for j = 1, #cell do
							local other = cell[j]
							if other > i then  -- Avoid duplicate pairs
								local dx_val = x[other] - xi
								if abs(dx_val) <= radius then
									local dy_val = y[other] - yi
									if abs(dy_val) <= radius then
										local dist_sq = dx_val*dx_val + dy_val*dy_val
										if dist_sq <= radiusSq then
											count[i] = count[i] + 1
											count[other] = count[other] + 1
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		-- Phase 4: Cache-line optimized max search
		local max_count, max_index = 0, 0
		for i = 1, n do
			if count[i] > max_count then
				max_count, max_index = count[i], i
			end
		end
		
		return max_count, enemies[max_index] and enemies[max_index].guid
	end
	-------------------------------------------------------
	-------------------------------------------------------
	-------------------------------------------------------
	-- _A.Listener:Add("steadycasting", "UNIT_SPELLCAST_SUCCEEDED", function(event, ...)
	
	-- local unit, spellID = ...
	-- if unit == "player" and spellID == "Auto Shot" then -- Auto Shot spell ID
	-- print(unit, spellID, GetTime())
	-- end
	-- end)
	
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
			table_sortoptimized( tempTable, function(a,b) return a.range < b.range end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
	end)
	_A.FakeUnits:Add('HealingStreamTotemNOLOS', function(num)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			for _,totems in ipairs(badtotems) do
				if Obj.name==totems 
					and (Obj:range()<=40 or _A.pull_location=="arena")
					then
					tempTable[#tempTable+1] = {
						guid = Obj.guid,
						range = Obj:range(),
					}
				end
			end
		end
		if #tempTable>1 then
			table_sortoptimized( tempTable, function(a,b) return a.range < b.range end, 1 )
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
			table_sortoptimized( tempTable, function(a,b) return a.range < b.range end, 1 )
		end
		if #tempTable>=1 then
			return tempTable[num] and tempTable[num].guid
		end
		return nil
	end)
	_A.PetGUID  = nil
	local function attacktotem()
		local htotem = Object("HealingStreamTotemNOLOS")
		local pettargetguid = _A.UnitTarget("pet") or nil
		if htotem and (_A.pull_location=="arena" or (toggle("pet_attacktotem") and htotem:range()<=60)) then
			if _A.PetGUID and (not pettargetguid or pettargetguid~=htotem.guid) then
				_A.PetAttack(htotem.guid)
				return true
			end
			return true
		end
		return false
	end
	
	local function attacklowest()
		local target = Object("lowestEnemyInSpellRangePetPOVKCNOLOS")
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
	local function petfollow() -- when pet target has a breakable cc
		if _A.UnitTarget("pet")~=nil then
			local target = Object(_A.UnitTarget("pet"))
			if target and target:alive() and target:enemy() and target:exists() and target:stateYOUCEF("incapacitate || disorient || charm || misc || sleep ||fear") then
				_A.CallWowApi("RunMacroText", "/petfollow")
				return true
			end
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
	function _Y.petengine_Surv() -- REQUIRES RELOAD WHEN SWITCHING SPECS
		if not _A.Cache.Utils.PlayerInGame then return end
		if not player then return true end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then return true end
		-- if player:mounted() then return end
		-- if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return end
		if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") or not _A.HasPetUI() then if _A.PetGUID then _A.PetGUID = nil end return true end
		_A.PetGUID = _A.PetGUID or _A.UnitGUID("pet")
		if _A.PetGUID == nil then return true end
		-- Pet Rotation
		if petpassive() then return true end
		if attacktotem() then return true end
		if attacklowest() then return true end
		if petfollow() then return true end
	end
	-- C_Timer.NewTicker(.1, _Y.petengine_Surv, false, "petengineengineSurvival")
end
local exeOnUnload = function()
	Listener:Remove("steadycasting")
	Listener:Remove("delaycasts_HUNT_SURV")
	Listener:Remove("warrior_stuff")
end

local dontdispell = {
	-- shaman irrelevent
	["Clearcasting"] = true,
	["Backdraft"] = true,
	-- Buffs (not worth it)
	["Legacy of the Emperor"] = true,
	["Legacy of the White Tiger"] = true,
	["Arcane Brilliance"] = true,
	["Mark of the Wild"] = true,
	["Blessing of Kings"] = true,
	["Blessing of Might"] = true,
	["Power Word: Fortitude"] = true,
	["Searing Flame"] = true,
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
local function purgenum(target)
	local purge_number = 0
    for i = 1, 40 do
        local name,_,_,_,atype = _A.UnitBuff(target, i)
        if not name then
            break -- No more buffs
		end
        if name and atype and (atype == "Magic" or atype == "Enrage") then
            purge_number = purge_number + 1
		end
	end
    return purge_number
end

survival.rot = {
	-- flasks
	items_agiflask = function()
		if player:ItemCooldown(76084) == 0  
			and player:ItemCount(76084) > 0
			and player:ItemUsable(76084)
			and not IsCurrentItem(76084)
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
				and not IsCurrentItem(5512)
				and player:ItemUsable(5512) then
				return player:useitem("Healthstone")
			end
		end
	end,
	
	items_noggenfogger = function()
		if player:ItemCooldown(8529) == 0  
			and player:ItemCount(8529) > 0
			and player:ItemUsable(8529)
			and not IsCurrentItem(8529)
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
	feigninterrupt = function()
		if player:SpellCooldown("Feign Death")==0 and not player:moving() and not IsCurrentSpell(5384) then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer 
					and Obj:range()<=50
					and Obj:IscastingOnMe()
					then return player:cast("Feign Death")
				end
			end
		end
	end,
	disengage_freemovement = function()
		if player:talent("Posthaste") and player:SpellCooldown("Disengage")==0 and player:stateYOUCEF("root || snare") 
			and not player:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then
			-- cancel cast
			if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  
				else return player:cast("Disengage")
			end
		end
	end,
	masterscall = function()
		if player:SpellCooldown("Master's Call")==0 and not player:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then 
			if player:stateYOUCEF("root") then
				if (player:talent("Posthaste") and player:SpellCooldown("Disengage")>0) or (not player:talent("Posthaste"))  then
					local pet = Object("pet")
					if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:range()<40 and pet:los() then
						-- cancel cast
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  
							else return player:cast("Master's Call")
						end
					end
				end
			end
		end
	end,
	masterscall_party1 = function()
		local party1 = Object("party1")
		if _A.pull_location=="arena" and party1 and player:SpellCooldown("Master's Call")==0 and party1:stateYOUCEF("root") then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:rangefrom(party1)<40 and pet:losFrom(party1) then
				-- cancel cast
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  
					else return party1:cast("Master's Call")
				end
			end
		end
	end,
	masterscall_party2 = function()
		local party1 = Object("party2")
		if _A.pull_location=="arena" and party1 and player:SpellCooldown("Master's Call")==0 and party1:stateYOUCEF("root") then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") 
				and pet:rangefrom(party1)<40 and pet:losFrom(party1) then
				-- cancel cast
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  
					else return party1:cast("Master's Call")
				end
			end
		end
	end,
	roarofsac = function()
		if player:SpellCooldown("Roar of Sacrifice(Cunning Ability)")==0 and player:health()<65 and player:combat() and not player:buff("Deterrence") and _A.castdelay("Deterrence",(5+player:gcd())) then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:range()<40 and pet:los() then
				return _A.CallWowApi("RunMacroText","/cast [@player] Roar of Sacrifice(Cunning Ability)")
			end
		end
	end,
	pet_cower = function()
		if player:SpellCooldown("Cower(Basic Ability)")==0 then
			local pet = Object("pet")
			if pet and pet:exists() and pet:alive() and not pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") and pet:health()<30 then
				return _A.CallWowApi("RunMacroText","/cast Cower(Basic Ability)")
			end
		end
	end,
	mendpet =  function()
		if	_A.UnitExists("pet") and not _A.UnitIsDeadOrGhost("pet") and _A.HasPetUI() and _A.castdelay("Mend Pet", (2*player:gcd())) and player:spellcooldown("Mend Pet")<cdcd
			and player:spellusable("Mend Pet")
			then
			local pet = Object("pet")
			if pet and pet:range()<=40 and pet:health()<90 and pet:combat() and not pet:buffany("Mend Pet") and pet:los() then 
				return player:cast("Mend Pet") 
			end
		end
	end,
	-- Misc
	autoattackmanager = function()
		local target = Object("target")
		if target and target.isplayer and target:enemy() and target:alive() and target:InConeOf(player, 180) and target:los() then
			if (target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") or _A.scattertargets[target.guid]) and player:autoattack() then _A.CallWowApi("RunMacroText", "/stopattack") 
				elseif not target:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep") and not _A.scattertargets[target.guid] and not player:autoattack() then  _A.CallWowApi("RunMacroText", "/startattack") 
			end
		end
	end,
	autoattackmanagerv2 = function()
		local lowest = Object("lowestEnemyInSpellRange(Arcane Shot)")
		if lowest then if lowest:delay("autoattack", 1) then _A.StartAttack(75,lowest.guid)  end
			-- elseif player:autoattack() then _A.CallWowApi("RunMacroText", "/stopattack") 
		end
	end,
	kick = function()
		if player:SpellCooldown("Counter Shot")==0 and player:spellusable("Counter Shot") then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Arcane Shot") 
					-- and obj:InConeOf("player", 170)
					and obj:caninterrupt() 
					and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=90
					)
					and _A.notimmune(obj)
					then
					if kickcheck(obj) then
						obj:FaceCast("Counter Shot", true)
					end
				end
			end
		end
	end,
	pet_misdirect = function()
		if player:Spellcooldown("Misdirection")==0 and _A.castdelay("Misdirection", 1.5)
			and player:combat() and _A.pull_location=="none" and not player:isCastingAny() and player:spellusable("Misdirection") and player:glyph("Glyph of Misdirection")
			then
			local pet = Object("pet")
			if pet and pet:alive() and pet:exists() and not player:buff("Misdirection") and pet:SpellRange("Misdirection") and pet:los() then
				return pet:Cast("Misdirection")
			end
		end
	end,
	-- Traps and CC
	concussion = function()
		if player:spellcooldown("Concussive Shot")<cdcd and player:spellusable("Concussive Shot") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee and lowestmelee:stateduration("snare")<1.5 and not lowestmelee:immuneYOUCEF("snare") then
				return lowestmelee:Cast("Concussive Shot")
			end
		end
	end,
	traps_ICE = function()
		if player:buff("Trap Launcher")
			and player:spellusable("Ice Trap") then
			local lowestmelee = Object("enemyplayercc")
			if lowestmelee then
				if player:Spellcooldown("Ice Trap")<cdcd
					then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting") end
					if not player:isCastingAny() then
						return _A.clickcast(lowestmelee, "Ice Trap")					
					end 
				end 
			end 
		end
	end,
	traps_SNAKE = function()
		if player:buff("Trap Launcher")
			and player:spellusable("Snake Trap") then
			local lowestmelee = Object("enemyplayercc")
			if lowestmelee then
				if player:Spellcooldown("Snake Trap")<cdcd and _A.castdelay(82941, 6) 
					then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting") end
					if not player:isCastingAny() then
						return _A.clickcast(lowestmelee, "Snake Trap")			
					end 
				end 
			end 
		end
	end,
	---------------------------------- CC SEQUENCE
	---------------------------------- CC SEQUENCE
	---------------------------------- CC SEQUENCE
	scatter = function()
		local focus = Object("focus")
		if player:SpellCooldown("Scatter Shot")<cdcd and player:SpellCooldown("Freezing Trap")<cdcd and player:buff("Trap Launcher") 
			and player:spellusable("Scatter Shot") then
			if focus and not _A.scattertargets[focus.guid] and focus:enemy() and focus:alive() and focus.isplayer and focus:spellRange("Scatter Shot") 
				and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and _A.notimmune(focus) and not focus:immuneYOUCEF("disorient")
				-- and focus:InConeOf("player", 170) 
				and (focus:drstate("Freezing Trap")==1 or focus:drstate("Freezing Trap")==-1) 
				and (focus:drstate("Scatter Shot")==1 or focus:drstate("Scatter Shot")==-1)
				and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not player:isCastingAny() then  return focus:FaceCast("Scatter Shot") end
			end
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Scatter Shot") 
						and healerspecid[Obj:spec()] 
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("disorient") 
						-- and Obj:InConeOf("player", 170) 
						and (Obj:drstate("Freezing Trap")==1 or Obj:drstate("Freezing Trap")==-1) 
						and (Obj:drstate("Scatter Shot")==1 or Obj:drstate("Scatter Shot")==-1)
						and Obj:los() then
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
						if not player:isCastingAny() then  return Obj:Facecast("Scatter Shot") end
					end
				end
			end
		end
	end,
	freezing = function()
		local focus = Object("focus")
		if player:SpellCooldown("Freezing Trap")<cdcd and player:buff("Trap Launcher") and player:spellusable("Freezing Trap") then
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
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:spellRange("Arcane Shot") 
						and healerspecid[Obj:spec()] 
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
		end
	end,
	sleep = function()
		local focus = Object("focus")
		if player:Talent("Wyvern Sting") and player:SpellCooldown("Wyvern Sting")<cdcd  and player:spellusable("Wyvern Sting") and player:SpellCooldown("Scatter Shot")>player:gcd()
			and _A.castdelay(60192,2) and _A.castdelay("Scatter Shot",2) then
			if focus and not _A.scattertargets[focus.guid] and focus:enemy() and focus:alive() and focus.isplayer and focus:spellRange("Arcane Shot") 
				-- and focus:InConeOf("player", 170)
				and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and _A.notimmune(focus) and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not  player:isCastingAny()  then
					return focus:FaceCast("Wyvern Sting")
				end
			end
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Arcane Shot") 
						-- and Obj:InConeOf("player", 170) 
						and healerspecid[Obj:spec()] 
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and Obj:los() then
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
						if not  player:isCastingAny()  then
							return Obj:FaceCast("Wyvern Sting")
						end
					end
				end
			end
		end
	end,
	-----------------------------------------------------------
	----------------------------------------------------------- SECOND SETUP
	-----------------------------------------------------------
	-----------------------------------------------------------
	sleep2 = function()
		local focus = Object("focus")
		if player:talent("Wyvern Sting") and player:SpellCooldown("Wyvern Sting")<cdcd and player:SpellCooldown("Freezing Trap")<cdcd and player:buff("Trap Launcher") 
			and player:spellusable("Wyvern Sting") then
			if focus and focus.isplayer and focus:enemy() and focus:alive() and not _A.scattertargets[focus.guid] and focus:spellRange("Arcane Shot")
				and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and _A.notimmune(focus) and not focus:immuneYOUCEF("sleep") 
				-- and focus:InConeOf("player", 170) 
				and (focus:drstate("Freezing Trap")==1 or focus:drstate("Freezing Trap")==-1) 
				and (focus:drstate("Wyvern Sting")==1 or focus:drstate("Wyvern Sting")==-1)
				and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not player:isCastingAny() then  return focus:facecast("Wyvern Sting") end
			end
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Arcane Shot") 
						and healerspecid[Obj:spec()] 
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and _A.notimmune(Obj) and not Obj:immuneYOUCEF("sleep") 
						-- and Obj:InConeOf("player", 170) 
						and (Obj:drstate("Freezing Trap")==1 or Obj:drstate("Freezing Trap")==-1) 
						and (Obj:drstate("Wyvern Sting")==1 or Obj:drstate("Wyvern Sting")==-1)
						and Obj:los() then
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
						if not player:isCastingAny() then  return Obj:facecast("Wyvern Sting") end
					end
				end
			end
		end
	end,
	freezing2 = function()
		local focus = Object("focus")
		if player:SpellCooldown("Freezing Trap")<cdcd and player:buff("Trap Launcher") and player:spellusable("Freezing Trap") then
			if focus and focus.isplayer and focus:alive() and focus:enemy() and focus:spellRange("Arcane Shot")
				and focus:stateduration("sleep || stun || misc || incapacitate")>1
				and focus:stateduration("sleep || stun || misc || incapacitate")<4
				and not focus:moving()
				and _A.notimmune(focus) and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not  player:isCastingAny()  then
					return _A.clickcast(focus, "Freezing Trap")
				end
			end
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and Obj:spellRange("Arcane Shot") 
						and healerspecid[Obj:spec()] 
						and Obj:stateduration("sleep || stun || misc || incapacitate")>1
						and Obj:stateduration("sleep || stun || misc || incapacitate")<4
						and not Obj:moving()
						and _A.notimmune(Obj) and Obj:los() then
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
						if not  player:isCastingAny()  then
							return _A.clickcast(Obj, "Freezing Trap")
						end
					end
				end
			end
		end
	end,
	scatter2 = function()
		local focus = Object("focus")
		if player:SpellCooldown("Scatter Shot")<cdcd  and player:spellusable("Scatter Shot")
			then
			if focus and focus:enemy() and focus:alive() and focus.isplayer and not _A.scattertargets[focus.guid] and focus:spellRange("Scatter Shot") 
				-- and focus:InConeOf("player", 170)
				and focus:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
				and (_A.castdelay(60192,2) or (focus:debuffduration("Freezing Trap")<2 and focus:debuffduration("Freezing Trap")>0))
				and _A.notimmune(focus) and focus:los() then
				if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
				if not  player:isCastingAny()  then
					return focus:facecast("Scatter Shot")
				end
			end
			if not focus then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Scatter Shot") 
						-- and Obj:InConeOf("player", 170) 
						and healerspecid[Obj:spec()] 
						and Obj:stateduration("incapacitate || disorient || charm || misc || sleep || stun || fear")<1.5
						and (_A.castdelay(60192,2) or (Obj:debuffduration("Freezing Trap")<2 and Obj:debuffduration("Freezing Trap")>0))
						and _A.notimmune(Obj) and Obj:los() then
						if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
						if not  player:isCastingAny()  then
							return Obj:facecast("Scatter Shot")
						end
					end
				end
			end
		end
	end,
	
	-----------------------------------------------------------
	-----------------------------------------------------------
	sleepKick = function()
		if player:SpellCooldown("Wyvern Sting")<cdcd and player:SpellCooldown("Freezing Trap")<cdcd and player:buff("Trap Launcher") 
			and player:spellusable("Wyvern Sting") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Arcane Shot")
					and (Obj:iscasting("Fists of Fury") or Obj:channeling("Fists of Fury"))
					and _A.notimmune(Obj) 
					-- and Obj:InConeOf("player", 170) 
					and Obj:los() then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
					if not player:isCastingAny() then  return Obj:facecast("Wyvern Sting") end
				end
			end
		end
	end,
	scatterKick = function()
		if player:SpellCooldown("Scatter Shot")<cdcd  and player:spellusable("Scatter Shot")
			then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and not _A.scattertargets[Obj.guid] and Obj:spellRange("Scatter Shot")
					and (Obj:iscasting("Fists of Fury") or Obj:channeling("Fists of Fury"))
					and _A.notimmune(Obj) 
					-- and Obj:InConeOf("player", 170) 
					and Obj:los() then
					if player:isCastingAny() then _A.CallWowApi("RunMacroText", "/stopcasting") _A.CallWowApi("RunMacroText", "/stopcasting")  end
					if not player:isCastingAny() then  return Obj:facecast("Scatter Shot") end
				end
			end
		end
	end,
	-----------------------------------------------------------
	-----------------------------------------------------------
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
				player:useitem(76089)
				return player:cast("Rapid Fire")
			end
		end
	end,
	fervor = function()
		if player:combat() and player:Talent("Fervor") and player:SpellCooldown("Fervor")==0 and player:spellusable("Fervor") and player:focus()<=30 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee
				-- and lowestmelee:health()>=35
				then 
				return player:cast("Fervor")
			end
		end
	end,
	stampede = function()
		if player:combat() and player:buff("Rapid Fire") and player:SpellCooldown("Stampede")<cdcd and player:spellusable("Stampede") then
			local lowestmelee = Object("simpletarget(Arcane Shot)")
			if lowestmelee and lowestmelee.isplayer
				-- and lowestmelee:health()>=35
				then 
				return lowestmelee:cast("Stampede")
			end
		end
	end,
	-- ROTATION
	explosiveshot = function()
		if  player:SpellCooldown("Explosive Shot")<cdcd then
			local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if _A.EScheck() and player:SpellUsable("Explosive Shot") then
					return lowestmelee:Cast("Explosive Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot") 
				end
			end
		end
	end,
	amoc = function()
		if player:talent("A Murder of Crows") and player:SpellCooldown("A Murder of Crows")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("A Murder of Crows") then
					return lowestmelee:Cast("A Murder of Crows")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot") 
				end
			end
		end
	end,
	blackarrow = function()
		if _A.BAcheck() and player:SpellUsable("Black Arrow") and player:SpellCooldown("Black Arrow")<cdcd then
			local lowestmelee = nil
			if _A.pull_location=="pvp" then
				lowestmelee = Object("highestEnemyInSpellRangeNOTAR(Arcane Shot)")
				else 
				lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			end
			if lowestmelee then
				if _A.BAcheck() and player:SpellUsable("Black Arrow") then
					return lowestmelee:Cast("Black Arrow")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot") 
				end
			end
		end
	end,
	serpentsting = function()
		if _A.MissileExists("Serpent Sting")==false and player:spellcooldown("Serpent Sting")<cdcd  then
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
		if _A.MissileExists("Serpent Sting")==false and player:spellcooldown("Serpent Sting")<cdcd
			and _A.castdelay("Serpent Sting", 10)
			then
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
		if player:spellcooldown("Multi-Shot")<cdcd and _Y.clumpguid and _Y.clumpnumber>=1 then
			local lowestmelee = Object(_Y.clumpguid)
			if lowestmelee then
				if player:SpellUsable("Multi-Shot") and _A.multishotcheck() then 
					return lowestmelee:Cast("Multi-Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	barrage = function()
		if player:Talent("Barrage") and player:spellcooldown("Barrage")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("Barrage") then
					return lowestmelee:Cast("Barrage")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	arcaneshot = function() -- and player:buff("Thrill of the Hunt") 
		if player:spellcooldown("Arcane Shot")<cdcd  then
			local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
			if lowestmelee then
				if player:SpellUsable("Arcane Shot") and _A.lowpriocheck("Arcane Shot") then
					return lowestmelee:Cast("Arcane Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	auto_multishot = function() -- and player:buff("Thrill of the Hunt") 
		if _A.pull_location~="arena" and player:spellcooldown("Multi-Shot")<cdcd then
			local lowestmelee =  Object(_Y.clumpguid)
			if lowestmelee then
				if player:SpellUsable("Multi-Shot") and _A.lowpriocheck("Multi-Shot") then
					return lowestmelee:Cast("Multi-Shot")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	tranq_hop = function()
		if player:SpellCooldown("Tranquilizing Shot")<cdcd then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and Obj:spellRange("Tranquilizing Shot") and not Obj:stateYOUCEF("incapacitate || disorient || charm || misc || sleep || fear")
					and not Obj:BuffAny("Divine Shield") and Obj:InConeOf("player", 170)
					and Obj:BuffAny("Hand of Protection || Fear Ward")
					and Obj:los() then
					if player:SpellUsable("Tranquilizing Shot") then
						return Obj:Cast("Tranquilizing Shot")
						elseif _A.CobraCheck() then 
						local lowestmelee = _A.totemtar or Object("lowestEnemyInSpellRange(Arcane Shot)")
						if lowestmelee then
							return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
						end
					end
				end
			end
		end
	end,
	tranquillshot_highprio = function()
		if player:spellcooldown("Tranquilizing Shot")<cdcd
			-- and _A.castdelay("Tranquilizing Shot", player:gcd()) 
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Tranquilizing Shot)")
			if lowestmelee and canpurge(lowestmelee.guid) then
				if purgenum(lowestmelee.guid)>=2 or not _A.MissileExists("Tranquilizing Shot") then
					if player:SpellUsable("Tranquilizing Shot") then
						return lowestmelee:Cast("Tranquilizing Shot")
						elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
					end
				end
			end
		end
	end,
	tranquillshot_midprio = function()
		if player:spellcooldown("Tranquilizing Shot")<cdcd
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Tranquilizing Shot)")
			if lowestmelee and canpurge(lowestmelee.guid) then
				if purgenum(lowestmelee.guid)>=2 or not _A.MissileExists("Tranquilizing Shot") then
					if player:SpellUsable("Tranquilizing Shot") and _A.lowpriocheck("Tranquilizing Shot") then
						return lowestmelee:Cast("Tranquilizing Shot")
						elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
					end
				end
			end
		end
	end,
	venom = function()
		if _A.MissileExists("Widow Venom")==false and player:spellcooldown("Widow Venom")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRange(Widow Venom)")
			local target = Object("target")
			if target and lowestmelee and lowestmelee:is(target) and lowestmelee.isplayer and not lowestmelee:debuff("Widow Venom") then
				if player:SpellUsable("Widow Venom") and _A.lowpriocheck("Widow Venom") then
					return lowestmelee:Cast("Widow Venom")
					elseif _A.CobraCheck() then return player:level()>=81 and lowestmelee:Cast("Cobra Shot") or lowestmelee:Cast("Steady Shot")
				end
			end
		end
	end,
	glaivetoss = function()
		if player:talent("Glaive Toss") and player:SpellCooldown("Glaive Toss")<cdcd then
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
		if player:Spellcooldown("Kill Shot")<cdcd then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Kill Shot)")
			if lowestmelee and lowestmelee:health()<=20 then
				return lowestmelee:Cast("Kill Shot")
			end
		end
	end,
}
local function AOEcheck()
	if _A.pull_location=="arena" then return false end
	if _A.modifier_shift() then return true end
	if (_Y.clumpnumber>=enemytreshhold) then return true end
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
_Y.clumpnumber = nil
_Y.clumpguid = nil
local inCombat = function()
	if not _A.Cache.Utils.PlayerInGame then return true end
	player = Object("player")
	if not player then return true end
	cdcd = _A.Parser.frequency and _A.Parser.frequency*3 or .3
	local focus = Object("focus")
	_A.pull_location = _A.pull_location or pull_location()
	if not player:combat() and not (_A.pull_location=="pvp" or _A.pull_location=="arena") then _A.CallWowApi("RunMacroText", "/petfollow") return true end
	_Y.petengine_Surv()
	--debug
	-- print(_A.MissileExists("Arcane Shot"))
	-- print(player:immuneduration("snare || all"))
	-- if player:alive() then
	-- print(player:stateYOUCEF("snare || root"))
	-- end
	if player:keybindUp("F7") and player:timeout("F7", 1) then
		_A.texplore(_A.Cache.Tooltip)
	end
	_A.latency = (select(3, GetNetStats())) and math.ceil(((select(3, GetNetStats()))/100))/10 or 0
	_A.interrupttreshhold = .3 + _A.latency
	_A.totemtar = Object("HealingStreamTotemPLAYER(Arcane Shot)")
	if not _A.pull_location then return true end
	if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return true end
	if player:mounted() then return true end
	if player:isChanneling("Barrage") then return true end
	-------------------------- UTILITY
	survival.rot.roarofsac()
	survival.rot.pet_cower()
	-- if player:lostcontrol() then return true end
	if player:buff("Camouflage") then return true end
	-- Defs
	if not player:buffany("Horde Flag || Alliance Flag") then survival.rot.deterrence() end
	if survival.rot.disengage_freemovement() then return true end
	if survival.rot.masterscall() then return true end
	survival.rot.masterscall_party1()
	survival.rot.masterscall_party2()
	-- no gcd
	if not player:isCastingAny() then
		survival.rot.pet_misdirect()
		survival.rot.items_healthstone()
	end
	-- Traps
	if not toggle("TrapEnable") then
		if survival.rot.traps_ICE() then return true end
		if survival.rot.traps_SNAKE() then return true end
	end
	if not player:buff("Deterrence") then
		survival.rot.sleepKick()
		survival.rot.scatterKick()
		survival.rot.bindingshot()
	end
	if toggle("TrapEnable") then
		if player:talent("Wyvern Sting") and toggle("WyvernEnable") then
			if survival.rot.sleep2() then return true end
			if survival.rot.freezing2() then return true end
			if survival.rot.scatter2() then return true end
			else
			if survival.rot.scatter() then return true end
			if survival.rot.freezing() then return true end
			if survival.rot.sleep() then return true end
		end
	end
	-------------------------- MAIN ROTATION
	if player:buff("Deterrence") then return true end
	survival.rot.autoattackmanager()
	if not _A.BUTTONHOOK_RELATED and _A.buttondelayfunc() then return true end -- pausing for manual casts
	-- survival.rot.autoattackmanagerv2()
	if not (not player:isCastingAny() or player:CastingRemaining() < 0.3) then return true end
	-- Burst
	survival.rot.activetrinket()
	survival.rot.items_agiflask()
	survival.rot.bursthunt()
	survival.rot.fervor()
	if not player:buffany("Horde Flag || Alliance Flag") then survival.rot.feigninterrupt() end
	survival.rot.stampede()
	survival.rot.kick()
	_Y.clumpnumber, _Y.clumpguid = _Y.mostclumpedenemy(40,8.5)
	-- print(_Y.clumpnumber)
	if AOEcheck() and survival.rot.barrage() then return true end -- make a complete aoe check function
	if AOEcheck() and survival.rot.multishot() then return true end -- make a complete aoe check function
	survival.rot.killshot()
	survival.rot.mendpet()
	if player:buff("Lock and Load") and survival.rot.explosiveshot() then return true end
	if (_A.modifier_ctrl() or toggle("enable_tranq")) and survival.rot.tranquillshot_highprio() then return true end -- ctrl enables tranq outisde arena
	if _A.modifier_alt() then survival.rot.concussion() end -- alt slows
	-- important spells
	if survival.rot.tranq_hop() then return true end
	if survival.rot.amoc() then return true end
	if survival.rot.blackarrow() then return true end
	if survival.rot.explosiveshot() then return true end
	if survival.rot.glaivetoss() then return true end
	-- heal pet
	-- excess focus priority
	-- if _Y.clumpnumber and _Y.clumpnumber>=3 and player:buff("Thrill of the Hunt") and survival.rot.auto_multishot() then return true end
	if player:buff("Thrill of the Hunt") and survival.rot.arcaneshot() then return true end
	-- if _Y.clumpnumber and _Y.clumpnumber>=3 and survival.rot.auto_multishot() then return true end
	if survival.rot.serpentsting_check() then return true end
	if survival.rot.venom() then return true end
	if survival.rot.arcaneshot() then return true end
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(255, {
	name = "Youcef's Survival Hunter",
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