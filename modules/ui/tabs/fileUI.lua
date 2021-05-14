fileUI = {
    saveBoxSize = {x = 525, y = 80},
	colors = {frame = {0, 50, 255}},
    filesData = {},
    names = {}
}

function fileUI.drawFile(recorder, file)

    local name = file.name:match("(.+)%..+$")

    if fileUI.filesData[name] == nil then
        print("loading " .. name)
        fileUI.filesData[name] = recorder.fileSystem.loadFile("saves/" .. name .. ".json") -- Load file if not loaded yet
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
            recorder.fileSystem.saveFile("saves/" .. name .. ".json", fileUI.filesData[name])
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
            os.remove("saves/" .. name .. ".json")
            fileUI.filesData[name] = nil
        end 
        
        ImGui.EndChild()
        recorder.CPS.colorEnd(2)
    end
end

function fileUI.draw(recorder)
    for _, file in pairs(dir("saves")) do
        fileUI.drawFile(recorder, file)
    end 
end

return fileUI