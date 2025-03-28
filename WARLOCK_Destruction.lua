local _,class = UnitClass("player")
if class~="WARLOCK" then return end
local media, _A, _Y = ...
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

local havoctable = {}
--============================================
local GUI = {
}
local exeOnLoad = function()
	_A.casttimers = {} -- doesnt work with channeled spells
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
	_A.FakeUnits:Add('mostgroupedenemyDESTRO', function(num, radius_min)
		local radius, min = _A.StrExplode(radius_min)
		min = tonumber(min) or 3
		local radius = Radius and (tonumber(Radius) + 1.5) or 10
		local range = Range or 40
		local most, mostGuid = 0, nil
		local radiusSq = radius * radius
		-- Phase 1: Directly collect into arrays (no temp table)
		local guids, x, y = {}, {}, {}
		local count = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:range() < range
				and Obj:InConeOf(player, 170) and _A.notimmune(Obj) and Obj:los() then
				local X, Y = _A.ObjectPosition(Obj.guid)
				guids[#guids + 1] = Obj.guid
				x[#x + 1] = X
				y[#y + 1] = Y
				count[Obj.guid] = 1
			end
		end
		local numEntries = #guids
		-- Phase 2: Spatial grid with cell size = radius
		local grid = {}
		for i = 1, numEntries do
			local cx = math.floor(x[i] / radius)
			local cy = math.floor(y[i] / radius)
			grid[cx] = grid[cx] or {}
			grid[cx][cy] = grid[cx][cy] or {}
			table.insert(grid[cx][cy], i)
		end
		-- Phase 3: Optimized neighbor checking with early exits
		for i = 1, numEntries do
			local xi, yi = x[i], y[i]
			local cx, cy = math.floor(xi / radius), math.floor(yi / radius)
			local guid_i = guids[i]
			
			-- Check 3x3 grid cells around current position
			for dx = -1, 1 do
				local cell_x = grid[cx + dx]
				if cell_x then
					for dy = -1, 1 do
						local cell = cell_x[cy + dy]
						if cell then
							for _, j in ipairs(cell) do
								-- Ensure j > i to avoid duplicate checks
								if j > i then
									local dx_val = x[j] - xi
									if abs(dx_val) <= radius then
										local dy_val = y[j] - yi
										if abs(dy_val) <= radius then
											if (dx_val*dx_val + dy_val*dy_val) <= radiusSq then
												count[guid_i] = count[guid_i] + 1
												count[guids[j]] = count[guids[j]] + 1
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		-- Phase 4: Find maximum cluster
		for guid, num in pairs(count) do
			if num > most then
				most, mostGuid = num, guid
			end
		end
		return most and most>=min and mostGuid
	end)
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
		if htotem and (_A.pull_location=="arena" or (toggle("pet_attacktotem") and htotem:range()<=60)) then
			if _A.PetGUID and (not _A.UnitTarget(_A.PetGUID) or _A.UnitTarget(_A.PetGUID)~=htotem.guid) then
				return _A.CallWowApi("PetAttack", htotem.guid), 1
			end
			return 1
		end
	end
	_A.FakeUnits:Add('lowestEnemyInSpellRangePetPOVKCNOLOS', function(num)
		local tempTable = {}
		local target = Object("target")
		local pet = Object("pet")
		if not pet then return end
		if pet and not pet:alive() then return end
		if pet:stateYOUCEF("incapacitate || fear || disorient || charm || misc || sleep || stun") then return end
		--
		local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Conflagrate)")
		if lowestmelee then
			return lowestmelee.guid
		end
		return nil
	end)
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
	local function petfollow() -- when pet target has a breakable cc
		if _A.PetGUID and _A.UnitTarget(_A.PetGUID)~=nil then
			local target = Object(_A.UnitTarget(_A.PetGUID))
			if target and target:alive() and target:enemy() and target:exists() and target:stateYOUCEF("incapacitate || disorient || charm || misc || sleep ||fear") then
				return _A.CallWowApi("RunMacroText", "/petfollow"), 4
			end
		end
	end
	function _Y.petengine() -- REQUIRES RELOAD WHEN SWITCHING SPECS
		if not _A.Cache.Utils.PlayerInGame then return end
		if not player then return true end
		if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then return true end
		-- if player:mounted() then return end
		-- if UnitInVehicle(player.guid) and UnitInVehicle(player.guid)==1 then return end
		if not _A.UnitExists("pet") or _A.UnitIsDeadOrGhost("pet") or not _A.HasPetUI() then if _A.PetGUID then _A.PetGUID = nil end return true end
		_A.PetGUID = _A.PetGUID or _A.UnitGUID("pet")
		if _A.PetGUID == nil then return end
		-- Pet Rotation
		if attacklowest() then return end
		if petfollow() then return end
	end
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
			if player:SpellCooldown("Dark Regeneration") == 0 and not IsCurrentSpell(108359)
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
				if _A.enoughmana(6201) then
					player:cast("Create Healthstone")
				end
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
		if player:combat() and player:SpellCooldown("Dark Soul: Instability")==0 and not player:buff("Dark Soul: Instability") and not IsCurrentSpell(113858) then
			if player:buff("Call of Dominance") then
				player:cast("Lifeblood")
				player:cast("Dark Soul: Instability")
			end
		end
	end,
	--============================================
	--============================================
	--============================================
	MortalCoil = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return 
				( a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if _A.targetless[1] then
			if player:health() <= 85 then
				if player:Talent("Mortal Coil") and player:SpellCooldown("Mortal Coil")<.3  and not player:isCastingAny() then
					return _A.targetless[1].obj:cast("Mortal Coil")
				end
			end
		end
	end,
	
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
	--AOE REWORK
	brimstone = function()
		if _A.BurningEmbers>=2 and lowestaoe  then
			if not player:buff("Fire and Brimstone") and not IsCurrentSpell(108683) then
				return player:cast("Fire and Brimstone")
			end
			else
			if player:buff("Fire and Brimstone") then
				return _A.RunMacroText("/cancelaura Fire and Brimstone")
			end
		end
	end,
	
	immolateaoe = function()
		if player:buff("Fire and Brimstone") and not player:isCastingAny() then
			if not player:moving() and not player:Iscasting("Immolate") then
				if lowestaoe and lowestaoe:exists() then
					if lowestaoe:debuffrefreshable("Immolate") then
						return lowestaoe:cast("Immolate")
					end
				end
			end
		end
	end,
	
	bloodhorror = function()
		if reflectcheck==false and player:SpellCooldown("Blood Horror")<.3 and player:health()>10 and not player:buff("Blood Horror") and not player:isCastingAny() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			return player:Cast("Blood Horror")
		end
	end,
	
	bloodhorrorremoval = function() -- rework this
		reflectcheck = false
		if player:buff("Blood Horror") then
			for _, Obj in pairs(_A.OM:Get('Enemy')) do
				if Obj.isplayer and warriorspecs[_A.UnitSpec(Obj.guid)] and (UnitTarget(Obj.guid)==player.guid) and (Obj:range(1)<16) and Obj:BuffAny("Spell Reflection") and Obj:los() then
					reflectcheck = true
				end
			end
			if reflectcheck == true then
				-- print("removing")
				_A.RunMacroText("/cancelaura Blood Horror")
			end
		end
	end,
	
	incinerateaoe = function()
		if player:buff("Fire and Brimstone") then
			if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
				if lowestaoe then
					return lowestaoe:cast("Incinerate")
				end
			end
		end
	end,
	
	conflagrateaoe = function()
		if player:buff("Fire and Brimstone") then
			if player:SpellCharges("Conflagrate") >= 1 then
				if lowestaoe then
					return lowestaoe:cast("Conflagrate")
				end
			end
		end
	end,
	--======================================
	--======================================
	--======================================
	immolate = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
				or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
				or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if _A.targetless[1] then
			if not player:moving() and not player:Iscasting("Immolate") and not player:isCastingAny() then
				return _A.targetless[1].obj:cast("Immolate")
			end
		end
	end,
	
	havoc = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
				or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
				or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if _A.targetless[1] and not player:isCastingAny() then
			if player:SpellCooldown("Havoc")<=.3 and numbads>=2 then
				return _A.targetless[1].obj:cast("Havoc")
			end
		end
	end,
	
	conflagrate = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
				or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
				or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if _A.targetless[1] and not player:isCastingAny() and not IsCurrentSpell(17962) then
			if player:SpellCooldown("Conflagrate") == 0 or player:spellcount("Conflagrate")>=1 then
				return _A.targetless[1].obj:cast("Conflagrate")
			end
		end
	end,
	
	
	shadowburn = function()
		if _A.BurningEmbers >= 1
			then
			if #_A.targetless>1 then
				table.sort( _A.targetless, function(a,b) return  -- order by havoc check
					( a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
					or (a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
				end )
			end
			if _A.targetless[1] and _A.targetless[1].health<=20 then
				if not player:isCastingAny() then
					-- player:cast("Dark Soul: Instability")
					return _A.targetless[1].obj:cast("Shadowburn", true)
				end
				if player:isCastingAny() then
					print("stop casting")	
					_A.CallWowApi("SpellStopCasting")
				end
			end
		end
	end,
	
	chaosbolt = function()
		if 
			-- _A.BurningEmbers >= 3 or 
			-- (_A.BurningEmbers >= 1 and player:Buff("Dark Soul: Instability")) or
			(_A.BurningEmbers >= 1 and modifier_ctrl())
			then
			if #_A.targetless>1 then
				table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
					or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
					or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
				end )
			end
			if _A.targetless[1] and _A.targetless[1].health>20 then
				if not player:moving() and not player:Iscasting("Chaos Bolt") and not player:isCastingAny()   then
					return _A.targetless[1].obj:cast("Chaos Bolt")
				end
			end
		end
	end,
	
	incinerate = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
				or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
				or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if _A.targetless[1] and (_A.targetless[1].health>20 or _A.BurningEmbers<1) and not player:isCastingAny()  then
			if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
				return _A.targetless[1].obj:cast("Incinerate")
			end
		end
	end,
	
	felflame = function()
		if #_A.targetless>1 then
			table.sort( _A.targetless, function(a,b) return ( a.havoc > b.havoc ) -- order by havoc check
				or ( a.havoc == b.havoc and a.isplayer > b.isplayer ) -- if same havoc status order by isplayer
				or ( a.havoc == b.havoc and a.isplayer == b.isplayer and a.health < b.health ) -- if same score and same isplayer, order by health
			end )
		end
		if player:moving() and not player:isCastingAny() then
			if _A.targetless[1] then
				return _A.targetless[1].obj:cast("fel flame")
			end
		end
	end,
	
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	--==================================================================================
	incinerate_tar = function()
		if (not player:moving() or player:buff("Backlash") or player:talent("Kil'jaeden's Cunning")) and not player:Iscasting("Incinerate") then
			if _A.target and (_A.target:health()>20 or _A.BurningEmbers<1)  then
				return _A.target:cast("Incinerate")
			end
		end
	end,
	
	conflagrate_tar = function()
		if _A.target and (_A.target:health()>20 or  _A.BurningEmbers<1) and not IsCurrentSpell(17962)  then
			if player:SpellCooldown("Conflagrate") == 0 then
				return _A.target:cast("Conflagrate")
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
	destro.rot.rainoffire() 
	if player:mounted() then return end
	-- if _A.buttondelayfunc()  then return end
	-- if player:isCastingAny() then return end
	destro.rot.Buffbuff()
	destro.rot.petres()
	-- HEALS AND DEFS
	destro.rot.summ_healthstone()
	destro.rot.items_intpot()
	destro.rot.Darkregeneration() -- And Dark Regen
	destro.rot.twilightward() -- And Dark Regen
	destro.rot.items_healthstone() -- And Dark Regen
	destro.rot.MortalCoil() -- And Dark Regen
	destro.rot.embertap() -- And Dark Regen
	--buff
	destro.rot.activetrinket()
	destro.rot.critburst()
	destro.rot.shadowburn()
	--utility
	destro.rot.lifetap()
	destro.rot.bloodhorrorremoval()
	destro.rot.bloodhorror()
	--rotation
	--AOE
	lowestaoe = Object("mostgroupedenemyDESTRO(10, 3)")
	destro.rot.brimstone()
	destro.rot.incinerateaoe()
	
	-- destro.rot.immolate()
	destro.rot.havoc()
	destro.rot.chaosbolt()
	-- if _A.pull_location ~="pvp" then
	-- destro.rot.conflagrate_tar()
	-- destro.rot.incinerate_tar()
	-- end
	destro.rot.conflagrate()
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
