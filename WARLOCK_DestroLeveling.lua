local _,class = UnitClass("player")
if class~="WARLOCK" then return end
local HarmonyMedia, _A, Harmony = ...
local DSL = function(api) return _A.DSL:Get(api) end
local Listener = _A.Listener
-- top of the CR
local next = next 
local C_Timer = _A.C_Timer
local player
local lowest
local lowestaoe
local reflectcheck = false
local numbads = 0
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
local warriorspecs = {
	[71]=true,
	[72]=true,
	[73]=true
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
_A.pull_location = pull_location()
local function modifier_shift()
	local modkeyb = _A.IsShiftKeyDown()
	if modkeyb then return true
	end
	return false
end
local function modifier_ctrl()
	local modkeyb = _A.IsControlKeyDown()
	if modkeyb then return true
	end
	return false
end
--============================================
--============================================
--============================================
--============================================
--============================================
_A.casttimers = {} -- doesnt work with channeled spells
local havoctable = {}
Listener:Add("destro_cleaning", {"PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD"}, function(event)
	_A.pull_location = pull_location()
	havoctable = {}
	_A.casttimers = {}
	-- print("location successfully set to ".._A.pull_location)
end)
Listener:Add("Destro_Havoc", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
	if guidsrc == UnitGUID("player") then -- only filter by me
		-- print(subevent.." "..idd)
		if (idd==80240) then
			if subevent == "SPELL_CAST_SUCCESS" or subevent=="SPELL_AURA_APPLIED" then
				-- print("havoc "..subevent)
				havoctable[guiddest]=true
			end
			if subevent=="SPELL_AURA_REMOVED" 
				then
				havoctable[guiddest]=nil
			end
		end
	end
end)
_A.casttbl = {}
Listener:Add("iscasting", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd) -- CAN BREAK WITH INVIS
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
Listener:Add("destrodelaycasts", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd)
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
destro.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.targetless = {}
		_A.target = nil
		_A.BurningEmbers = _A.UnitPower("player", 14)
		numbads = destro.rot.numenemiesaround()
		local target = Object("target")
		if target and target:enemy() and target:spellRange("Conflagrate") and target:Infront() and ((not target:Debuff(80240)) or (numbads==1)) and _A.attackable(target) and _A.notimmune(target)  and target:los() then
			if target then _A.target = target end
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj)  and Obj:los() then
				_A.targetless[#_A.targetless+1] = {
					obj = Obj,
					havoc = ((havoctable[Obj.guid]==nil) or (numbads==1)) and 1 or 0,
					isplayer = Obj.isplayer and 1 or 0,
					-- ishealer = healerspecid[_A.UnitSpec(Obj.guid)] or 0,
					health = Obj:health()
				}
			end
		end
	end,
	
	rainoffire = function()
		if player:Keybind("T") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return _A.CastGround("Rain of Fire", "cursor")
		end
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
	
	numenemiesaround = function()
		local num = 0
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:Infront() and _A.attackable(Obj) and _A.notimmune(Obj) and Obj:los() then
				num = num + 1
			end
		end
		return num
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
	
	twilightward = function()
		if player:SpellCooldown("Twilight Ward")<.3 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Twilight Ward")
		end
	end,
	
	summ_healthstone = function()
		if (player:ItemCount(5512) == 0 and player:ItemCooldown(5512) < 2.55 ) or (player:ItemCount(5512) < 3 and not player:combat()) then
			if not player:moving() and not player:Iscasting("Create Healthstone") and _A.castdelay(6201, 1.5) then
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
	
	items_intpot = function()
		if player:ItemCooldown(76093) == 0
			and player:ItemCount(76093) > 0
			and player:ItemUsable(76093)
			and player:Buff("Dark Soul: Instability")
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
	--============================================
	activetrinket = function()
		if player:buff("Surge of Dominance") and player:combat() then
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
	
	critburst = function()
		if player:combat() and player:SpellCooldown("Dark Soul: Instability")==0 and not player:buff("Dark Soul: Instability") then
			if player:buff("Call of Dominance") then
				player:cast("Lifeblood")
				player:cast("Dark Soul: Instability")
			end
		end
	end,
	--============================================
	--============================================
	--============================================
	
	embertap = function()
		if (_A.BurningEmbers > 2 ) and not player:isCastingAny() then
			if player:health() <= 75 and player:SpellCooldown("Ember Tap")<.3 then
				return player:cast("Ember Tap")
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
				if not player:moving() and not player:iscasting("Summon Imp") and not player:isCastingAny() then
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
			and not player:isCastingAny()
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
	
	
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	incinerate_tar = function()
		if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
			local target = Object("target")
			if target and target:enemy() and target:alive() and target:infront() and target:range()<=40
				-- and (_A.target:health()>20 or  _A.BurningEmbers<1) 
				then
				return target:cast("Incinerate")
			end
		end
	end,
	
	conflagrate_tar = function()
		if player:SpellCooldown("Conflagrate") == 0 then
			local target = Object("target")
			if target and target:enemy() and target:alive() and target:infront() and target:range()<=40
				-- and (_A.target:health()>20 or  _A.BurningEmbers<1) 
				then
				
				return target:cast("Conflagrate")
			end
		end
	end,
	
	facetarget = function()
	local target = Object("target")
	if target and target:enemy() and target:alive() and not target:infront() and target:range()<=40 then
	_A.FaceDirection(target, true) 
	end
	end,
}
---========================
---========================
---========================
---========================
---========================
local inCombat = function()	
	lowestaoe = nil
	player = player or Object("player")
	if not player then return end
	if player:mounted() then return end
	-- if _A.buttondelayfunc()  then return end
	-- if player:isCastingAny() then return end
	-- HEALS AND DEFS
	destro.rot.facetarget()
	destro.rot.summ_healthstone()
	destro.rot.conflagrate_tar()
	destro.rot.incinerate_tar()
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
	name = "Youcef's Destro for Leveling",
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
