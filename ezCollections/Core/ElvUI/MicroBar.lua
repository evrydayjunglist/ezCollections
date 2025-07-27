ezCollections:MergeHook("ezCollectionsElvUIHook", function()

-- Wrap everything in pcall to prevent errors from breaking the addon
local success, errorMsg = pcall(function()
	local E, L, V, P, G = unpack(ElvUI);
	if not E then return end

	local AB = E:GetModule("ActionBars")
	if not AB then return end

	-- Check if UpdateMicroButtonsParent exists before hooking
	if AB.UpdateMicroButtonsParent then
		hooksecurefunc(AB, "UpdateMicroButtonsParent", function(self)
			-- Ensure CollectionsMicroButton exists and is valid before setting parent
			if CollectionsMicroButton and ElvUI_MicroBar and CollectionsMicroButton.IsObjectType and CollectionsMicroButton:IsObjectType("Button") then
				CollectionsMicroButton:SetParent(ElvUI_MicroBar);
				-- Removed problematic call to UpdateMicroPositionDimensions() since it doesn't exist
				if AB.UpdateMicroButtons then
					AB:UpdateMicroButtons()
				end
			end
		end);
	end

	-- Check if UpdateMicroButtons exists before hooking
	if AB.UpdateMicroButtons then
		hooksecurefunc(AB, "UpdateMicroButtons", function(self)
			if not ElvUI_MicroBar then return end
			
			-- Initialize ezCollectionsMicroButtons if it doesn't exist
			if not AB.ezCollectionsMicroButtons then
				AB.ezCollectionsMicroButtons = {}
			end
			
			-- If ezCollectionsMicroButtons is empty, try to populate it with standard buttons plus CollectionsMicroButton
			if #AB.ezCollectionsMicroButtons == 0 and CollectionsMicroButton then
				local standardButtons = {
					CharacterMicroButton,
					SpellbookMicroButton,
					TalentMicroButton,
					AchievementMicroButton,
					QuestLogMicroButton,
					SocialsMicroButton,
					PVPMicroButton,
					LFDMicroButton,
					MainMenuMicroButton,
					HelpMicroButton,
					CollectionsMicroButton
				}
				
				-- Filter out nil buttons to prevent "table index is nil" error
				for i, button in ipairs(standardButtons) do
					if button and button.IsObjectType and button:IsObjectType("Button") then
						table.insert(AB.ezCollectionsMicroButtons, button);
					end
				end
			end
			
			-- Filter out nil buttons to prevent "table index is nil" error
			local MICRO_BUTTONS = {};
			for i, button in ipairs(AB.ezCollectionsMicroButtons) do
				if button and button.IsObjectType and button:IsObjectType("Button") then
					table.insert(MICRO_BUTTONS, button);
				end
			end
			
			-- If no valid buttons, return early
			if #MICRO_BUTTONS == 0 then return end

			local numRows = 1
			local prevButton = ElvUI_MicroBar
			local offset = E:Scale(E.PixelMode and 1 or 3)
			local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

			for i = 1, #MICRO_BUTTONS do
				local button = MICRO_BUTTONS[i]
				local lastColumnButton = i - self.db.microbar.buttonsPerRow
				lastColumnButton = MICRO_BUTTONS[lastColumnButton];

				button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
				button:ClearAllPoints()
				button:Show();

				if prevButton == ElvUI_MicroBar then
					button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
				elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
					button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
					numRows = numRows + 1
				else
					button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
				end

				prevButton = button
			end
		end);
	end

	-- Check if SetupMicroBar exists before hooking
	if AB.SetupMicroBar then
		hooksecurefunc(AB, "SetupMicroBar", function(self)
			-- Ensure CollectionsMicroButton exists and is valid before handling
			if CollectionsMicroButton and self.HandleMicroButton and CollectionsMicroButton.IsObjectType and CollectionsMicroButton:IsObjectType("Button") then
				self:HandleMicroButton(CollectionsMicroButton);
			end
		end);
	end
end)

if not success then
	print("ezCollections ElvUI Hook Error: " .. tostring(errorMsg))
end

end);
ezCollections:MergeHook("ezCollectionsElvUIConfigHook", function()

local E, L, V, P, G = unpack(ElvUI);

E.Options.args.actionbar.args.microbar.args.buttonsPerRow.max = E.Options.args.actionbar.args.microbar.args.buttonsPerRow.max + 1;

end);
