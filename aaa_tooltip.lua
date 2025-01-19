local mediaPath, _A = ...
local CreateFrame, UIParent, UnitName, ApepRnd = _A.CreateFrame, _A.UIParent, _A.UnitName, _A.ApepRnd
local tBuffs = _A.Cache.Tooltip.Buffs
_A.Tooltip = _A.Tooltip or {}
local tDebuffs = _A.Cache.Tooltip.Debuffs
local frame = CreateFrame('GameTooltip', ApepRnd..'_ScanningTooltip', UIParent, 'GameTooltipTemplate')
frame:SetOwner(UIParent, 'ANCHOR_NONE') -- Define o proprietário da frame
local function pPattern(text, pattern)
	local pattern_tp = type(pattern)
	if pattern_tp == 'string' then
		local match = text:lower():match(pattern)
		if match then return true end
		elseif pattern_tp == 'table' then
		for i=1, #pattern do
			local match = text:lower():match(pattern[i])
			if match then return true end
		end
	end
end
local function Scan_Buff(target)
	if not tBuffs[target] then
		local i, tooltip = 1, true
		while tooltip do
			_A[ApepRnd.."_ScanningTooltipTextLeft1"]:SetText()
			frame:SetUnitBuff(target, i)
			tooltip = _A[ApepRnd.."_ScanningTooltipTextLeft1"]:GetText()
			if tooltip then
				tBuffs[target] = tBuffs[target] or {}
				tBuffs[target][i] = tBuffs[target][i] or {}
				local totalText = ""
				for j = 1, frame:NumLines() do
					tBuffs[target][i][j] = tBuffs[target][i][j] or {}
					local tooltipLeft = _A[ApepRnd.."_ScanningTooltipTextLeft" .. j]:GetText()
					local tooltipRight = _A[ApepRnd.."_ScanningTooltipTextRight" .. j]:GetText()
					tBuffs[target][i][j].Left = tooltipLeft or ""
					tBuffs[target][i][j].Right = tooltipRight or ""		
				end
			end
			i = i + 1
		end
	end
end
local function Scan_Debuff(target)
	if not tDebuffs[target] then
		local i, tooltip = 1, true
		while tooltip do
			_A[ApepRnd.."_ScanningTooltipTextLeft1"]:SetText()
			frame:SetUnitDebuff(target, i)
			tooltip = _A[ApepRnd.."_ScanningTooltipTextLeft1"]:GetText()
			if tooltip then
				tDebuffs[target] = tDebuffs[target] or {}
				tDebuffs[target][i] = tDebuffs[target][i] or {}
				local totalText = ""
				for j = 1, frame:NumLines() do
					tDebuffs[target][i][j] = tDebuffs[target][i][j] or {}
					local tooltipLeft = _A[ApepRnd.."_ScanningTooltipTextLeft" .. j]:GetText()
					local tooltipRight = _A[ApepRnd.."_ScanningTooltipTextRight" .. j]:GetText()
					tDebuffs[target][i][j].Left = tooltipLeft or ""
					tDebuffs[target][i][j].Right = tooltipRight or ""		
				end
			end
			i = i + 1
		end
	end
end
--------------------------------------
function _A.Tooltip.Scan_Buff(_, target, pattern)
	Scan_Buff(target)
	if tBuffs[target] then
		for _,t in ipairs(tBuffs[target]) do
			if ( t[1] and pPattern(t[1].Left, pattern) )
				or ( t[2] and pPattern(t[2].Left, pattern) ) then
				return true
			end
		end
	end
	return false
end
--------------------------------------
function _A.Tooltip.Scan_Debuff(_, target, pattern)
	Scan_Debuff(target)
	if tDebuffs[target] then
		for _,t in ipairs(tDebuffs[target]) do
			if ( t[1] and pPattern(t[1].Left, pattern) )
				or ( t[2] and pPattern(t[2].Left, pattern) ) then
				return true
			end	
		end
	end
	return false
end
-----------------------------------------------------------------------
function _A.Tooltip.Scan_Debuff_Duration(_, target, pattern) -- my reasoning behind what I want here is a little too long, messaging you there is a chat feature, wait
	Scan_Debuff(target)
	local tempTable = {}
	if tDebuffs[target] then
		for _,t in ipairs(tDebuffs[target]) do
			if ( t[1] and pPattern(t[1].Left, pattern) )
				or ( t[2] and pPattern(t[2].Left, pattern) ) then
				local remain = tonumber(_A.DSL:Get("debuff.duration.any")(target, t[1].Left)) or 0
				tempTable[#tempTable+1] = {
					duration = remain
				}
			end	
		end
	end
	if #tempTable>1 then
		table.sort( tempTable, function(a,b) return (a.duration > b.duration) end )
	end
	return tempTable[1] and tempTable[1].duration or 0
end
local function debufftype(target, buff)
	local name,_,_,_,atype = UnitDebuff(target, buff)
	return atype or " "
end
function _A.Tooltip.Scan_Debuff_Dispellable(_, target, pattern)
	Scan_Debuff(target)
	if tDebuffs[target] then
		for _,t in ipairs(tDebuffs[target]) do
			if (t[1] and pPattern(t[1].Left, pattern))
				or ( t[2] and pPattern(t[2].Left, pattern)) then
			end	
		end
	end
end
-----------------------------------------------------------------------
function _A.Tooltip.Scan_Buff_Duration(_, target, pattern)
	local tempTable = {}
	Scan_Buff(target)
	if tBuffs[target] then
		for _,t in ipairs(tBuffs[target]) do
			if ( t[1] and pPattern(t[1].Left, pattern) )
				or ( t[2] and pPattern(t[2].Left, pattern) ) then
				if tostring(t[1].Left)~=nil then
					local remain = tonumber(_A.DSL:Get("buff.duration.any")(target, t[1].Left)) or 0
					tempTable[#tempTable+1] = {
						duration = remain
					}
				end
			end
		end
	end
	if #tempTable>1 then
		table.sort( tempTable, function(a,b) return (a.duration > b.duration) end )
	end
	return tempTable[1] and tempTable[1].duration or 0
end
------------------------------------------------------------------------
local function debufftype(target, buff)
    local name,_,_,_,atype = _A.UnitDebuff(target, buff)
    if name and atype then
        return atype
	end
	return " "
end
function _A.Tooltip.Scan_Debuff_Dispellable(_, target, pattern) -- checks if all debuffs within a pattern are dispellable
    local DEBUFFtype
    Scan_Debuff(target)
    if tDebuffs[target] then
        for _,t in ipairs(tDebuffs[target]) do
            if ( t[1] and pPattern(t[1].Left, pattern) )
                or ( t[2] and pPattern(t[2].Left, pattern) ) then
                DEBUFFtype = debufftype(target, t[1].Left)
                if DEBUFFtype ~= "Magic" 
                    and DEBUFFtype ~= "Poison"
					and DEBUFFtype ~= "Disease" then -- if not magic poison or disease means undispellable (for detox only)
					return false
				end
			end    
		end   
        return true -- looped through everything without returning false, means everything is dispellable 
	end
	return false -- just in case
end
---------------------------------------------------------------------------------------------------
