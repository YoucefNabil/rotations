local _, _A = ...
C_Timer = _A.C_Timer
local player
local Object = _A.Object
-- Create GUI
local RelatedHelper_GUI = _A.Interface:BuildGUI({
    key = "RelatedHelper",
    width = 300,
    height = 440,
    title = "|cFFffd000Related Helper Settings|r",
    config = {
        { type = 'ruler' },
        { type = 'header',           text = "Related Helper", size = 20, align = "CENTER" },
        { type = 'ruler' },
        { type = 'header',           text = "LFG Settings",   size = 15, align = "LEFT" },
        { key = "enable_autoaccept", type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Auto Accept LFG",     default = false },
        { key = "enable_flashwow",   type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Flash WoW",           default = false },
        { key = "enable_autoleave",  type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Auto Leave Battlefield",     default = false },
        { type = 'spinner',          cw = 15,                 ch = 15,   size = 15,                           size = checkbox_tsize, text = "Delay Before Joining BGs: ", key = 'bg_delay', default = 0, step = 0.01, max = 30, min = 0 },
        { type = 'ruler' },
        { key = "enable_visuals",    type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Farm Visuals",        default = false },
        { key = "enable_autoloot",   type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Autoloot",            default = false },
        { key = "enable_autofarm",   type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Auto Farm",           default = false },
        { key = "enable_chaseback",  type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable Chase Back",          default = false },
        { key = "chaseback_key",     type = "input",          size = 15, text = "Chase Back Key",             default = "E", },
        { key = "enable_hsgrab",     type = "checkbox",       cw = 15,   ch = 15,                             size = 15,             text = "Enable HS Grab",             default = false },
        { type = 'spacer',           size = 10 },
        { key = "update_freq",       type = "spinner",        size = 15, text = "Update Frequency (seconds)", default = 0.05,        step = 0.05,                         min = 0.05,       max = 5 },
        { key = "draw_distance",     type = "spinner",        size = 15, text = "Draw Distance (yards)", default = 100,          step = 5,                            min = 10,         max = 400 },
    }
})

-- Add to menu
if not menu then menu = _A.Interface:AddCustomMenu("|rRelated Helper|r") end
_A.Interface:AddCustomSubMenu(menu, "|cFF349eebSettings|r", function() RelatedHelper_GUI.parent:Show() end)
RelatedHelper_GUI.parent:Hide()

-- Helper function to fetch settings
function RelatedHelper_GUI.F(_, key, default)
    return _A.Interface:Fetch('RelatedHelper', key, default or false)
end

-- Helper function to check if object is in our list
local function interactIdList(UNIT, tbl)
    for _, id in pairs(tbl) do
        if UNIT.id == id then
            return true
        end
    end
end

-- Drawing function
local drawn = false
local currentNodeKey = nil
local currentColor = nil
local function drawFarmNodes()
    if not RelatedHelper_GUI:F("enable_visuals") then
        if drawn then
            DrawTick:UnRender("farmVisuals")
            drawn = false
            currentNodeKey = nil
            currentColor = nil
        end
        return
    end

    local lineDistance = RelatedHelper_GUI:F("draw_distance")
    local foundNode = false

    for _, farm in pairs(_A.OM:Get('GameObject')) do
        if farm:distance() > lineDistance then return end
        if interactIdList(farm, _A.related.OreHerb) then
            foundNode = true
            local isInRange = farm:distance() <= 5
            local circleColor = isInRange and 0xC000ff00 or 0xC0ff0000

            -- Only redraw if something changed
            if not drawn or currentNodeKey ~= farm.key or currentColor ~= circleColor then
                local x, y, z = _A.ObjectPosition(farm.key)
                local object, rotation = { x, y, z }, { 0, 0, 0 }

                -- Only unrender if we're about to draw something new
                DrawTick:UnRender("farmVisuals")
                DrawTick:Render("farmVisuals", function()
                    Draw:Circle3D(object, 5, circleColor, 1, 0, true, 1.5, rotation, -1)
                end)

                drawn = true
                currentNodeKey = farm.key
                currentColor = circleColor
            end
            return -- Exit after finding and processing first node
        end
    end

    -- Only unrender if we previously had a node but now don't
    if not foundNode and drawn then
        DrawTick:UnRender("farmVisuals")
        drawn = false
        currentNodeKey = nil
        currentColor = nil
    end
end

-- HS Grab
local function hsgrab()
    if RelatedHelper_GUI:F("enable_hsgrab") then
        player = player or Object("player")
        if not player then
            return
        end
        if player:combat() then return end
        if player:iscastinganyspell() then return end
        local soulwell = 181621
        local healthstone = GetItemInfo(5512)
        local hasFreeSlot = false
        for i = 0, 4 do
            local freeSlots = GetContainerNumFreeSlots(i)
            if freeSlots > 0 then
                hasFreeSlot = true
                break
            end
        end
        if player:ItemCount(healthstone) == 0 and hasFreeSlot then
            for _, Obj in pairs(_A.OM:Get('GameObject')) do
                if Obj.id == soulwell then
                    if Obj:distance() <= 5 then
                        _A.InteractUnit(Obj.key)
                    end
                end
            end
        end
    end
end

C_Timer.NewTicker(1.5, hsgrab, false, "RelatedHelper_HSGrab")

-- Table to store looted corpses
local lootedCorpses = {}

-- autoloot
local function autoloot()
    if RelatedHelper_GUI:F("enable_autoloot") then
        player = player or Object("player")
        if not player then
            return
        end
        -- Don't loot if player is moving
        if player:moving() or player:combat() then
            return
        end

        for _, loot in pairs(_A.OM:Get('Dead')) do
            -- Only process if we haven't looted this corpse yet
            if not lootedCorpses[loot.guid] then
                if loot:distance() <= 5
                    and loot:hasloot()
                    and _A.GetNumLootItems() == 0
                then
                    _A.InteractUnit(loot.key)
                    -- Add to looted corpses table
                    lootedCorpses[loot.guid] = true
                end
            end
        end
    end
end

-- autofarm table
local lastInteractTime = {}

-- autofarm
local function autofarm()
    if RelatedHelper_GUI:F("enable_autofarm") then
        player = player or Object("player")
        if not player then
            return
        end
        
        -- Early returns for player states
        if player:combat() or player:moving() or player:IscastingAnySpell() then
            return
        end
        
        -- Don't try to interact if we're already looting
        if _A.GetNumLootItems() > 0 then
            return
        end

        -- autoFarm (ore / herbs / container)
        for _, farm in pairs(_A.OM:Get('GameObject')) do
            -- Check if it's a valid node first
            if interactIdList(farm, _A.related.OreHerb) and farm:distance() <= 5 then
                -- Check if we've interacted recently using guid (more reliable than key)
                local currentTime = GetTime()
                if lastInteractTime[farm.key] and (currentTime - lastInteractTime[farm.key] < 5) then
                    return
                end

                -- Attempt interaction and record the time
                lastInteractTime[farm.key] = currentTime
                _A.InteractUnit(farm.key)
                return -- Exit after attempting one interaction
            end
        end
    end
end

C_Timer.NewTicker(.1, autoloot, false, "RelatedHelper_Autoloot")
C_Timer.NewTicker(300, function()
    lootedCorpses = {}
end, false, "RelatedHelper_Autoloot_Reset")

C_Timer.NewTicker(.1, autofarm, false, "RelatedHelper_Autofarm")

-- Initialize
C_Timer.After(5, function()
    _A.LibDraw:Sync(drawFarmNodes)
    _A.LibDraw:Enable(RelatedHelper_GUI:F("update_freq", 0.05))
end)

-- Chase Back variables
_A.FaceAlways = true
local spells = {
    "Mortal Strike",
    "Slam",
    "Tiger Palm",
}

local function ChaseBack()
    if RelatedHelper_GUI:F("enable_chaseback") then
        player = player or Object("player")
        local target = Object("target")
        if player and target and target:Exists() and target:Enemy() and target:alive() and player:keybind(RelatedHelper_GUI:F("chaseback_key", "E")) then
            local tx, ty, tz = _A.ObjectPosition(target.guid)
            local px, py, pz = _A.ObjectPosition(player.guid)
            local facing = _A.ObjectFacing(target.guid)
            local destX = tx - math.cos(facing) * 1.5
            local destY = ty - math.sin(facing) * 1.5
            local now = _A.GetTime() or GetTime()

            -- Move to position behind target
            _A.ClickToMove(destX, destY, tz)

            -- Warrior specific charge logic
            if player:spec() == 71 and target:SpellRange("Charge") and
                not player:BuffAny("Bladestorm") and target:infront() and
                target:los() and not IsCurrentSpell(100) then
                target:cast("Charge")
            end
        end
    end
end

-- Update ticker with original name
C_Timer.NewTicker(0.1, ChaseBack, false, "moving")

-- Add flag clicking functionality
local heFLAGS = {
    ["Horde Flag"] = true,
    ["Alliance Flag"] = true,
    ["Alliance Mine Cart"] = true,
    ["Horde Mine Cart"] = true,
    ["Huge Seaforium Bombs"] = true,
    ["Orb of Power"] = true,
}

local function pull_location()
    return string.lower(select(2, GetInstanceInfo()))
end

-- Add location tracking
Listener:Add("RelatedHelper_Location", "PLAYER_ENTERING_WORLD", function(event)
    local location = pull_location()
    _A.pull_location = location
end)

-- Add flag clicking function
local function ClickPVPFlags()
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get('GameObject')) do
        if heFLAGS[Obj.name] then
            tempTable[#tempTable + 1] = {
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

-- Update the AutoAcceptLFG function
local function AutoAcceptLFG()
    -- Handle battlefield leave and flag clicking
    local function CheckBattlefieldLeave()
        if not _A.Cache.Utils.PlayerInGame then return end
        local player = Object("player")
        if not player then return end
        -- Add flag clicking functionality
        ClickPVPFlags()
        if RelatedHelper_GUI:F("enable_autoleave") then
            local battlefieldstatus = GetBattlefieldWinner()
            if battlefieldstatus ~= nil then
                if RelatedHelper_GUI:F("enable_flashwow") and not _A.IsForeground() then
                    _A.FlashWow()
                end
                LeaveBattlefield()
            end
        end
    end
    C_Timer.NewTicker(0.1, CheckBattlefieldLeave, false, "clickpvp")
    -- Handle LFG proposal
    local function OnLFGProposal(evt)
        if not _A.Cache.Utils.PlayerInGame then return end
        local player = Object("player")
        if not player then return end
        if not RelatedHelper_GUI:F("enable_autoaccept") then return end
        C_Timer.After(RelatedHelper_GUI:F("bg_delay_spin"), function()
            if evt == "LFG_PROPOSAL_SHOW" then
                if RelatedHelper_GUI:F("enable_flashwow") and not _A.IsForeground() then
                    _A.FlashWow()
                end
                _A.AcceptProposal()
            else
                for i = 1, 3 do
                    local status, _, _ = _A.GetBattlefieldStatus(i)
                    if status == "confirm" then
                        if RelatedHelper_GUI:F("enable_flashwow") and not _A.IsForeground() then
                            _A.FlashWow()
                        end
                        _A.CallWowApi("AcceptBattlefieldPort", i, 1)
                        _A.StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
                    end
                end
            end
        end)
    end

    -- Handle role check and ready check
    local function OnRoleCheck()
        if not _A.Cache.Utils.PlayerInGame then return end
        local player = Object("player")
        if not player then return end
        if not RelatedHelper_GUI:F("enable_autoaccept") then return end
        -- Set role as DPS
        --SetLFGRoles(false, false, true) -- q as dps (tank, healer, dps)
        -- Try direct button click first
        _A.CallWowApi("RunMacroText", "/click LFDRoleCheckPopupAcceptButton")
    end

    -- Add listeners with original names to maintain compatibility
    Listener:Add("BG", { 'LFG_PROPOSAL_SHOW', 'UPDATE_BATTLEFIELD_STATUS' }, OnLFGProposal)
    Listener:Add("BG2", { 'LFG_ROLE_CHECK_SHOW', 'LFG_READY_CHECK_SHOW' }, OnRoleCheck)

    -- Add battlefield leave and flag checker with original name
end

-- Initialize Auto Accept LFG
-- C_Timer.After(1, AutoAcceptLFG)
AutoAcceptLFG()

-- Return the plugin
return {
    title = "Related Helper",
    desc = "Visual aid for farming nodes",
    icon = "Interface\\Icons\\Trade_Herbalism",
    enabled = true
}
