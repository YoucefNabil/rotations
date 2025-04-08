local addonName, _A, _R = ...
local _G = _A._G
local Version = "v2.65"
local isEnabled = false
local fishCount = 0
local startTime = 0
local timer = nil
local bobberInteracted = false
local attempt = false
local fired_b = false
local lure_applied = false

local wowDirectory = _A.GetWoWDirectory()
local DebugPath = wowDirectory .. "\\Debug.lua"
local contents = _A.ReadFile(wowDirectory .. "\\Players.lua")

local DM_B = {}
local FishSpace = {}

local MonitorFrame = CreateFrame("FRAME", "FishingFrame")

local playerWhisperCount = {}
local playerLastWhisperTime = {}
local playerSayCount = {}
local playerLastSayTime = {}

local _Check = false
local lastPlayerPosition = { x = nil, y = nil, z = nil }

local LooterFr = CreateFrame("Frame")

local fphr = CreateFrame("Frame", UIParent)
local FPHc = 0

local freeSpaceSended = false

function SafeCallApi(apiName, ...)
	local results = { pcall(_A.CallWowApi, apiName, ...) }
	local success = table.remove(results, 1)
	if success then
		if #results == 1 and results[1] == "attempt to call a nil value" then
			if _A[apiName] then
				return _A[apiName](...)
			else
				_A.print("Function '" .. apiName .. "' does not exist, check code!")
			end
		else
			return unpack(results)
		end
	else
		_A.print('CallWowApi not exist.')
	end
end

_S = {}
setmetatable(_S, {
	__index = function(_, apiName)
		return function(...)
			return SafeCallApi(apiName, ...)
		end
	end
})

local messages = {
	"Reticulating splines...",
	"Swapping time and space...",
	"Tokenizing real life...",
	"Bending the spoon...",
	"We need a new fuse...",
	"The bits are breeding",
	"Follow the white rabbit",
	"Are we there yet?",
	"It's not you. It's me.",
	"Counting backwards from Infinity",
	"Embiggening Prototypes",
	"Creating time-loop inversion field",
	"Spinning the wheel of fortune...",
	"I'm sorry Dave, I can't do that.",
	"Adjusting flux capacitor...",
	"Cleaning off the cobwebs...",
	"Spinning the hamster…",
	"Stay awhile and listen..",
	"Convincing AI not to turn evil..",
	"How did you get here",
	"Constructing additional pylons...",
	"Roping some seaturtles...",
	"Dividing by zero...",
	"Proving P=NP...",
	"Entangling superstrings...",
	"Twiddling thumbs...",
	"Trying to sort in O(n)...",
	"Winter is coming...",
	"Aw, snap! Not..",
	"Ordering 1s and 0s...",
	"Updating dependencies...",
	"Please wait... Consulting the manual...",
	"Mining some bitcoins...",
	"Initializing the initializer...",
	"Optimizing the optimizer...",
	"Pushing pixels...",
	"Building a wall...",
	"Running with scissors...",
	"Definitely not a virus...",
	"You may call me Steve.",
	"Obfuscating quantum entaglement",
	"Making breakfast...",
	"Combing the desert...",
	"Yes, yes. Yes. Without the oops."
}

local fishing_pools = {
	[180751] = true,
	[398778] = true,
	[216764] = true,
	[180682] = true,
	[382090] = true,
	[382180] = true,
	[401847] = true,
	[180684] = true,
	[182956] = true,
	[180901] = true,
	[402921] = true,
	[192054] = true,
	[180712] = true,
	[182959] = true,
	[381101] = true,
	[212174] = true,
	[192051] = true,
	[377938] = true,
	[192049] = true,
	[212169] = true,
	[373437] = true,
	[192050] = true,
	[229072] = true,
	[229069] = true,
	[221549] = true,
	[180658] = true,
	[373439] = true,
	[216761] = true,
	[218648] = true,
	[413568] = true,
	[211423] = true,
	[373441] = true,
	[377957] = true,
	[226967] = true,
	[192059] = true,
	[212171] = true,
	[218539] = true,
	[212175] = true,
	[202777] = true,
	[218649] = true,
	[218632] = true,
	[229070] = true,
	[212163] = true,
	[218652] = true,
	[218653] = true,
	[218630] = true,
	[202778] = true,
	[218629] = true,
	[218636] = true,
	[202779] = true,
	[208311] = true,
	[210216] = true,
	[229073] = true,
	[212172] = true,
	[218634] = true,
	[237342] = true,
	[229068] = true,
	[246491] = true,
	[218650] = true,
	[218635] = true,
	[382123] = true,
	[267437] = true,
	[184845] = true,
	[341344] = true,
	[381098] = true,
	[243325] = true,
	[218651] = true,
	[250642] = true,
	[229071] = true,
	[381100] = true,
	[293750] = true,
	[259930] = true,
	[194479] = true,
	[278401] = true,
	[214547] = true,
	[381099] = true,
	[182951] = true,
	[273294] = true,
	[246488] = true,
	[246490] = true,
	[278404] = true,
	[378271] = true,
	[227868] = true,
	[381097] = true,
	[325890] = true,
	[218576] = true,
	[260003] = true,
	[247586] = true,
	[246489] = true,
	[236756] = true,
	[246492] = true,
	[246493] = true,
	[349088] = true,
	[381062] = true,
	[237295] = true,
	[267574] = true,
	[247497] = true,
	[211169] = true,
	[243354] = true,
	[254059] = true,
	[327162] = true,
	[207734] = true,
	[246679] = true,
	[381096] = true,
	[218578] = true,
	[381061] = true,
	[379275] = true,
	[252110] = true,
	[381060] = true,
	[349083] = true,
	[247490] = true,
	[370396] = true,
	[207724] = true,
	[251950] = true,
	[247582] = true,
	[328414] = true,
	[250680] = true,
	[254058] = true,
	[247581] = true,
	[254057] = true,
	[254056] = true,
	[254054] = true,
	[323370] = true,
	[381717] = true,
	[260004] = true,
	[260005] = true,
	[260009] = true,
	[381058] = true,
	[349086] = true,
	[293749] = true,
	[349084] = true,
	[278403] = true,
	[218577] = true,
	[250681] = true,
	[246677] = true,
	[250679] = true,
	[246676] = true,
	[247587] = true,
	[254055] = true,
	[247489] = true,
	[254060] = true,
	[247584] = true,
	[247590] = true,
	[254061] = true,
	[381059] = true,
	[259931] = true,
	[247580] = true,
	[260002] = true,
	[260006] = true,
	[260007] = true,
	[349082] = true,
	[246554] = true,
	[326054] = true,
	[278402] = true,
	[327161] = true,
	[180662] = true,
	[180685] = true,
	[192053] = true,
	[182957] = true,
	[182952] = true,
	[192046] = true,
	[180248] = true,
	[192052] = true,
	[180369] = true,
	[180655] = true,
	[192048] = true,
	[180664] = true,
	[192057] = true,
	[180683] = true,
	[180661] = true,
	[180902] = true,
	[180752] = true,
	[180184] = true,
	[180656] = true,
	[182953] = true,
	[182954] = true,
	[182958] = true,
	[180582] = true,
	[180750] = true,
	[229067] = true,
	[202776] = true,
	[221548] = true,
	[218633] = true,
	[246553] = true,
	[278406] = true,
	[202780] = true,
	[218631] = true,
	[341343] = true,
	[278399] = true,
	[254062] = true,
	[247583] = true,
	[278405] = true,
	[246678] = true,
	[349087] = true,
	[212177] = true,
	[260008] = true,
	[247589] = true
}

if not contents then
	_A.WriteFile(wowDirectory .. "\\Players.lua", date() .. ' | LOG Created |' .. "\n", true) -- just to generate file...
end

local function discord_data(message, color)
	local data = {
		embeds = {
			{
				title = "[Fish-Bot Monitor]",
				description = message,
				color = color
			}
		}
	}
	return data
end
local safe_cast = CreateFrame("Frame")
local function RegisterEvent(eventName, callback)
	safe_cast:RegisterEvent(eventName)
	safe_cast:SetScript("OnEvent", function(self, event, ...)
		callback(event, ...)
	end)
end

MonitorFrame:RegisterEvent("CHAT_MSG_WHISPER")
MonitorFrame:RegisterEvent("CHAT_MSG_SAY")
MonitorFrame:RegisterEvent("CHAT_MSG_YELL")
MonitorFrame:RegisterEvent("CHAT_MSG_EMOTE")

local function onUpdate(self, elapsed)
	if self.time and self.time < _A.GetTime() - 2.8 then
		if self:GetAlpha() > 0 then
			local newAlpha = self:GetAlpha() - 0.05
			if newAlpha < 0 then
				newAlpha = 0
			end
			self:SetAlpha(newAlpha)
		else
			self:Hide()
		end
	end
end

local notify = CreateFrame("Frame", nil, ChatFrame1)
notify:SetSize(ChatFrame1:GetWidth(), 30)
notify:Hide()
notify:SetScript("OnUpdate", onUpdate)
notify:SetPoint("TOP", 0, 5)
notify.text = notify:CreateFontString(nil, "OVERLAY", "MovieSubtitleFont")
notify.text:SetAllPoints()
notify.texture = notify:CreateTexture()
notify.texture:SetAllPoints()
notify.texture:SetTexture(0, 0, 0, 0.40)
notify.time = 0

function notify:message(message)
	self.text:SetText(message)
	self:SetAlpha(1)
	self.time = _A.GetTime()
	self:Show()
end

local TextAnim = CreateFrame("Frame", nil, UIParent)
TextAnim.elapsed = 0
TextAnim:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	-- Calculate RGB values based on time
	local r = math.abs(math.sin(self.elapsed * 2))
	local g = math.abs(math.sin(self.elapsed * 3))
	local b = math.abs(math.sin(self.elapsed * 5))


	if fphr:IsShown() then
		fphr:SetBackdropBorderColor(r, g, b, 1)
	end

	-- Set the RGB color to the statusMessage
	if notify:IsShown() then
		local statusMessage = isEnabled and
			"|cff" .. string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. "FB: Enabled|r" or
			"|cff" .. string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. "FB: Disabled|r"
		notify:message(statusMessage)
	end
end)

local function _s(color, text)
	return "|cff" .. color .. text .. "|r"
end

local Bait_Txt = _s('ffffff', '[Enter multiple id: 123;1234;123;1234;...]')
local Plr_txt = _s('ffd000', 'WowDir\\Players.lua')
local Msg_txt = _s('ffd000', 'WowDir\\messages.lua')
local Log_txt = _s('ffd000', 'WowDir\\fishlog.lua')
local Info_GUI = _s('ffffff',
	'Last seen Players on exit: ' .. Plr_txt .. ' \nLast spotted say\\whispers: ' .. Msg_txt .. '\nBot Log: ' .. Log_txt)
local Warn_Txt = _s('ffffff', '[Do not move after start bot with that.]')
local Warn_Txt2 = _s('ffd000', 'Protection.\n' .. Warn_Txt)
local Title_GUI = _s('ffd000', 'Related Fish-Bot: ')
local Title_Header = _s('ffd000', 'Related Fish-Bot')
local Discord_WebHook = _s('ffd000', 'Enter discord webhook url:')
local Message_txt = _s('ffffff', 'After X say near me or whispers\nfrom certain person under 30 sec,\nwill ForceExit.')
local Message_Info = _s('ffd000', 'Message count:\n' .. Message_txt)
local BagsFree_Info = _s('ffd000', 'Maximum free slots:')
local Target_Txt2 = _s('ffffff',
	'Protection must be enabled.\nLeave from game if someone target you\nsummary for 30 sec under 1 minute.\nIf someone target you less 30s, you find his name in log.')
local Target_Txt = _s('ffd000', 'Protection: Check near players targets.\n' .. Target_Txt2)
local Bags_Txt = _s('ffd000', 'Protection: Exit on full bags?')
local BagsStop_Txt = _s('ffd000', 'Protection: Stop on full bags?')
local Pools_Txt = _s('ffd000', 'Auto-face near pool?')
local _min = _s('ffd000', 'Min.')
local _max = _s('ffd000', 'Max.')
local Money_Txt2 = _s('ffd000', 'Gold checker:')


local version_list = {
	{ key = "Wotlk", text = "WotLK" },
	{ key = "Cata",  text = "Cata" },
	{ key = "Mop",   text = "MoP" },
}

local FB_GUI = _A.Interface:BuildGUI({
	key = "Related_FishBot",
	width = 420,
	height = 700,
	title = Title_GUI,
	config = {
		-- Dummy Section
		{
			type = "section",
			dummy = true,
			contentHeight = 20,
		},
		{ type = 'header',   text = Title_Header, size = 14, align = 'CENTER' },

		{
			type = "section",
			size = 14,
			text = "|cFFffd000Version Settings|r",
			align = "CENTER",
			contentHeight = 20,
			expanded = false,
			height = 20,
		},

		-- Info Section
		{ type = "dropdown", key = "u_version",   size = 15, text = "Select Version", desc = "", default = "Mop", list = version_list },

		-- Protection Section
		{
			type = "section",
			size = 14,
			text = "|cFFffd000Protection Settings|r",
			align = "CENTER",
			contentHeight = 235,
			expanded = false,
			height = 20,
		},
		{ type = 'spacer',   size = 8 },
		{ type = "checkbox", key = "u_protection",  cw = 15,     ch = 15,     size = 12, text = Warn_Txt2,     default = false },
		{ type = 'spacer',   size = 8 },
		{ type = "checkbox", key = "u_Targetleave", cw = 15,     ch = 15,     size = 12, text = Target_Txt,    default = false },
		{ type = 'spacer',   size = 8 },
		{ type = "checkbox", key = "u_Bagsleave",   cw = 15,     ch = 15,     size = 12, text = Bags_Txt,      default = false },
		{ type = 'spacer',   size = 8 },
		{ type = "checkbox", key = "u_BagsStop",    cw = 15,     ch = 15,     size = 12, text = BagsStop_Txt,  default = false },
		{ type = 'spacer',   size = 8 },
		{ type = "spinner",  key = "u_BagsFree",    width = 200, height = 20, size = 12, text = BagsFree_Info, default = 2,    step = 1, min = 1, max = 350 },
		{ type = 'spacer',   size = 8 },
		{ type = "spinner",  key = "u_message",     width = 200, height = 20, size = 12, text = Message_Info,  default = 2,    step = 1, min = 1, max = 300 },
		{ type = 'spacer',   size = 12 },

		-- Discord Section
		{
			type = "section",
			size = 14,
			text = "|cFFffd000Discord Integration|r",
			align = "CENTER",
			contentHeight = 50,
			expanded = false,
			height = 20,
		},
		{ type = 'spacer', size = 8 },
		{ type = 'text',   text = Discord_WebHook, size = 12 },
		{ type = 'spacer', size = 6 },
		{ type = 'input',  key = "u_discord",      size = 10, width = 380, text = '' },
		{ type = 'spacer', size = 12 },

		-- Timing Section
		{
			type = "section",
			size = 14,
			text = "|cFFffd000Timing Settings|r",
			align = "CENTER",
			contentHeight = 160,
			expanded = false,
			height = 20,
		},
		{ type = 'spacer',  size = 8 },
		{ type = 'text',    text = "Interact Delay", size = 12,   align = 'CENTER' },
		{ type = 'spacer',  size = 6 },
		{ type = "spinner", key = "u_float1",        width = 200, size = 12,       text = _min, default = 0.4, step = 0.1, min = 0.1, max = 5 },
		{ type = "spinner", key = "u_float1_",       width = 200, size = 12,       text = _max, default = 1.2, step = 0.1, min = 0.1, max = 5 },
		{ type = 'spacer',  size = 8 },
		{ type = 'text',    text = "Cast Delay",     size = 12,   align = 'CENTER' },
		{ type = 'spacer',  size = 6 },
		{ type = "spinner", key = "u_float2",        width = 200, size = 12,       text = _min, default = 0.4, step = 0.1, min = 0.1, max = 5 },
		{ type = "spinner", key = "u_float2_",       width = 200, size = 12,       text = _max, default = 1.2, step = 0.1, min = 0.1, max = 5 },
		{ type = 'spacer',  size = 8 },
		{ type = 'text',    text = "Re-cast Delay",  size = 12,   align = 'CENTER' },
		{ type = 'spacer',  size = 6 },
		{ type = "spinner", key = "u_float3",        width = 200, size = 12,       text = _min, default = 0.4, step = 0.1, min = 0.1, max = 5 },
		{ type = "spinner", key = "u_float3_",       width = 200, size = 12,       text = _max, default = 1.2, step = 0.1, min = 0.1, max = 5 },
		{ type = 'spacer',  size = 12 },

		-- Features Section
		{
			type = "section",
			size = 14,
			text = "|cFFffd000Features|r",
			align = "CENTER",
			contentHeight = 200,
			expanded = false,
			height = 20,
		},
		{ type = 'spacer',   size = 6 },
		{ type = 'input',    key = "u_bait",    size = 10, width = 380,     text = '' },
		{ type = 'spacer',   size = 6 },
		{ type = 'text',     text = Bait_Txt,   size = 11, align = 'CENTER' },
		{ type = 'spacer',   size = 8 },
		{ type = 'text',     text = Money_Txt2, size = 12 },
		{ type = 'spacer',   size = 6 },
		{ type = 'input',    key = "u_money",   size = 10, width = 380,     text = '' },
		{ type = 'spacer',   size = 8 },
		{ type = "checkbox", key = "u_pools",   cw = 15,   ch = 15,         size = 12, text = Pools_Txt, default = false },
		{ type = 'spacer',   size = 12 },

		-- Info Section
		{ type = 'text',     text = Info_GUI,   size = 11 },
		{ type = "spacer",   size = 12 }, -- apofis buttons fucked somehow...

		-- Start/Stop Button
		{
			type = "button",
			text = 'Start\\Stop',
			width = 240,
			height = 30,
			callback = function()
				DM_B.Start()
			end,
			align = 'CENTER'
		},
		{ type = "spacer", size = 12 }, -- apofis buttons fucked somehow...

	}
})

function FB_GUI.F(_, key, default)
	return _A.Interface:Fetch('Related_FishBot', key, default or false)
end

if not menu then menu = _A.Interface:AddCustomMenu("|cFFffa500[Related] Related|r: Plugins") end
_A.Interface:AddCustomSubMenu(menu, "|cFF349eebFish-Bot|r", function() FB_GUI.parent:Show() end)
--_A.Interface:Add("|cFFffa500[Related] FishBot|r", function() FB_GUI.parent:Show() end)
FB_GUI.parent:Hide()


function FishSpace.getLatency()
	local lag = select(3, _A.GetNetStats()) / 1000
	if lag < 0.05 then
		lag = 0.05
	elseif lag > 0.4 then
		lag = 0.4
	end
	return lag
end

function FishSpace.pos_reset()
	if lastPlayerPosition.x ~= nil then lastPlayerPosition.x = nil end
	if lastPlayerPosition.y ~= nil then lastPlayerPosition.y = nil end
	if lastPlayerPosition.z ~= nil then lastPlayerPosition.z = nil end
end

function DM_B.Start()
	isEnabled = not isEnabled
	local statusMessage = isEnabled and "Enabled" or "Disabled"
	notify:message(statusMessage)
	FishSpace.pos_reset()
	if isEnabled then
		if not fphr:IsShown() then
			fphr:Show()
		end
	else
		if fphr:IsShown() then
			fphr:Hide()
		end
	end
	freeSpaceSended = false
	LooterFr[isEnabled and "RegisterEvent" or "UnregisterEvent"](LooterFr, "LOOT_CLOSED")
	_A.C_Timer.After(1.5, function() notify:Hide() end)
end

_A.C_Timer.NewTicker(FishSpace.getLatency(), function() -- server lag based
	local enabled = isEnabled
	if enabled then
		DM_B.Looper()
	end
end)


function FishSpace.sendToDiscord(data, webhookURL)
	local json = _G.json:encode(data)
	local url = webhookURL
	_G.http:request("POST", url, json, function() end)
end

function FishSpace.cstng()
	local chnnl = _A.UnitChannelInfo('player')
	if UnitCastingInfo('player') or chnnl and chnnl ~= _A.GetSpellInfo(18248) then
		return true
	end
	return false
end

function FishSpace.NotHasCD(itemID)
	local cooldown = _A.DSL:Get("item.cooldown")(_, itemID)
	if cooldown == 0 then
		return true
	end
	return false
end

function FishSpace.spelltoName(spellID)
	return tostring(select(1, _A.GetSpellInfo(spellID)))
end

function FishSpace.getBobber()
	local bobberID = 35591
	for _, data in pairs(_A.OM.GameObject) do
		if data.id == bobberID and _A.ObjectCreator(data.key) == _A.UnitGUID("Player") then
			return data.key
		end
	end
end

function FishSpace.getFishPool()
	for _, data in pairs(_A.OM.GameObject) do
		if _A.ObjectExists(data.key) then
			if fishing_pools[data.id] then
				return data.key
			end
		end
	end
end

function FishSpace.isBobbing()
	local bobber = FishSpace.getBobber()
	local version = FB_GUI:F("u_version")
	local _byte = ""

	if version == "Wotlk" then
		_byte = 0xBC
	end

	if version == "Cata" then
		_byte = 0xD4
	end

	if version == "Mop" then
		_byte = 0xCC
	end

	if _A.ObjectExists(bobber) then
		local AnimationStatus = _A.ReadMemory("byte", bobber, _byte)
		if AnimationStatus ~= 0 then
			return true
		end
	end
	return false
end

local Timestamp = 0
local Timestamp2 = 0
local Timestamp3 = 0
local cooldownTime = 1.2
local usableBaitID = false
local isTimerActive = false
local isTimer2Active = false
local isTimer3Active = false

local function gb()
	local bait = FB_GUI:F("u_bait")
	if bait then
		local baitIDs = { strsplit(";", bait) }
		for _, id in ipairs(baitIDs) do
			if FishSpace.NotHasCD(id) and _A.GetItemCount(id) > 0 then
				usableBaitID = id
				break
			else
				usableBaitID = false
			end
		end
	end
	return usableBaitID
end

local function randomFloat(min, max)
	min = min or 0.1                       -- default minimum value
	max = max or 1.2                       -- default maximum value
	if min > max then min, max = max, min end -- ensure min is less than max
	return min + math.random() * (max - min)
end

function FishSpace.Start_Fishing()
	local bobberObject = FishSpace.getBobber()
	local bait = FB_GUI:F("u_bait")
	local pools = FB_GUI:F("u_pools")
	local float1 = FB_GUI:F("u_float1_spin")
	local float1_ = FB_GUI:F("u_float1__spin")
	local float2 = FB_GUI:F("u_float2_spin")
	local float2_ = FB_GUI:F("u_float2__spin")
	local float3 = FB_GUI:F("u_float3_spin")
	local float3_ = FB_GUI:F("u_float3__spin")

	local baitID = gb()
	local lure_enchant = _A.GetWeaponEnchantInfo()
	local near_pool = FishSpace.getFishPool()

	if baitID and lure_enchant ~= 1 then
		if baitID and not lure_enchant ~= 1 then
			local currentTime = _A.GetTime()
			if currentTime - Timestamp2 >= 4 then
				_A.RunMacroText("/use item:" .. baitID)
				Timestamp2 = currentTime
				return true
			end
		end
		return
	end

	if pools and _A.ObjectExists(near_pool) then
		local distance = _A.GetDistanceBetweenObjects("player", near_pool)
		local isFacing_pool = _A.UnitIsFacing("player", near_pool, 30)
		if not isFacing_pool then
			if distance < 20 then
				_A.FaceDirection(near_pool, true)
			end
			return
		end
	end

	if _A.ObjectExists(bobberObject) and FishSpace.isBobbing() and not isTimerActive then
		local delay = randomFloat(float1, float1_)
		isTimerActive = true
		_A.C_Timer.After(delay, function()
			_A.InteractUnit(bobberObject)
			Timestamp = currentTime
			isTimerActive = false
		end)
	end

	if FishSpace.cstng() then
		return
	end

	if not _A.ObjectExists(bobberObject) and not select(1, _A.UnitChannelInfo('player')) and not isTimer3Active then
		isTimer3Active = true
		local delay2 = randomFloat(float2, float2_)
		_A.C_Timer.After(delay2, function()
			_A.CastSpellByName(_A.GetSpellInfo(7620))
			isTimer3Active = false
		end)
	end


	local function LooterFrOnEvent(self, event, ...)
		if not isTimer2Active then -- :\
			local delay = randomFloat(float3, float3_)

			isTimer2Active = true

			_A.C_Timer.After(delay, function()
				_A.CastSpellByName(_A.GetSpellInfo(7620))
				Timestamp = currentTime
				isTimer2Active = false
			end)
		end
	end

	LooterFr:SetScript("OnEvent", LooterFrOnEvent)
end

function FishSpace.log_players()
	local discord = FB_GUI:F("u_discord")

	if discord and string.len(discord) > 5 and not attempt then
		attempt = true
		local DiscordMessage = string.format(
			'%s | Who: %s | in: %s | Has exited, check logs.\n',
			date(), _A.UnitName("player"), _A.GetMinimapZoneText()
		)
		FishSpace.sendToDiscord(discord_data(DiscordMessage, 0xFF0000), discord)
	end

	local filePath = wowDirectory .. "\\Players.lua"
	local isNewPlayerAdded = false

	for _, data in pairs(_A.OM.All) do
		if _A.ObjectIsUnit(data.key) and _A.UnitIsPlayer(data.key) then
			local playerName = data.name
			local playerGuid = data.key
			local fileContents = _A.ReadFile(filePath)

			if fileContents then
				local isPresent = string.find(fileContents, playerGuid, 1, true)
				if not isPresent then
					_A.WriteFile(filePath, date() .. ' | ' .. playerName .. ' | ' .. playerGuid .. "\n", true)
					isNewPlayerAdded = true
				end
			else
				print('Error: fileContents is nil')
			end
		end
	end

	if not isNewPlayerAdded then
		_A.ForceQuit()
	end
end

MonitorFrame:SetScript("OnEvent", function(self, event, msg, sender, ...)
	if isEnabled then
		local e_pp = FB_GUI:F('u_protection')
		local e_msgc = FB_GUI:F('u_message')

		local logMessage = string.format(
			'%s | %s | Who: %s | msg: %s | to: %s | in: %s\n',
			date(), event, sender, msg, _A.UnitName("player"), _A.GetMinimapZoneText()
		)
		_A.WriteFile(wowDirectory .. "\\messages.lua", logMessage, true)

		if e_pp then
			-- Check if the event is CHAT_MSG_WHISPER
			if event == "CHAT_MSG_WHISPER" then
				local currentTime = _A.GetTime()
				playerWhisperCount[sender] = (playerWhisperCount[sender] or 1) + 1
				playerLastWhisperTime[sender] = currentTime
				if playerWhisperCount[sender] >= e_msgc and currentTime - playerLastWhisperTime[sender] <= 30 then
					local logMessage = string.format(
						'%s | Got more than %s Whispers within 30 seconds: Logout | %s in %s\n',
						date(), e_msgc, _A.UnitName("player"), _A.GetMinimapZoneText()
					)
					_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)
					FishSpace.log_players()
				end
			end

			-- Check if the event is CHAT_MSG_Say
			if event == "CHAT_MSG_SAY" then
				local currentTime = _A.GetTime()
				playerSayCount[sender] = (playerSayCount[sender] or 1) + 1
				playerLastSayTime[sender] = currentTime
				if playerSayCount[sender] >= e_msgc and currentTime - playerLastSayTime[sender] <= 30 then
					local logMessage = string.format(
						'%s | Got more than %s Says within 30 seconds: Logout | %s in %s\n',
						date(), e_msgc, _A.UnitName("player"), _A.GetMinimapZoneText()
					)
					_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)
					FishSpace.log_players()
				end
			end
		end
	end
end)


local function r_W(sender)
	playerWhisperCount[sender] = nil
	playerLastWhisperTime[sender] = nil
end

local function r_S(sender)
	playerSayCount[sender] = nil
	playerLastSayTime[sender] = nil
end


local ticker = _A.C_Timer.NewTicker(5, function()
	local currentTime = _A.GetTime()

	for s_S, s_T in pairs(playerLastSayTime) do
		if currentTime - s_T > 30 then
			r_S(s_S)
		end
	end
	for w_W, w_T in pairs(playerLastWhisperTime) do
		if currentTime - w_T > 30 then
			r_W(w_W)
		end
	end
end)

local function Start_Monitoring()
	local filePath = wowDirectory .. "\\Protection.lua"
	local isProtectionEnabled = FB_GUI:F('u_protection')
	local playerX, playerY, playerZ = _A.ObjectPosition('player')

	if lastPlayerPosition.x == nil then lastPlayerPosition.x = playerX end
	if lastPlayerPosition.y == nil then lastPlayerPosition.y = playerY end
	if lastPlayerPosition.z == nil then lastPlayerPosition.z = playerZ end

	if isProtectionEnabled then
		local newPlayerX, newPlayerY, newPlayerZ = _A.ObjectPosition('player')
		if _A.UnitIsDND('player') ~= 1 then
			local randomIndex = math.random(1, #messages)
			local randomMessage = messages[randomIndex]
			_A.RunMacroText("/dnd " .. randomMessage)
		end

		if _A.UnitAffectingCombat('player') or _A.UnitIsDeadOrGhost('player') then
			local logMessage = string.format(
				'%s | Got combat or died: Logout | %s in %s\n',
				date(), _A.UnitName("player"), _A.GetMinimapZoneText()
			)
			_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)
			FishSpace.log_players()
		end

		if newPlayerX ~= lastPlayerPosition.x or newPlayerY ~= lastPlayerPosition.y or newPlayerZ ~= lastPlayerPosition.z then
			local logMessage = string.format(
				'%s | Player moved: Logout | %s in %s\n',
				date(), _A.UnitName("player"), _A.GetMinimapZoneText()
			)
			_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)
			FishSpace.log_players()
		end
	end
end


local playerGUID = _A.UnitGUID("player")
local targetingTimes = {}
local targetTable = {}
local fired_d = false

local function target_monitoring()
	local discord = FB_GUI:F("u_discord")
	local currentTime = _A.GetTime()

	for _, unit in pairs(_A.OM:Get('All')) do
		if _A.ObjectExists(unit.key) and _A.ObjectIsPlayer(unit.key) then
			local pointer, tguid = _A.UnitTarget(unit.key)
			if tguid and tguid == playerGUID then
				local playerName = _A.UnitName(unit.key)
				local playerIndex = _A.UnitGUID(unit.key)

				if not targetingTimes[playerIndex] then
					targetingTimes[playerIndex] = currentTime
					targetTable[playerIndex] = playerName
				end

				local duration = currentTime - targetingTimes[playerIndex]
				if duration > 30 then
					if not fired_d then
						local logMessage = string.format(
							'%s - %s in %s - Protection: %s has targeted you for more than 30 seconds.\n',
							date(), _A.UnitName("player"), _A.GetMinimapZoneText(), playerName
						)
						_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)

						if discord and string.len(discord) > 5 then
							local discordMessage = string.format(
								':clock: - %s\n:map: - %s in %s\n:triangular_flag_on_post: - Protection: %s has targeted you for more than 30 seconds.',
								date(), _A.UnitName("player"), _A.GetMinimapZoneText(), playerName
							)
							FishSpace.sendToDiscord(discord_data(discordMessage, 0xFF0000), discord)
						end

						_A.ForceQuit()
						fired_d = true
					end
				end
			end
		end
	end

	-- Remove inactive targets from the table
	for playerIndex, lastTargetTime in pairs(targetingTimes) do
		local duration = currentTime - lastTargetTime
		if duration > 60 then
			targetingTimes[playerIndex] = nil
			local playerName = targetTable[playerIndex] or tostring(playerIndex)

			local logMessage = string.format(
				'%s - %s in %s - Protection: %s has targeted you 60 seconds ago.\n',
				date(), UnitName("player"), GetMinimapZoneText(), playerName
			)
			_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)

			targetTable[playerIndex] = nil
		end
	end
end

fphr:SetSize(300, 100)
fphr:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
fphr:SetMovable(true)
fphr:EnableMouse(true)
fphr:RegisterForDrag("LeftButton")
fphr:SetScript("OnDragStart", fphr.StartMoving)
fphr:SetScript("OnDragStop", fphr.StopMovingOrSizing)
local closeButton = _G.CreateFrame("Button", nil, fphr, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", 0, 0)
closeButton:SetScript("OnClick", function()
	fphr:Hide()
end)
fphr:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
fphr:SetBackdropColor(0, 0, 0, 1)


-- Add text to the frame
fphr.text = fphr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fphr.text:SetPoint("CENTER", fphr, "CENTER")

fphr:Hide()



local function AUCTIONATOR_PriceByID(itemID)
	faction = _A.GetRealmName() .. "_" .. _A.UnitFactionGroup("player");
	local itemName = _A.GetItemInfo(itemID)
	local priceDatabase = AUCTIONATOR_PRICE_DATABASE
	if priceDatabase and priceDatabase[faction] and priceDatabase[faction][itemName] then
		local itemData = priceDatabase[faction][itemName]
		local minPrice = itemData["mr"]
		return minPrice
	else
		return 0
	end
end

local function FishInBags()
	local FishID = {
		21071, 2677, 5504, 35562, 21153, 2673, 13889, 13888, 6308, 12205, 74860, 2674, 5503, 4603, 13760, 3731, 6889, 27422, 8365, 13756, 74856, 3712, 12207, 13758,
		41807, 13754, 6289, 74841, 3173, 22644, 74857, 27674, 41806, 6291, 53065, 62778, 27681, 41809, 74839, 53068, 769, 43012, 3685, 43013, 13759, 27438, 74833,
		6303, 20424, 53067, 27439, 75014, 31671, 53064, 41813, 74863, 41805, 3404, 2672, 74866, 6361, 53062, 74853, 12203, 27437, 53070, 27677, 31670, 41800, 53063,
		74837, 74861, 74865, 12208, 33824, 35285, 7974, 41803, 62784, 33823, 74838, 74859, 5468, 74660, 6317, 27671, 53072, 27425, 27678, 43009, 74864, 12037, 41814,
		74845, 34736, 41801, 12184, 62791, 53066, 43010, 1468, 1015, 41810, 5465, 41802, 24477, 74847, 27682, 43652, 74844, 2251, 74848, 79246, 4655, 53071, 74834,
		74851, 21024, 5469, 62782, 62785, 2665, 2675, 6362, 27429, 5471, 41808, 62780, 3667, 3730, 723, 2886, 12202, 12206, 62781, 43647, 74843, 85583, 5470, 102542,
		27435, 53069, 74846, 74852, 41812, 62779, 67229, 74661, 74662, 730, 5467, 74850, 43646, 74659, 2924, 8959, 1080, 5466, 43572, 74849, 729, 12223, 62783, 102536,
		731, 3172, 12204, 36782, 43011, 43571, 85506, 102537, 102538, 3174, 74832, 79250, 102541, 27668, 74840, 102543, 27669, 74854, 85584, 102540, 23676, 85585, 35794,
		44834, 102539, 43501, 74842, 37588
	}
	local itemPrices = {}

	for _, itemId in ipairs(FishID) do
		itemPrices[itemId] = AUCTIONATOR_PriceByID(itemId)
	end

	local totalItemValue = 0
	for itemId, price in pairs(itemPrices) do
		local count = _A.GetItemCount(itemId)
		if count > 0 then
			totalItemValue = totalItemValue + (price or 0) * count
		end
	end
	FishGold = totalItemValue / 10000
	return FishGold
end



local _Gold_Bags = 0
local _Gold_Fish = 0
_A.C_Timer.NewTicker(3, function()
	local Gold_Price = FB_GUI:F('u_money')
	local Gold_in_Bags = _A.GetMoney() / 10000
	local Gold_From_Fish_in_Bags = FishInBags() or 0

	if string.len(Gold_Price) > 0 then
		_Gold_Bags = math.ceil(Gold_Price * Gold_in_Bags)

		if Gold_From_Fish_in_Bags ~= 0 then
			_gold_p_fish = Gold_From_Fish_in_Bags + Gold_in_Bags
			_Gold_Fish = math.ceil(Gold_Price * _gold_p_fish)
		end
	end

	fphr.text:SetText(
		"Current fish per hour: " .. FPHc
		.. '\n\n' ..
		'Gold in bags to real money: ' .. tonumber(_Gold_Bags)
		.. '\n' ..
		'Gold+Fish in bags to real money: ' .. tonumber(_Gold_Fish)
		.. '\n\r' ..
		'Important note: Scan with Auctionator'
	)
end)

DM_B.Looper = function()
	local e_pp = FB_GUI:F('u_protection')
	local discord = FB_GUI:F("u_discord")
	local Bagsleave = FB_GUI:F('u_Bagsleave')
	local BagsFree = FB_GUI:F('u_BagsFree')
	local BagsStop = FB_GUI:F('u_BagsStop')
	local totalFreeSpace = 0
	for bag = 0, NUM_BAG_SLOTS do
		local freeSlots, _ = _A.GetContainerNumFreeSlots(bag)
		totalFreeSpace = totalFreeSpace + freeSlots
	end

	if totalFreeSpace == BagsFree then
		if discord and string.len(discord) > 5 and not freeSpaceSended then
			local DiscordMessage = string.format(
				':clock: - %s\n:map: - %s in %s\n:handbag: - No freespace in bags',
				date(), _A.UnitName("player"), _A.GetMinimapZoneText()
			)
			FishSpace.sendToDiscord(discord_data(DiscordMessage, 0xee7c3a), discord)
			freeSpaceSended = true
		end

		local logMessage = string.format(
			'%s - %s in %s - No freespace in bags, exit game.\n',
			date(), _A.UnitName("player"), _A.GetMinimapZoneText()
		)

		_A.WriteFile(wowDirectory .. "\\fishlog.lua", logMessage, true)

		if Bagsleave then _A.ForceQuit() end
		if BagsStop then
			isEnabled = false; freeSpaceSended = false
		end
	end

	if e_pp then
		local e_tgm = FB_GUI:F('u_Targetleave')
		if e_tgm then target_monitoring() end
		Start_Monitoring()
	end

	if not e_pp then
		Px, Py, Pz = _A.ObjectPosition('player')
		if _A.UnitIsDND('player') == 1 then
			_A.RunMacroText("/dnd")
		end
	end


	if not timer then
		local fishCounted = false
		local fishCount = 0
		startTime = _A.GetTime()
		timer = _A.C_Timer.NewTicker(0.5, function()
			local bobberObject = FishSpace.getBobber()
			if FishSpace.isBobbing() and _A.ObjectExists(bobberObject) and not fishCounted then
				fishCount = fishCount + 1
				fishCounted = true
			end
			if not _A.ObjectExists(bobberObject) or not FishSpace.isBobbing() then
				fishCounted = false
			end
		end)

		_A.C_Timer.After(300, function()
			if timer then
				timer:Cancel()
				timer = nil

				local elapsedTime = _A.GetTime() - startTime
				local fishPerHour = fishCount * (60 / 5) -- Adjusted calculation for fish per hour based on 5-minute stat

				print(date() .. " Caught Fish per Hour: " .. math.floor(fishPerHour))
				FPHc = math.floor(fishPerHour)
				if discord and string.len(discord) > 5 then
					FishSpace.sendToDiscord(
						discord_data(
							':clock: - ' ..
							date() ..
							'\n' ..
							':map: - ' ..
							_A.UnitName("player") ..
							' in ' ..
							_A.GetMinimapZoneText() ..
							"\n" ..
							':fishing_pole_and_fish: - Caught Fish per Hour: ' ..
							math.floor(fishPerHour) ..
							"\n" .. ":handbag: - Current freespace in bags: " .. totalFreeSpace,
							0xffbf00), discord)
				end

				_A.WriteFile(wowDirectory .. "\\fishlog.lua",
					date() ..
					' | ' ..
					'Fish per Hour: ' ..
					math.floor(fishPerHour) .. " | " .. _A.UnitName("player") .. ' in ' .. _A.GetMinimapZoneText() ..
					"\n", true)
			end
		end)
	end

	if _A.GetUnitSpeed('player') == 0 then
		FishSpace.Start_Fishing();
	end
end
