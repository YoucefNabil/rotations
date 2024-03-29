local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local player
local demono = {}
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
end
local exeOnUnload = function()
end
local usableitems= { -- item slots
	13, --first trinket
	14 --second trinket
}
demono.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.fury = (UnitPower("player", 15)/10)
		_A.pull_location = pull_location()
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
	
	demoburst = function()
		if player:combat() and player:SpellCooldown("Dark Soul: Knowledge")==0 and not player:buff("Dark Soul: Knowledge") and _A.enoughmana(113861)  then
			if player:buff("Call of Dominance") then
				player:cast("Lifeblood")
				player:cast("Dark Soul: Knowledge")
			end
		end
	end,
	
	impswarm = function()
		if player:combat() and player:SpellCooldown(104316)<.3 and player:buff("Dark Soul: Knowledge")  then
			return player:cast(104316)
		end
	end,
	
	handofguldan = function()
	if _A.GetShapeshiftForm() == 0 then
		if _A.fury>=30 and player:combat() and player:buff("Call of Dominance") then
			local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
			if lowest and lowest:exists() and player:SpellCharges(105174)~=0 then
				return lowest:cast(105174)
			end
		end
		end
	end,
	
	metamorf = function()
		if player:SpellCharges(105174)==0 and _A.fury>=30 and not player:buff("Metamorphosis") and player:combat() and player:buff("Call of Dominance") and player:SpellCount("Hand of Gul'dan") == 0   then
			return player:cast("Metamorphosis")
		end
	end,
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
	--======================================
	--======================================
	--======================================
	--======================================
	Doom = function()
		local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
		if lowest and lowest:exists() and lowest:DebuffRefreshable("Doom")  then
			return lowest:cast("Doom")
		end
	end,
	
	touchofchaos = function()
		local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
		if lowest and lowest:exists()  then
			return lowest:cast(103964)
		end
	end,
	--======================================
	--======================================
	--======================================
	--======================================
	--======================================
	--======================================
	Corruption = function()
		local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
		if lowest and lowest:exists() and lowest:DebuffRefreshable("Corruption")  then
			return lowest:cast("Corruption")
		end
	end,
	
	Soulfire = function()
		if not player:moving() and not player:Iscasting("Soul Fire") and player:buff("Molten Core") then
			local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
			if lowest and lowest:exists() then
				return lowest:cast("Soul Fire")
			end
		end
	end,
	
	felflame_shift = function()
		if modifier_shift()==true then
			local lowest = Object("lowestEnemyInSpellRange(Soul Fire)")
			if lowest and lowest:exists()  then
				return lowest:cast("fel flame", true)
			end
		end
	end,
	
	
	shadowbolt = function()
		if (not player:moving() or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Shadow Bolt") then
			local lowest = Object("lowestEnemyInSpellRange(Shadow Bolt)")
			if lowest and lowest:exists() then
				return lowest:cast("Shadow Bolt")
			end
		end
	end,
	
	felflame = function()
		local lowest = Object("lowestEnemyInSpellRange(fel flame)")
		if lowest and lowest:exists()  then
			return lowest:cast("fel flame")
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
	demono.rot.caching()
	if _A.buttondelayfunc()  then return end
	if player:lostcontrol()  then return end 
	if player:Mounted() then return end
	-- burst
	demono.rot.activetrinket()
	demono.rot.demoburst()
	demono.rot.impswarm()
	demono.rot.handofguldan()
	demono.rot.metamorf()
	-- metamorphosis
	if _A.GetShapeshiftForm() == 1 then
		demono.rot.Doom()
		demono.rot.touchofchaos()
	end
	-- default form
	if _A.GetShapeshiftForm() == 0 then
		demono.rot.Corruption()
		demono.rot.Soulfire()
		demono.rot.felflame_shift()
		demono.rot.shadowbolt()
		demono.rot.felflame()
	end
end
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(266, {
	name = "Youcef's Demonology",
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
