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
local ijustdidthatthing = false
local ijustdidthatthing2 = false
local ijustdidthatthingtime = 0
local ijustdidthatthingtime2 = 0
--Cleaning
-- _A.Listener:Add("lock_cleantbls", {"PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD"}, function(event)
_A.Listener:Add("lock_cleantbls", "PLAYER_ENTERING_WORLD", function(event) -- better for testing, combat checks breaks with dummies
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
	ijustdidthatthing = false
end)
-- dots
_A.Listener:Add("dotstables", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		if (idd==146739) or (idd==172) then
			if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				-- if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_PERIODIC_DAMAGE" and corruptiontbl[guiddest]==nil) or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				then
				corruptiontbl[guiddest]=_A.myscore()
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				corruptiontbl[guiddest]=nil
			end
		end
		if (idd==980)  then
			if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				-- if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_PERIODIC_DAMAGE" and agonytbl[guiddest]==nil) or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				then
				agonytbl[guiddest]=_A.myscore()
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				agonytbl[guiddest]=nil
			end
		end
		if (idd==30108)  then
			if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				-- if subevent=="SPELL_AURA_APPLIED" or (subevent =="SPELL_CAST_SUCCESS") or (subevent=="SPELL_PERIODIC_DAMAGE" and unstabletbl[guiddest]==nil) or (subevent=="SPELL_AURA_REFRESH" and ijustdidthatthing==false)
				then
				unstabletbl[guiddest]=_A.myscore()
				
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				unstabletbl[guiddest]=nil
			end
		end	
		
	end
	if guiddest == UnitGUID("player") then -- only filter by me
		if (idd==86211)  then
			if subevent=="SPELL_AURA_REMOVED" 
				then
				ijustdidthatthing2 = false
				soulswaporigin=nil 
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
				ijustdidthatthing2 = true
				ijustdidthatthingtime2 = GetTime() -- time at which I used soulswap
				soulswaporigin = guiddest -- remove after 3 seconds or after exhalings
			end
			if idd==86213 then -- exhale
				ijustdidthatthing = true -- when true, means I just used exhale, important so stats stay accurate
				ijustdidthatthingtime = GetTime() -- time at which I used exhale
				unstabletbl[guiddest]=unstabletbl[soulswaporigin]
				agonytbl[guiddest]=agonytbl[soulswaporigin]
				corruptiontbl[guiddest]=corruptiontbl[soulswaporigin]
				-- copy stats from origin to exhale dest
				ijustdidthatthing2 = false
				soulswaporigin = nil -- remove after 3 seconds or after exhaling
				-- print("you just exhaled "..guiddest)
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
		if ijustdidthatthing == true and GetTime()-ijustdidthatthingtime>=.3 then
			-- print("safe to snapshot now")
			ijustdidthatthing=false -- so I wouldn't overwrite stats wrongfully
		end
		if ijustdidthatthing2 == true and GetTime()-ijustdidthatthingtime2>=3 then
			-- print("yes yes yes yes")
			soulswaporigin = nil
			ijustdidthatthing2=false -- so I wouldn't overwrite stats wrongfully
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
local GUI = {
}
local exeOnLoad = function()
end
local exeOnUnload = function()
end
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}

affliction.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.pull_location = pull_location()
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
	--============================================
	--============================================
	--============================================
	
	petres = function()
		if player:SpellCooldown("Raise Dead")<.3 then
			if not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or not _A.HasPetUI()
				then 
				return player:cast("Raise Dead")
			end
		end
	end,
	
	corruptionsnap = function()
		local highestscore, highestscoreGUID = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then
				local score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0)
				if (score == 0 and score >= highestscore) or score > highestscore then
					highestscore = score
					highestscoreGUID = Obj
					if highestscoreGUID and (corruptiontbl[Obj.guid]~=nil and _A.myscore() > corruptiontbl[Obj.guid]) or (corruptiontbl[Obj.guid]==nil) then return highestscoreGUID:cast("Corruption") end
				end
			end
		end
	end,
	
	agonysnap = function()
		local highestscore, highestscoreGUID = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then
				local score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0)
				if (score == 0 and score >= highestscore) or score > highestscore then
					highestscore = score
					highestscoreGUID = Obj
					if highestscoreGUID and (agonytbl[Obj.guid]~=nil and _A.myscore() > agonytbl[Obj.guid]) or (agonytbl[Obj.guid]==nil) then return highestscoreGUID:cast("Agony") end
				end
			end
		end
	end,
	
	unstablesnap = function()
		local highestscore, highestscoreGUID = 0
		if not player:moving() and not player:Iscasting("Unstable Affliction") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then
					local score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0)
					if (score == 0 and score >= highestscore) or score > highestscore then
						highestscore = score
						highestscoreGUID = Obj
						if highestscoreGUID and (unstabletbl[Obj.guid]~=nil and _A.myscore() > unstabletbl[Obj.guid]) or (unstabletbl[Obj.guid]==nil) then return highestscoreGUID:cast("Unstable Affliction") end
					end
				end
			end
		end
	end,
	
	drainsoul = function()
		local lowesthealth, lowesthealthGUID = 99999999999999999
		if player:Soulshards() <=2 and not player:moving() and not player:Iscasting("Drain Soul") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and Obj:infront() and _A.notimmune(Obj) and Obj:los() then
					local health = Obj:HealthActual()
					if  health <= lowesthealth then
						lowesthealth = health
						lowesthealthGUID = Obj
						if lowesthealthGUID and lowesthealthGUID:Health()<=20 and lowesthealthGUID:HealthActual() <=70000 then
							return lowesthealthGUID:cast("Drain Soul")
						end
					end
				end
			end
		end
	end,
	
	exhalenodebuffs = function()
		local highestscore, highestscoreGUID = 9999999
		if soulswaporigin ~= nil  then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then
					if Obj.guid ~= soulswaporigin then
						if (not Obj:Debuff("Agony")) or (not Obj:Debuff("Corruption")) or (not Obj:Debuff("Unstable Affliction")) then
							return Obj:cast(86213)
						end
					end
					end
				end
			end
		end,
	
	exhale = function()
		local highestscore, highestscoreGUID = 9999999
		if soulswaporigin ~= nil  then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then -- order then by lowest duration
					if Obj.guid ~= soulswaporigin then
						local score = (unstabletbl[Obj.guid]==nil and 0 or unstabletbl[Obj.guid]) + (corruptiontbl[Obj.guid]==nil and 0 or corruptiontbl[Obj.guid]) + (agonytbl[Obj.guid]==nil and 0 or agonytbl[Obj.guid])  -- make a function out of this to avoid doubling functions
						if score <= highestscore then
							highestscore = score
							highestscoreGUID = Obj
							if highestscoreGUID then return highestscoreGUID:cast(86213) end
						end
					end
				end
			end
		end
	end,
	
	soulswap = function()
		local highestscore, highestscoreGUID = 0
		if soulswaporigin == nil  then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj:spellRange(172) and _A.notimmune(Obj) and Obj:los() then
					local score = (unstabletbl[Obj.guid] or 0) + (corruptiontbl[Obj.guid] or 0) + (agonytbl[Obj.guid] or 0)
					if (score == 0 and score >= highestscore) or score > highestscore then -- order then by highest duration
						highestscore = score
						highestscoreGUID = Obj
						if highestscoreGUID then 
							if _A.enoughmana(74434) then player:cast(74434) end
						return highestscoreGUID:cast(86121) end
					end
				end
			end
		end
	end,
	
	
	
	Buffbuff = function()
		if player:SpellCooldown("Horn of Winter")<.3 and _A.dkenergy <= 90 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Horn of Winter")
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
	if _A.ceeceed(player)  then return end 
	-- if  player:isCastingAny() then return end
	if player:Mounted() then return end
	-- affliction.rot.unstableaffliction()
	--snapshots
	affliction.rot.drainsoul()
	affliction.rot.agonysnap()
	affliction.rot.corruptionsnap()
	affliction.rot.unstablesnap()
	-- soul swap
	-- soulswaps
	affliction.rot.soulswap()
	affliction.rot.exhalenodebuffs()
	affliction.rot.exhale()
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
