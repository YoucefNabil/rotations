local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end

local GUI = {
	
}

local exeOnLoad = function()
end

local exeOnUnload = function()
	
end

local highpriority = {
	{"Detox", "debuff.type(Poison)", "player"},
	{"Detox", "debuff.type(Disease)", "player"},
	{"Stance of the Sturdy Ox", "!stance == 1", "player"},
	{"Legacy of the Emperor", "!buff.any && spell.range && los && exists && isplayer", "roster"},
}
local defensives = {
	{"Fortifying Brew", "health <= 50", "player"},
}
local press_shift = {
	{"Leg Sweep", "keybind(shift)", "player"}, -- stun
	{"Rushing Jade Wind", "keybind(shift)", "player"}, -- spin
	{"Breath of Fire", "keybind(shift)", "player"}, -- press shift to disorient
}
local kicks = {
	{"Leg Sweep", "exists", "stuntarget"},
	--{"Paralysis", "exists", "paralysistarget"},
	{"&Spear Hand Strike", "exists", "kicktarget"},
}
local keepupbuffs = {
	{{
		{"Tiger Palm", "exists", "lowestEnemyInSpellRange(Blackout Kick)"},
	}, "player.buff(Tiger Power).duration <= 1.5 "},
	
    {"&Elusive Brew", "player.buff(Elusive Brew).stack >= 15 && player.buff(Heavy Stagger)", "player"},
    {"&Elusive Brew", "player.buff(Elusive Brew).stack >= 15 && player.buff(Moderate Stagger) && player.health <= 75", "player"},
}

local aoeprio = {
	{"Rushing Jade Wind", "spinnumber >= 3", "player"},
}

local comboconsumer = {
	{{
		{"Blackout Kick", "exists", "lowestEnemyInSpellRange(Blackout Kick)"},
	}, "player.buff(Shuffle).duration <= 1.5"},
	{"Guard", "player.buff(Power Guard) && !player.buff(Guard)", "player"},
	{"Purifying Brew", "player.buff(Shuffle) && player.debuff(Heavy Stagger)", "player"},
	{"Purifying Brew", "player.buff(Shuffle) && player.debuff(Moderate Stagger)", "player"},
}

local chibuilders = {
	{{
		{"Keg Smash", "exists", "lowestEnemyInSpellRange(Keg Smash)"},
	}, "chifix < chifixmax - 1"},
	{"Expel Harm", "kegcheck && chifix < chifixmax", "player"},
	{{
		{"Jab", "exists ", "lowestEnemyInSpellRange(Blackout Kick)"},
	}, "kegcheck && chifix < chifixmax" },
	
}

local filling = {
	--{"Summon Black Ox Statue", "stance == 1", "player.ground"},
	{"Chi Wave", "spell.range && los && exists", "lowest"},
	{{
		{"Rushing Jade Wind", "exists", "lowestEnemyInSpellRange(Blackout Kick)"},
	}, "kegcheck" },
	{"Tiger Palm", "exists", "lowestEnemyInSpellRange(Blackout Kick)"},
	{function() return true end, "lowestEnemyInSpellRange(Blackout Kick).exists"},
	{"Healing Sphere", "health <= 90", "player.ground"},
}

local inCombat = {
	{highpriority},
	--{defensives},
	{kicks},
	{press_shift},
	---- rotation
	{keepupbuffs},
	{aoeprio},
	{comboconsumer},
	{chibuilders},
	{filling},
}	

local outCombat = {
{inCombat},
}

local spellIds_Loc = {
	
}

local blacklist = {
	
}

_A.CR:Add(268, {
	name = "Monk Tank (DSL mode)",
	ic = inCombat,
	ooc = outCombat,
	use_lua_engine = false,
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
