local mediaPath, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end

local GUI = {
	
}

local exeOnLoad = function()
	
	_A.FakeUnits:Add('lowestEnemyInSpellRange', function(num, spell)
		local tempTable = {}
		for _, Obj in pairs(_A.OM:Get('EnemyCombat')) do
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
end

local exeOnUnload = function()
	
end

local ST = {
	--{"Corruption", "exists && debuff.duration(Corruption) < 4 && !player.buff(Metamorphosis) && to(corrup, 0.2)", "enemiesCombat"},    --WORKS
	{"Soul Fire", "exists && !player.moving && player.buff(Molten Core).count >= 2 && player.buff(Demonic Calling)", "lowestEnemyInSpellRange(Soul Fire)"},
	
	{"Corruption", "exists && debuff(Corruption).refreshable && !player.buff(Metamorphosis) && range < 40", "enemiesCombat"},
	{"Hand of Gul\'dan", "exists && !player.buff(Metamorphosis)", "lowestEnemyInSpellRange(Hand of Gul\'dan)"},
	{"Hand of Gul\'dan", "exists && !player.buff(Metamorphosis) && debuff(Shadowflame).duration <= 3", "lowestEnemyInSpellRange(Hand of Gul\'dan)"},
	{"Hellfire", "player.area(10).enemies>=2 && player.buff(Metamorphosis) && !player.buff(104025)"},
	{"/cancelaura Immolation Aura", "player.area(10).enemies<=2 && player.buff(Metamorphosis) && player.buff(104025)"},
	{"Soul Fire", "exists && !player.moving && player.buff(Molten Core).count >= 7 && to(soulf, 0.2)", "lowestEnemyInSpellRange(Soul Fire)"},
	{"Soul Fire", "exists && !player.moving && player.buff(Molten Core).count >= 2 && player.buff(Metamorphosis) && to(soulf, 0.2)", "lowestEnemyInSpellRange(Soul Fire)"},
	
	{"Corruption", "exists && debuff(Doom).refreshable && player.buff(Metamorphosis) && range < 40", "enemiesCombat"}, -- Doom
	
	--{"Metamorphosis: Touch of Chaos", "exists && player.buff(Metamorphosis)", "lowestEnemyInSpellRange(Metamorphosis: Touch of Chaos)"},
	{"Shadow Bolt", "exists && range < 40 && player.buff(Metamorphosis) && debuff(Corruption).refreshable", "enemiesCombat"},
	{"Shadow Bolt", "exists && range < 40 && player.buff(Metamorphosis)", "target"},
	{"Shadow Bolt", "exists && !player.moving ", "lowestEnemyInSpellRange(Shadow Bolt)"},
	{"Fel Flame", "exists", "lowestEnemyInSpellRange(Fel Flame)"},
	
	
	
}

local inCombat = {
	{ST},
	
	
	
}

local outCombat = {
	-- {"/cancelaura Metamorphosis", "player.buff(Metamorphosis)"},
	
}

local spellIds_Loc = {
	
}

local blacklist = {
	
}

_A.CR:Add(266, {
	name = "DemoWL (DSL mode)",
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
