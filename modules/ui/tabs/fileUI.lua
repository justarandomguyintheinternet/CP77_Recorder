fileUI = {
    saveBoxSize = {x = 525, y = 80},
	colors = {frame = {0, 50, 255}},
    filesData = {},
    names = {},
    popup = false,
    deleteFile = nil
}

function fileUI.drawFile(recorder, file)

    local name = file.name:match("(.+)%..+$")

    if fileUI.filesData[name] == nil then
        fileUI.filesData[name] = recorder.config.loadFile("saves/" .. name .. ".json") -- Load file if not loaded yet
    end

    if next(fileUI.filesData[name]) ~= nil and name ~= "tmp" then
        local info = fileUI.filesData[name].info -- Get info field

        recorder.CPS.colorBegin("Border", fileUI.colors.frame)
        recorder.CPS.colorBegin("Separator", fileUI.colors.frame)  -- Do some ImGui stuff
        ImGui.BeginChild("file_".. name, fileUI.saveBoxSize.x, fileUI.saveBoxSize.y, true)

        if fileUI.names[name] == nil then
            fileUI.names[name] = info.name -- Set the tmp name if not done yet (Need so it can be changed using InputText)
        end
        ImGui.PushItemWidth(300)
        fileUI.names[name] = ImGui.InputTextWithHint("", "EmptyName", fileUI.names[name], 100)
        ImGui.PopItemWidth()
        ImGui.SameLine()
        pressed = ImGui.Button("Apply Name")
        if pressed then 
            fileUI.filesData[name].info.name = fileUI.names[name]  -- Change name logic
            fileUI.filesData[name].info = info
            recorder.config.saveFile("saves/" .. name .. ".json", fileUI.filesData[name])
            os.rename("saves/" .. name .. ".json", "saves/" .. fileUI.filesData[name].info.name .. ".json")
        end

        ImGui.Separator()
        ImGui.Text("Recorded on: " .. info.recordedOn .. " | Length: " .. info.frames .. " | Location: " .. info.location) -- Some small infos

        pressed = ImGui.Button("Load")
        if pressed then 
            recorder.baseUI.switchToArrange = true
            recorder.baseUI.arrangeUI.loadFromFile(fileUI.filesData[name], recorder) 
        end

        ImGui.SameLine()
        pressed = ImGui.Button("Delete File")
        if pressed then
            if recorder.settings.deleteConfirm then
                fileUI.popup = true
                fileUI.deleteFile = file
            else
                os.remove("saves/" .. name .. ".json")
                fileUI.filesData[name] = nil
            end
        end

        ImGui.EndChild()
        recorder.CPS.colorEnd(2)
    end
end

function fileUI.handlePopUp(recorder) -- ToDo : Make this its own universal module
    if fileUI.popup then
        ImGui.OpenPopup("Delete Record?")
        if ImGui.BeginPopupModal("Delete Record?", true, ImGuiWindowFlags.AlwaysAutoResize) then
            local again, changed = ImGui.Checkbox("Dont ask again", not recorder.settings.deleteConfirm)
            if changed then recorder.settings.deleteConfirm = not again end

            if ImGui.Button("Cancel") then
                ImGui.CloseCurrentPopup()
                fileUI.popup = false
            end

            ImGui.SameLine()

            if ImGui.Button("Confirm") then
                ImGui.CloseCurrentPopup()
                os.remove("saves/" .. fileUI.deleteFile.name)
                fileUI.filesData[fileUI.deleteFile.name] = nil
                fileUI.popup = false
            end
            ImGui.EndPopup()
        end
    end
end

function fileUI.draw(recorder)
    local f = false -- True if any .json file
    for _, file in pairs(dir("saves")) do
        if file.name:match("^.+(%..+)$") == ".json" then
            f = true
            fileUI.drawFile(recorder, file)
        end
    end
    if not f then
        ImGui.Text("Nothing here ... Record something first!")
    end
    fileUI.handlePopUp(recorder)
end

return fileUI