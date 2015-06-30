local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnEvent", function(self, event, ...)
	local _,eventType,_,source,_,_,_,_,npcName,_,_,_,_,_,spellID= ...
	if eventType == "SPELL_INTERRUPT" and (source == UnitGUID("player") or source == UnitGUID("pet")) then
		local channel = "SAY"
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			channel = "INSTANCE_CHAT"
		elseif IsInRaid() then
			channel = "RAID"
		elseif IsInGroup() then
			channel = "PARTY"
		end
		-- if channel then
			print(...)
			local link = GetSpellLink(spellID)
			local msg = ACTION_SPELL_INTERRUPT:gsub("^%l", string.upper).." "..npcName..": "..link
			print(msg)
			SendChatMessage(msg ,channel ,"COMMON")
		-- end
	end
end)