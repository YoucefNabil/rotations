local mediaPath, _A = ...
local C_PB = C_PetBattles
local C_PJ = C_PetJournal
local C_Timer = C_Timer
local isRunning = false
local maxPetLvl = 0

local PB_GUI = _A.Interface:BuildGUI({
    key = "Related_PetBot",
    title = "|cFFffd000Related Pet Bot|r",
    width = 380,  -- Match RelatedHelper width
    height = 560, -- Match RelatedHelper height
    config = {
        { type = 'ruler' },
        { type = 'header',   text = "|cFF00FF00Related Pet Bot|r",         size = 20,          align = "Center" },
        { type = 'ruler' },
        { type = 'spacer',   size = 15 },

        -- Settings Group
        { type = 'header',   text = "|cFFFF6B00Settings|r",                size = 15,          align = "LEFT" },
        { type = "spinner",  text = "|cFFFFA500Change Pet at Health %:|r", key = "swapHealth", min = 10,        max = 100, default = 25, step = 1, cw = 15, ch = 15, size = 15 },
        { type = "checkbox", text = "|cFFFFA500Auto Trap|r",               key = "trap",       default = false, cw = 15,   ch = 15,      size = 15 },
        { type = "checkbox", text = "|cFFFFA500Only use favorite pets|r",  key = "favorites",  default = false, cw = 15,   ch = 15,      size = 15 },
        {
            type = "dropdown",
            text = "|cFFFFA500Team type:|r",
            key = "teamtype",
            list = {
                { text = "Battle Team",   key = "BattleTeam" },
                { text = "Leveling Team", key = "LvlngTeam" },
            },
            default = "BattleTeam",
            cw = 15,
            ch = 15,
            size = 15
        },
        { type = 'spacer', size = 5 },
        { type = 'ruler' },
        { type = 'spacer', size = 15 },

        -- Status Group
        { type = 'header', text = "|cFF00FFFFCurrent Status|r",    size = 15,    align = "center" },
        { type = 'spacer', size = 15 },
        -- Pet Slot 1
        { type = "text",   text = "|cFFFFA500Pet in slot 1:|r",    size = 15 },
        { type = "text",   size = 15,                              text = "...", key = 'petslot1' },
        { type = 'spacer', size = 5 },
        -- Pet Slot 2
        { type = "text",   text = "|cFFFFA500Pet in slot 2:|r",    size = 15 },
        { type = "text",   size = 15,                              text = "...", key = 'petslot2' },
        { type = 'spacer', size = 5 },
        -- Pet Slot 3
        { type = "text",   text = "|cFFFFA500Pet in slot 3:|r",    size = 15 },
        { type = "text",   size = 15,                              text = "...", key = 'petslot3' },
        { type = 'spacer', size = 15 },
        -- Last attack
        { type = "text",   text = "|cFFFFA500Last Used Attack:|r", size = 15 },
        { type = "text",   size = 15,                              text = "...", key = 'lastAttack' },
        { type = 'spacer', size = 5 },
        { type = 'ruler' },
        { type = 'spacer', size = 15 },

        -- Start/Stop Button
        {
            type = "button",
            text = "|cFF00FF00Start|r",
            width = 350,
            height = 25,
            callback = function(self, button)
                isRunning = not isRunning
                self:SetText(isRunning and "|cFFFF0000Stop|r" or "|cFF00FF00Start|r")
            end
        },
    }
})

function PB_GUI.F(_, key, default)
    return _A.Interface:Fetch('Related_PetBot', key, default or false)
end

if not menu then menu = _A.Interface:AddCustomMenu("|cFFffa500[Related] Related|r: Plugins") end
_A.Interface:AddCustomSubMenu(menu, "|cFF349eebPetBot|r", function() PB_GUI.parent:Show() end)
PB_GUI.parent:Hide()

local function getPetHealth(owner, index)
    return math.floor((C_PB.GetHealth(owner, index) / C_PB.GetMaxHealth(owner, index)) * 100)
end

local function scanJournal()
    local petTable = {}
    local _, petAmount = C_PJ.GetNumPets()
    for i = 1, petAmount do
        local guid, _, _, _, lvl, _, _, _, _ = C_PJ.GetPetInfoByIndex(i)
        local health, maxHealth, attack = C_PJ.GetPetStats(guid)
        local healthPercentage = math.floor((health / maxHealth) * 100)
        if healthPercentage > tonumber(PB_GUI:F('swapHealth_spin')) then
            petTable[#petTable + 1] = {
                guid = guid,
                lvl = lvl,
                attack = attack,
            }
        end
    end
    if petTable[1] then
        if PB_GUI:F('teamtype') == 'BattleTeam' then
            table.sort(petTable, function(a, b) return a.attack > b.attack end)
        else
            table.sort(petTable, function(a, b) return a.lvl > b.lvl end)
        end
        maxPetLvl = petTable[1].lvl
    end
    return petTable
end

local function scanLoadOut()
    local loadOut = {}
    for k = 1, 3 do
        local petID = C_PJ.GetPetLoadOutInfo(k)
        local _, _, level = C_PJ.GetPetInfoByPetID(petID)
        local health, maxHealth, attack = C_PJ.GetPetStats(petID)
        local healthPercentage = math.floor((health / maxHealth) * 100)
        loadOut[#loadOut + 1] = {
            health = healthPercentage,
            level = level,
            id = petID,
            attack = attack
        }
    end
    return loadOut
end

local function buildBattleTeam()
    if PB_GUI:F('teamtype') == 'BattleTeam' then
        local petTable = scanJournal()
        for i = 1, #petTable do
            if #petTable > 0 and not C_PJ.PetIsSlotted(petTable[i].guid) then
                local loadOut = scanLoadOut()
                for k = 1, #loadOut do
                    if loadOut[k].level < maxPetLvl then
                        if loadOut[k].level < maxPetLvl or loadOut[k].health < tonumber(PB_GUI:F('swapHealth_spin'))
                            or not C_PJ.PetIsFavorite(loadOut[k].id) and PB_GUI:F('favorites')
                            or loadOut[k].attack < petTable[i].attack then
                            C_PJ.SetPetLoadOutInfo(k, petTable[i].guid)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function buildLevelingTeam()
    if PB_GUI:F('teamtype') == 'LvlngTeam' then
        local petTable = scanJournal()
        for i = 1, #petTable do
            if #petTable > 0 and not C_PJ.PetIsSlotted(petTable[i].guid) then
                local loadOut = scanLoadOut()
                for k = 1, #loadOut do
                    if loadOut[k].level >= maxPetLvl then
                        if loadOut[k].level >= maxPetLvl or loadOut[k].health < tonumber(PB_GUI:F('swapHealth_spin'))
                            or not C_PJ.PetIsFavorite(loadOut[k].id) and PB_GUI:F('favorites') then
                            C_PJ.SetPetLoadOutInfo(k, petTable[i].guid)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function scanGroup()
    local petAmount = C_PB.GetNumPets(1)
    local goodPets = {}
    for k = 1, petAmount do
        local health = getPetHealth(1, k)
        if health > tonumber(PB_GUI:F('swapHealth_spin')) then
            goodPets[#goodPets + 1] = {
                id = k,
                health = health
            }
        end
    end
    table.sort(goodPets, function(a, b) return a.health > b.health end)
    return goodPets
end

local function PetSwap()
    local activePet = C_PB.GetActivePet(1)
    local goodPets = scanGroup()
    if #goodPets < 1 then
        C_PB.ForfeitGame()
    else
        for i = 1, #goodPets do
            if getPetHealth(1, activePet) <= tonumber(PB_GUI:F('swapHealth_spin')) then
                C_PB.ChangePet(goodPets[i].id)
                break
            end
        end
    end
    return false
end

local function scanPetAbilitys()
    local Abilitys = {}
    local activePet = C_PB.GetActivePet(1)
    local enemieActivePet = C_PB.GetActivePet(2)
    for i = 3, 1, -1 do
        local isUsable = C_PB.GetAbilityState(1, activePet, i)
        if isUsable then
            local _, name, icon, _, _, _, abilityPetType = C_PB.GetAbilityInfo(1, activePet, i)
            local enemieType = C_PB.GetPetType(2, enemieActivePet)
            local attackModifer = C_PB.GetAttackModifier(abilityPetType, enemieType)
            local power = C_PB.GetPower(1, activePet)
            local totalDmg = power * attackModifer
            Abilitys[#Abilitys + 1] = {
                dmg = totalDmg,
                name = name,
                icon = icon,
                id = i
            }
            --print(i..' '..totalDmg..'( '..power..' \ '..attackModifer..' \ '..numTurns..' )'..maxcooldown)
        end
    end
    table.sort(Abilitys, function(a, b) return a.dmg > b.dmg end)
    return Abilitys
end

local _lastAttack = ''
local function PetAttack()
    local Abilitys = scanPetAbilitys()
    for i = 1, #Abilitys do
        if #Abilitys > 1 and _lastAttack ~= Abilitys[i].name or #Abilitys <= 1 then
            if Abilitys[i] then
                _lastAttack = Abilitys[i].name
                PB_GUI.elements["lastAttack"]:SetText('|T' .. Abilitys[i].icon .. ':10:10|t' .. Abilitys[i].name)
                C_PB.UseAbility(Abilitys[i].id)
            end
        end
    end
    C_PB.SkipTurn()
end

C_Timer.NewTicker(0.5, (function()
    if PB_GUI.parent:IsShown() then
        local enemieActivePet = C_PB.GetActivePet(2)

        -- Pet 1 to 3
        for i = 1, 3 do
            local _, _, _, _, _, _, _, petName, petIcon = C_PJ.GetPetInfoByPetID(C_PJ.GetPetLoadOutInfo(i))
            PB_GUI.elements["petslot" .. i]:SetText('|T' .. petIcon .. ':10:10|t' .. petName)
        end

        if isRunning
            and not C_PB.IsWaitingOnOpponent() then
            if not C_PB.IsInBattle() then
                buildBattleTeam()
                buildLevelingTeam()
            else
                -- Trap
                if getPetHealth(2, enemieActivePet) <= 35
                    and PB_GUI:F('trap')
                    and C_PB.IsWildBattle()
                    and C_PB.IsTrapAvailable() then
                    C_PB.UseTrap()
                    -- Swap
                elseif not PetSwap() then
                    if C_PB.GetBattleState() == 3 then
                        PetAttack()
                    end
                end
            end
        end
    end
end), nil)
