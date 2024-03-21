local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local player
local affliction = {}
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
--snapshottable
local corruptiontbl = {}
local agonytbl = {}
local unstabletbl = {}
local soulswaporigin = nil
local ijustdidthatthing2 = false
local ijustdidthatthingtime2 = 0
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
	soulswaporigin = nil
	ijustdidthatthing2 = false
end)
-- dots
_A.Listener:Add("dotstables", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		if (idd==146739) or (idd==172) then
			if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
				then
				corruptiontbl[guiddest]=_A.myscore() 
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				corruptiontbl[guiddest]=nil
			end
		end
		if (idd==980) then
			if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
				then
				agonytbl[guiddest]=_A.myscore()
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				agonytbl[guiddest]=nil
			end
		end
		if (idd==30108) then
			if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
				then
				unstabletbl[guiddest]=_A.myscore() 
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				unstabletbl[guiddest]=nil
			end
		end
		if (idd==119678) then
			if subevent=="SPELL_AURA_APPLIED" or subevent =="SPELL_CAST_SUCCESS"
				then
				corruptiontbl[guiddest]=_A.myscore() 
				unstabletbl[guiddest]=_A.myscore() 
				agonytbl[guiddest]=_A.myscore() 
			end
		end
	end
end
)
-- Soul Swap
_A.Listener:Add("soulswaprelated", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
	if guidsrc == UnitGUID("player") then -- only filter by me
		if subevent =="SPELL_CAST_SUCCESS" then
			if idd==86121 then -- Soul Swap 86213
				soulswaporigin = guiddest -- remove after 3 seconds or after exhalings
				ijustdidthatthing2 = true
				ijustdidthatthingtime2 = GetTime() -- time at which I used soulswap
			end
			if idd==86213 then -- exhale
				unstabletbl[guiddest]=unstabletbl[soulswaporigin]
				agonytbl[guiddest]=agonytbl[soulswaporigin]
				corruptiontbl[guiddest]=corruptiontbl[soulswaporigin]
				ijustdidthatthing2 = false
				soulswaporigin = nil -- remove after 3 seconds or after exhaling
			end
		end
	end
end)
local timerframe = CreateFrame("Frame")
local timerframeinterval = 0.1 -- default
timerframe.TimeSinceLastUpdate2 = 0
timerframe:SetScript("OnUpdate", function(self,elapsed)
	self.TimeSinceLastUpdate2 = self.TimeSinceLastUpdate2 + elapsed;
	if self.TimeSinceLastUpdate2 >= timerframeinterval then
		if ijustdidthatthing2 == true and GetTime()-ijustdidthatthingtime2>=3 then
			soulswaporigin = nil
			ijustdidthatthing2=false -- so I wouldn't overwrite stats wrongfully
		end
		self.TimeSinceLastUpdate2 = self.TimeSinceLastUpdate2 - timerframeinterval
	end
end)
_A.totalscore = function()
end
--============================================
--============================================
--============================================
_A.casttimers = {}
_A.Listener:Add("delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		-- print(subevent.." "..idd)
		if subevent == "SPELL_CAST_SUCCESS" then
			_A.casttimers[idd] = _A.GetTime()
		end
	end
end)
function _A.castdelay(idd, delay)
	if delay == nil then return true end
	if _A.casttimers[idd]==nil then return true end
	return (_A.GetTime() - _A.casttimers[idd])>=delay
end
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
_A.temptabletbl = {}
affliction.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.temptabletbl = {}
		_A.pull_location = pull_location()
		if not player:BuffAny(86211) and soulswaporigin ~= nil then soulswaporigin = nil end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
				_A.temptabletbl[#_A.temptabletbl+1] = {
					obj = Obj,
					score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0),
					agonyscore = (agonytbl[Obj.guid] or 0),
					unstablescore = (unstabletbl[Obj.guid] or 0),
					corruptionscore = (corruptiontbl[Obj.guid] or 0)
				}
			end
		end
		table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) end )
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
				player:cast("Dark Regeneration", true)
				player:cast("Unending Resolve", true)
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
	summ_healthstone = function()
		if player:ItemCount(5512) < 3 and not player:combat() then
			if not player:moving() and not player:Iscasting("Create Healthstone") then
				player:cast("Create Healthstone")
			end
		end
	end,
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
	
	hasteburst = function()
		if player:SpellCooldown("Dark Soul: Misery")==0 and not player:buff("Dark Soul: Misery") then
			if player:buff("Surge of Dominance") then
				return player:cast("Dark Soul: Misery")
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
		if player:talent("Grimoire of Supremacy") and player:SpellCooldown(112869)<.3 then
			if 
				not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or 
				not _A.HasPetUI()
				then 
				if (not player:buff(74434) and _A.enoughmana(74434) and player:combat()) --or player:buff("Shadow Trance") 
					then player:cast(74434) -- shadowburn
				end	
				if (not player:moving()  or player:buff(74434))  and not player:iscasting(112869) and _A.castdelay(112869, 1.5) then
					return player:cast(112869)
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
		if not player:buffany("Dark Intent") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Dark Intent")
		end
	end,
	
	bloodhorror = function()
		if player:SpellCooldown("Blood Horror")<.3 and player:health()>10 and not player:buff("Blood Horror") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Blood Horror")
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
	
	corruptionsnap = function()
		if _A.temptabletbl[1] then 
			if _A.myscore()>_A.temptabletbl[1].corruptionscore then return _A.temptabletbl[1].obj:Cast("Corruption")
			end
		end
	end,
	
	agonysnap = function()
		if _A.temptabletbl[1] then 
			if _A.myscore()>_A.temptabletbl[1].agonyscore then return _A.temptabletbl[1].obj:Cast("Agony")
			end
		end
	end,
	
	unstablesnapinstant = function()
		if  _A.temptabletbl[1] then 
			if player:buff(74434) then return  _A.temptabletbl[1].obj:Cast(119678) end -- improved soul swap (dots instead)
			if (not player:buff(74434) and _A.enoughmana(74434)) --or player:buff("Shadow Trance")
				then 
				if _A.myscore()> _A.temptabletbl[1].unstablescore  then player:cast(74434) -- shadowburn
				end	 
			end		
		end		
	end,
	
	unstablesnap = function()
		if _A.temptabletbl[1] then 
			if not player:moving() and not player:Iscasting("Unstable Affliction") then
				if _A.myscore()>_A.temptabletbl[1].unstablescore then return _A.temptabletbl[1].obj:Cast("Unstable Affliction")
				end
			end
		end
	end,
	
	shiftmode_haunt = function()
		if _A.modifier_shift() then
			if not player:moving() and not player:Iscasting("Haunt") and _A.enoughmana(48181) and _A.castdelay(48181, 1.5) then
				local lowest = Object("lowestEnemyInSpellRange(Corruption)")
				if lowest and lowest:exists() and not lowest:debuff(48181) then
					lowest:cast("haunt")
				end
			end
		end
	end,
	
	shiftmode_grasp = function()
		if _A.modifier_shift() then
			if not player:moving() and not player:Iscasting("Malefic Grasp") then
				local lowest = Object("lowestEnemyInSpellRange(Corruption)")
				if lowest and lowest:exists() then
					lowest:cast("Malefic Grasp")
				end
			end
		end
	end,
	
	exhale = function()
		local temptable = {}
		if soulswaporigin ~= nil then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
					if Obj.guid ~= soulswaporigin then
						temptable[#temptable+1] = {
							obj = Obj,
							duration = Obj:DebuffDuration("Unstable Affliction")
						}
					end
				end
			end
			table.sort( temptable, function(a,b) return ( a.duration < b.duration ) end )
			return temptable[1] and temptable[1].obj:Cast(86213)
		end
	end,
	
	soulswap = function() -- order by highest score first, highest duration second
		local temptable = {}
		if soulswaporigin == nil then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
					temptable[#temptable+1] = {
						obj = Obj,
						duration = Obj:DebuffDuration("Unstable Affliction")
					}
				end
			end
			table.sort( temptable, function(a,b) return ( a.duration > b.duration ) end )
			if #temptable>=2 then
				return temptable[1] and temptable[1].obj:Cast(86121)
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
	affliction.rot.caching()
	affliction.rot.ClickthisPleasepvp()
	if _A.buttondelayfunc()  then return end
	if player:lostcontrol()  then return end 
	if player:isCastingAny() then return end
	if player:Mounted() then return end
	--
	affliction.rot.Buffbuff()
	affliction.rot.petres()
	affliction.rot.petres_supremacy()
	affliction.rot.items_healthstone()
	affliction.rot.summ_healthstone()
	--snapshots
	affliction.rot.activetrinket()
	affliction.rot.hasteburst()
	--utility
	affliction.rot.bloodhorror()
	--exhale
	affliction.rot.exhale()
	--utility
	affliction.rot.lifetap()
	-- affliction.rot.drainsoul()
	affliction.rot.agonysnap()
	affliction.rot.corruptionsnap()
	affliction.rot.unstablesnapinstant()
	affliction.rot.unstablesnap()
	-- shift mode
	affliction.rot.shiftmode_haunt()
	affliction.rot.shiftmode_grasp()
	-- soul swap
	affliction.rot.soulswap()
	--buff
	affliction.rot.darkintent()
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
