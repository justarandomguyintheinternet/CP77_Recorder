tooltips = {
    label = "?",
    settings = nil
}

function tooltips.drawButton(recorder, key)
    if recorder.settings.tooltips == 1 then
        ImGui.SameLine()
        ImGui.Button(tooltips.label)
        tooltips.displayTooltip(recorder, key)
    end
end

function tooltips.drawHover(recorder, key)
    if recorder.settings.tooltips == 2 then
        tooltips.displayTooltip(recorder, key)
    end
end

function tooltips.drawCombo(recorder, key)
    if recorder.settings.tooltips == 1 then
        ImGui.SameLine()
        ImGui.Button(tooltips.label)
        tooltips.displayTooltip(recorder, key)
    end
    if recorder.settings.tooltips == 2 then
        tooltips.displayTooltip(recorder, key)
    end
end

function tooltips.displayTooltip(recorder, key)
    active = ImGui.IsItemHovered()
    if active then
        if key == "tt_setSubjectButton" then
            recorder.CPS.CPToolTip1Begin(255, 112)
            ImGui.TextWrapped("Look at: Sets the GameObject under your crosshair as subject (If available)")
            ImGui.Separator()
            ImGui.TextWrapped("Player: Sets player as subject")
            ImGui.Separator()
            ImGui.TextWrapped("Mounted Vehicle: Uses mounted vehicle as sSubject (If available)")
            recorder.CPS.CPToolTip1End()
        elseif key == "tt_setSubjectLook" then
            ImGui.SetTooltip("Sets the GameObject under your crosshair as subject (If available)")
        elseif key == "tt_setSubjectPlayer" then
            ImGui.SetTooltip("Sets player as subject")
        elseif key == "tt_setSubjectVehicle" then
            ImGui.SetTooltip("Sets mounted vehicle as subject (If available)")
        elseif key == "tt_setSubjectClear" then
            ImGui.SetTooltip("Clears the current subject")
        elseif key == "tt_setHomePoint" then
            ImGui.SetTooltip("Sets the subjects position as home point")
        elseif key == "tt_tpHomePoint" then
            ImGui.SetTooltip("Teleports the subject to the previously stored home point")
        elseif key == "tt_homePointButton" then
            recorder.CPS.CPToolTip1Begin(200, 115)
            ImGui.TextWrapped("Set subject position as home point: Sets the subjects position as home point")
            ImGui.Separator()
            ImGui.TextWrapped("TP to home: Teleports the subject to the previously stored home point")
            recorder.CPS.CPToolTip1End()
        elseif key == "tt_timeSpeedToggle" then
            ImGui.SetTooltip("Sets the \"Toggle Time Speed\" hotkey value")
        elseif key == "tt_startPlaybackWithRecord" then
            ImGui.SetTooltip("Start all loaded records when starting recording")
        elseif key == "tt_editSetSubjectButton" then
            recorder.CPS.CPToolTip1Begin(250, 132)
            ImGui.TextWrapped("Look at: Sets the GameObject under your crosshair as subject (If available)")
            ImGui.Separator()
            ImGui.TextWrapped("Player: Sets player as subject")
            ImGui.Separator()
            ImGui.TextWrapped("Mounted Vehicle: Uses mounted vehicle as subject (If available)")
            ImGui.Separator()
            ImGui.TextWrapped("Clear: Clears the current subject")
            recorder.CPS.CPToolTip1End()
        elseif key == "tt_trySpawn" then
            ImGui.SetTooltip("Trys to spawn the object this record was recorded on")
        elseif key == "tt_tpToCurrentFrame" then
            ImGui.SetTooltip("Teleports the player to the current frames position")
        elseif key == "tt_deleteVehiclePin" then
            ImGui.SetTooltip("Removes the little car icon above a player spawned vehicle")
        elseif key == "tt_playerCamPitch" then
            ImGui.SetTooltip("Should player cam playback recorded pitch rotation")
        elseif key == "tt_playerCamRoll" then
            ImGui.SetTooltip("Should player cam playback recorded roll rotation")
        elseif key == "tt_tooltipHover" then
            ImGui.SetTooltip("This is a hover tooltip")
        elseif key == "tt_toggleHUDButton" then
            ImGui.SetTooltip("Does the same as the toggle HUD hotkey")
        elseif key == "tt_tooltipButton" then
            ImGui.SetTooltip("This is a button tooltip")
        elseif key == "tt_noWeapon" then
            ImGui.SetTooltip("Disables weapons during edit mode, to avoid changing them when using scroll")
        elseif key == "tt_removeNoWeapon" then
            ImGui.SetTooltip("Removes the no weapon restriction, use this if you are stuck on no weapon")
        elseif key == "tt_hotkeys" then
            ImGui.SetTooltip("Display only, use CET Bindings Menu to change them. Tooltips to explain what the hotkeys do.")
        elseif key == "tt_HKtoggleHud" then
            ImGui.SetTooltip("Hotkey to toggle the HUD on and off")
        elseif key == "tt_HKswitchHud" then
            ImGui.SetTooltip("Cycles through the 3 hud modes")
        elseif key == "tt_HKsetSubject" then
            ImGui.SetTooltip("Auto sets the subject to mounted vehicle, look at or player (In that order). Requires HUD Mode \"Record\" or \"Edit\"")
        elseif key == "tt_HKstart" then
            ImGui.SetTooltip("HUD mode record: Starts recording. HUD mode Playback/Edit: Starts playback")
        elseif key == "tt_HKpause" then
            ImGui.SetTooltip("HUD mode record: Pauses recording. HUD mode Playback/Edit: Pauses playback")
        elseif key == "tt_HKreset" then
            ImGui.SetTooltip("HUD mode record: Stops and saves recording. HUD mode Playback/Edit: Resets playback")
        elseif key == "tt_HKtimeSpeed" then
            ImGui.SetTooltip("Switches the time speed between 1 and the set value in the \"Record\" tab. Only available during recording.")
        end
    end
end

return tooltips