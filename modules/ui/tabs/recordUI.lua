recordUI = {
	colors = {frame = {0, 50, 255}},
    tooltips = require("modules/ui/tooltips")
}

function recordUI.draw(recorder)
    recorder.CPS.colorBegin("Border", recordUI.colors.frame)

    local h = 2 * ImGui.GetFrameHeight() + 3 * ImGui.GetStyle().ItemSpacing.y + 2 * ImGui.GetStyle().FramePadding.y
    ImGui.BeginChild("subjectSettings", 525, h, true)
    ImGui.Text("Recording subject:")
    ImGui.SameLine()
    ImGui.Text(tostring(recorder.recordLogic.currentSubjectText))
    ImGui.Spacing()

    pressed = ImGui.Button("Use look at")
    recordUI.tooltips.drawHover(recorder, "tt_setSubjectLook")
    if pressed then recorder.recordLogic.setSubject(recorder, "lookAt") end
    ImGui.SameLine()

    pressed = ImGui.Button("Use player")
    recordUI.tooltips.drawHover(recorder, "tt_setSubjectPlayer")
    if pressed then recorder.recordLogic.setSubject(recorder, "player") end
    ImGui.SameLine()

    pressed = ImGui.Button("Use mounted vehicle")
    if pressed then recorder.recordLogic.setSubject(recorder, "mountedVehicle") end
    recordUI.tooltips.drawHover(recorder, "tt_setSubjectVehicle")
    recordUI.tooltips.drawButton(recorder, "tt_setSubjectButton")
    ImGui.EndChild()

    local h = 4 * ImGui.GetFrameHeight() + 6 * ImGui.GetStyle().ItemSpacing.y + 2 * ImGui.GetStyle().FramePadding.y
    ImGui.BeginChild("miscSettings", 525, h, true)
    pressed = ImGui.Button("Set subject position as home point")
    if pressed then recorder.recordLogic.setHomePoint() end
    recordUI.tooltips.drawHover(recorder, "tt_setHomePoint")
    ImGui.SameLine()

    pressed = ImGui.Button("TP to home")
    if pressed then recorder.recordLogic.tpToHome(recorder) end
    recordUI.tooltips.drawHover(recorder, "tt_tpHomePoint")
    recordUI.tooltips.drawButton(recorder, "tt_homePointButton")

    recorder.recordLogic.timeSpeed = ImGui.SliderFloat("Time speed toggle", recorder.recordLogic.timeSpeed, 0, 3, "%.2f")
    recordUI.tooltips.drawCombo(recorder, "tt_timeSpeedToggle")

    recorder.recordLogic.recordingName =  ImGui.InputTextWithHint("Record Name", "Name...", recorder.recordLogic.recordingName, 100)
    recorder.recordLogic.startPlayback = ImGui.Checkbox("Start playback with recording", recorder.recordLogic.startPlayback)
    recordUI.tooltips.drawCombo(recorder, "tt_startPlaybackWithRecord")
    ImGui.EndChild()

    ImGui.Spacing()
    pressed = ImGui.Button("Start recording")
    if pressed then recorder.recordLogic.startRecord(recorder) end
    ImGui.SameLine()

    pressed = ImGui.Button("Stop recording")
    if pressed then recorder.recordLogic.stopRecord(recorder) end

    recorder.CPS.colorEnd(1)
end

return recordUI