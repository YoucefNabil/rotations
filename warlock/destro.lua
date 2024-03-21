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
end
local exeOnUnload = function()
end
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}
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
	
	ClickthisPleasepvp = function()
		local tempTable = {}
		if _A.pull_location=="pvp" then
			for _, Obj in pairs(_A.OM:Get('GameObject')) do
				if heFLAGS[Obj.name] then
					tempTable[#tempTable+1] = {
						guid = Obj.guid,
						distance = Obj:distance()
					}
				end
			end
			if #tempTable > 1 then
				table.sort(tempTable, function(a, b) return a.distance < b.distance end)
			end
			if tempTable[1] then _A.ObjectInteract(tempTable[1].guid) end
		end
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
	
	petres = function()
		if player:talent("Grimoire of Sacrifice") and not player:Buff("Grimoire of Sacrifice") and player:SpellCooldown("Grimoire of Sacrifice")==0 then
			if not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or not _A.HasPetUI()
				then 
				if not player:moving() and not player:Iscasting("Summon Imp") then
					return player:cast("Summon Imp")
				end
			end
		end
	end,
	
	Buffbuff = function()
		if player:talent("Grimoire of Sacrifice") and player:SpellCooldown("Grimoire of Sacrifice")==0 and _A.UnitExists("pet") and not _A.UnitIsDeadOrGhost("pet") and _A.HasPetUI() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
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
	immolate = function()
		if not player:moving() and not player:Iscasting("Immolate") then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				if not lowest:debuff("Immolate") then
					return lowest:cast("Immolate")
				end
			end
		end
	end,
	
	conflagrate = function()
		if player:SpellCharges("Conflagrate") > 1 then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Conflagrate")
			end
		end
	end,
	
	chaosbolt = function()
		if _A.BurningEmbers >= 3 or 
			(_A.BurningEmbers >= 1 and player:Buff("Dark Soul: Instability"))
			then
			if not player:moving() and not player:Iscasting("Chaos Bolt") then
				local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
				if lowest and lowest:exists() then
					return lowest:cast("Chaos Bolt")
				end
			end
		end
	end,
	
	conflagrateonecharge = function()
		if player:SpellCharges("Conflagrate") == 1 then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Conflagrate")
			end
		end
	end,
	
	incinerate = function()
		if (not player:moving() or player:buff("Backlash")) and not player:Iscasting("Incinerate") then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("Incinerate")
			end
		end
	end,
	
	felflame = function()
		if player:moving() then
			local lowest = Object("lowestEnemyInSpellRange(Conflagrate)")
			if lowest and lowest:exists() then
				return lowest:cast("felflame")
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
	destro.rot.ClickthisPleasepvp()
	if _A.buttondelayfunc()  then return end
	if player:lostcontrol()  then return end 
	if player:isCastingAny() then return end
	if player:Mounted() then return end
	--
	destro.rot.Buffbuff()
	destro.rot.petres()
	destro.rot.items_healthstone()
	--buff
	--snapshots
	destro.rot.activetrinket()
	--utility
	destro.rot.lifetap()
	destro.rot.immolate()
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
