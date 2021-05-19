arrangeUI = {
    saveBoxSize = {x = 530, y = 130},
	colors = {frame = {0, 50, 255}},
    loadedRecords = {},
    miscUtils = require("modules/logic/miscUtils"),
    record = require("modules/logic/record"),
}

function arrangeUI.clearAllTargets()
    for _, v in ipairs(arrangeUI.loadedRecords) do
        v:setSubject("clear")
    end
end

function arrangeUI.getActiveRecords()
    local records = {}

    for _, r in ipairs(arrangeUI.loadedRecords) do
        if r.playbackSettings.enabled then
            table.insert(records, r)
        end
    end

    return records
end

function arrangeUI.getRunningRecords()
    local records = {}

    for _, r in ipairs(arrangeUI.loadedRecords) do
        if r.currentFrame ~= r.info.frames and r.playbackSettings.enabled then
            table.insert(records, r)
        end
    end

    return records
end

function arrangeUI.getNumNames(name)
    local num = 0

    for _, v in pairs(arrangeUI.loadedRecords) do
        if name:gsub('%d','')  == v.info.name:gsub('%d','') then 
            num = num + 1
        end
    end

    return num - 1
end

function arrangeUI.loadFromFile(data, recorder)
    local r = arrangeUI.record:new(recorder)
    table.insert(arrangeUI.loadedRecords, r)
    local id = miscUtils.indexValue(arrangeUI.loadedRecords, r)

    arrangeUI.loadedRecords[id]:load(miscUtils.deepcopy(data))

    arrangeUI.loadedRecords[id].info.playbackOnText = "Not set"

    if arrangeUI.getNumNames(arrangeUI.loadedRecords[id].info.name) > 0 then 
        arrangeUI.loadedRecords[id].info.name = arrangeUI.loadedRecords[id].info.name .. arrangeUI.getNumNames(arrangeUI.loadedRecords[id].info.name)
    end
end

function arrangeUI.loadRecord(record)
    record.info.playbackOnText = "Not set"

    if arrangeUI.getNumNames(record.info.name) > 0 then
        record.info.name = record.info.name .. arrangeUI.getNumNames(record.info.name)
    end

    table.insert(arrangeUI.loadedRecords, record)

    record.recorder.offsetManager.resetRecord(record.recorder, record) -- Makes sure that there is an entry in the offset table for that record, since loadRecord gets called when creating a new one, and thus doesnt call record:load
end

function arrangeUI.drawSlot(recorder, record, id)
    info = record.info
    recorder.CPS.colorBegin("Border", arrangeUI.colors.frame)
    recorder.CPS.colorBegin("Separator", arrangeUI.colors.frame)
    ImGui.BeginChild("loadedSlot" .. id, arrangeUI.saveBoxSize.x, arrangeUI.saveBoxSize.y, true)

    ImGui.PushItemWidth(300)
    record.info.name = ImGui.InputTextWithHint("", "EmptyName", info.name, 100)
    ImGui.PopItemWidth()
    ImGui.SameLine()
    record.playbackSettings.enabled, changed = ImGui.Checkbox("Playback enabled", record.playbackSettings.enabled)
    if changed and not record.playbackSettings.enabled then Game.GetPlayer():GetFPPCameraComponent():SetLocalOrientation(GetSingleton('EulerAngles'):ToQuat(EulerAngles.new(0, 0, 0))) end
    ImGui.Separator()

    ImGui.Text(tostring("Recorded on: " .. info.recordedOn))
    ImGui.Text(tostring("Playback on: " .. info.playbackOnText))
    ImGui.Text(tostring("Length: " .. info.frames))
    ImGui.Text(tostring("Start delay: " .. record.playbackSettings.offset))

    pressed = ImGui.Button("Open in Editor")
    if pressed then
        recorder.hud.mode = "Edit"
        recorder.baseUI.editUI.loadRecord(record) 
        recorder.baseUI.switchToEdit = true
    end
    ImGui.SameLine()
    pressed = ImGui.Button("Save")
    if pressed then 
        record:save() 
        recorder.baseUI.fileUI.filesData[info.name] = nil
    end
    ImGui.SameLine()
    pressed = ImGui.Button("Remove")
    if pressed then
        Game.GetPlayer():GetFPPCameraComponent():SetLocalOrientation(GetSingleton('EulerAngles'):ToQuat(EulerAngles.new(0, 0, 0)))
        if recorder.baseUI.editUI.record == arrangeUI.loadedRecords[id] then
            recorder.baseUI.editUI.record = nil
        end
        table.remove(arrangeUI.loadedRecords, id) 
    end

    ImGui.EndChild()
    recorder.CPS.colorEnd(2)
end

function arrangeUI.drawPlayback(recorder)
    recorder.CPS.colorBegin("Border", arrangeUI.colors.frame)
    ImGui.BeginChild("playbackSettings", arrangeUI.saveBoxSize.x, 44, true)

    if recorder.CPS.CPButton("Play", 50, 25) then
        recorder.playback:startPlayback()
    end
    ImGui.SameLine()
    if recorder.CPS.CPButton("Pause", 50, 25) then
        recorder.playback:pausePlayback()
    end
    ImGui.SameLine()
    if recorder.CPS.CPButton("Reset", 50, 25) then
        recorder.playback:resetPlayback()
    end

    ImGui.EndChild()
    recorder.CPS.colorEnd(1)
end

function arrangeUI.draw(recorder)
    if next(arrangeUI.loadedRecords) == nil then
        ImGui.Text("Nothing here ... Record something new or load an existing record!")
    else
        for k, data in pairs(arrangeUI.loadedRecords) do
            arrangeUI.drawSlot(recorder, data, k)
        end
        arrangeUI.drawPlayback(recorder)
    end
end

return arrangeUI


