local _, class = UnitClass("player");
if class ~= "WARRIOR" then return end;
local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
local hooksecurefunc =_A.hooksecurefunc
-- top of the CR
local player
local arms = {}
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
	-- [265]="Lock Affli",
	-- [266]="Lock Demono",
	-- [267]="Lock Destro",
	[105]="Druid Resto",
	-- [102]="Druid Balance",
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
--
--


local GUI = {
}
local exeOnLoad = function()
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
	--
	hooksecurefunc("UseAction", function(...)
		local slot, target, clickType = ...
		local Type, id, subType, spellID
		-- print(slot)
		local player = Object("player")
		if slot==STARTSLOT then 
			_A.pressedbuttonat = 0
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=true then
				_A.Interface:toggleToggle("mastertoggle", true)
				_A.print("ON")
			end
		end
		if slot==STOPSLOT then 
			-- TEST STUFF
			-- _A.print(string.lower(player.name)==string.lower("PfiZeR"))
			-- TEST STUFF
			-- local target = Object("target")
			-- if target and target:exists() then print(target:creatureType()) end
			if _A.DSL:Get("toggle")(_,"MasterToggle")~=false then
				_A.Interface:toggleToggle("mastertoggle", false)
				_A.print("OFF")
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
	_A.buttondelayfunc = function()
		local player = Object("player")
		if player and player:stance()==1 then
		if _A.GetTime() - _A.pressedbuttonat < _A.buttondelay then return true end end
		return false
	end
	
	function _A.notimmune(unit) -- needs to be object
		if unit then 
			if unit:immune("all") then return false end
		end
		for _,v in ipairs(immunebuffs) do
			if unit:BuffAny(v) then return false end
		end
		for _,v in ipairs(immunedebuffs) do
			if unit:DebuffAny(v) then return false end
		end
		return true
	end
	
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
		if target and target:enemy() and target:spellRange(spell) and target:Infront() and  _A.notimmune(target)  and target:los() then
			return target and target.guid
		end
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
	end)
	
	_A.FakeUnits:Add('lowestEnemyInSpellRangeNOTAR', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('Enemy')) do
			if Obj:spellRange(spell) and  Obj:Infront() and _A.notimmune(Obj)  and Obj:los() then
				tempTable[#tempTable+1] = {
					guid = Obj.guid,
					health = Obj:health(),
					isplayer = Obj.isplayer and 1 or 0
				}
			end
		end
		if #tempTable>1 then
			table.sort( tempTable, function(a,b) return (a.isplayer > b.isplayer) or (a.isplayer == b.isplayer and a.health < b.health) end )
		end
		return tempTable[num] and tempTable[num].guid
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
end
local exeOnUnload = function()
end

arms.rot = {
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
	
	Charge = function()
		if player:SpellCooldown("Charge")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Charge") and obj:infront()
					and obj:caninterrupt() and healerspecid[_A.UnitSpec(obj.guid)]
					and obj:channame()~="mind sear"
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					and obj:los()
					then
					obj:Cast("Charge")
				end
			end
		end
	end,
	
	Pummel = function()
		if player:SpellCooldown("Pummel")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Mortal Strike") and obj:infront()
					and obj:caninterrupt() 
					and obj:channame()~="mind sear"
					and (obj:castsecond() <_A.interrupttreshhold or obj:chanpercent()<=92
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Pummel")
				end
			end
		end
	end,
	
	thunderclap = function()
		if player:SpellCooldown("Thunder Clap")<.3 and player:SpellUsable("thunder clap") then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer and obj:range()<=7 and  not healerspecid[_A.UnitSpec(obj.guid)] and _A.notimmune(obj) and obj:debuffduration("Weakened Blows")<1 and obj:los() then
					return player:cast("thunder clap")
				end
			end
		end
	end,
	
	hamstringpvp = function()
		if player:SpellCooldown("Hamstring")<.3 and player:spellusable("Hamstring") then
			local target = Object("target")
			if target and target.isplayer and target:enemy() 
				and target:debuffduration("Hamstring")<1
				and _A.notimmune(target)
				and not target:buff("Hand of Freedom") then
				return target:cast("Hamstring")
			end
		end
	end,
	
	Disruptingshout = function()
		if player:talent("Disrupting Shout") and player:SpellCooldown("Disrupting Shout")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and  obj:isCastingAny() and obj:range()<=10 then
					if player:SpellCooldown("Pummel")>0 or player:buff("Bladestorm") or (not obj:SpellRange("Mortal Strike")) or (obj:SpellRange("Mortal Strike") and not obj:infront()) then
						if obj:caninterrupt() and healerspecid[_A.UnitSpec(obj.guid)]
							and obj:channame()~="mind sear"
							and (obj:castsecond() < _A.interrupttreshhold or obj:chanpercent()<=92
							)
							and _A.notimmune(obj)
							then
							obj:Cast("Disrupting Shout")
						end
					end
				end
			end
		end
	end,
	
	colossussmash = function()
		if  player:SpellCooldown("Colossus Smash")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee:exists() and lowestmelee:debuffduration("Colossus Smash")<1 then
				return lowestmelee:Cast("Colossus Smash")
			end
		end
	end,
	
	Mortalstrike = function()
		if  player:SpellCooldown("Mortal Strike")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Mortal Strike")
			end
		end
	end,
	
	Execute = function()
		if player:rage()>=30 then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Mortal Strike)")
			if lowestmelee and lowestmelee:exists() and lowestmelee:health()<=20 then
				return lowestmelee:Cast("Execute")
			end
		end
	end,
	
	battleshout = function ()
		if player:SpellCooldown("battle shout")<.3 and player:rage()<=75 then return player:cast("battle shout")
		end
	end,
	
	slam = function()
		if  player:SpellCooldown("Slam")<.3 and player:SpellUsable("Slam") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee:exists() then
				if player:buff(1719) or (player:rage()>80 and player:buffstack(60503)<3) or (lowestmelee:debuff("Colossus Smash") and player:rage()>=40) then
					return lowestmelee:Cast("Slam")
				end
			end
		end
	end,
	
	burstdisarm = function()
		if player:SpellCooldown("Disarm")<.3 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer 
					and obj:SpellRange("Disarm") 
					and obj:Infront()
					and not healerspecid[_A.UnitSpec(obj.guid)] 
					and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest") or obj:BuffAny("Call of Dominance"))
					and not obj:BuffAny("Bladestorm")
					and not obj:LostControl()
					and not obj:state("disarm")
					and not obj:debuffany("Disarm") and not obj:debuffany("Grapple Weapon")
					and (obj:drState("Disarm") == 1 or obj:drState("Disarm")==-1)
					and _A.notimmune(obj)
					and obj:los() then
					return obj:Cast("Disarm")
				end
			end
		end
	end,
	
	
	overpower = function()
		if  player:SpellUsable("Overpower") then
			local lowestmelee = Object("lowestEnemyInSpellRange(Mortal Strike)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Overpower")
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
	_A.latency = (select(3, GetNetStats())) and ((select(3, GetNetStats()))/1000) or 0
	_A.interrupttreshhold = math.max(_A.latency, .1) 
	if _A.buttondelayfunc()  then return end
	if  player:isCastingAny() then return end
	if player:mounted() then return end
	-- if player:lostcontrol()  then return end 
	-- Interrupts
	arms.rot.Charge()
	arms.rot.colossussmash()
	arms.rot.Execute()
	arms.rot.Pummel()
	arms.rot.thunderclap()
	arms.rot.burstdisarm()
	arms.rot.battleshout()
	arms.rot.Disruptingshout()
	arms.rot.hamstringpvp()
	arms.rot.Mortalstrike()
	arms.rot.slam()
	arms.rot.overpower()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(71, {
	name = "Youcef's Arms Warrior",
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
