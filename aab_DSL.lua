local HarmonyMedia, _A, _Y = ...
local LibDispellable = _A.LibStub('LibDispellable-1.0')
local tlp = _A.Tooltip
local locale = GetLocale()

_A.DSL:Register('state.purge', function(target, spell)
	spell = _A.Core:GetSpellID(spell)
	return LibDispellable:CanDispelWith(target, spell)
end)

_A.locale = _A.locale or {}
local YL = _A.locale
YL.locale = GetLocale()


YL.States = {}
YL.Immune = {}
if YL.locale == "enUS" then
	YL.States = {
		charm        = {'^charmed'},
		disarm       = {'disarmed'},
		disorient    = {'^disoriented'},
		dot          = {'damage every.*sec', 'damage per.*sec'},
		fear         = {'^horrified', '^fleeing', '^feared', '^intimidated', '^cowering in fear', '^running in fear', '^compelled to flee'},
		incapacitate = {'^incapacitated', '^sapped'},
		misc         = {'unable to act', '^bound', '^frozen.$', '^cannot attack or cast spells', '^shackled.$'},
		root         = {'^rooted', '^immobil', '^webbed', 'frozen in place', '^paralyzed', '^locked in place', '^pinned in place'},
		stun         = {'^stunned', '^webbed'},
		silence      = {'^silenced'},
		sleep        = {'^asleep'},
		snare        = {'^movement.*slowed', 'movement speed reduced', '^slowed by', '^dazed', '^reduces movement speed'}
	}
	YL.Immune = {
		all          = {'dematerialize', 'deterrence', 'divine shield', 'ice block', 'desoriented and invulnerable', 'cyclone'},
		charm        = {'bladestorm', 'desecrated ground', 'grounding totem effect', 'lichborne'},
		disorient    = {'bladestorm', 'desecrated ground'},
		fear         = {'berserker rage', 'bladestorm', 'desecrated ground', 'grounding totem','lichborne', 'nimble brew'},
		incapacitate = {'bladestorm', 'desecrated ground'},
		melee        = {'dispersion', 'evasion', 'hand of protection', 'ring of peace', 'touch of karma'},
		misc         = {'bladestorm', 'desecrated ground'},
		silence      = {'devotion aura', 'inner focus', 'unending resolve'},
		polly        = {'immune to polymorph'},
		sleep        = {'bladestorm', 'desecrated ground', 'lichborne'},
		snare        = {'bestial wrath', 'bladestorm', 'death\'s advance', 'desecrated ground','dispersion', 'hand of freedom', 'master\'s call', 'windwalk totem'},
		spell        = {'anti-magic shell', 'cloak of shadows', 'diffuse magic', 'dispersion','massspell reflection', 'ring of peace', 'spell reflection', 'touch of karma'},
		stun         = {'bestial wrath', 'bladestorm', 'desecrated ground', 'icebound fortitude','grounding totem', 'nimble brew'}
	}
	elseif YL.locale == "ruRU" then
	YL.States = {
		charm        = {'^charmed'},
		disarm       = {'disarmed'},
		disorient    = {'^disoriented'},
		dot          = {'урона каждую.*сек', 'урона в.*сек'},
		fear         = {'^horrified', '^fleeing', '^feared', '^intimidated', '^cowering in fear', '^running in fear', '^compelled to flee'},
		incapacitate = {'^incapacitated', '^sapped'},
		misc         = {'unable to act', '^bound', '^frozen.$', '^не могу атаковать или произносить заклинания', '^shackled.$'},
		root         = {'^rooted', '^immobil', '^webbed', 'frozen in place', '^paralyzed', '^locked in place', '^pinned in place'},
		stun         = {'^stunned', '^webbed'},
		silence      = {'^silenced'},
		sleep        = {'^asleep'},
		snare        = {'^movement.*slowed', 'скорость передвижения снижена', '^slowed by', '^dazed', '^reduces movement speed'}
	}
	YL.Immune = {
		all          = {'dematerialize', 'deterrence', 'divine shield', 'ice block', 'desoriented and invulnerable', 'cyclone'},
		charm        = {'bladestorm', 'desecrated ground', 'grounding totem effect', 'lichborne'},
		disorient    = {'bladestorm', 'desecrated ground'},
		fear         = {'berserker rage', 'bladestorm', 'desecrated ground', 'grounding totem', 'lichborne', 'nimble brew'},
		incapacitate = {'bladestorm', 'desecrated ground'},
		melee        = {'dispersion', 'evasion', 'hand of protection', 'ring of peace', 'touch of karma'},
		misc         = {'bladestorm', 'desecrated ground'},
		silence      = {'devotion aura', 'inner focus', 'unending resolve'},
		polly        = {'immune to polymorph'},
		sleep        = {'bladestorm', 'desecrated ground', 'lichborne'},
		snare        = {'bestial wrath', 'bladestorm', 'death\'s advance', 'desecrated ground','dispersion', 'hand of freedom', 'master\'s call', 'windwalk totem'},
		spell        = {'anti-magic shell', 'cloak of shadows', 'diffuse magic', 'dispersion','massspell reflection', 'ring of peace', 'spell reflection', 'touch of karma'},
		stun         = {'bestial wrath', 'bladestorm', 'desecrated ground', 'icebound fortitude','grounding totem', 'nimble brew'}
	}
end
------ THESE ARE THE FUNCTIONS LIFTED FROM MORB, they work fine
_A.DSL:Register('stateYOUCEF', function(unit, args)
	local tbl = {_A.StrExplode(args, "||")}
	for _,state in ipairs(tbl) do
		local pattern = YL.States[tostring(state):lower()]
		if pattern then
			if tlp:Scan_Debuff(unit, pattern) then
				return true
			end
		end
	end
	return false
end)

_A.DSL:Register('immuneYOUCEF', function(unit, args)
	local tbl = {_A.StrExplode(args, "||")}
	for _,imm in ipairs(tbl) do
		local pattern = YL.Immune[tostring(imm):lower()]
		if pattern then
			if tlp:Scan_Buff(unit, pattern) then --
				return true
			end
		end
	end
	return false
end)
----------------------------------------------------
_A.DSL:Register('stateduration', function(unit, args)
	local tbl = {_A.StrExplode(args, "||")}
	local tempTable = {}
	for _,state in ipairs(tbl) do
		local pattern = YL.States[tostring(state):lower()]
		if pattern and tlp:Scan_Debuff(unit, pattern) then
			tempTable[#tempTable+1]={
				duration = tlp:Scan_Debuff_Duration(unit, pattern)
			}
		end
	end
	if #tempTable>1 then
		table.sort( tempTable, function(a,b) return (a.duration > b.duration) end )
	end
	return #tempTable>=1 and tempTable[1].duration or 0
end)
_A.DSL:Register('immuneduration', function(unit, args)
	local tbl = {_A.StrExplode(args, "||")}
	local tempTable = {}
	for _,imm in ipairs(tbl) do
		local pattern = YL.Immune[tostring(imm):lower()]
		if pattern and tlp:Scan_Buff(unit, pattern) then
			tempTable[#tempTable+1]={
				duration = tlp:Scan_Buff_Duration(unit, pattern)
			}
		end
	end
	if #tempTable>1 then
		table.sort( tempTable, function(a,b) return (a.duration > b.duration) end )
	end
	return #tempTable>=1 and tempTable[1].duration or 0
end)
----------------------------------------------------------
_A.DSL:Register('statepurgecheck', function(unit, args)
	local tbl = {_A.StrExplode(args, "||")}
	local tempTable = {}
	for _,state in ipairs(tbl) do
		local pattern = YL.States[tostring(state):lower()]
		if pattern and tlp:Scan_Debuff(unit, pattern) then
			tempTable[#tempTable+1]={
				check = tlp:Scan_Debuff_Dispellable(unit, pattern)
			}
		end
	end
	if #tempTable>=1 then
		for _,v in ipairs(tempTable) do
			if v.check==false then return false -- found an undispellable thing, return false
			end
		end
		return true -- passed all checks, return true
	end
	return false
end)