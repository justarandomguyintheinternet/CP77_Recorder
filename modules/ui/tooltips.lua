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
        end
    end
end

return tooltips