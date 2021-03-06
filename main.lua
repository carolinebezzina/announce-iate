local Announceiate = {};
local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
PlayerClass = UnitClass("player")
local pageValue = 20

local function DisplaySpell(SpellName, SkillType, SpellSubName, SpellID)
	local ExcludeList = {
        ["Auto Attack"] = true,
        ["Wartime Ability"] = true,
		["Garrison Ability"] = true,
		["Combat Ally"] = true,
		["Activate Empowerment"] = true,
		["Sanity Restoration Orb"] = true,
		["Construct Ability"] = true
	}
	if
		SkillType == "SPELL"
		and (SpellSubName == ""
			or SpellSubName == "Racial")
		and IsPassiveSpell(SpellID) == false
		and IsSpellKnown(SpellID) == true
		and not ExcludeList[SpellName]
	then
		return true
	end
	
	return false
end

local function FetchSpells()
	local i = 1
	while true do
		local SpellName, SpellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not SpellName then
		  break
		end
		if GetSpellBookItemInfo(SpellName) then
			local SkillType, SpellID = GetSpellBookItemInfo(SpellName)
			if(DisplaySpell(SpellName, SkillType, SpellSubName, SpellID)) then
				Announceiate.Announcements[PlayerClass].Spell[SpellID] = {}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].SpellID = {}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].SpellName = {}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].Channel = {}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].Text = {}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].SpellID = SpellID
				Announceiate.Announcements[PlayerClass].Spell[SpellID].SpellName = SpellName
				Announceiate.Announcements[PlayerClass].Spell[SpellID].Channel = 
					{
						Party = false,
						Instance = false,
						Say = false,
						Emote = false
					}
				Announceiate.Announcements[PlayerClass].Spell[SpellID].Text = ""
			end
		end
		i = i + 1
	end
end

local function UpdateSpells(pageValue, SpellNameText, SayValue, CheckBox)
	local a = 1
	for i, s in pairs(Announceiate.Announcements[PlayerClass].Spell) do
		if a <= pageValue and a > pageValue - 20 then
			SpellNameText[i]:Show()
			SayValue[i]:Show()
			for ii, ss in pairs(Announceiate.Announcements[PlayerClass].Spell[i].Channel) do
				CheckBox[i][ii]:Show()
			end
		else
			SpellNameText[i]:Hide()
			SayValue[i]:Hide()
			for ii, ss in pairs(Announceiate.Announcements[PlayerClass].Spell[i].Channel) do
				CheckBox[i][ii]:Hide()
			end
		end
		a = a + 1
	end
end

local function CreateButtons(Config, PageValue, SpellNameText, SayValue, CheckBox)
	local left = CreateFrame("Button", nil, Config)
	left:SetPoint("BOTTOMLEFT", Config, "BOTTOMLEFT", 150, 20)
	left:SetWidth(80)
	left:SetHeight(20)
	
	left:SetText("< Prev")
	left:SetNormalFontObject("GameFontNormal")
	
	local ntex = left:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	left:SetNormalTexture(ntex)
	
	local htex = left:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	left:SetHighlightTexture(htex)
	
	local ptex = left:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	left:SetPushedTexture(ptex)

	local right = CreateFrame("Button", nil, Config)
	right:SetPoint("BOTTOMRIGHT", Config, "BOTTOMRIGHT", -150, 20)
	right:SetWidth(80)
	right:SetHeight(20)
	
	right:SetText("Next >")
	right:SetNormalFontObject("GameFontNormal")
	
	local ntex = right:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	right:SetNormalTexture(ntex)
	
	local htex = right:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	right:SetHighlightTexture(htex)
	
	local ptex = right:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	right:SetPushedTexture(ptex)
	
	right:SetScript("OnClick", function()
		pageValue = pageValue + 20
		UpdateSpells(pageValue, SpellNameText, SayValue, CheckBox)
	end)
	
	left:SetScript("OnClick", function()
		if pageValue > 20 then
			pageValue = pageValue - 20
			UpdateSpells(pageValue, SpellNameText, SayValue, CheckBox)
		end
	end)
end

local function CreateConfig(pageValue, SpellNameText, SayValue, CheckBox)
	local Config = CreateFrame("Frame", "Announce-iate", UIParent)
	Config:Hide()
	Config.name = "Announce-iate"
	InterfaceOptions_AddCategory(Config)

	local ConfigTitle = Config:CreateFontString("ConfigTitle", "ARTWORK", "GameFontNormalLarge")
	ConfigTitle:SetPoint("TOPLEFT", 10, -20)
	ConfigTitle:SetText("Announce-iate Configuration")	
	local Tooltip = Config:CreateFontString("Tooltip", "ARTWORK", "GameFontNormal")
	Tooltip:SetPoint("TOPLEFT", 10, -50)
	Tooltip:SetText("Please note: /say will not work outdoors and can only be used inside instances.")
	Tooltip:SetTextColor(1, 1, 1)
	Tooltip:SetFont("Fonts\\FRIZQT__.TTF", 12)
	
	if(Announceiate.Announcements[PlayerClass]) then
		local a = 1

		for i, s in pairs(Announceiate.Announcements[PlayerClass].Spell) do
			local distanceFromTop = (-90 + (a - 1) * -20)
			local pageNo = math.floor(a / 20)
			distanceFromTop = distanceFromTop + ((pageNo * 20) * 20)

			SpellNameText[i] = Config:CreateFontString("SpellNameText", "ARTWORK", "GameFontNormal")
			SpellNameText[i]:SetJustifyH("LEFT");
			SpellNameText[i]:SetPoint ("TOPLEFT", "Announce-iate", 10, distanceFromTop)
			SpellNameText[i]:SetWidth(150)
			SpellNameText[i]:SetHeight(20)
			SpellNameText[i]:SetText(s.SpellName)
			SpellNameText[i]:SetTextColor(1, 1, 1)
			SpellNameText[i]:Hide()

			SayValue[i] = CreateFrame("EditBox", nil, Config)
			SayValue[i]:SetPoint ("TOPLEFT", "Announce-iate", 180, distanceFromTop)
			SayValue[i]:SetFontObject(GameFontNormal)
			SayValue[i]:SetWidth(150)
			SayValue[i]:SetHeight(15)
			SayValue[i]:SetText(s.Text)
			SayValue[i].texture = SayValue[i]:CreateTexture(nil, "BACKGROUND")
			SayValue[i].texture:SetAllPoints(true)
			SayValue[i].texture:SetColorTexture(1.0, 1.0, 1.0, 0.1)
			SayValue[i]:Hide()
			
			CheckBox[i] = {}
			local x = 1
			
			for ii, ss in pairs(Announceiate.Announcements[PlayerClass].Spell[i].Channel) do
				CheckBox[i][ii] = CreateFrame("CheckButton", nil, Config, "UICheckButtonTemplate")
				CheckBox[i][ii]:SetPoint("TOPRIGHT", "Announce-iate", (-250 + (x - 1) * 70), 5 + distanceFromTop)
				CheckBox[i][ii]:SetSize(27,27)
				CheckBox[i][ii].text:SetText(ii)
				
				if(Announceiate.Announcements[PlayerClass].Spell[i].Channel[ii] == true) then
					CheckBox[i][ii]:SetChecked(true)
				else
					CheckBox[i][ii]:SetChecked(false)
				end
				x = x + 1
				CheckBox[i][ii]:Hide()

			end
			a = a + 1
		end

		CreateButtons(Config, pageValue, SpellNameText, SayValue, CheckBox)
	end

	Config.okay = function (self)
		for i, s in pairs(Announceiate.Announcements[PlayerClass].Spell) do
			Announceiate.Announcements[PlayerClass].Spell[i].Text = SayValue[i]:GetText()
			for ii, ss in pairs(Announceiate.Announcements[PlayerClass].Spell[i].Channel) do
				Announceiate.Announcements[PlayerClass].Spell[i].Channel[ii] = CheckBox[i][ii]:GetChecked()
			end
		end
	end
end

local function Announce()
	local SpellCast_EventFrame = CreateFrame("Frame")
	SpellCast_EventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	SpellCast_EventFrame:SetScript("OnEvent",
	function(self, event, unit, arg1, spellID, arg2, arg3)
		if(unit == "player" and Announceiate.Announcements[PlayerClass].Spell[spellID]) then
			for ii, c in pairs(Announceiate.Announcements[PlayerClass].Spell[spellID].Channel) do
				if c == true then
					if (ii ~= "Instance" or IsInGroup(LE_PARTY_CATEGORY_INSTANCE))
					and (ii ~= "Party" or IsInGroup(LE_PARTY_CATEGORY_HOME)) then 
						SendChatMessage(Announceiate.Announcements[PlayerClass].Spell[spellID].Text, ii)
					end
				end
			end
		end
	end)
end


frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Announce-iate" then
		if event == "ADDON_LOADED" then
			if Announceiate.Announcements == nil then
				Announceiate.Announcements = {}
			end
		end
	end
	if event == "PLAYER_LOGIN" then
		if Announceiate.Announcements[PlayerClass] == nil then
			Announceiate.Announcements[PlayerClass] = {}
			Announceiate.Announcements[PlayerClass].Spell = {}
			FetchSpells()
		end
		
		local SpellNameText = {}
		local SayValue = {}
		local CheckBox = {}
		
		CreateConfig(pageValue, SpellNameText, SayValue, CheckBox)
		
		UpdateSpells(pageValue, SpellNameText, SayValue, CheckBox)
		
		Announce()
	end
end)