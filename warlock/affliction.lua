local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
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
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
		if guidsrc == UnitGUID("player") then
			-- print(subevent.." "..idd)
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
end
local exeOnUnload = function()
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
			if Obj:spellRange(172) and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
				-- backup cleaning, for when spell aura remove event doesnt fire for some reason
				if corruptiontbl[Obj.guid]~=nil and not Obj:Debuff("Corruption") then corruptiontbl[Obj.guid]=nil end
				if agonytbl[Obj.guid]~=nil and not Obj:Debuff("Agony") then agonytbl[Obj.guid]=nil end
				if unstabletbl[Obj.guid]~=nil and not Obj:Debuff("Unstable Affliction") then unstabletbl[Obj.guid]=nil end
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
					duration = Obj:DebuffDuration("Unstable Affliction") or Obj:DebuffDuration("Corruption") or Obj:DebuffDuration("Agony") or 0
				}
			end -- end of enemy filter
			if warriorspecs[_A.UnitSpec(Obj.guid)] and Obj:range(1)<5 and Obj:BuffAny("Spell Reflection") and Obj:los() then
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
		if player:health() <= 55 then
			if player:SpellCooldown("Dark Regeneration") == 0
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
		if player:ItemCooldown(76093) == 0
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
		if player:combat() and player:SpellCooldown("Dark Soul: Misery")==0 and not player:buff("Dark Soul: Misery") and _A.enoughmana(113860) then
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
		if player:talent("Grimoire of Supremacy")  and player:SpellCooldown(112866)<.3 and _A.castdelay(112866, 1.5) and not player:iscasting(112866) and _A.enoughmana(112866)  then
			if 
				not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or not _A.HasPetUI()
				then 
				if player:buff(74434) or ( not player:moving() ) then
					return player:cast(112866)
				end
				if (not player:buff(74434) and player:combat() and player:SpellCooldown(74434)==0 and _A.shards>=1 ) --or player:buff("Shadow Trance") 
					then player:cast(74434) -- shadowburn
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
		if _A.reflectcheck == false and player:SpellCooldown("Blood Horror")<.3 and player:health()>10 and not player:buff("Blood Horror") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Blood Horror")
		end
	end,
	
	bloodhorrorremovalopti = function() -- rework this
		if _A.reflectcheck == true then
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
	
	corruptionsnap = function()
		if #_A.temptabletbl>1 then
			table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) -- order by score
				or ( a.score == b.score and a.isplayer > b.isplayer ) -- if same score order by isplayer
				or ( a.score == b.score and a.isplayer == b.isplayer and a.range < b.range ) -- if same score and same isplayer, order by closest
				-- or ( a.score == b.score and a.isplayer == b.isplayer and a.health > b.health ) -- if same score and same isplayer, order by highest health
			end )
		end
		if _A.temptabletbl[1] and _A.enoughmana(172)  then 
			if _A.myscore()>_A.temptabletbl[1].corruptionscore then return _A.temptabletbl[1].obj:Cast("Corruption")
			end
		end
	end,
	
	agonysnap = function()
		if #_A.temptabletbl>1 then
			table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) -- order by score
				or ( a.score == b.score and a.isplayer > b.isplayer ) -- if same score order by isplayer
				or ( a.score == b.score and a.isplayer == b.isplayer and a.range < b.range ) -- if same score and same isplayer, order by closest
				-- or ( a.score == b.score and a.isplayer == b.isplayer and a.health > b.health ) -- if same score and same isplayer, order by highest health
			end )
		end
		if _A.temptabletbl[1] and _A.myscore()>_A.temptabletbl[1].agonyscore and _A.enoughmana(980) 
			then return _A.temptabletbl[1].obj:Cast("Agony")
		end
	end,
	
	unstablesnapinstant = function()
		if #_A.temptabletbl>1 then
			table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) -- order by score
				or ( a.score == b.score and a.isplayer > b.isplayer ) -- if same score order by isplayer
				or ( a.score == b.score and a.isplayer == b.isplayer and a.range < b.range ) -- if same score and same isplayer, order by closest
				-- or ( a.score == b.score and a.isplayer == b.isplayer and a.health > b.health ) -- if same score and same isplayer, order by highest health
			end )
		end
		if _A.temptabletbl[1] and  _A.myscore()> _A.temptabletbl[1].unstablescore and player:SpellCooldown("Unstable Affliction")<.3 then 
			if player:buff(74434) then
				return _A.temptabletbl[1].obj:Cast(119678)
			end
			if  _A.shards>=1 and not player:buff(74434) and player:SpellCooldown(74434)==0 --or player:buff("Shadow Trance")
				then player:cast(74434) -- shadowburn
			end
		end -- improved soul swap (dots instead)
	end,
	
	unstablesnap = function()
		if #_A.temptabletbl>1 then
			table.sort( _A.temptabletbl, function(a,b) return ( a.score > b.score ) -- order by score
				or ( a.score == b.score and a.isplayer > b.isplayer ) -- if same score order by isplayer
				or ( a.score == b.score and a.isplayer == b.isplayer and a.range < b.range ) -- if same score and same isplayer, order by closest
				-- or ( a.score == b.score and a.isplayer == b.isplayer and a.health > b.health ) -- if same score and same isplayer, order by highest health
			end )
		end
		if _A.temptabletbl[1] and not player:buff(74434) and _A.myscore()>_A.temptabletbl[1].unstablescore  then 
			if not player:moving() and not player:Iscasting("Unstable Affliction") then
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
		if not player:isCastingAny() and not player:Ischanneling("Malefic Grasp")  and not player:moving() and _A.enoughmana(103103)  then
			local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
			if lowest and lowest:exists() and lowest:health()>20 then
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
			and not player:Ischanneling("Drain Soul") 
			and _A.enoughmana(1120)
			then
			local lowest = Object("lowestEnemyInSpellRangeNOTAR(Corruption)")
			if lowest and lowest:exists() and lowest:health()<=20 then
				return lowest:cast("Drain Soul", true)
			end
		end
	end,
	
	soulswapopti = function()
		if  #_A.temptabletbl>1 and soulswaporigin == nil and _A.enoughmana(86121) then
			if #_A.temptabletblsoulswap > 1 then
				table.sort( _A.temptabletblsoulswap, function(a,b) return ( a.duration > b.duration ) end ) -- highest duration is always the best solution for soulswap
			end
			return _A.temptabletblsoulswap[1] and _A.temptabletblsoulswap[1].obj:Cast(86121)
		end
	end,
	
	exhaleopti = function()
		if soulswaporigin ~= nil then
			if #_A.temptabletblexhale > 1 then
				table.sort(_A.temptabletblexhale, function(a,b) return  (a.duration < b.duration )  -- order by duration
					or (a.duration == b.duration and a.isplayer > b.isplayer ) -- if same (or no) duration, order by players first
					-- or (a.duration == b.duration and a.isplayer == b.isplayer and a.rangedis < b.rangedis )  -- if same (or no) duration, and same isplayer, order by closest
					or (a.duration == b.duration and a.isplayer == b.isplayer and a.health > b.health )  -- if same (or no) duration, and same isplayer, order by highest health
				end
				)
			end
			return _A.temptabletblexhale[1] and _A.temptabletblexhale[1].obj:Cast(86213)
		end
	end,
	
	items_intflask = function()
		if player:ItemCooldown(76085) == 0  
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
	player = player or Object("player")
	if not player then return end
	affliction.rot.caching()
	if player:Mounted() then return end
	if _A.buttondelayfunc()  then return end
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
	if affliction.rot.petres_supremacy() then return end
	if affliction.rot.summ_healthstone() then return end
	--bursts
	affliction.rot.activetrinket()
	affliction.rot.hasteburst()
	--HEALS
	affliction.rot.Darkregeneration()
	affliction.rot.items_healthstone()
	if affliction.rot.CauterizeMaster()  then return end
	if affliction.rot.MortalCoil()  then return end
	if affliction.rot.twilightward()  then return end
	--utility
	if affliction.rot.bloodhorrorremovalopti()  then return end
	if affliction.rot.bloodhorror()  then return end
	if affliction.rot.snare_curse()  then return end
	-- shift
	if modifier_shift()==true then
		if affliction.rot.haunt()  then return end
		if affliction.rot.drainsoul() then return end
		if affliction.rot.grasp()  then return end
		if affliction.rot.felflame()  then return end
	end
	-- DOT DOT
	if affliction.rot.agonysnap()  then return end
	if affliction.rot.corruptionsnap()  then return end
	-- if affliction.rot.sneedofcorruption()  then return end
	if affliction.rot.unstablesnapinstant()  then return end
	if affliction.rot.unstablesnap()  then return end
	-- SOUL SWAP
	if affliction.rot.soulswapopti()  then return end
	--buff
	affliction.rot.darkintent()
	--fills
	if affliction.rot.lifetap()  then return end
	if affliction.rot.drainsoul() then return end
	if affliction.rot.haunt()  then return end
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