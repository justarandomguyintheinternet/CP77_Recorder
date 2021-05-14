recordUI = {
	colors = {frame = {0, 50, 255}}
}

function recordUI.draw(recorder)
    recorder.CPS.colorBegin("Border", recordUI.colors.frame)

    ImGui.BeginChild("subjectSettings", 525, 60, true)
    ImGui.Text("Recording subject:")
    ImGui.SameLine()
    ImGui.Text(tostring(recorder.recordLogic.currentSubjectText))
    ImGui.Spacing()
    pressed = ImGui.Button("Use look at")
    if pressed then recorder.recordLogic.setSubject(recorder, "lookAt") end
    ImGui.SameLine()
    pressed = ImGui.Button("Use player")
    if pressed then recorder.recordLogic.setSubject(recorder, "player") end
    ImGui.SameLine()
    pressed = ImGui.Button("Use mounted vehicle")
    if pressed then recorder.recordLogic.setSubject(recorder, "mountedVehicle") end
    ImGui.EndChild()

    ImGui.BeginChild("miscSettings", 525, 105, true)
    pressed = ImGui.Button("Set subject position as home point")
    if pressed then recorder.recordLogic.setHomePoint() end
    ImGui.SameLine()
    pressed = ImGui.Button("TP to home")
    if pressed then recorder.recordLogic.tpToHome(recorder) end
    recorder.recordLogic.timeSpeed = ImGui.SliderFloat("Time speed toggle", recorder.recordLogic.timeSpeed, 0, 3, "%.2f")
    recorder.recordLogic.recordingName =  ImGui.InputTextWithHint("Record Name", "Name...", recorder.recordLogic.recordingName, 100)
    recorder.recordLogic.startPlayback = ImGui.Checkbox("Start playback with recording", recorder.recordLogic.startPlayback)
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