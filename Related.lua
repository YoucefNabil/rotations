local _, _A = ...
-- Initialize gathering tables if they don't exist
_A.related = {}
local related = _A.related
local Queuer = _A.Queuer

related.trashMobs = {
    [40817] = true,            -- shadow of obsidius
    [39425] = function(obj)    -- temple guardian anhur
        return obj:buff(74938) -- shield of light
	end,
    [39984] = true,            -- Malignant Trogg
    [45704] = true,            -- Lurking Tempest
    [52430] = function(obj)    -- hakkar's chains
        return obj:buff(97417) -- barrier
	end,
    [42180] = function(obj)    --toxitron
        return obj:buff(79835)
	end,
    [42166] = function(obj) --arcanotron
        return obj:buff(79735)
	end,
    [42178] = function(obj) --magmatron
        return obj:buff(79582)
	end,
    [42179] = function(obj) --electron
        return obj:buff(79900)
	end,
    [52755] = function(obj)     --totem zul
        return obj:buff(97502)  --refreshing totem
	end,
    [56448] = function(obj)     -- wise mari
        return obj:buff(106062) -- water bubble
	end,
}

related.avoidMobs = function(obj)
    if not obj or not obj.id then return false end
	
    local check = related.trashMobs[obj.id]
    if check then
        -- For direct boolean checks
        if type(check) == "boolean" then
            return check
			
            -- For buff-based checks
			elseif type(check) == "function" then
            local success, result = pcall(check, obj)
            if success then
                return result
			end
		end
	end
	
    return false
end

-- Herb IDs table
related.Ores = {
    -- Ores
    [181556] = { id = 181556, icon = GetItemIcon(23425) }, -- Adamantite Deposit
    [185557] = { id = 185557, icon = GetItemIcon(34907) }, -- Ancient Gem Vein
    [189978] = { id = 189978, icon = GetItemIcon(36909) }, -- Cobalt Deposit
    [1731] = { id = 1731, icon = GetItemIcon(2770) },      -- Copper Vein
    [2055] = { id = 2055, icon = GetItemIcon(2770) },      -- Copper Vein
    [3763] = { id = 3763, icon = GetItemIcon(2770) },      -- Copper Vein
    [103713] = { id = 103713, icon = GetItemIcon(2770) },  -- Copper Vein
    [181248] = { id = 181248, icon = GetItemIcon(2770) },  -- Copper Vein
    [165658] = { id = 165658, icon = GetItemIcon(11370) }, -- Dark Iron Deposit
    [202738] = { id = 202738, icon = GetItemIcon(52185) }, -- Elementium Vein
    [181555] = { id = 181555, icon = GetItemIcon(23424) }, -- Fel Iron Deposit
    [209311] = { id = 209311, icon = GetItemIcon(72092) }, -- Ghost Iron Deposit
    [221538] = { id = 221538, icon = GetItemIcon(72092) }, -- Ghost Iron Deposit
    [1734] = { id = 1734, icon = GetItemIcon(2776) },      -- Gold Vein
    [150080] = { id = 150080, icon = GetItemIcon(2776) },  -- Gold Vein
    [181109] = { id = 181109, icon = GetItemIcon(2776) },  -- Gold Vein
    [180215] = { id = 180215, icon = GetItemIcon(10620) }, -- Hakkari Thorium Vein
    [1610] = { id = 1610, icon = GetItemIcon(3340) },      -- Incendicite Mineral Vein
    [1667] = { id = 1667, icon = GetItemIcon(3340) },      -- Incendicite Mineral Vein
    [19903] = { id = 19903, icon = GetItemIcon(5833) },    -- Indurium Mineral Vein
    [1735] = { id = 1735, icon = GetItemIcon(2772) },      -- Iron Deposit
    [181557] = { id = 181557, icon = GetItemIcon(23426) }, -- Khorium Vein
    [209312] = { id = 209312, icon = GetItemIcon(72093) }, -- Kyparite Deposit
    [181069] = { id = 181069, icon = GetItemIcon(22203) }, -- Large Obsidian Chunk
    [2653] = { id = 2653, icon = GetItemIcon(4278) },      -- Lesser Bloodstone Deposit
    [2040] = { id = 2040, icon = GetItemIcon(3858) },      -- Mithril Deposit
    [150079] = { id = 150079, icon = GetItemIcon(3858) },  -- Mithril Deposit
    [176645] = { id = 176645, icon = GetItemIcon(3858) },  -- Mithril Deposit
    [185877] = { id = 185877, icon = GetItemIcon(32464) }, -- Nethercite Deposit
    [202736] = { id = 202736, icon = GetItemIcon(22203) }, -- Obsidium Deposit
    [73941] = { id = 73941, icon = GetItemIcon(2776) },    -- Ooze Covered Gold Vein
    [123310] = { id = 123310, icon = GetItemIcon(3858) },  -- Ooze Covered Mithril Deposit
    [177388] = { id = 177388, icon = GetItemIcon(10620) }, -- Ooze Covered Rich Thorium Vein
    [73940] = { id = 73940, icon = GetItemIcon(2775) },    -- Ooze Covered Silver Vein
    [123848] = { id = 123848, icon = GetItemIcon(10620) }, -- Ooze Covered Thorium Vein
    [123309] = { id = 123309, icon = GetItemIcon(7911) },  -- Ooze Covered Truesilver Deposit
    [195036] = { id = 195036, icon = GetItemIcon(36912) }, -- Pure Saronite Deposit
    [202737] = { id = 202737, icon = GetItemIcon(52183) }, -- Pyrite Deposit
    [181570] = { id = 181570, icon = GetItemIcon(23425) }, -- Rich Adamantite Deposit
    [181569] = { id = 181569, icon = GetItemIcon(23425) }, -- Rich Adamantite Deposit
    [189979] = { id = 189979, icon = GetItemIcon(36909) }, -- Rich Cobalt Deposit
    [202741] = { id = 202741, icon = GetItemIcon(52185) }, -- Rich Elementium Vein
    [209328] = { id = 209328, icon = GetItemIcon(72092) }, -- Rich Ghost Iron Deposit
    [221539] = { id = 221539, icon = GetItemIcon(72092) }, -- Rich Ghost Iron Deposit
    [209329] = { id = 209329, icon = GetItemIcon(72093) }, -- Rich Kyparite Deposit
    [202739] = { id = 202739, icon = GetItemIcon(22203) }, -- Rich Obsidium Deposit
    [202740] = { id = 202740, icon = GetItemIcon(52183) }, -- Rich Pyrite Deposit
    [189981] = { id = 189981, icon = GetItemIcon(36912) }, -- Rich Saronite Deposit
    [175404] = { id = 175404, icon = GetItemIcon(10620) }, -- Rich Thorium Vein
    [209330] = { id = 209330, icon = GetItemIcon(72094) }, -- Rich Trillium Vein
    [221540] = { id = 221540, icon = GetItemIcon(72094) }, -- Rich Trillium Vein
    [189980] = { id = 189980, icon = GetItemIcon(36912) }, -- Saronite Deposit
    [1733] = { id = 1733, icon = GetItemIcon(2775) },      -- Silver Vein
    [105569] = { id = 105569, icon = GetItemIcon(2775) },  -- Silver Vein
    [181068] = { id = 181068, icon = GetItemIcon(22203) }, -- Small Obsidian Chunk
    [324] = { id = 324, icon = GetItemIcon(10620) },       -- Small Thorium Vein
    [150082] = { id = 150082, icon = GetItemIcon(10620) }, -- Small Thorium Vein
    [176643] = { id = 176643, icon = GetItemIcon(10620) }, -- Small Thorium Vein
    [1732] = { id = 1732, icon = GetItemIcon(2771) },      -- Tin Vein
    [2054] = { id = 2054, icon = GetItemIcon(2771) },      -- Tin Vein
    [3764] = { id = 3764, icon = GetItemIcon(2771) },      -- Tin Vein
    [103711] = { id = 103711, icon = GetItemIcon(2771) },  -- Tin Vein
    [181249] = { id = 181249, icon = GetItemIcon(2771) },  -- Tin Vein
    [191133] = { id = 191133, icon = GetItemIcon(36910) }, -- Titanium Vein
    [209313] = { id = 209313, icon = GetItemIcon(72094) }, -- Trillium Vein
    [221541] = { id = 221541, icon = GetItemIcon(72094) }, -- Trillium Vein
    [2047] = { id = 2047, icon = GetItemIcon(7911) },      -- Truesilver Deposit
    [150081] = { id = 150081, icon = GetItemIcon(7911) },  -- Truesilver Deposit
    [181108] = { id = 181108, icon = GetItemIcon(7911) },  -- Truesilver Deposit
}

related.Herbs = {
    -- Herbs
    [191019] = { id = 191019, icon = GetItemIcon(191019) }, -- Adder's Tongue
    [181278] = { id = 181278, icon = GetItemIcon(181278) }, -- Ancient Lichen
    [142141] = { id = 142141, icon = GetItemIcon(142141) }, -- Arthas' Tears
    [176642] = { id = 176642, icon = GetItemIcon(176642) }, -- Arthas' Tears
    [202749] = { id = 202749, icon = GetItemIcon(202749) }, -- Azshara's Veil
    [176589] = { id = 176589, icon = GetItemIcon(176589) }, -- Black Lotus
    [253069] = { id = 253069, icon = GetItemIcon(253069) }, -- Blacker Lotus
    [142143] = { id = 142143, icon = GetItemIcon(142143) }, -- Blindweed
    [183046] = { id = 183046, icon = GetItemIcon(183046) }, -- Blindweed
    [181166] = { id = 181166, icon = GetItemIcon(181166) }, -- Bloodthistle
    [1621] = { id = 1621, icon = GetItemIcon(1621) },       -- Briarthorn
    [3729] = { id = 3729, icon = GetItemIcon(3729) },       -- Briarthorn
    [1622] = { id = 1622, icon = GetItemIcon(1622) },       -- Bruiseweed
    [3730] = { id = 3730, icon = GetItemIcon(3730) },       -- Bruiseweed
    [202747] = { id = 202747, icon = GetItemIcon(202747) }, -- Cinderbloom
    [2044] = { id = 2044, icon = GetItemIcon(2044) },       -- Dragon's Teeth
    [176639] = { id = 176639, icon = GetItemIcon(176639) }, -- Dreamfoil
    [180168] = { id = 180168, icon = GetItemIcon(180168) }, -- Dreamfoil
    [176584] = { id = 176584, icon = GetItemIcon(176584) }, -- Dreamfoil
    [183045] = { id = 183045, icon = GetItemIcon(183045) }, -- Dreaming Glory
    [181271] = { id = 181271, icon = GetItemIcon(181271) }, -- Dreaming Glory
    [1619] = { id = 1619, icon = GetItemIcon(1619) },       -- earthroot
    [3726] = { id = 3726, icon = GetItemIcon(3726) },       -- earthroot
    [2042] = { id = 2042, icon = GetItemIcon(2042) },       -- Fadeleaf
    [181270] = { id = 181270, icon = GetItemIcon(181270) }, -- Felweed
    [183044] = { id = 183044, icon = GetItemIcon(183044) }, -- Felweed
    [2866] = { id = 2866, icon = GetItemIcon(2866) },       -- Firebloom
    [191303] = { id = 191303, icon = GetItemIcon(191303) }, -- Firethorn
    [181276] = { id = 181276, icon = GetItemIcon(181276) }, -- Flame Cap
    [221547] = { id = 221547, icon = GetItemIcon(221547) }, -- Fool's Cap
    [209355] = { id = 209355, icon = GetItemIcon(209355) }, -- Fool's Cap
    [190176] = { id = 190176, icon = GetItemIcon(190176) }, -- Frost Lotus
    [190173] = { id = 190173, icon = GetItemIcon(190173) }, -- Frozen Herb
    [190174] = { id = 190174, icon = GetItemIcon(190174) }, -- Frozen Herb
    [190175] = { id = 190175, icon = GetItemIcon(190175) }, -- Frozen Herb
    [206085] = { id = 206085, icon = GetItemIcon(206085) }, -- Frozen Herb
    [142144] = { id = 142144, icon = GetItemIcon(142144) }, -- Ghost Mushroom
    [189973] = { id = 189973, icon = GetItemIcon(189973) }, -- Goldclover
    [209354] = { id = 209354, icon = GetItemIcon(72238) },  -- Golden Lotus
    [221545] = { id = 221545, icon = GetItemIcon(72238) },  -- Golden Lotus
    [176638] = { id = 176638, icon = GetItemIcon(176638) }, -- Golden Sansam
    [180167] = { id = 180167, icon = GetItemIcon(180167) }, -- Golden Sansam
    [176583] = { id = 176583, icon = GetItemIcon(176583) }, -- Golden Sansam
    [2046] = { id = 2046, icon = GetItemIcon(2046) },       -- Goldthorn
    [1628] = { id = 1628, icon = GetItemIcon(1628) },       -- Grave Moss
    [209349] = { id = 209349, icon = GetItemIcon(209349) }, -- Green Tea Leaf
    [221542] = { id = 221542, icon = GetItemIcon(221542) }, -- Green Tea Leaf
    [176637] = { id = 176637, icon = GetItemIcon(176637) }, -- Gromsblood
    [142145] = { id = 142145, icon = GetItemIcon(142145) }, -- Gromsblood
    [202750] = { id = 202750, icon = GetItemIcon(202750) }, -- Heartblossom
    [176588] = { id = 176588, icon = GetItemIcon(176588) }, -- Icecap
    [190172] = { id = 190172, icon = GetItemIcon(190172) }, -- Icethorn
    [2043] = { id = 2043, icon = GetItemIcon(2043) },       -- Khadgar's Whisker
    [1624] = { id = 1624, icon = GetItemIcon(1624) },       -- Kingsblood
    [190171] = { id = 190171, icon = GetItemIcon(190171) }, -- Lichbloom
    [2041] = { id = 2041, icon = GetItemIcon(2041) },       -- Liferoot
    [1620] = { id = 1620, icon = GetItemIcon(1620) },       -- Mageroyal
    [3727] = { id = 3727, icon = GetItemIcon(3727) },       -- Mageroyal
    [181281] = { id = 181281, icon = GetItemIcon(181281) }, -- Mana Thistle
    [176640] = { id = 176640, icon = GetItemIcon(176640) }, -- Mountain Silversage
    [180166] = { id = 180166, icon = GetItemIcon(180166) }, -- Mountain Silversage
    [176586] = { id = 176586, icon = GetItemIcon(176586) }, -- Mountain Silversage
    [181279] = { id = 181279, icon = GetItemIcon(181279) }, -- Netherbloom
    [185881] = { id = 185881, icon = GetItemIcon(185881) }, -- Netherdust Bush
    [181280] = { id = 181280, icon = GetItemIcon(181280) }, -- Nightmare Vine
    [1618] = { id = 1618, icon = GetItemIcon(1618) },       -- peacebloom
    [3724] = { id = 3724, icon = GetItemIcon(3724) },       -- Peacebloom
    [176641] = { id = 176641, icon = GetItemIcon(176641) }, -- Plaguebloom
    [142140] = { id = 142140, icon = GetItemIcon(142140) }, -- Purple Lotus
    [180165] = { id = 180165, icon = GetItemIcon(180165) }, -- Purple Lotus
    [181275] = { id = 181275, icon = GetItemIcon(181275) }, -- Ragveil
    [183043] = { id = 183043, icon = GetItemIcon(183043) }, -- Ragveil
    [221543] = { id = 221543, icon = GetItemIcon(221543) }, -- Rain Poppy
    [209353] = { id = 209353, icon = GetItemIcon(209353) }, -- Rain Poppy
    [215412] = { id = 215412, icon = GetItemIcon(215412) }, -- Sha-Touched Herb
    [214510] = { id = 214510, icon = GetItemIcon(214510) }, -- Sha-Touched Herb
    [209350] = { id = 209350, icon = GetItemIcon(97621) },  -- Silkweed
    [221544] = { id = 221544, icon = GetItemIcon(97621) },  -- Silkweed
    [1617] = { id = 1617, icon = GetItemIcon(1617) },       -- silverleaf
    [3725] = { id = 3725, icon = GetItemIcon(3725) },       -- Silverleaf
    [209351] = { id = 209351, icon = GetItemIcon(209351) }, -- Snow Lily
    [176587] = { id = 176587, icon = GetItemIcon(176587) }, -- Sorrowmoss
    [202748] = { id = 202748, icon = GetItemIcon(202748) }, -- Stormvine
    [2045] = { id = 2045, icon = GetItemIcon(2045) },       -- Stranglekelp
    [142142] = { id = 142142, icon = GetItemIcon(142142) }, -- Sungrass
    [176636] = { id = 176636, icon = GetItemIcon(176636) }, -- Sungrass
    [180164] = { id = 180164, icon = GetItemIcon(180164) }, -- Sungrass
    [190170] = { id = 190170, icon = GetItemIcon(190170) }, -- Talandra's Rose
    [181277] = { id = 181277, icon = GetItemIcon(181277) }, -- Terocone
    [190169] = { id = 190169, icon = GetItemIcon(36904) },  -- Tiger Lily
    [202751] = { id = 202751, icon = GetItemIcon(202751) }, -- Twilight Jasmine
    [202752] = { id = 202752, icon = GetItemIcon(202752) }, -- Whiptail
    [1623] = { id = 1623, icon = GetItemIcon(1623) },       -- Wild Steelbloom
}

related.drinking = { id = 104270, name = GetSpellInfo(104270) }
related.eating = { id = 104935, name = GetSpellInfo(104935) }

related.buffs = {
    stat      = "90363||20217||115921||1126",
    stamina   = "469||90364||109773||21562",
    atkpwr    = "19506||57330||6673",
    atkspeed  = "55610||113742||30809||128432||128433",
    spllpwr   = "77747||109773||126309||61316||1459",
    spllhaste = "24907||15473||51470||49868",
    crit      = "17007||1459||61316||116781||97229||24604||90309||126373||126309",
    mastery   = "116956||19740||93435||128997",
}

related.debuffList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT:debuff(id) then
            return true
		end
	end
end

related.debuffAnyList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT:debuffAny(id) then
            return true
		end
	end
end

related.buffList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT:buff(id) then
            return true
		end
	end
end

related.buffAnyList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT:buffAny(id) then
            return true
		end
	end
end

related.ignoreIdList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT.id == id then
            return true
		end
	end
end

related.interactIdList = function(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT.id == id then
            return true
		end
	end
end

related.castingIdList = function(UNIT, tbl)
    for _, spellname in pairs(tbl) do
        if UNIT:Casting(spellname) then
            return true
		end
	end
end

related.ignoreByBuff = {
    WaterBubble = 106062,
    ChargingSoul = 110945,
    AvatarofFlame = 15636,
    Protect = 123250,
    UnstableEnergy = 116994,
    AmberCarapace = 122540,
    Bulwark = 119476,
}

related.ignoreByCasting = {
    GetSpellInfo(137531),
    GetSpellInfo(137491),
    GetSpellInfo(138763)
}

function Queuer:Add(id, target, type)
    local spellName = GetSpellInfo(id)
    table.insert(self.Queue, {
        id = id,
        spellName = spellName,
        time = GetTime(),
        target = target,
        type = type,
	})
end

function Queuer:Add2(id, target, type)
    local spellName = GetSpellInfo(id)
	for k,_ in ipairs(self.Queue) do
		if k > 1 then
			self.Queue[k]=nil
		end
	end
	self.Queue[1] = {
		id = id,
		spellName = spellName,
		time = GetTime(),
		target = target,
		type = type,
	}
end

function _A.Queuer:Spell(_, data)
	-- local ready = _A.DSL:Get("spell.ready")(_, data.id)
	local player = Object("player")
	local ready = player and data.id~=119996 and ( player:spellcooldown(data.id)<.24 and player:spellusable(data.id))
	return data and ready
end

function Queuer:Queued(spell)
    if spell then
        for _, v in pairs(self.Queue) do
            if v.id == spell or v.spellName == spell then
                return true
            else
                return false
            end
        end
    end
end

function Queuer:Execute()
	-- Process first item in queue (FIFO)
	local data = self.Queue[1]
	if not data then return end
	
	if (GetTime() - data.time) > 5 then
		table.remove(self.Queue, 1)
		elseif self:Spell(_, data) then
		if data.type == "spell" then
			local target = data.target or Object("target")
			if target then
				target:Cast(data.spellName)
				table.remove(self.Queue, 1)
				return true
			end
			elseif data.type == "ground" then
			local target = data.target
			if target then
				target:CastGround(data.spellName)
				table.remove(self.Queue, 1)
				return true
			end
		end
	end
end

_A.DSL:Register("queue", function(unit, spell)
	return Queuer:Add(spell, unit, "spell")
end)

_A.DSL:Register("queueGround", function(unit, spell)
	return Queuer:Add(spell, unit, "ground")
end)

_A.DSL:Register("queued", function(unit, spell)
    return Queuer:Queued(spell)
end)

-- Add this near the other initialization code
local oldCastCommand = SlashCmdList["CAST"]
SlashCmdList["CAST"] = function(msg)
	local player = Object("player")
	-- If in combat, block the cast
	if player:combat() then
		print("[Combat] Spell casting via /cast is disabled in combat")
		return
	end
	
	-- Out of combat, proceed with normal cast behavior
	oldCastCommand(msg)
end

-- Hook the other cast command variations
for _, cmd in ipairs({ "CAST" }) do
	_G["SLASH_" .. cmd .. "1"] = "/" .. string.lower(cmd)
	_G["SLASH_" .. cmd .. "2"] = "#" .. string.lower(cmd)
end
