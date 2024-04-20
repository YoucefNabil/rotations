local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end
local player
_A.Banzai = true
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
local function unitDD(unit)
	local UnitExists = UnitExists
	local UnitGUID = UnitGUID
	if UnitExists(unit) then
		return tonumber((UnitGUID(unit)):sub(-13, -9), 16)
		else return -1
	end
end
local function isActive(spellID)
	local conda, condb = IsUsableSpell(spellID);
	if conda ~= nil then
		return true
		else
		return false
	end
end
local blacklist = {
}
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
	_A.FakeUnits:Add('lowestall', function(num, spell)
		local tempTable = {}
		local location = pull_location()
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (location=="arena" and fr:ispet()) then
				if _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable+1] = {
						HP = fr:health(),
						guid = fr.guid
					}
				end
			end
		end
		table.sort( tempTable, function(a,b) return ( a.HP < b.HP ) end )
		return tempTable[1] and tempTable[1].guid
	end)
	_A.FakeUnits:Add('lowestallNOHOT', function(num, spell)
		local tempTable = {}
		local location = pull_location()
		for _, fr in pairs(_A.OM:Get('Friendly')) do
			if fr.isplayer or string.lower(fr.name)=="ebon gargoyle" or (location=="arena" and fr:ispet()) then
				if not fr:Buff(132120) 
					and _A.nothealimmune(fr) and fr:los() then
					tempTable[#tempTable+1] = {
						HP = fr:health(),
						guid = fr.guid
					}
				end
			end
		end
		table.sort( tempTable, function(a,b) return ( a.HP < b.HP ) end )
		return tempTable[1] and tempTable[1].guid
	end)
	_A.SMguid = nil
	_A.casttimers = {} -- doesnt work with channeled spells
	_A.Listener:Add("delaycasts_Monk_and_misc", "COMBAT_LOG_EVENT_UNFILTERED", function(event, _, subevent, _, guidsrc, _, _, _, guiddest, _, _, _, idd,_,_,amount)
		-- Testing
		-- if subevent == "SWING_DAMAGE" or subevent == "RANGE_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "SPELL_BUILDING_DAMAGE" or subevent == "ENVIRONMENTAL_DAMAGE"  then
		-- print(subevent.." "..amount) -- too much voodoo
		-- end
		if guidsrc == UnitGUID("player") then
			-- Delay Cast Function
			if subevent == "SPELL_CAST_SUCCESS" then -- doesnt work with channeled spells
				_A.casttimers[idd] = _A.GetTime()
			end
			-- soothing mist guid capture
			if idd == 115175 then
				if subevent == "SPELL_CAST_SUCCESS" then 
					_A.SMguid = guiddest
				end
				if subevent == "SPELL_AURA_REMOVED" then
					-- print("nilled")
					_A.SMguid = nil
				end
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
local mw_rot = {
	
	caching = function()
		_A.pull_location = pull_location()
	end,
	
	turtletoss = function()
		local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable = UnitCastingInfo("boss1");
		local channelName, _, _, _, channelStartTime, channelEndTime, _, channelInterruptable = UnitChannelInfo("boss1");
		if channelName ~= nil then
			castName = channelName
		end
		if unitDD("boss1") == 67977 then -- tortos id
			if castName == GetSpellInfo(133939) then -- furious stone breath
				if unitDD("target") == 67966 then -- turtle id
					if isActive(134031) then -- kick shell	
						_A.RunMacroText("/click ExtraActionButton1")
					end
				end
			end
		end
		-- if unitDD("target") == 71604 then -- puddle id
		-- if HP("target")<100 then --
		-- if GetShapeshiftForm()==1 then
		-- cast(115460) -- ORB big heal, but mana drain
		-- castonthis("target")
		-- stoptargeting()
		-- return true
		-- end
		-- end
		-- end
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
		if player:health() <= 35    then
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
		if player:Stance() == 1   then
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
		if player:Stance() == 1   then
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
		if player:Stance() == 1   then
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
		if player:Stance() == 1 and pull_location()~="arena"   then
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
			if player:Talent("Leg Sweep") and player:SpellCooldown("Leg Sweep")<0.3   then
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
			if player:Talent("Charging Ox Wave") and player:SpellCooldown("Charging Ox Wave")<0.3   then
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
		if player:Stance() == 1   then
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
	
	ctrl_mode = function()
		-- if _A.modifier_ctrl() and _A.castdelay(124682, 6) then
		if _A.modifier_ctrl() then
			if not player:moving() then
				-- local lowest = Object("lowestall")
				local lowest = Object("lowestallNOHOT")
				if player:isChanneling("Soothing Mist") and _A.SMguid then
					local SMobj = Object(_A.SMguid)
					if SMobj and SMobj:SpellRange("Renewing Mist") then
						if SMobj:buff(132120) then _A.CallWowApi("SpellStopCasting") end
						if player:Chi()>= 3 and SMobj:los() then return SMobj:cast("Enveloping Mist", true) end
						if _A.enoughmana(116694) and player:Chi()< 3 and SMobj:los() then return SMobj:cast("Surging Mist", true) end
					end
				end
				if not player:isChanneling("Soothing Mist") and _A.enoughmana(115175) and lowest and lowest:exists() then return lowest:cast("Soothing Mist") end 
			end
			else if player:isChanneling("Soothing Mist") then _A.CallWowApi("SpellStopCasting") end
		end
	end,
	
	burstdisarm = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
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
		if player:SpellCooldown("Spear Hand Strik")==0   then
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
					obj:Cast("Spear Hand Strike")
				end
			end
		end
	end,
	
	pvp_disable = function()
		local target = Object("target")
		if not _A.modifier_shift()   then
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
		if player:Stance() == 1   then
			if player:Talent("Ring of Peace") and player:SpellCooldown("Ring of Peace")<0.3 then
				local peacetarget = Object("mostTargetedRosterPVP")
				if peacetarget and peacetarget:exists()  then
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
	end,
	
	chi_wave = function()
		if player:Talent("Chi Wave")  
			and player:SpellCooldown("Chi Wave")<.3 then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest then
					if  lowest:exists() and lowest:SpellRange("Chi Wave")
						then 
						return lowest:Cast("Chi Wave")
					end
				end
			end
		end
	end,
	
	manatea = function()
		if player:Stance() == 1   then
			if player:SpellCooldown("Mana Tea")<.3
				-- and player:Glyph("Glyph of Mana Tea")
				and _A.powerpercent()<= 92
				and player:BuffStack("Mana Tea")>=2
				then
				return player:Cast("Mana Tea")
				-- _A.CastSpellByName("Mana Tea")
			end
		end
	end,
	
	chibrew = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			
			if player:Talent("Chi Brew")
				and player:SpellCooldown("Chi Brew")==0
				and player:Chi()<=2
				then
				player:Cast("Chi Brew")
			end
		end
	end,
	
	fortifyingbrew = function()
		if player:Stance() == 1   then
			if	player:SpellCooldown("Fortifying Brew")==0
				and player:Health()<50
				then
				player:Cast("Fortifying Brew")
			end
		end
	end,
	
	thunderfocustea = function()
		if player:Stance() == 1 and player:Chi()>=1   and not player:buff(116680) then
			if	player:SpellCooldown("Thunder Focus Tea")==0 and player:SpellUsable("Thunder Focus Tea")
				then
				player:Cast("Thunder Focus Tea")
			end
		end
	end,
	
	tigerslust = function()
		if  player:Talent("Tiger's Lust") and player:SpellCooldown("Tiger's Lust")<.3   then
			if player:Stance() == 1 then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr:SpellRange("Tiger's Lust") then
						if fr.isplayer then
							if _A.nothealimmune(fr) then
								if (not fr:LostControl()) and (fr:State("root") or fr:State("snare")) and fr:los()
									then
									if fr.guid ~= player.guid then
										return fr:Cast("Tiger's Lust")
										else
										return fr:Cast("Tiger's Lust")
									end
								end
							end
						end	
					end
				end
			end	
		end
	end,
	
	dispellplzarena = function()
		local temptable = {}
		if player:Stance() == 1   then
			if player:SpellCooldown("Detox")<.3 and _A.enoughmana("Detox")then
				for _, fr in pairs(_A.OM:Get('Friendly')) do
					if fr.isplayer
						and fr:SpellRange("Detox")
						and _A.nothealimmune(fr)
						and not fr:DebuffAny("Unstable Affliction")
						and (fr:DebuffType("Magic") or fr:DebuffType("Poison") or fr:DebuffType("Disease")) then
						if fr:State("fear || sleep || charm || disorient || incapacitate || misc || stun || root || silence") or fr:LostControl() or _A.pull_location == "party" or _A.pull_location == "raid"
							or fr:DebuffAny("Entangling Roots") or  fr:DebuffAny("Freezing Trap")
							then
							if fr:los() then
								return fr:Cast("Detox")
							end
						end
					end	
				end
			end
		end
	end,
	
	lifecocoon = function()
		if player:SpellCooldown("Life Cocoon")<.3 and _A.enoughmana(116849)   then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:exists() and lowest:SpellRange("Life Cocoon") then 			
					--]]
					if 
						-- (lowest:health()<40 or (pull_location()=="pvp" and lowest:health()<40))
						lowest:health()<40
						then
						return lowest:Cast("Life Cocoon")
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
				if lowest and lowest:SpellRange("Surging Mist") then 	
					--]]
					
					if  
						lowest:Health()<=85
						
						then
						return lowest:Cast("Surging Mist")
					end
				end
			end
		end
	end,
	
	renewingmist = function()
		if player:SpellCooldown("Renewing Mist")<.3 and _A.enoughmana(115151)   then
			--if not player:LostControl() then
			if player:Stance() == 1 then
				local lowest = Object("lowestall")
				if lowest and lowest:exists() and lowest:SpellRange("Renewing Mist") then 
					return lowest:Cast("Renewing Mist")
				end
			end
		end
	end,
	
	healstatue = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			
			if	player:SpellCooldown("Summon Jade Serpent Statue")<.3
				then
				return player:CastGround("Summon Jade Serpent Statue")
			end
		end
	end,
	
	healingsphere_shift = function()
		if player:SpellCooldown("Healing Sphere")<.3   then
			if player:Stance() == 1 then
				if _A.modifier_shift() then
					if _A.enoughmana(115460) then
						local lowest = Object("lowestall")
						if lowest and lowest:exists() then
							if (lowest:Health() < 99) then
								if lowest:Distance() < 40 then
									-- if lowest:los() then
									-- return lowest:CastGround("Healing Sphere")
									return _A.CastPredictedPos(lowest.guid, "Healing Sphere", 15)
									-- end
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
		if player:SpellCooldown("Healing Sphere")<.3   then
			if player:Stance() == 1 then
				if _A.enoughmana(115460) then
					if _A.manaengine()==true or _A.modifier_shift() then
						--- ORBS
						local lowest = Object("lowestall")
						if lowest then
							if lowest:exists() then
								if (lowest:Health() < 85) then
									-- if lowest:los() then
									-- return lowest:CastGround("Healing Sphere", true)
									return _A.CastPredictedPos(lowest.guid, "Healing Sphere", 15)
									-- end
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
		if player:Stance() == 1   then
			if player:Chi()>=2 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
		if player:Stance() == 1  and not player:Keybind("R") then
			if player:Chi()>=1 then
				if player:Buff("Muscle Memory") then
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
		if player:Stance() == 1   then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 2
					and not player:Buff("Serpent's Zeal") -- and player:Buff("Muscle Memory") 
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
		if player:Stance() == 1   then
			if not player:Buff("Thunder Focus Tea") then -- and player:Buff("Muscle Memory") 
				if player:Chi()>= 1
					and not player:Buff("Tiger Power")
					then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
		if player:Stance() == 1   then
			if	player:SpellUsable("Uplift")
				and player:Chi()>= 2 
				then
				return player:Cast("Uplift")
			end
		end
	end,
	
	expelharm = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
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
		if player:Stance() == 1   then
			if player:Chi() == 1 then
				if player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							return lowestmelee:Cast("Tiger Palm")
						end
					end
				end
			end
		end
	end,
	
	blackout_keybind = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if player:Chi()>=2 then
				-- if player:Buff("Muscle Memory") then
				-- if player:Keybind("R") and player:Buff("Muscle Memory") then
				if player:Keybind("R") 	then
					
					---------------------------------- 
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
					if lowestmelee then
						if lowestmelee:exists() then
							---------------------------------- 
							return lowestmelee:Cast("Blackout Kick", true)
						end
					end
					--------------------------------- damage based
				end
			end
		end
	end,
	
	jab_filler = function()
		--if not player:LostControl() then
		if player:Stance() == 1   then
			if _A.manaengine() then
				if player:Buff("Rushing Jade Wind") and not player:Buff("Muscle Memory") then
					local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					if lowestmelee:exists() then
						return lowestmelee:Cast("Jab")
					end
				end
			end
		end
	end,
	
	spin_keybind = function()
		if player:Stance() == 1 and player:Keybind("R") then
			if	player:Talent("Rushing Jade Wind") 
				and player:SpellCooldown("Rushing Jade Wind")<.3
				and _A.enoughmana(116847)
				then
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
				if lowestmelee then
					if lowestmelee:exists() then
						return player:Cast("Rushing Jade Wind")
					end
				end
			end
		end
	end,
	
	jab_keybind = function()
		if player:Stance() == 1 and player:Keybind("R") and player:mana()>=9 then
			local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
			if lowestmelee then
				if lowestmelee:exists() then
					return lowestmelee:Cast("Jab", true)
				end
			end
		end
	end,
	
	lightning_keybind = function()
		if player:Stance() == 1 and player:Keybind("R") and player:mana()>=9 and not player:moving() then
			if not player:isChanneling("Crackling Jade Lightning") then
				local lowestmelee = Object("lowestEnemyInSpellRange(Crackling Jade Lightning)")
				if lowestmelee and lowestmelee:exists() and lowestmelee:los() then
				return lowestmelee:Cast("Crackling Jade Lightning")
			end
			end
			else if player:isChanneling("Crackling Jade Lightning") then _A.CallWowApi("SpellStopCasting") end
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
		if player:Stance() ~= 2 and not _A.modifier_shift()   then
			if player:SpellCooldown("Stance of the Fierce Tiger")<.3
				and not player:Buff("Rushing Jade Wind") then
				if player:Talent("Rushing Jade Wind") then
					return player:Cast("Stance of the Fierce Tiger")
				end
				local lowestmelee = Object("lowestEnemyInSpellRange(Blackout Kick)")
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
	mw_rot.caching()
	if _A.buttondelayfunc()  then return end
	if player:mounted() then return end
	-- if player:isChanneling("Crackling Jade Lightning") then return end
	mw_rot.items_healthstone()
	mw_rot.items_noggenfogger()
	mw_rot.items_intflask()
	mw_rot.turtletoss()
	mw_rot.kick_legsweep()
	mw_rot.dispellplzarena()
	mw_rot.kick_paralysis()
	mw_rot.kick_spear()
	mw_rot.manatea()
	mw_rot.ringofpeace()
	mw_rot.burstdisarm()
	mw_rot.healingsphere_shift()
	mw_rot.pvp_disable()
	mw_rot.chi_wave()
	mw_rot.chibrew()
	mw_rot.fortifyingbrew()
	mw_rot.tigerslust()
	mw_rot.lifecocoon()
	mw_rot.surgingmist()
	mw_rot.renewingmist()
	mw_rot.ctrl_mode()
	mw_rot.healstatue()
	mw_rot.healingsphere()
	mw_rot.tigerpalm_mm()
	mw_rot.bk_buff()
	mw_rot.tp_buff()
	mw_rot.thunderfocustea()
	mw_rot.spin_keybind()
	mw_rot.blackout_keybind()
	mw_rot.uplift()
	mw_rot.expelharm()
	mw_rot.jab_keybind()
	mw_rot.lightning_keybind()
	mw_rot.tigerpalm_filler()
	mw_rot.jab_filler()
	mw_rot.statbuff()
	mw_rot.dpsstance_jab()
	mw_rot.dpsstance_spin()
	mw_rot.dpsstance_healstance()
	mw_rot.dpsstanceswap()
end
local spellIds_Loc = function()
end
local blacklist = function()
end
_A.CR:Add(270, {
	name = "Monk Heal EFFICIENT",
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
