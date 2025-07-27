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
			
			-- Create a safe copy of MICRO_BUTTONS or use our ezCollectionsMicroButtons
			local MICRO_BUTTONS = {};
			
			-- First try to use AB.ezCollectionsMicroButtons if it has valid buttons
			if AB.ezCollectionsMicroButtons and #AB.ezCollectionsMicroButtons > 0 then
				for i, button in ipairs(AB.ezCollectionsMicroButtons) do
					if button and button.IsObjectType and button:IsObjectType("Button") then
						table.insert(MICRO_BUTTONS, button);
					end
				end
			end
			
			-- If we still don't have buttons, try to get them from ElvUI's MICRO_BUTTONS
			if #MICRO_BUTTONS == 0 and _G.MICRO_BUTTONS then
				for i, button in ipairs(_G.MICRO_BUTTONS) do
					if button and button.IsObjectType and button:IsObjectType("Button") then
						table.insert(MICRO_BUTTONS, button);
					end
				end
				
				-- Add CollectionsMicroButton if it exists and is not already in the list
				if CollectionsMicroButton and CollectionsMicroButton.IsObjectType and CollectionsMicroButton:IsObjectType("Button") then
					local found = false
					for i, button in ipairs(MICRO_BUTTONS) do
						if button == CollectionsMicroButton then
							found = true
							break
						end
					end
					if not found then
						table.insert(MICRO_BUTTONS, CollectionsMicroButton);
					end
				end
			end
			
			-- If no valid buttons, return early
			if #MICRO_BUTTONS == 0 then return end

			-- Store the validated buttons back to AB.ezCollectionsMicroButtons for future use
			AB.ezCollectionsMicroButtons = MICRO_BUTTONS

			local numRows = 1
			local prevButton = ElvUI_MicroBar
			local offset = E:Scale(E.PixelMode and 1 or 3)
			local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

			for i = 1, #MICRO_BUTTONS do
				local button = MICRO_BUTTONS[i]
				-- Additional safety check for the current button
				if not button or not button.IsObjectType or not button:IsObjectType("Button") then
					-- Skip invalid buttons
					goto continue
				end
				
				local lastColumnButton = nil
				local lastColumnIndex = i - self.db.microbar.buttonsPerRow
				-- Add bounds checking to prevent "table index is nil" error
				if lastColumnIndex > 0 and lastColumnIndex <= #MICRO_BUTTONS then
					local potentialButton = MICRO_BUTTONS[lastColumnIndex]
					-- Verify the button at lastColumnIndex is valid
					if potentialButton and potentialButton.IsObjectType and potentialButton:IsObjectType("Button") then
						lastColumnButton = potentialButton;
					end
				end

				-- Additional safety check before calling methods on button
				if button.Size and button.ClearAllPoints and button.Show and button.Point then
					button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
					button:ClearAllPoints()
					button:Show();

					if prevButton == ElvUI_MicroBar then
						button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
					elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 and lastColumnButton then
						button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
						numRows = numRows + 1
					else
						button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
					end

					prevButton = button
				end
				
				::continue::
			end
		end);
	end

	-- Check if SetupMicroBar exists before hooking
	if AB.SetupMicroBar then
		hooksecurefunc(AB, "SetupMicroBar", function(self)
			-- Ensure CollectionsMicroButton exists and is valid before handling
			if CollectionsMicroButton and self.HandleMicroButton and CollectionsMicroButton.IsObjectType and CollectionsMicroButton:IsObjectType("Button") then
				-- Additional safety check for HandleMicroButton method
				local success, err = pcall(function()
					self:HandleMicroButton(CollectionsMicroButton);
				end)
				if not success then
					print("ezCollections: Error in HandleMicroButton:", err)
				end
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

-- Safety check before modifying options
if E and E.Options and E.Options.args and E.Options.args.actionbar and E.Options.args.actionbar.args and E.Options.args.actionbar.args.microbar and E.Options.args.actionbar.args.microbar.args and E.Options.args.actionbar.args.microbar.args.buttonsPerRow then
	E.Options.args.actionbar.args.microbar.args.buttonsPerRow.max = E.Options.args.actionbar.args.microbar.args.buttonsPerRow.max + 1;
end

end);
