local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local player
local destro = {}
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
_A.casttimers = {}
_A.Listener:Add("delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		-- print(subevent.." "..idd)
		if (idd==688) then
			if subevent == "SPELL_CAST_SUCCESS" then
				_A.casttimers[idd] = _A.GetTime()
			end
		end
	end
end)
_A.casttbl = {}
_A.Listener:Add("iscasting", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		if subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_CAST_FAILED"   then
			_A.casttbl[idd] = nil
		end
		if subevent == "SPELL_CAST_START" then
			_A.casttbl[idd] = true
		end
	end
end)
function _A.overkillcheck(id)
	if not id then return false end
	if not player:Iscasting(id) and _A.casttbl[idd] == true then
		_A.casttbl[idd] = nil return false
	end
	return _A.casttbl[idd] or false
end
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
	_A.numenemiesaround = function()
		local num = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange("Conflagrate") and  Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
				num = num + 1
			end
		end
		return num
	end
	_A.FakeUnits:Add('mostgroupedenemyDESTRO', function(num, spell_range_threshhold)
		local tempTable = {}
		local most, mostGuid = 0
		local numbads = _A.numenemiesaround()
		local spell, range, threshhold = _A.StrExplode(spell_range_threshhold)
		if not spell then return end
		range = tonumber(range) or 10
		threshhold = tonumber(threshhold) or 1
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
				if (Obj:Debuff(80240)==false) or (numbads==1) then
					tempTable[Obj.guid] = 1
					for _, Obj2 in pairs(_A.OM:Get('Enemy')) do
						if Obj.guid~=Obj2.guid and Obj:rangefrom(Obj2)<=range and _A.attackable(Obj2) and _A.notimmune(Obj2)  and Obj2:los() then
							tempTable[Obj.guid] = tempTable[Obj.guid] + 1
						end
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
	_A.FakeUnits:Add('lowestEnemyInSpellRangeDESTRO', function(num, spell)
		local tempTable = {}
		-- local target = Object("target")
		local numbads = _A.numenemiesaround()
		-- if target and target:enemy() and target:spellRange(spell) and target:Infront() and _A.attackable and _A.notimmune(target)  and target:los() then
		-- if (target:Debuff(80240)==false) or (numbads==1) then
		-- return target and target.guid
		-- end
		-- end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and Obj:Infront() and  _A.notimmune(Obj) and Obj:los() then
				if (Obj:Debuff(80240)==false) or (numbads==1) then
					tempTable[#tempTable+1] = {
						guid = Obj.guid,
						health = Obj:health(),
						isplayer = Obj.isplayer and 1 or 0
					}
				end
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end
	)
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTARDESTRO', function(num, spell)
		local tempTable = {}
		local numbads = _A.numenemiesaround()
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and Obj:Infront() and  _A.notimmune(Obj) and Obj:los() then
				-- if (Obj:Debuff(80240)==false) or (numbads==1) then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
				-- end
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end
	)
end
local exeOnUnload = function()
end
local usableitems= { -- item slots
	13, --first trinket
	14 --second trinket
}
destro.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.pull_location = pull_location()
		_A.BurningEmbers = _A.UnitPower("player", 14)
	end,
	
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
		if player:health() <= 55 then
			if player:SpellCooldown("Dark Regeneration") == 0
				then
				player:cast("Dark Regeneration")
				player:useitem("Healthstone")
			end
		end
	end,
	
	summ_healthstone = function()
		if player:ItemCount(5512) == 0 and not player:combat() then
			if not player:moving() and not player:Iscasting("Create Healthstone") then
				player:cast("Create Healthstone")
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
	--============================================
	--============================================
	--============================================
	activetrinket = function()
		if player:buff("Surge of Dominance") then
			for i=1, #usableitems do
				if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~= nil then
					if GetItemSpell(select(1, GetInventoryItemID("player", usableitems[i])))~="PvP Trinket" then
						if cditemRemains(GetInventoryItemID("player", usableitems[i]))==0 then 
							return _A.RunMacroText(string.format(("/use %s "), usableitems[i]))
						end
					end
				end
			end
		end
	end,
	--============================================
	--============================================
	--============================================
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
	
	Buffbuff = function()
		if player:talent("Grimoire of Sacrifice") and player:SpellCooldown("Grimoire of Sacrifice")==0 and _A.HasPetUI() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Grimoire of Sacrifice")
		end
	end,
	
	lifetap = function()
		if soulswaporigin == nil 
			and player:SpellCooldown("life tap")<=.3 
			and player:health()>=35
			and player:Mana()<=45
			then
			player:cast("life tap")
		end
	end,
	--======================================
	--======================================
	--======================================
	--AOE
	brimstone = function()
		local lowest = ((modifier_shift() and Object("mostgroupedenemyDESTRO(Conflagrate,10,1)")) or Object("mostgroupedenemyDESTRO(Conflagrate,10,4)"))
		if lowest and lowest:exists() then
			if not player:buff("Fire and Brimstone") then
				if _A.BurningEmbers>=1 then
					return player:cast("Fire and Brimstone")
				end
			end
			else
			if player:buff("Fire and Brimstone") then
				return _A.RunMacroText("/cancelaura Fire and Brimstone")
			end
		end
	end,
	
	immolateaoe = function()
		if player:buff("Fire and Brimstone") then
			if not player:moving() and not player:Iscasting("Immolate") then
				local lowest = ((modifier_shift() and Object("mostgroupedenemyDESTRO(Conflagrate,10,1)")) or Object("mostgroupedenemyDESTRO(Conflagrate,10,4)"))
				if lowest and lowest:exists() then
					if lowest:debuffrefreshable("Immolate") then
						return lowest:cast("Immolate")
					end
				end
			end
		end
	end,
	
	incinerateaoe = function()
		if player:buff("Fire and Brimstone") then
			if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
				local lowest = ((modifier_shift() and Object("mostgroupedenemyDESTRO(Conflagrate,10,1)")) or Object("mostgroupedenemyDESTRO(Conflagrate,10,4)"))
				if lowest and lowest:exists() then
					return lowest:cast("incinerate")
				end
			end
		end
	end,
	--======================================
	--======================================
	--======================================
	immolate = function()
		if not player:moving() and not player:Iscasting("Immolate") then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				if lowest:debuffrefreshable("Immolate") then
					return lowest:cast("Immolate")
				end
			end
		end
	end,
	
	havoc = function()
		local numbads = _A.numenemiesaround()
		if player:SpellCooldown("Havoc")<=.3 and numbads>=1 then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Havoc")
			end
		end
	end,
	
	conflagrate = function()
		if player:SpellCharges("Conflagrate") > 1 then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Conflagrate")
			end
		end
	end,
	
	shadowburn = function()
		if _A.BurningEmbers >= 1
			then
			local lowest = Object("lowestEnemyInSpellRangeNOTARDESTRO(Shadowburn)")
			if lowest and lowest:exists() and lowest:health()<=20 then
				if player:iscasting() then
					_A.SpellStopCasting()
					_A.SpellStopCasting()
					_A.RunMacroText("/stopcasting")
					_A.RunMacroText("/stopcasting")
				end
				player:cast("Dark Soul: Instability")
				lowest:cast("Shadowburn", true)
				return true
			end
		end
	end,
	
	chaosbolt = function()
		if _A.BurningEmbers >= 3 or 
			(_A.BurningEmbers >= 1 and player:Buff("Dark Soul: Instability"))
			then
			if not player:moving() and not player:Iscasting("Chaos Bolt") then
				local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
				if lowest and lowest:exists() then
					return lowest:cast("Chaos Bolt")
					end
				end
		end
	end,
	
	conflagrateonecharge = function()
		if player:SpellCharges("Conflagrate") == 1 then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Conflagrate")
			end
		end
	end,
	
	incinerate = function()
		if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Incinerate")
			end
		end
	end,
	
	felflame = function()
		if player:moving() then
			local lowest = Object("lowestEnemyInSpellRangeDESTRO(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("fel flame")
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
	destro.rot.caching()
	if _A.buttondelayfunc()  then return end
	if player:lostcontrol()  then return end 
	-- if player:isCastingAny() then return end
	if player:Mounted() then return end
	--
	destro.rot.Buffbuff()
	destro.rot.petres()
	-- HEALS AND DEFS
	destro.rot.summ_healthstone()
	destro.rot.Darkregeneration() -- And Dark Regen
	destro.rot.items_healthstone() -- And Dark Regen
	destro.rot.MortalCoil() -- And Dark Regen
	--buff
	destro.rot.activetrinket()
	destro.rot.shadowburn()
	--utility
	destro.rot.lifetap()
	destro.rot.brimstone()
	-- destro.rot.immolateaoe()
	destro.rot.incinerateaoe()
	--
	-- destro.rot.immolate()
	destro.rot.havoc()
	destro.rot.conflagrate()
	destro.rot.chaosbolt()
	destro.rot.conflagrateonecharge()
	destro.rot.incinerate()
	destro.rot.felflame()
	-- soul swap
end
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(267, {
	name = "Youcef's Destro",
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
