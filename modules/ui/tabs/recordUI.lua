recordUI = {
	colors = {frame = {0, 50, 255}},
    tooltips = require("modules/ui/tooltips")
}

function recordUI.draw(recorder)
    recorder.CPS.colorBegin("Border", recordUI.colors.frame)

    ImGui.BeginChild("subjectSettings", 525, 60, true)
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

    ImGui.BeginChild("miscSettings", 525, 105, true)
    pressed = ImGui.Button("Set subject position as home point")
    if pressed then recorder.recordLogic.setHomePoint() end
    recordUI.tooltips.drawHover(recorder, "tt_setHomePoint")
    ImGui.SameLine()

    pressed = ImGui.Button("TP to home")
    if pressed then recorder.recordLogic.tpToHome(recorder) end
    recordUI.tooltips.drawHover(recorder, "tt_tpHomePoint")
    recordUI.tooltips.drawButton(recorder, "tt_homePointButton")

    recorder.recordLogic.timeSpeed = ImGui.SliderFloat("Time speed toggle", recorder.recordLogic.timeSpeed, 0, 3, "%.2f")
    recordUI.tooltips.drawHover(recorder, "tt_timeSpeedToggle")
    recordUI.tooltips.drawButton(recorder, "tt_timeSpeedToggle")

    recorder.recordLogic.recordingName =  ImGui.InputTextWithHint("Record Name", "Name...", recorder.recordLogic.recordingName, 100)
    recorder.recordLogic.startPlayback = ImGui.Checkbox("Start playback with recording", recorder.recordLogic.startPlayback)
    recordUI.tooltips.drawHover(recorder, "tt_startPlaybackWithRecord")
    recordUI.tooltips.drawButton(recorder, "tt_startPlaybackWithRecord")
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