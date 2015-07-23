local frame = CreateFrame("Frame")
local cFrame = CreateFrame("Frame")

local bloodlust = {[80353]=true,[90355]=true,[160452]=true,[32182]=true,[2825]=true,[178207]=true}
local buffs = {[175215]=true,[173979]=true,[173978]=true,[185705]=true,[185708]=true,[29893]=true,[698]=true,[174889]=true,[174887]=true}
local channel, prevMsg, prevTime, _playerGUID, _petGUID

frame:SetScript('OnEvent', function(self, event, ...)
	self[event](...)
	end)
cFrame:SetScript('OnEvent', function(self,_,_,event,...)
	if self[event] then
		self[event](self, ...)
	end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
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
	if (prevMsg ~= msg or (GetTime() - prevTime > 10 )) and channel then
		prevMsg = msg
		prevTime = GetTime()
		SendChatMessage(msg,channel,"COMMON")
	end
end

function registerEvents(register)
	setChannel()
	print("channel is",channel)
	if register == false or channel == false then
		print("UnregisterEvent1")
		cFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	elseif channel or register then
		cFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		print("RegisterEvent")
	else
		cFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		print("UnregisterEvent2")
	end
end

function cFrame:SPELL_SUMMON(_,playerGUID)
	if playerGUID == _playerGUID then
		_petGUID = UnitGUID("pet")
	end
end

function frame:PLAYER_ENTERING_WORLD()
	_playerGUID = UnitGUID("player")
	_petGUID = UnitGUID("pet")
	registerEvents()
end

function frame:GROUP_ROSTER_UPDATE()
	registerEvents()
end

function frame:PLAYER_REGEN_ENABLED()
	registerEvents()
end

function frame:PLAYER_REGEN_DISABLED()
	registerEvents(false)
end


