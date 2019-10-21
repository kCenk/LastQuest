-- File: LastQuest.lua
-- Name: LastQuest
-- Author: kCenk
-- Description: LastQuest is a simple WoW Classic addon that will display the last accepted Quest.
-- Version: 1.0.0

-- local variables
local GetQuestLogTitle = GetQuestLogTitle
local gsub = gsub
local version = "1.0.0"
local pairs = pairs
local table = table
local _Quests = {}
local _QuestIndex = 0

-- Main frame
local lastQuest = CreateFrame("Frame", "lastQuest")
-- # OnEvent: registers events
function lastQuest:OnEvent(event, ...)
	local action = self[event]
	if action then
		action(self, event, ...)
	end
end
-- # Init: initialisation
function lastQuest:Init()
  self:SetScript("OnEvent", self.OnEvent)
  self:RegisterEvent("ADDON_LOADED")
end
-- # ADDON_LOADED: triggered when addon loaded
function lastQuest:ADDON_LOADED(_, addonName)
  if addonName ~= "LastQuest" then return end
  cssdebug("{red}v"..version.."{/red} loaded")
  self:RegisterEvent("QUEST_ACCEPTED")
  self:RegisterEvent("QUEST_REMOVED")
  self:RegisterEvent("QUEST_TURNED_IN")
  self:RegisterEvent("PLAYER_LOGOUT")
  local qi = QuestIndex
  if not qi or qi == nil or qi == 0 then return end
  _QuestIndex = QuestIndex
  local lq = self:getLastQuest()
  if not lq or lq == nil then return end
  _Quests = Quests
  cssdebug("=> {red}"..lq.title)
end
-- # QUEST_ACCEPTED: triggered when new quest accepted
function lastQuest:QUEST_ACCEPTED(_, questID)
  local title, level, _, _, _, _, _, realquestID = GetQuestLogTitle(questID)
  _QuestIndex = _QuestIndex + 1
  _Quests[realquestID] = _QuestIndex
  cssdebug("=> {red}"..title.."{/red}")
end
-- # QUEST_REMOVED: triggered when quest abandoned
function lastQuest:QUEST_REMOVED(_, realquestID)
  _Quests[realquestID] = nil
  local lq = self:getLastQuest()
  if not lq or lq == nil then return end
  cssdebug("=> {red}"..lq.title)
end
-- # QUEST_TURNED_IN: triggered when quest done
function lastQuest:QUEST_TURNED_IN(_, realquestID)
  _Quests[realquestID] = nil
  local lq = self:getLastQuest()
  if not lq or lq == nil then return end
  cssdebug("=> {red}"..lq.title)
end
-- # PLAYER_LOGOUT: triggered when player logs out
function lastQuest:PLAYER_LOGOUT()
  Quests = _Quests
  QuestIndex = _QuestIndex
end
-- # special functions
function lastQuest:getLastQuest()
  for k, v in spairs(_Quests, function(t, a, b) return t[b] < t[a] end) do
    local tit = GetQuestLogTitle(GetQuestLogIndexByID(k))
    return {id = k, title = tit}
  end
end

-- global functions
local colors = {
  green = "|cff98ff95",
  red = "|cffffa8a8",
  blue = "|cff9bc9ff"
}
function cssdebug(message)
  message = "{green}LastQuest:{/green} "..message
  for k, v in pairs(colors) do
    message = message:gsub("{"..k.."}", v)
    message = message:gsub("{/"..k.."}", "|r")
  end
  print(message)
end
-- special thanks and credits to Michal Kottman GitHub: https://stackoverflow.com/a/15706820
function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end
-- slash command
SLASH_LASTQUEST1 = "/lq";
function SlashCmdList.LASTQUEST(msg)
  for k, v in spairs(_Quests, function(t, a, b) return t[b] < t[a] end) do
    cssdebug("=> {red}"..GetQuestLogTitle(GetQuestLogIndexByID(k)))
    return
  end
end

lastQuest:Init()
