local mediaPath, _A, _R = ...
C_Timer = _A.C_Timer
local player
local Object = _A.Object
_A.AutoLogin(false)

-- Create GUI
local RelatedHelper_GUI = _A.Interface:BuildGUI({
    key = "RelatedHelper",
    width = 380,
    height = 560,
    title = "|cFFffd000Related Helper Settings|r",
    config = {
        { type = 'ruler' },
        { type = 'header',           text = "|cFF00FF00Related Helper|r",        size = 20,                                                                                                                 align = "CENTER" },
        { type = 'ruler' },
		
        -- Battleground Settings Group
        { type = 'header',           text = "|cFFFF6B00Battleground Settings|r", size = 15,                                                                                                                 align = "LEFT" },
        { key = "enable_autoaccept", type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Auto Accept LFG",                                                                                                                            default = false },
        { key = "enable_flashwow",   type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Flash WoW",                                                                                                                                  default = false },
        { key = "enable_autoleave",  type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Auto Leave Battlefield",                                                                                                                            default = false },
        { key = 'bg_delay',          type = 'spinner',                           cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Delay Before Joining BGs: ",                                                                                                                        default = 0,    step = 0.01, max = 30, min = 0 },
        { type = 'ruler' },
		
        -- Farming Settings Group
        { type = 'header',           text = "|cFF00FFFFFarming Settings|r",      size = 15,                                                                                                                 align = "LEFT" },
        { key = "enable_visuals",    type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Farm Visuals",                                                                                                                               default = false },
        { key = "enable_autoloot",   type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Autoloot",                                                                                                                                   default = false },
        { key = "enable_autofarm",   type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Auto Farm",                                                                                                                                  default = false },
        { key = "update_freq",       type = "spinner",                           size = 15,                                                                                                                 text = "Update Frequency (seconds)", default = 0.05, step = 0.05,                                                                                                                                                min = 0.05,     max = 5 },
        { key = "draw_distance",     type = "spinner",                           size = 15,                                                                                                                 text = "Draw Distance (yards)",      default = 100,  step = 5,                                                                                                                                                   min = 10,       max = 400 },
        { type = 'ruler' },
		
        -- Button Delay Settings Group
        { type = 'header',           text = "|cFFFF0000Button Delay Settings|r", size = 15,                                                                                                                 align = "LEFT" },
        { type = 'text',             size = 15,                                  text = "Button delay helps to queue spells between rotation execution\nRecommended to keep enabled for better performance" },
        { type = "spacer",           size = 15 },
        { key = "hook_ActionBars",   type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "|cFFFFFF00Enable Button Delay|r",                                                                                                                   default = true },
        { key = "queueSpells",       type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Queue Spells\n|cFFffd000ON: |rQueue Spells with interrupting current cast\n|cFFffd000OFF: |rQueue Spells without interrupting current cast", default = false },
        { key = "queueMacros",       type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Queue Macros\n|cFFffd000ON: |rQueue Macros with interrupting current cast\n|cFFffd000OFF: |rQueue Macros without interrupting current cast", default = false },
        { key = "ququeOne",          type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Queue One\n|cFFffd000ON: |rOnly queues one ability at a time\n|cFFffd000OFF: |rQueues all abilities pressed",                                default = false },
		{ type = "spacer",           size = 15 },
        { type = 'ruler' },
		
        -- Combat Settings Group
        { type = 'header',           text = "|cFFFF69B4Combat Settings|r",       size = 15,                                                                                                                 align = "LEFT" },
        { key = "enable_chaseback",  type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Chase Back",                                                                                                                                 default = false },
        { key = "chaseback_key",     type = "input",                             size = 15,                                                                                                                 text = "Chase Back Key",             default = "E" },
        { key = "enable_hsgrab",     type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable HS Grab",                                                                                                                                    default = false },
        { type = 'ruler' },
		
        -- Advanced Settings Group
        { type = 'header',           text = "|cFF9370DBAdvanced Settings|r",     size = 15,                                                                                                                 align = "LEFT" },
        { key = "enable_glitch",     type = "checkbox",                          cw = 15,                                                                                                                   ch = 15,                             size = 15,      text = "Enable Mining Glitch",                                                                                                                              default = false },
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

_A.BUTTONHOOK_RELATED = nil
C_Timer.NewTicker(1, function() 
	player = Object("player")
	if player then _A.BUTTONHOOK_RELATED = RelatedHelper_GUI:F("hook_ActionBars")
	-- print(RelatedHelper_GUI:F("hook_ActionBars"))
	end
end, false, "updatevar")	

-- Helper function to check if object is in our list
local function interactIdList(UNIT, tbl)
    -- Check if the unit ID matches any herb or ore ID
    if tbl[UNIT.id] then
        return true
	end
    return false
end

-- Helper function to check if object is in our list and get its data
local function getNodeData(UNIT)
    local hasHerb = false
    local hasOre = false
	
    -- Check player's professions
    for _, key in pairs({ GetProfessions() }) do
        local _, _, _, _, _, _, skillline = GetProfessionInfo(key)
        if skillline == 182 then hasHerb = true end
        if skillline == 186 then hasOre = true end
	end
	
    -- Check herbs only if player has herbalism
    if hasHerb and _A.related.Herbs[UNIT.id] then
        return _A.related.Herbs[UNIT.id]
	end
	
    -- Check ores only if player has mining
    if hasOre and _A.related.Ores[UNIT.id] then
        return _A.related.Ores[UNIT.id]
	end
	
    return nil
end

-- Drawing function
local drawn = {}
local function drawFarmNodes()
    if not RelatedHelper_GUI:F("enable_visuals") then
        -- Clear all drawings if visuals are disabled
        DrawTick:UnRender("farmVisuals")
        drawn = {}
        return
	end
	
    local drawDistance = RelatedHelper_GUI:F("draw_distance_spin")
    local foundNodes = {}
    local hasHerb = false
    local hasOre = false
	
    for _, key in pairs({ GetProfessions() }) do
        local name, icon, rank, maxrank, numspells, spelloffset, skillline = GetProfessionInfo(key)
        if skillline == 182 then hasHerb = true end
        if skillline == 186 then hasOre = true end
	end
    if not hasHerb and not hasOre then return end
	
    -- Collect all valid nodes first
    for _, farm in pairs(_A.OM:Get('GameObject')) do
        local nodeData = getNodeData(farm)
        if farm:distance() <= drawDistance and nodeData then
            local isInRange = farm:distance() <= 5
            local circleColor = isInRange and 0xC000ff00 or 0xC0ff0000
            local x, y, z = _A.ObjectPosition(farm.key)
            foundNodes[farm.key] = {
                position = { x, y, z },
                color = circleColor,
                icon = nodeData.icon,
                id = nodeData.id,
                name = farm.name or "Unknown Node"
			}
		end
	end
	
    -- Remove drawings for nodes that no longer exist
    for key in pairs(drawn) do
        if not foundNodes[key] then
            drawn[key] = nil
		end
	end
	
    -- Clear and redraw all nodes
    DrawTick:UnRender("farmVisuals")
    local fontObj = Draw:LoadFont(mediaPath .. "calibrib.ttf", 24, "Latin")
    DrawTick:Render("farmVisuals", function()
        for key, node in pairs(foundNodes) do
            local needsUpdate = not drawn[key] or drawn[key] ~= node.color
            if needsUpdate then
                drawn[key] = node.color
			end
			
			
            -- Draw circle
            Draw:Circle3D(
                { node.position[1], node.position[2], node.position[3] }, -- position
                5,                                                        -- radius
                node.color,                                               -- color
                1,                                                        -- segments
                0,                                                        -- offset
                true,                                                     -- filled
                1.5,                                                      -- thickness
                { 0, 0, 0 },                                              -- rotation
                -1                                                        -- layer
			)
			
			
			
            -- Draw text above the node
            local textpos = { node.position[1], node.position[2], node.position[3] + 2.5 }
            Draw:Text3D(node.name, textpos, fontObj, 24, 0xFFFFFFFF, true, 0)
		end
	end)
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
    if RelatedHelper_GUI:F("enable_autofarm") or RelatedHelper_GUI:F("enable_glitch") then
        player = player or Object("player")
        if not player then
            return
		end
		
        local hasFreeSlot = false
        for i = 0, 4 do
            local freeSlots = _A.GetContainerNumFreeSlots(i)
            if freeSlots > 0 then
                hasFreeSlot = true
                break
			end
		end
		
        if not hasFreeSlot then
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
        local tempTable = {}
        for _, farm in pairs(_A.OM:Get('GameObject')) do
            -- Check if it's a valid node first
            if (interactIdList(farm, _A.related.Ores)) or (interactIdList(farm, _A.related.Herbs)) and farm:distance() <= 5 then
                tempTable[#tempTable + 1] = {
                    guid = farm.guid,
                    distance = farm:distance()
				}
			end
		end
		
        if #tempTable > 1 then
            table.sort(tempTable, function(a, b) return a.distance < b.distance end)
		end
		
        if tempTable[1] and lastInteractTime[tempTable[1].guid] and (GetTime() - lastInteractTime[tempTable[1].guid] < 5) then
            return
		end
        if tempTable[1] then
            lastInteractTime[tempTable[1].guid] = GetTime()
            return _A.ObjectInteract(tempTable[1].guid)
		end
	end
end

local function ClickFarm()
    if not RelatedHelper_GUI:F("enable_glitch") then return end
    local player = Object("player")
    if not player then return end
    local MapID = _A.MapId()
    if MapID ~= 959 then return end
    local hasFreeSlot = false
    for i = 0, 4 do
        local freeSlots = _A.GetContainerNumFreeSlots(i)
        if freeSlots > 0 then
            hasFreeSlot = true
            break
		end
	end
	
    if not hasFreeSlot then
        if not player:isCastingAnySpell() and player:ItemUsable(GetItemInfo(6948)) then
            player:UseItem(GetItemInfo(6948))
		end
        return
	end
	
    if player:IscastingAnySpell() or player:Dead() or player:Mounted() or player:LostControl() then
        return
	end
	
    if player then
        _A.AutoLogin(true)
        player:Macro("/logout")
	end
end

C_Timer.NewTicker(0.1, ClickFarm, false, "ClickFarm")

C_Timer.NewTicker(.1, autoloot, false, "RelatedHelper_Autoloot")
C_Timer.NewTicker(300, function()
    lootedCorpses = {}
end, false, "RelatedHelper_Autoloot_Reset")

C_Timer.NewTicker(.1, autofarm, false, "RelatedHelper_Autofarm")

-- Initialize
C_Timer.After(5, function()
    _A.LibDraw:Sync(drawFarmNodes)
    _A.LibDraw:Enable(RelatedHelper_GUI:F("update_freq_spin"))
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

-- Create a table with names instead of IDs
local heFLAGS = {
    [179830] = true, -- Alliance Flag (Base)
    [179785] = true, -- Alliance Flag (Open Field)
    [179831] = true, -- Horde Flag (Base)
    [179786] = true, -- Horde Flag (Open Field)
    [220164] = true, -- Alliance Mine Cart
    [220166] = true, -- Horde Mine Cart
    [212091] = true, -- Orb of Power
    [212092] = true, -- Orb of Power
    [212093] = true, -- Orb of Power
    [212094] = true, -- Orb of Power
    [195332] = true, -- Huge Seaforium Bombs
    [195333] = true, -- Huge Seaforium Bombs
    [184142] = true, -- Netherstorm Flag
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
        if heFLAGS[Obj.id] then
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

-- BUTTON DELAY functionality
local function ParseMacroBody(body)
    if not body then return nil, nil end
	
    -- First, clean up the input by removing any leading/trailing whitespace
    body = string.gsub(body, "^%s*(.-)%s*$", "%1")
	
    -- Pattern to match variations of cast commands
    -- Will match: cast [@mouseover] Fear, cast [target=focus] Fear, cast Fear
    local target = string.match(body, "@([%w_]+)") or string.match(body, "target=([%w_]+)")
    local spellName = string.match(body, "]%s*([^%[]+)$") or string.match(body, "cast%s+([^%[]+)$")
	
    if spellName then
        spellName = string.gsub(spellName, "^%s*(.-)%s*$", "%1")
	end
	
    return target, spellName
end

_A.hooksecurefunc("UseAction", function(...)
    player = player or Object("player")
    if not RelatedHelper_GUI:F("hook_ActionBars") then
        return
	end
	local inTarget = Object("target") or Object("player")
	if not inTarget then return end
	-- if not player:combat() then return end
	local slot, target, clickType = ...
	local Type, id
	local blacklistedSpells = {
		[121827] = true, -- Roll
		[121828] = true, -- Chi Torpedo
	}
	if slot and clickType ~= nil then
		Type, id = _A.GetActionInfo(slot)
		if blacklistedSpells[id] then
			return
		end
		if Type == "spell" then
			-- _A.ui:alert({
			-- text = "Pressed " .. GetSpellInfo(id),
			-- icon = select(3, GetSpellInfo(id)),
			-- fade = { 2, 0.175, 0.3 },
			-- size = 20
			-- })
			_A.C_Timer.After(0.2, function()
				if player:lastCast(id) and player:lastCastSeen(id) <= player:SpellCasttime(id) then return end
				local castid, channelid = player:UnitCastID()
				if RelatedHelper_GUI:F("queueSpells") and castid ~= id and channelid ~= id then
					_A.SpellStopCasting()
				end
				return RelatedHelper_GUI:F("ququeOne") and _A.Queuer:Add2(id, inTarget, "spell") or _A.Queuer:Add(id, inTarget, "spell")
			end)
		end
		if Type == "macro" then
			if not RelatedHelper_GUI:F("queueMacros") then return end
			local name, icon, body, isLocal = _A.GetMacroInfo(id)
			local macroTarget, spellName = ParseMacroBody(body)
			local acceptedTargets = {
				["player"] = true,
				["target"] = true,
				["focus"] = true,
				["mouseover"] = true,
				["pet"] = true,
				["pettarget"] = true,
				["arena1"] = true,
				["arena2"] = true,
				["arena3"] = true,
				["arena4"] = true,
				["arena5"] = true,
				["boss1"] = true,
				["boss2"] = true,
				["boss3"] = true,
				["boss4"] = true,
				["boss5"] = true,
				["cursor"] = true,
			}
			if not acceptedTargets[macroTarget] then return end
			-- Get the appropriate target based on macro conditions
			local targetObj
			if macroTarget and macroTarget ~= "cursor" and acceptedTargets[macroTarget] then
				targetObj = Object(macroTarget)
			end
			if macroTarget == "cursor" and spellName then
				local cursor = Object("cursor")
				_A.SpellStopCasting()
				_A.SpellCancelQueuedSpell()
				if RelatedHelper_GUI:F("ququeOne") then _A.Queuer:Add2(spellName, cursor, "ground")
					else
					_A.Queuer:Add(spellName, cursor, "ground")
				end
				return
			end
			-- Use the found target or fall back to default target
			local finalTarget = targetObj.guid or inTarget.guid
			
			if finalTarget and spellName then
				if player:lastCast(spellName) and player:lastCastSeen(spellName) <= player:SpellCasttime(spellName) then return end
				local spell = UnitCastingInfo("player")
				if RelatedHelper_GUI:F("queueSpells") and spell ~= spellName then
					_A.SpellStopCasting()
					return RelatedHelper_GUI:F("ququeOne") and _A.Queuer:Add2(spellName, finalTarget, "spell") or _A.Queuer:Add(spellName, finalTarget, "spell")
					else
					return RelatedHelper_GUI:F("ququeOne") and _A.Queuer:Add2(spellName, finalTarget, "spell") or _A.Queuer:Add(spellName, finalTarget, "spell")
				end
			end
		end
	end
end)

-- Return the plugin
return {
    title = "Related Helper",
    desc = "Visual aid for farming nodes",
    icon = "Interface\\Icons\\Trade_Herbalism",
    enabled = true
}
