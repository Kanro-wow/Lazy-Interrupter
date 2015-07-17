local f = CreateFrame("Frame")
local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_ENTERING_WORLD")
f2:RegisterEvent("GROUP_ROSTER_UPDATE")
local bloodlust = {
	[80353] = true,
	[90355] = true,
	[160452] = true,
	[32182] = true,
	[2825] = true,
	[178207] = true,
}
local buffs = {
	[175215] = true, --Savage Feast
	[173979] = true, --Feast of the waters
	[173978] = true, --Feast of Blood
	[185705] = true, --Fancy Darkmoon Feast
	[185708] = true, --Sugar-Crusted Fish Feast
	[29893] = true, --Soulwell
	[698] = true, --Summoning Portal
	[174889] = true, --Aeda Perk: Ritual of Summoning
	[174887] = true, --Illona Perk: Guiding Light
}
local channel
local prevMsg
local prevTime = 0

local function getChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	else
		return false
	end
end

local function announce(msg)
	if prevMsg ~= msg or (GetTime() - prevTime > 10 ) then
		prevMsg = msg
		prevTime = GetTime()
	SendChatMessage(msg,channel,"COMMON")
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	local _,eventType,_,source,sourceName,_,_,_,npcName,_,_,buffID,buffName,_,spellID= ...
	if eventType == "SPELL_INTERRUPT" and (source == UnitGUID("player") or source == UnitGUID("pet")) then
		local msg = ACTION_SPELL_INTERRUPT:gsub("^%l", string.upper).." "..npcName..": "..GetSpellLink(spellID)
		announce(msg)
	elseif eventType == "SPELL_AURA_APPLIED" and bloodlust[buffID] then
		local msg = sourceName.." casted "..GetSpellLink(buffID).."!"
		announce(msg)
	elseif eventType == "SPELL_CREATE" and buffs[buffID] then
		local msg = sourceName.." placed down "..npcName
		announce(msg)
	end

end)

f2:SetScript("OnEvent", function(self,event,...)
	if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
		channel = getChannel()
		if channel then
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end)