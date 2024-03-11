local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
local player
local function blank()
end
local function runthese(...)
	local runtable = {...}
	return function()
		for i=1, #runtable do
			if runtable[i]() then
				break
			end
		end
	end
end
local function pull_location()
	return string.lower(select(2, GetInstanceInfo()))
end
--
--
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
local GUI = {
}
local exeOnLoad = function()
end
local exeOnUnload = function()
end
local heFLAGS = {["Horde Flag"] = true, ["Alliance Flag"] = true, ["Alliance Mine Cart"] = true, ["Horde Mine Cart"] = true, ["Huge Seaforium Bombs"] = true,}
local mw_rot = {
	ClickthisPleasepvp = function()
		local tempTable = {}
		if pull_location()=="pvp" then
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
	
	items_intflask = function()
		if player:ItemCooldown(76085) == 0
			and player:ItemCount(76085) > 0
			and player:ItemUsable(76085)
			and not player:Buff(105691)
			then
			if pull_location()=="pvp" then
				player:useitem("Flask of the Warm Sun")
			end
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
			and (not player:BuffAny(16591) or not player:BuffAny(16595))
			then
			if pull_location()=="pvp" then
				player:useitem("Noggenfogger Elixir")
			end
		end
	end,
	
	kick_legsweep = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:enemy()
						and obj:range()<4
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Leg Sweep")
					end 
				end
			end
		end
	end,
	
	arena_legsweep = function()
		local arenatar = 0
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if pull_location()=="arena" then
				if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3 then
					for _, obj in pairs(_A.OM:Get('Enemy')) do
						if 	obj.isplayer and obj:range()<4
							and _A.notimmune(obj)
							and obj:los() then
							arenatar = arenatar + 1
						end 
					end
					if arenatar >= 2 then
						return obj:Cast("Leg Sweep")
					end
				end
			end
		end
	end,
	
	statbuff = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			local roster = Object("roster")
			-- BUFFS
			if roster then
				if not roster:enemy()
					and not roster:charmed()
					and roster:alive()
					and roster:exists()
					and roster.isplayer
					then 
					if not roster:BuffAny("Legacy of the Emperor")
						and roster:SpellRange("Legacy of the Emperor")
						then 
						if roster:los() then
							return roster:Cast("Legacy of the Emperor")
						end
					end
				end
			end
		end
	end,
	
	statbuff_noarena = function()
		--if not player:LostControl() then
		if player:Stance() == 1 and pull_location()~="arena" then
			local roster = Object("roster")
			-- BUFFS
			if roster then
				if not roster:enemy()
					and not roster:charmed()
					and roster:alive()
					and roster:exists()
					and roster.isplayer
					then 
					if not roster:BuffAny("Legacy of the Emperor")
						and roster:SpellRange("Legacy of the Emperor")
						then 
						if roster:los() then
							return roster:Cast("Legacy of the Emperor")
						end
					end
				end
			end
		end
	end,
	
	kick_legsweep = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:range()<5
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Leg Sweep")
					end 
				end
			end
		end
	end,
	
	kick_chargingox = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Charging Ox Wave") and player:SpellCooldown("Charging Ox Wave")<0.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj:isCastingAny()
						and obj:range()<30
						and obj:Infront()
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Charging Ox Wave")
					end 
				end
			end
		end
	end,
	
	kick_paralysis = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:SpellCooldown("Paralysis")<.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer 
						and obj:isCastingAny()
						and obj:SpellRange("Paralysis") 
						and obj:Infront()
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Paralysis")
					end
				end
			end
		end
	end,
	
	burstdisarm = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:SpellCooldown("Grapple Weapon")<.3 then
				for _, obj in pairs(_A.OM:Get('Enemy')) do
					if obj.isplayer 
						and obj:SpellRange("Grapple Weapon") 
						and obj:Infront()
						and not healerspecid[_A.UnitSpec(obj.guid)] 
						and (obj:BuffAny("Call of Victory") or obj:BuffAny("Call of Conquest"))
						and not obj:BuffAny("Bladestorm")
						and not obj:LostControl()
						and not obj:state("disarm")
						and (obj:drState("Grapple Weapon") == 1 or obj:drState("Grapple Weapon")==-1)
						and _A.notimmune(obj)
						and obj:los() then
						return obj:Cast("Grapple Weapon")
					end
				end
			end
		end
	end,
	
	kick_spear = function()
		--if not player:LostControl() then
		if player:SpellCooldown("Spear Hand Strik")==0 then
			for _, obj in pairs(_A.OM:Get('Enemy')) do
				if obj:isCastingAny()
					and obj:SpellRange("Blackout Kick") 
					and obj:infront()
					and not obj:State("silence")	
					and obj:caninterrupt() 
					and not obj:LostControl()
					and obj:castsecond() < 0.3 or obj:chanpercent()<=95
					and _A.notimmune(obj)
					then
					obj:Cast("Spear Hand Strike", true)
				end
			end
		end
	end,
	
	pvp_disable = function()
		local target = Object("target")
		if not _A.modifier_shift() then
			if player:Stance() == 1 --and pull_location()=="arena" 
				then
				if target then
					if target:exists() then
						if target:enemy()
							and _A.UnitIsPlayer(target.guid)
							and target:SpellRange("Blackout Kick") 
							and target:Infront()
							and not target:BuffAny("Bladestorm")
							and not target:BuffAny("Divine Shield")
							and not target:BuffAny("Die by the Sword")
							and not target:BuffAny("Hand of Protection")
							and not target:BuffAny("Hand of Freedom")
							and not target:BuffAny("Deterrence")
							and target:DebuffDuration("Disable")<1 
							and ( target:DebuffDuration("Disable")>0 or not target:DebuffAny("disable") )
							and _A.notimmune(target)
							and target:los() then
							return target:Cast("Disable")
						end
					end
				end
			end
		end
	end,
	
	ringofpeace = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace")<0.3 then
				local peacetarget = Object("mostTargetedRosterPVP")
				if peacetarget then
					if not peacetarget:enemy()
						and not peacetarget:charmed()
						and peacetarget:alive()
						and peacetarget:exists() then
						if peacetarget:SpellRange("Ring of Peace") and peacetarget:Health()<=85 and not peacetarget:BuffAny("Ring of Peace") then
							if ( peacetarget:areaEnemies(6) >= 3 ) or ( peacetarget:areaEnemies(6) >= 1 and peacetarget:Health()<85 ) then
								if peacetarget:los() then
									return peacetarget:Cast("Ring of Peace")
								end
							end
						end
					end
				end
			end
		end
	end,
	
	chi_wave = function()
		if player:Talent("Chi Wave")
			and player:SpellCooldown("Chi Wave")<.3 then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then
					if  lowest:exists()
						and lowest:alive()					
						and not lowest:charmed()
						and not lowest:DebuffAny("Parasitic Growth")
						and not lowest:DebuffAny("Dissonance Field")
						then 
						if 
							lowest:SpellRange("Chi Wave")
							then 
							if lowest:los() then
								return lowest:Cast("Chi Wave")
							end
						end
					end
				end
			end
		end
	end,
	
	manatea = function()
		if player:Stance() == 1 then
			if player:SpellCooldown("Mana Tea")<.3
				and player:Glyph("Glyph of Mana Tea")
				and _A.powerpercent()<= 92
				and player:BuffStack("Mana Tea")>=2
				then
				return player:Cast("Mana Tea")
			end
		end
	end,
	
	chibrew = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			
			if player:Talent("Chi Brew")
				and player:SpellCooldown("Chi Brew")==0
				and player:Chi()<=2
				then
				player:Cast("Chi Brew")
			end
		end
	end,
	
	fortifyingbrew = function()
		if player:Stance() == 1 then
			if	player:SpellCooldown("Fortifying Brew")==0
				and player:Health()<50
				then
				player:Cast("Fortifying Brew")
			end
		end
	end,
	
	thunderfocustea = function()
		if player:Stance() == 1 and player:Chi()>=1 then
			if	player:SpellCooldown("Thunder Focus Tea")==0
				and _A.enoughmana(116680)
				then
				player:Cast("Thunder Focus Tea", true)
			end
		end
	end,
	
	tigerslust = function()
		if player:SpellCooldown("Tiger's Lust")<.3 then
			--if not player:LostControl() then
			if player:Stance() == 1 and player:Talent("Tiger's Lust") then
				local lowest = Object("lowestall")
				if lowest then
					if lowest:SpellRange("Tiger's Lust") then
						if not lowest:charmed()
							and lowest:alive()
							and lowest:exists()
							then 
							if (not lowest:LostControl()) and (lowest:State("root") or lowest:State("snare")) then
								if lowest:los() --and _A.UnitCanCooperate("player",lowest.guid) 
									then
									return lowest:Cast("Tiger's Lust")
								end	
							end
						end
					end
				end
			end	
		end
	end,
	
	dispellplzarena = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox")<.3 and _A.enoughmana("Detox")then
				local lowest = Object("dispellunit")
				if lowest then
					if 
						lowest:alive()
						and lowest:exists()
						then 
						if lowest:SpellRange("Detox") then
							if lowest:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence") or lowest:LostControl() or
								lowest:DebuffAny("Entangling Roots") or  lowest:DebuffAny("Freezing Trap")
								then
								return lowest:Cast("Detox")
							end
						end
					end	
				end
			end
		end
	end,
	
	dispellplz = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:SpellCooldown("Detox")<.3 and _A.enoughmana("Detox")then
				local lowest = Object("dispellunit")
				if lowest then
					if 
						lowest:alive()
						and lowest:exists()
						then 
						-- DETOX
						--
						if lowest:SpellRange("Detox") then
							if lowest:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence") or lowest:LostControl() or
								lowest:DebuffAny("Entangling Roots") or  lowest:DebuffAny("Freezing Trap")  or (pull_location()~="pvp")
								then
								return lowest:Cast("Detox")
							end
						end
					end	
				end
			end
		end
	end,
	-- end
	-- end
	
	-- for j=1,40 do
	-- if (
	-- (select(5,UnitDebuff(k,j)))=="Magic"  -- mostly saps traps and fears
	-- or (select(5,UnitDebuff(k,j)))=="Poison" -- spam, mostly useless
	-- or (select(5,UnitDebuff(k,j)))=="Disease" -- spam, mostly useless
	-- )
	
	lifecocoon = function()
		if player:SpellCooldown("Life Cocoon")<.3 and _A.enoughmana(116849) then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then 
					if not lowest:enemy()
						and not lowest:charmed()
						and lowest:alive()
						and lowest:exists()
						and not lowest:DebuffAny("Parasitic Growth")
						and not lowest:DebuffAny("Dissonance Field")
						then				
						--]]
						if 
							(lowest:health()<30 or (pull_location()=="pvp" and lowest:health()<40))
							and lowest:SpellRange("Life Cocoon")
							then
							if lowest:los() then
								return lowest:Cast("Life Cocoon")
							end
						end
					end
				end
			end
		end
	end,
	
	surgingmist = function()
		if player:BuffStack("Vital Mists")>=5
			and player:Chi() < player:ChiMax() then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then 
					if not lowest:enemy()
						and not lowest:charmed()
						and lowest:alive()
						and lowest:exists()
						and not lowest:DebuffAny("Parasitic Growth")
						and not lowest:DebuffAny("Dissonance Field")
						then				
						--]]
						
						if  
							lowest:Health()<=85
							and lowest:SpellRange("Surging Mist")
							then
							if lowest:los() then
								return lowest:Cast("Surging Mist")
							end
						end
					end
				end
			end
		end
	end,
	
	renewingmist = function()
		if player:SpellCooldown("Renewing Mist")<.3 and _A.enoughmana(115151) then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then 
					if not lowest:enemy()
						and not lowest:charmed()
						and lowest:alive()
						and lowest:exists()
						and not lowest:DebuffAny("Parasitic Growth")
						and not lowest:DebuffAny("Dissonance Field")
						then
						if 
							lowest:SpellRange("Renewing Mist")
							
							then
							if lowest:los() then
								return lowest:Cast("Renewing Mist")
							end
						end
					end
				end
			end
		end
	end,
	
	healstatue = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			
			if	player:SpellCooldown("Summon Jade Serpent Statue")<.3
				then
				return player:CastGround("Summon Jade Serpent Statue")
			end
		end
	end,
	
	healingsphere_shift = function()
		if player:SpellCooldown("Healing Sphere")<.3 then
			if player:Stance() == 1 then
				if _A.modifier_shift() then
					if _A.enoughmana(115460) then
						local lowest = Object("lowestall")
						if lowest then
							if not lowest:enemy() and not lowest:DebuffAny("Parasitic Growth") and not lowest:DebuffAny("Dissonance Field") then
								if (lowest:Health() < 99) then
									if lowest:exists() then
										if lowest:Distance() < 40 then
											if lowest:los() then
												return lowest:CastGround("Healing Sphere", true)
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
	end,
	
	healingsphere = function()
		--if not player:LostControl() then
		if player:SpellCooldown("Healing Sphere")<.3 then
			if player:Stance() == 1 then
				if _A.enoughmana(115460) then
					if _A.manaengine()==true or _A.modifier_shift() then
						--- ORBS
						local lowest = Object("lowestall")
						if lowest then
							if lowest:exists() then
								if lowest:alive() then
									if not lowest:enemy() and not lowest:DebuffAny("Parasitic Growth") and not lowest:DebuffAny("Dissonance Field") then
										if (lowest:Health() < 85) then
											if lowest:Distance() < 40 then
												if lowest:los() then
													return lowest:CastGround("Healing Sphere")
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
		end
	end,
	
	blackout_mm = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Chi()>=2 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							---------------------------------- 
							return lowestmelee:Cast("Blackout Kick")
						end
					end
					--------------------------------- damage based
				end
			end
		end
	end,
	
	tigerpalm_mm = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Chi()>=1 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							---------------------------------- 
							return lowestmelee:Cast("Tiger Palm")
						end
					end
					--------------------------------- damage based
				end
			end
		end
	end,
	
	bk_buff = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 2
					and not player:Buff("Serpent's Zeal") -- and player:Buff("Muscle Memory") 
					then
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							
							return lowestmelee:Cast("Blackout Kick")
						end
					end
				end
			end
		end
	end,
	
	tp_buff = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm")
						end
					end
				end
			end
		end
	end,
	
	uplift = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if	player:SpellUsable("Uplift")
				and player:Chi()>= 2 
				then
				return player:Cast("Uplift")
			end
		end
	end,
	
	expelharm = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if	player:Chi()<player:ChiMax()
				and player:SpellCooldown("Expel Harm")<.3
				and _A.enoughmana(115072)
				then
				return player:Cast("Expel Harm")
			end
		end
	end,
	
	tigerpalm_filler = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if player:Chi() == 1 then
				if player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm")
						end
					end
				end
			end
		end
	end,
	
	jab_filler = function()
		--if not player:LostControl() then
		if player:Stance() == 1 then
			if _A.manaengine() then
				if player:Buff("Rushing Jade Wind") and not player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInRange(4)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Jab")
						end
					end
				end
			end
			-- {"Summon Jade Serpent Statue", "spell.cooldown<1 && stance == 1", "player.ground"},
		end -- stance 1
	end,
	
	dpsstance_jab = function()
		if player:Stance() ~= 1 then
			if not player:Buff("Muscle Memory")
				or player:Chi()==0 then
				local lowestmelee = Object("lowestEnemyInRange(4)")
				if lowestmelee then
					if lowestmelee:exists() then
						return lowestmelee:Cast("Jab")
					end
				end
			end
		end
	end,
	
	dpsstance_spin = function()
		if player:Stance() ~= 1 then
			
			if	player:Talent("Rushing Jade Wind") 
				and player:SpellCooldown("Rushing Jade Wind")<.3
				then
				return player:Cast("Rushing Jade Wind")
			end
		end
	end,
	
	dpsstance_healstance = function()
		if player:Stance() ~= 1 then
			if	player:SpellCooldown("Stance of the Wise Serpent")<.3
				then
				return player:Cast("Stance of the Wise Serpent")
			end
		end
	end,
	
	dpsstanceswap = function()
		
		--if not player:LostControl() then
		if player:Stance() ~= 2 and not _A.modifier_shift() then
			if player:SpellCooldown("Stance of the Fierce Tiger")<.3
				and not player:Buff("Rushing Jade Wind") then
				if player:Talent("Rushing Jade Wind") then
					return player:Cast("Stance of the Fierce Tiger")
				end
				local lowestmelee = Object("lowestEnemyInRange(4)")
				if lowestmelee then
					if lowestmelee:exists() then
						return player:Cast("Stance of the Fierce Tiger")
					end
				end
			end
		end
	end,
}



local inCombat = function()	
	player = player or Object("player")
	if not player then return end
	if _A.buttondelayfunc()  then return end
	if player:lostcontrol()  then return end 
	-- if _A.ceeceed(player)  then return end 
	if  player:isCastingAny() then return end
	mw_rot.ClickthisPleasepvp()
	mw_rot.items_healthstone()
	mw_rot.items_noggenfogger()
	mw_rot.items_intflask()
	-- mw_rot.kick_legsweep()
	mw_rot.kick_paralysis()
	mw_rot.kick_spear()
	mw_rot.burstdisarm()
	mw_rot.pvp_disable()
	mw_rot.ringofpeace()
	mw_rot.healingsphere_shift()
	mw_rot.chi_wave()
	mw_rot.manatea()
	mw_rot.chibrew()
	mw_rot.fortifyingbrew()
	mw_rot.thunderfocustea()
	mw_rot.dispellplzarena()
	-- mw_rot.dispellplz()
	mw_rot.tigerslust()
	mw_rot.lifecocoon()
	mw_rot.surgingmist()
	mw_rot.renewingmist()
	mw_rot.healstatue()
	mw_rot.healingsphere()
	mw_rot.tigerpalm_mm()
	mw_rot.bk_buff()
	mw_rot.tp_buff()
	mw_rot.uplift()
	mw_rot.expelharm()
	mw_rot.tigerpalm_filler()
	mw_rot.jab_filler()
	mw_rot.statbuff()
	mw_rot.dpsstance_jab()
	mw_rot.dpsstance_spin()
	mw_rot.dpsstance_healstance()
	mw_rot.dpsstanceswap()
end
local outCombat = function()
	return inCombat()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(270, {
	name = "Monk Heal EFFICIENT",
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
