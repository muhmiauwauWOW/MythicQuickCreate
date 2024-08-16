MythicQuickCreate = LibStub("AceAddon-3.0"):NewAddon("MythicQuickCreate", "AceEvent-3.0", "AceBucket-3.0");
local _ = LibStub("Lodash"):Get()
local mplusObj = {}


function MythicQuickCreate:OnInitialize()
	local f = CreateFrame("Frame", "MythicQuickCreateContent", LFGListFrame.EntryCreation)
	f:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.Name, "BOTTOMLEFT", -5, -10)
	f:SetPoint("TOPRIGHT", LFGListFrame.EntryCreation.Name, "BOTTOMRIGHT", 0, -10 )
	f:SetPoint("CENTER",  0, 0 )
	f:SetHeight(32)

	MythicQuickCreate.DescriptionLabelPoint = table.pack(LFGListFrame.EntryCreation.DescriptionLabel:GetPoint())
	MythicQuickCreate.DescriptionHeight = LFGListFrame.EntryCreation.Description:GetHeight()
	MythicQuickCreate.PlayStyleLabelPoint = table.pack(LFGListFrame.EntryCreation.PlayStyleLabel:GetPoint())

	LFGListFrame.CategorySelection.StartGroupButton:HookScript("OnClick", function(self) 
		local panel = self:GetParent();
		if ( not panel.selectedCategory ) then
			return;
		end

		local baseFilters = panel:GetParent().baseFilters;
		if baseFilters == 4 and panel.selectedCategory == 2 and panel.selectedFilters == 0 then 
			MythicQuickCreate:Show()
		else 
			MythicQuickCreate:Hide()
		end
    end)

	table.foreach(C_LFGList.GetAvailableActivities(2), function(k, id)
		local info = C_LFGList.GetActivityInfoTable(id)
		if info.isMythicPlusActivity then
			tinsert(mplusObj, {
				id = id,
				name = info.fullName
			})
		end
	end)

	MythicQuickCreate:createDungeonsButtons()
end



function MythicQuickCreate:checkOwnedKeystone()
	local activityID, groupID, keystoneLevel  = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel()
	local f = _G["MythicQuickCreate" .. activityID]
	if not f then return end

	local children = {MythicQuickCreateContent:GetChildren()}
	table.foreach(children, function(k,v)
		v.Glowborder:Hide()
		v.Text:SetText("")
	end)

	f.Glowborder:Show()
	f.Text:SetText(keystoneLevel)
end


function MythicQuickCreate:Show()
	self:checkOwnedKeystone()
	LFGListFrame.EntryCreation.DescriptionLabel:SetPoint("TOPLEFT",LFGListFrame.EntryCreation.NameLabel, "TOPLEFT",  0,-90)
	LFGListFrame.EntryCreation.Description:SetHeight(13)
	LFGListFrame.EntryCreation.PlayStyleLabel:SetPoint("TOPLEFT",LFGListFrame.EntryCreation.DescriptionLabel, "TOPLEFT", 0,-55)
	MythicQuickCreateContent:Show() 
end

function MythicQuickCreate:Hide()
	LFGListFrame.EntryCreation.DescriptionLabel:SetPoint("TOPLEFT",LFGListFrame.EntryCreation.NameLabel, "TOPLEFT",  MythicQuickCreate.DescriptionLabelPoint[4], MythicQuickCreate.DescriptionLabelPoint[5])
	LFGListFrame.EntryCreation.Description:SetHeight(MythicQuickCreate.DescriptionHeight)
	LFGListFrame.EntryCreation.PlayStyleLabel:SetPoint("TOPLEFT",LFGListFrame.EntryCreation.DescriptionLabel, "TOPLEFT", MythicQuickCreate.PlayStyleLabelPoint[4], MythicQuickCreate.PlayStyleLabelPoint[5])
	MythicQuickCreateContent:Hide() 
end



function MythicQuickCreate:createDungeonsButtons()
	local spacer = 4
	local amount = _.size(dConfig)
	local width = MythicQuickCreateContent:GetWidth()

	local size = (width - ((amount - 1) * spacer)) / amount

	local mapChallengeModeIDs = C_ChallengeMode.GetMapTable()
	local dObj = {}

	table.foreach(mapChallengeModeIDs, function(index, mapID)
		local mapInfo = table.pack(C_ChallengeMode.GetMapUIInfo(mapID))
		tinsert(dObj, {
			name =  mapInfo[1],
			texture = mapInfo[4]
		})
	end)

	table.sort(dObj, function(a, b)
		return a.name < b.name
	end)



	table.foreach(dObj, function(index, dungeon)
		local find = _.find(mplusObj, function(entry)
			return entry.name:sub(1, #dungeon.name) == dungeon.name
		end)

		if find then
			
			local f = CreateFrame("Button", "MythicQuickCreate" .. find.id, MythicQuickCreateContent)
			f:SetSize(size,size)
			local x = (index - 1) * (size + spacer)
			f:SetPoint("TOPLEFT", x, 0)

			f.Texture = f:CreateTexture()
			f.Texture:SetAllPoints()
			f.Texture:SetTexture(dungeon.texture)

			f.Glowborder = f:CreateTexture()
			f.Glowborder:SetAllPoints()
			f.Glowborder:SetAtlas("UI-HUD-ActionBar-PetAutoCast-Corners", true)
			f.Glowborder:Hide()

	
			f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			f.Text:SetPoint("CENTER")
			f.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			f.Text:SetText("")


			local find = _.find(mplusObj, function(entry)
				return entry.name:sub(1, #dungeon.name) == dungeon.name
			end)

			f:SetScript("OnEnter", function(self) 
				GameTooltip:SetOwner(MythicQuickCreateContent, "ANCHOR_BOTTOM");
				GameTooltip:ClearLines();
				GameTooltip:SetText(find.name, 1, 1, 1, 1, 1)
				GameTooltip:Show() 
			end)
									
			f:SetScript("OnLeave", function(self) 
				GameTooltip:Hide() 
			end)

			f:SetScript("OnClick", function (self, button, down)
				LFGListFrame.EntryCreation.selectedActivity = find.id
				LFGListEntryCreation_ListGroup(LFGListFrame.EntryCreation);
			end);
		end
	end)
end