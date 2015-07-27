local frame = CreateFrame("Frame")
local combatFrame = CreateFrame("Frame")

local create = {
	[29893] = true, 			-- create soulwell
	[698] = true, 				-- ritual of summoning
}

local aura = {
	[90355] = true, 			-- ancient hysteria
	[160452] = true, 			-- netherwinds
	[80353] = true, 			-- time warp
	[2825] = true, 				-- bloodlust
	[32182] = true, 			-- heroism
	[178207] = true, 			-- drums of fury
	[871] = "PLAYER", 		-- shield wall
	[48792] = "PLAYER", 	-- icebound fortitude
	[12975] = "PLAYER",		-- last stand
}

local spellcast = {
	[76577] = "PLAYER",		-- smoke bomb
	[20707] = "PLAYER",		-- soulstone
	[61999] = "PLAYER",		-- raise ally
	[175498] = true, 			-- ritual of summoning - aeda brightdawn`
	[175516] = true, 			-- ritual of summoning - defender illona
}


local strings = {
	["SPELL_AURA_APPLIED"] = "%s used %s!",
	["SPELL_AURA_APPLIED_PLAYER"] = "Used %s!",
	["SPELL_CREATE"] = "%s placed down a %s!",
	["SPELL_CREATE_PLAYER"] = "Placed down a %s!",
	["SPELL_CAST_SUCCESS"] = "%s used %s!",
	["SPELL_CAST_SUCCESS_PLAYER"] = "Used %s!",
}
local channel, prevMsg, playerGUID, playerName, petGUID
local prevTime = 0

frame:SetScript('OnEvent', function(self, event, ...)
	self[event](...)
	end)
combatFrame:SetScript('OnEvent', function(self,_,_,event,...)
	if self[event] then
		self[event](self,event,...)
	end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")

local function setChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		channel = "INSTANCE_CHAT"
	elseif IsInRaid() then
		channel = "RAID"
	elseif IsInGroup() then
		channel = "PARTY"
	else
		-- Debug, set return to true.
		channel = true
	end
end

local function announce(msg)
	print(msg)

	if (prevMsg ~= msg or (GetTime() - prevTime > 10 )) and channel then
		prevMsg = msg
		prevTime = GetTime()
		SendChatMessage(msg,channel,"COMMON")
	end
end

local function createMsg(sourceName,spellId,event)
	local link = GetSpellLink(spellId)
	if sourceName == playerName and strings[event.."_PLAYER"] then
		announce(format(strings[event.."_PLAYER"],sourceName,link))
	else
		announce(format(strings[event],link))
	end
end

function registerEvents()
	setChannel()
	if channel then
		combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		combatFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

-- hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellId,spellName,spellSchool
function combatFrame:SPELL_AURA_APPLIED(event,_,sourceGUID,sourceName,_,_,destGUID,_,_,_,spellId)
	if aura[spellId] and destGUID == playerGUID then
		if aura[spellId] == "PLAYER" and sourceGUID ~= playerGUID then
			return
		end
		createMsg(sourceName,spellId,event)
	end
end

function combatFrame:SPELL_CAST_SUCCESS(event,_,sourceGUID,sourceName,_,_,_,_,_,_,spellId)
	if spellcast[spellId] then
		if spellcast[spellId] == true or (spellcast[spellId] == "PLAYER" and sourceGUID == playerGUID) then
			createMsg(sourceName,spellId,event)
		end
	end
end

function combatFrame:SPELL_CREATE(event,_,sourceGUID,sourceName,_,_,_,_,_,_,spellId)
	if create[spellId] then
		if create[spellId] == true or (create[spellId] == "PLAYER" and sourceGUID == playerGUID) then
			createMsg(sourceName,spellId,event)
		end
	end
end

function combatFrame:SPELL_SUMMON(_,sourceGUID)
	if sourceGUID == playerGUID then
		petGUID = UnitGUID("pet")
	end
end

function frame:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
	playerName = UnitName("player")
	petGUID = UnitGUID("pet")
	registerEvents()
end

function frame:GROUP_ROSTER_UPDATE()
	registerEvents()
end


