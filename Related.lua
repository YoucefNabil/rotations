local _, _A = ...
-- Initialize gathering tables if they don't exist
_A.related = {}
local related = _A.related

related.trashMobs = {
    [40817] = true,      -- shadow of obsidius
    [39425] = function(obj) -- temple guardian anhur
        return obj:buff(74938) -- shield of light
    end,
    [39984] = true,      -- Malignant Trogg
    [45704] = true,      -- Lurking Tempest
    [52430] = function(obj) -- hakkar's chains
        return obj:buff(97417) -- barrier
    end,
    [42180] = function(obj) --toxitron
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
    [52755] = function(obj) --totem zul
        return obj:buff(97502) --refreshing totem
    end,
    [56448] = function(obj) -- wise mari
        return obj:buff(106062) -- water bubble
    end,
}

related.avoidMobs = function(obj)
    if not obj or not obj.id then return false end
    
    local check = relatedtrashMobs[obj.id]
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
related.OreHerb = {
    -- Ores
    181556, -- Adamantite Deposit
    185557, -- Ancient Gem Vein
    189978, -- Cobalt Deposit
    1731,   -- Copper Vein
    2055,   -- Copper Vein
    3763,   -- Copper Vein
    103713, -- Copper Vein
    181248, -- Copper Vein
    165658, -- Dark Iron Deposit
    202738, -- Elementium Vein
    181555, -- Fel Iron Deposit
    209311, -- Ghost Iron Deposit
    221538, -- Ghost Iron Deposit
    1734,   -- Gold Vein
    150080, -- Gold Vein
    181109, -- Gold Vein
    180215, -- Hakkari Thorium Vein
    1610,   -- Incendicite Mineral Vein
    1667,   -- Incendicite Mineral Vein
    19903,  -- Indurium Mineral Vein
    1735,   -- Iron Deposit
    181557, -- Khorium Vein
    209312, -- Kyparite Deposit
    181069, -- Large Obsidian Chunk
    2653,   -- Lesser Bloodstone Deposit
    2040,   -- Mithril Deposit
    150079, -- Mithril Deposit
    176645, -- Mithril Deposit
    185877, -- Nethercite Deposit
    202736, -- Obsidium Deposit
    73941,  -- Ooze Covered Gold Vein
    123310, -- Ooze Covered Mithril Deposit
    177388, -- Ooze Covered Rich Thorium Vein
    73940,  -- Ooze Covered Silver Vein
    123848, -- Ooze Covered Thorium Vein
    123309, -- Ooze Covered Truesilver Deposit
    195036, -- Pure Saronite Deposit
    202737, -- Pyrite Deposit
    181570, -- Rich Adamantite Deposit
    181569, -- Rich Adamantite Deposit
    189979, -- Rich Cobalt Deposit
    202741, -- Rich Elementium Vein
    209328, -- Rich Ghost Iron Deposit
    221539, -- Rich Ghost Iron Deposit
    209329, -- Rich Kyparite Deposit
    202739, -- Rich Obsidium Deposit
    202740, -- Rich Pyrite Deposit
    189981, -- Rich Saronite Deposit
    175404, -- Rich Thorium Vein
    209330, -- Rich Trillium Vein
    221540, -- Rich Trillium Vein
    189980, -- Saronite Deposit
    1733,   -- Silver Vein
    105569, -- Silver Vein
    181068, -- Small Obsidian Chunk
    324,    -- Small Thorium Vein
    150082, -- Small Thorium Vein
    176643, -- Small Thorium Vein
    1732,   -- Tin Vein
    2054,   -- Tin Vein
    3764,   -- Tin Vein
    103711, -- Tin Vein
    181249, -- Tin Vein
    191133, -- Titanium Vein
    209313, -- Trillium Vein
    221541, -- Trillium Vein
    2047,   -- Truesilver Deposit
    150081, -- Truesilver Deposit
    181108, -- Truesilver Deposit

    -- Herbs
    191019, -- Adder's Tongue
    181278, -- Ancient Lichen
    142141, -- Arthas' Tears
    176642, -- Arthas' Tears
    202749, -- Azshara's Veil
    176589, -- Black Lotus
    253069, -- Blacker Lotus
    142143, -- Blindweed
    183046, -- Blindweed
    181166, -- Bloodthistle
    1621,   -- Briarthorn
    3729,   -- Briarthorn
    1622,   -- Bruiseweed
    3730,   -- Bruiseweed
    202747, -- Cinderbloom
    2044,   -- Dragon's Teeth
    176639, -- Dreamfoil
    180168, -- Dreamfoil
    176584, -- Dreamfoil
    183045, -- Dreaming Glory
    181271, -- Dreaming Glory
    1619,   -- earthroot
    3726,   -- earthroot
    2042,   -- Fadeleaf
    181270, -- Felweed
    183044, -- Felweed
    2866,   -- Firebloom
    191303, -- Firethorn
    181276, -- Flame Cap
    221547, -- Fool's Cap
    209355, -- Fool's Cap
    190176, -- Frost Lotus
    190173, -- Frozen Herb
    190174, -- Frozen Herb
    190175, -- Frozen Herb
    206085, -- Frozen Herb
    142144, -- Ghost Mushroom
    189973, -- Goldclover
    209354, -- Golden Lotus
    221545, -- Golden Lotus
    176638, -- Golden Sansam
    180167, -- Golden Sansam
    176583, -- Golden Sansam
    2046,   -- Goldthorn
    1628,   -- Grave Moss
    209349, -- Green Tea Leaf
    221542, -- Green Tea Leaf
    176637, -- Gromsblood
    142145, -- Gromsblood
    202750, -- Heartblossom
    176588, -- Icecap
    190172, -- Icethorn
    2043,   -- Khadgar's Whisker
    1624,   -- Kingsblood
    190171, -- Lichbloom
    2041,   -- Liferoot
    1620,   -- Mageroyal
    3727,   -- Mageroyal
    181281, -- Mana Thistle
    176640, -- Mountain Silversage
    180166, -- Mountain Silversage
    176586, -- Mountain Silversage
    181279, -- Netherbloom
    185881, -- Netherdust Bush
    181280, -- Nightmare Vine
    1618,   -- peacebloom
    3724,   -- Peacebloom
    176641, -- Plaguebloom
    142140, -- Purple Lotus
    180165, -- Purple Lotus
    181275, -- Ragveil
    183043, -- Ragveil
    221543, -- Rain Poppy
    209353, -- Rain Poppy
    215412, -- Sha-Touched Herb
    214510, -- Sha-Touched Herb
    209350, -- Silkweed
    221544, -- Silkweed
    1617,   -- silverleaf
    3725,   -- Silverleaf
    209351, -- Snow Lily
    176587, -- Sorrowmoss
    202748, -- Stormvine
    2045,   -- Stranglekelp
    142142, -- Sungrass
    176636, -- Sungrass
    180164, -- Sungrass
    190170, -- Talandra's Rose
    181277, -- Terocone
    190169, -- Tiger Lily
    202751, -- Twilight Jasmine
    202752, -- Whiptail
    1623,   -- Wild Steelbloom
}
