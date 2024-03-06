local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
-- top of the CR
local player
local unholy = {}
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
--
--


local GUI = {
}
local exeOnLoad = function()
end
local exeOnUnload = function()
end
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}

unholy.rot = {
	blank = function()
	end,
	
	caching= function()
		_A.dkenergy = _A.UnitPower("player") or 0
		_A.blood, _A.frost, _A.unholy, _A.death, _A.total = _A.runes()
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
	
	gargoyle = function()
		if (player:Buff("Unholy Frenzy")) 
			and player:SpellCooldown("Summon Gargoyle")<player:Gcd() then
			local lowestmelee = Object("lowestEnemyInSpellRange(Summon Gargoyle)")
			if lowestmelee 
				and lowestmelee:exists() 
				then 
				return lowestmelee:Cast("Summon Gargoyle")
			end
		end
	end,
	
	hasteburst = function()
		if (player:Buff("Unholy Frenzy")) 
			and player:SpellCooldown("Lifeblood")==0
			then 
			player:Cast("Lifeblood", true)
		end
	end,
	
	Empowerruneweapon = function()
		if player:SpellCooldown("Empower Rune Weapon")==0 and (player:Buff("Unholy Frenzy")) and _A.depletedrune()>=3
			then 
			player:Cast("Empower Rune Weapon", true)
		end
	end,
	
	
	MindFreeze = function()
		if player:SpellCooldown("Mind Freeze")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if ( obj.isplayer or _A.pull_location == "party" or _A.pull_location == "raid" ) and obj:isCastingAny() and obj:SpellRange("Death Strike") and obj:infront()
					and obj:caninterrupt() 
					and (obj:castsecond() < 0.4 or obj:chanpercent()<=90
					)
					and _A.notimmune(obj)
					then
					obj:Cast("Mind Freeze", true)
				end
			end
		end
	end,
	
	
	GrabGrab = function()
		if player:SpellCooldown("Death Grip")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if (_A.pull_location ~= "arena") or (_A.pull_location == "arena" and not hunterspecs[_A.UnitSpec(obj.guid)]) then
					if obj.isplayer and obj:isCastingAny() and obj:SpellRange("Death Grip") and obj:infront() 
						and (player:SpellCooldown("Mind Freeze")>player:Gcd() or not obj:caninterrupt() or not obj:SpellRange("Death Strike"))
						and not obj:State("root")
						and _A.notimmune(obj)
						and obj:los() then
						obj:Cast("Death Grip", true)
					end
				end
			end
		end
	end,
	
	GrabGrabHunter = function()
		if _A.pull_location == "arena" then
			local roster = Object("roster")
			if player:SpellCooldown("Death Grip")==0 then
				if roster and roster:DebuffAny("Scatter Shot") then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if 	obj.isplayer and hunterspecs[_A.UnitSpec(obj.guid)] and obj:SpellRange("Death Grip") and obj:infront() 
							and not obj:State("root")
							and _A.notimmune(obj)
							and obj:los() then
							obj:Cast("Death Grip", true)
						end
					end
				end
			end
		end
	end,
	
	strangulate=function()
		if (_A.blood>=1 or _A.death>=1) and player:SpellCooldown("Strangulate")==0 then
			if player:Glyph("Glyph of Strangulate") or _A.someoneislow() then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer and obj:isCastingAny()  and obj:SpellRange("Strangulate") and obj:infront() and _A.isthisahealer(obj) 
						then if ((player:SpellCooldown("Mind Freeze")>player:Gcd() or not obj:SpellRange("Death Strike") or not obj:caninterrupt()) and (player:SpellCooldown("Death Grip")>player:Gcd() or obj:State("root")))
							and _A.someoneislow() -- default : or
							then if not obj:iscasting("Mana tea") and not obj:DebuffAny("Strangulate")
								and _A.notimmune(obj)  and obj:los() then
								obj:Cast("Strangulate", true)
							end
						end
					end
				end
			end
		end
	end,
	
	strangulatesnipe = function()
		if  (_A.blood>=1 or _A.death>=1) and player:SpellCooldown("Strangulate")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer  and _A.isthisahealer(obj)  and obj:SpellRange("Strangulate")  and obj:infront() 
					and not obj:DebuffAny("Strangulate")
					and not obj:State("silence")
					and _A.notimmune(obj)
					and _A.someoneisuperlow()
					and obj:los() then
					obj:Cast("Strangulate", true)
				end
			end
			
		end
	end,
	
	darksimulacrum = function()
		if _A.dkenergy>=20 and player and player:SpellCooldown("Dark Simulacrum")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj.isplayer then
					if darksimulacrumspecsBGS[_A.UnitSpec(obj.guid)] or darksimulacrumspecsARENA[_A.UnitSpec(obj.guid)] 
						then
						if obj:SpellRange("Dark Simulacrum") and obj:infront() and not obj:State("silence") 
							and not obj:lostcontrol()
							and _A.notimmune(obj)
							and obj:los() 
							then
							obj:Cast("Dark Simulacrum", true)
						end
					end
				end
			end
		end
	end,
	
	root = function()
		local target = Object("target")
		if target and player:SpellCooldown("Chains of Ice")
			and target.isplayer
			and not target:spellRange("Death Strike") 
			and target:spellRange("Chains of Ice") 
			and target:infront()
			-- and _A.isthishuman("target")
			and target:exists()
			and target:enemy() 
			and not target:buffany(50435)
			and not target:buffany(1044)
			and not target:buffany(45524)
			and not target:buffany(48707)
			and not target:buffany("Bladestorm")
			and not target:Debuff("Chains of Ice") -- remove this
			and not target:state("root")
			and _A.notimmune(target)
			then if target:los()
				then 
				return target:Cast("Chains of Ice") -- slow/root
			end
		end
	end,
	
	dotsnapshotOutBreak = function()
		if _A.pull_location == "party" or _A.pull_location == "raid" then
			local target = Object("target")
			if player:SpellCooldown("Outbreak")<.3 then 
				if target and target:exists()
					and target:enemy()
					and target:SpellRange("Outbreak")
					and target:infront()
					and _A.notimmune(target)
					then
					if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
						if  target:los() then
							-- print("refreshing dot")
							return target:Cast("Outbreak")
						end
					end
				end
			end
		end
	end,
	
	dotsnapshotPS = function()
		if _A.pull_location == "party" or _A.pull_location == "raid" then
			local target = Object("target")
			if  player:SpellCooldown("Plague Strike")<player:Gcd() then 
				if target and target:exists()
					and target:enemy()
					and target:SpellRange("Plague Strike")
					and target:infront()
					and _A.notimmune(target)
					then
					if _A.enemyguidtab[target.guid]~=nil and _A.myscore()>enemyguidtab[target.guid] then
						if target:los() then
							-- print("refreshing dot")
							return target:Cast("Plague Strike")
						end
					end
				end
			end
		end
	end,
	
	petres = function()
		if player:SpellCooldown("Raise Dead")<player:Gcd() then
			if not _A.UnitExists("pet")
				or _A.UnitIsDeadOrGhost("pet")
				or not _A.HasPetUI()
				then 
				return player:cast("Raise Dead")
			end
		end
	end,
	
	antimagicshell = function()
		if player:SpellCooldown("Anti-Magic Shell")==0  then
			local lowestmelee = Object("lowestEnemyInRangeNOTARNOFACE(30)")
			if lowestmelee and lowestmelee:exists()
				then 
				player:Cast("Anti-Magic Shell", true)
			end
		end
	end,
	
	deathpact = function()
		if player:Talent("Death Pact") then
			if player:SpellCooldown("Death Pact")==0 then
				if player:health()<=50 then
					if  _A.UnitExists("pet")
						and not _A.UnitIsDeadOrGhost("pet")
						and _A.HasPetUI() then
						player:cast("Death Pact")
					end
				end
			end
		end
	end,
	
	Lichborne = function()
		if player:Talent("Lichborne") then
			if player:health()<=40 then
				if player:SpellCooldown("Lichborne")==0 then
					player:cast("Lichborne", true)
				end
			end
		end
	end,
	
	dkuhaoe = function()
		local pestcheck = false
		if _A.blood>=1 or _A.death>=1 then
			if player:Talent("Roiling Blood") then
				for _, Obj in pairs(_A.OM:Get('Enemy')) do
					if Obj:range()<=10 then
						if (Obj:Debuff("Frost Fever") and Obj:Debuff("Blood Plague")) then
							if  _A.notimmune(Obj) then
								pestcheck = true
							end
						end
					end
				end
				if pestcheck == true then
					for _, Obj in pairs(_A.OM:Get('Enemy')) do
						if Obj.isplayer and Obj:range()<10 then
							if (not Obj:Debuff("Frost Fever") and not Obj:Debuff("Blood Plague")) then
								if not _A.notimmune(Obj) then
									return player:Cast("Blood Boil")
								end
							end
						end
					end
				end
				
			end
			if _A.modifier_shift() then
				return player:Cast("Blood Boil")
			end
		end
	end,
	
	outbreak = function()
		if player:SpellCooldown("Outbreak")<player:Gcd() --OUTBREAK
			and _A.enoughmana(77575)
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Outbreak)")
			if lowestmelee then
				if lowestmelee:exists() then
					if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) 
						then 
						return lowestmelee:Cast("Outbreak")  --outbreak
					end
				end
			end
		end
	end,
	
	BonusDeathStrike = function()
		if player:Buff("Dark Succor")
			then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Death Strike")
				end
			end
		end
	end,
	
	dotapplication = function()
		if player:SpellCooldown("Plague Strike")<player:Gcd()
			then 
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if (not lowestmelee:Debuff("Frost Fever") or not lowestmelee:Debuff("Blood Plague")) then
						return lowestmelee:Cast("Plague Strike")
					end
				end
			end
		end
	end,
	
	pettransform = function()
		if player:BuffStack("Shadow Infusion")==5
			and (_A.unholy>=1 or _A.death>=1) -- default just unholy check
			and HasPetUI()
			then player:cast("Dark Transformation") -- pet transform -- NEED DOING
		end
	end,
	
	DeathcoilDump = function()
		if _A.dkenergy >= 85 then
			if player:SpellCooldown("Death Coil")<player:Gcd() then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
				local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
				if lowestmelee then
					if lowestmelee:exists() then
						return lowestmelee:Cast("Death Coil")
					end
				end
			end
		end
	end,
	
	DeathcoilHEAL = function()
		if player:SpellCooldown("Death Coil")<player:Gcd() and player:Buff("Lichborne") then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
			if _A.enoughmana(47541) then
				return player:Cast("Death Coil")
			end
		end
	end,
	
	SoulReaper = function()
		if (_A.death>=1 or _A.unholy>=1)
			then
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Soul Reaper)")
			if lowestmelee then
				if lowestmelee:exists() then
					if lowestmelee:health()<35 then
						return lowestmelee:Cast("Soul Reaper")
					end
				end
			end
		end
	end,
	
	NecroStrike = function()
		if _A.pull_location ~= "party" and _A.pull_location ~= "raid" then
			if  _A.death>=1
				then
				local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
				if lowestmelee then
					if lowestmelee:exists() then
						if lowestmelee.isplayer then
							return lowestmelee:Cast("Necrotic Strike")
							else return lowestmelee:Cast("Scourge Strike")
						end
					end
				end
			end
		end
	end,
	
	icytouch = function()
		if _A.pull_location ~= "party" and _A.pull_location ~= "raid" then
			if (_A.frost>_A.blood and _A.frost>=1) then
				local lowestmelee = Object("lowestEnemyInSpellRange(Icy Touch)")
				if lowestmelee and lowestmelee:exists() then
					return lowestmelee:Cast("Icy Touch")
				end
			end
		end
	end,
	
	bloodboilorphanblood = function()
		if _A.pull_location ~= "party" and _A.pull_location ~= "raid" then
			if ((_A.blood>_A.frost and _A.blood>=1))
				then
				local lowestmelee = Object("lowestEnemyInRangeNOTARNOFACE(9)")
				if lowestmelee then
					if lowestmelee:exists() then
						return player:Cast("Blood Boil")
					end
				end
			end
		end
	end,
	
	festeringstrikePVEnohuman = function()
	if _A.pull_location == "party" or _A.pull_location == "raid" then
		if player:SpellCooldown("Festering Strike")<.3 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if not lowestmelee.isplayer then
						return lowestmelee:Cast("Festering Strike")
					end
				end
			end
		end
		end
	end,
	
	festeringstrike = function()
		if (_A.blood >=1 and _A.frost >=1) then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee 
				and lowestmelee:exists() then
				return lowestmelee:Cast("Festering Strike")
			end
		end
	end,
	
	Deathcoil = function()
		if player:SpellCooldown("Death Coil")<player:Gcd() and (player:buff("Sudden Doom") or _A.dkenergy>=32) then 
			local lowestmelee = Object("lowestEnemyInSpellRangeNOTAR(Death Coil)")
			if lowestmelee and lowestmelee:exists() then
				return lowestmelee:Cast("Death Coil")
			end
		end
	end,
	
	scourgestrike = function()
		if _A.unholy>=1 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Death Strike)")
			if lowestmelee then
				if lowestmelee:exists() then
					if lowestmelee:health()>35
						then
						return lowestmelee:Cast("Scourge Strike")
					end
				end
			end
		end
	end,
	
	Buffbuff = function()
		if player:SpellCooldown("Horn of Winter")<player:Gcd() and _A.dkenergy <= 90 then -- and _A.UnitIsPlayer(lowestmelee.guid)==1
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
	if _A.buttondelayfunc() then return end
	if player:lostcontrol() then return end
	if player:isCastingAny() then return end
	unholy.rot.GrabGrab()
	unholy.rot.GrabGrabHunter()
	if player:Mounted() then return end
	-- utility
	unholy.rot.caching()
	unholy.rot.ClickthisPleasepvp()
	-- Burst and utility
	unholy.rot.items_strpot()
	unholy.rot.items_strflask()
	unholy.rot.hasteburst()
	unholy.rot.items_healthstone()
	unholy.rot.gargoyle()
	unholy.rot.Empowerruneweapon()
	-- PVP INTERRUPTS AND CC
	unholy.rot.MindFreeze()
	-- unholy.rot.strangulate()
	unholy.rot.strangulatesnipe()
	unholy.rot.darksimulacrum()
	unholy.rot.root()
	-- DEFS
	unholy.rot.antimagicshell()
	unholy.rot.petres()
	unholy.rot.deathpact()
	unholy.rot.Lichborne()
	-- rotation
	unholy.rot.DeathcoilDump()
	unholy.rot.dkuhaoe()
	unholy.rot.outbreak()
	unholy.rot.dotapplication()
	unholy.rot.pettransform()
	unholy.rot.BonusDeathStrike()
	unholy.rot.DeathcoilHEAL()
	unholy.rot.SoulReaper()
	----pve part
	unholy.rot.dotsnapshotOutBreak()
	unholy.rot.dotsnapshotPS()
	unholy.rot.festeringstrikePVEnohuman()
	----pvp part
	unholy.rot.NecroStrike()
	unholy.rot.icytouch()
	unholy.rot.bloodboilorphanblood()
	unholy.rot.festeringstrike()
	unholy.rot.Deathcoil()
	----filler
	unholy.rot.scourgestrike()
	unholy.rot.Buffbuff()
	unholy.rot.blank()
end
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(252, {
	name = "UnholyDK",
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
