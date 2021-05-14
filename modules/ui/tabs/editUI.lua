editUI = {
    record = nil,
    recordLastFrame = 1,
    saveBoxSize = {info = {x = 530, y = 102},
                   subject = {x = 530, y = 130},
                   pbs = {x = 530, y = 148},
                   eds = {x = 530, y = 80},
                   efs = {x = 530, y = 75, yCalc = 0}},  
	colors = {frame = {0, 50, 255}},
    selectedEffect = 0,
    effectNames = {[0] = {dName = "Subject | Clear", key = "subject_clear"},
                   [1] = {dName = "Subject | Destroy", key = "destroy"},
                   [2] = {dName = "Subject | Position Offset", key = "subject_offset"},
                   [4] = {dName = "Game | Time Speed", key = "game_timeSpeed"},
                   [3] = {dName = "Game | Time", key = "game_time"},
                   [5] = {dName = "Vehicle | Honk and Flash", key = "veh_honk"},
                   [6] = {dName = "Vehicle | Lights", key = "veh_light"},
                   [7] = {dName = "Vehicle | Explode", key = "veh_explode"},
                   [8] = {dName = "Vehicle | Doors", key = "veh_door"},
                   [9] = {dName = "Vehicle | Windows", key = "veh_window"},
                   [10] = {dName = "Device | Power", key = "device_power"},
                   [11] = {dName = "Camera | FOV", key = "cam_fov"}}
}

function editUI.loadRecord(data)
    editUI.record = data
end

function editUI.drawInfo()
    local info = editUI.record.info

    ImGui.BeginChild("editUI_Info", editUI.saveBoxSize.info.x, editUI.saveBoxSize.info.y, true)

    ImGui.Text("Info")
    ImGui.Separator()
    ImGui.Text(tostring("Name: " .. info.name))
    ImGui.Text(tostring("Length: " .. info.frames))
    ImGui.Text(tostring("Recorded on: " .. info.recordedOn))
    ImGui.Text(tostring("Playback on: " .. info.playbackOnText))

    ImGui.EndChild()
end

function editUI.drawSubject()
    local y = 0
    local targetVehicle = (editUI.record.target ~= nil and editUI.record.target:IsVehicle())
    if targetVehicle then y = 27 end

    ImGui.BeginChild("editUI_Subject", editUI.saveBoxSize.subject.x, editUI.saveBoxSize.subject.y + y, true)

    ImGui.Text("Subject")

    ImGui.Separator()
    if ImGui.Button("Use look at") then editUI.record:setSubject("lookAt") end
    ImGui.SameLine()
    if ImGui.Button("Use player") then editUI.record:setSubject("player") end
    ImGui.SameLine()
    if ImGui.Button("Use mounted vehicle") then editUI.record:setSubject("mountedVehicle") end
    ImGui.SameLine()
    if ImGui.Button("Clear") then editUI.record:setSubject("clear") end

    ImGui.Separator()

    if ImGui.Button("Try spawn") then
        editUI.record:spawnTarget()
    end

    if ImGui.Button("TP to current Frame") then
        local pos = editUI.record.recordData[editUI.record:calcPlayFrame(editUI.record.currentFrame)].pos
	    pos = Vector4.new(pos.x, pos.y, pos.z, pos.w)

        Game.GetTeleportationFacility():Teleport(Game.GetPlayer(), pos, EulerAngles.new(0,0,Game.GetPlayer():GetWorldYaw()))
    end
    editUI.record.playbackSettings.invincible = ImGui.Checkbox("Invincible", editUI.record.playbackSettings.invincible)

    if targetVehicle then
        ImGui.Separator()
        if ImGui.Button("Delete Vehicle Mappin") then
            editUI.record.target:GetVehicleComponent():DestroyMappin()
        end
    end

    ImGui.EndChild()
end

function editUI.drawPlaybackSettings()
    local y = 0
    local isPlayer = (editUI.record.target ~= nil and editUI.record.target:IsPlayer())
    if isPlayer then y = 50 end

    ImGui.BeginChild("editUI_PlaybackSettings", editUI.saveBoxSize.pbs.x, editUI.saveBoxSize.pbs.y + y, true)

    ImGui.Text("Playback Settings")
    ImGui.Separator()

    ImGui.PushItemWidth(100)
    v, changed = ImGui.InputInt("Start offset", editUI.record.playbackSettings.offset, 0, 999999999)
    if changed then editUI.record:updateOffset(v) end 
    v, changed = ImGui.InputInt("Trim start", editUI.record.playbackSettings.startTrim, 0, editUI.record.info.frames)
    if changed then editUI.record:updateTrimStart(v) end
    ImGui.SameLine()
    v, changed = ImGui.InputInt("Trim end", editUI.record.playbackSettings.endTrim, 0, editUI.record.info.frames)
    if changed then editUI.record:updateTrimEnd(v) end
    ImGui.PopItemWidth()

    editUI.record.playbackSettings.ignoreRot = ImGui.Checkbox("Ignore Rotation", editUI.record.playbackSettings.ignoreRot)
    editUI.record.playbackSettings.ignorePos = ImGui.Checkbox("Ignore Position", editUI.record.playbackSettings.ignorePos)
    editUI.record.playbackSettings.reverse = ImGui.Checkbox("Reverse Playback", editUI.record.playbackSettings.reverse)

    if isPlayer then
        ImGui.Separator()
        editUI.record.playbackSettings.camPitch = ImGui.Checkbox("Player Camera Set Pitch", editUI.record.playbackSettings.camPitch)
        editUI.record.playbackSettings.camRoll = ImGui.Checkbox("Player Camera Set Roll", editUI.record.playbackSettings.camRoll)
    end

    ImGui.EndChild()
end

function editUI.drawEditSettings()
    ImGui.BeginChild("editUI_EditSettings", editUI.saveBoxSize.eds.x, editUI.saveBoxSize.eds.y, true)

    ImGui.Text("Edit Settings")
    ImGui.Separator()

    value, changed = ImGui.SliderInt("Current Frame", editUI.record.currentFrame, 1, editUI.record.info.frames)
    if changed then
        editUI.record:setFrameEdit(value)
    end

    if ImGui.Button("Frame Back") then
        if editUI.record.currentFrame - 1 < 1 then
            editUI.record:setFrameEdit(editUI.record.info.frames)
        else
            editUI.record:setFrameEdit(editUI.record.currentFrame - 1)
        end
    end
    ImGui.SameLine()
    if ImGui.Button("Frame Forward") then
        if editUI.record.currentFrame + 1 > editUI.record.info.frames then
            editUI.record:setFrameEdit(1)
        else
            editUI.record:setFrameEdit(editUI.record.currentFrame + 1)
        end
    end

    ImGui.EndChild()
end

function editUI.drawEffects()
    ImGui.BeginChild("editUI_EffectsSettings", editUI.saveBoxSize.efs.x, 60, true) -- editUI.saveBoxSize.efs.yCalc

    ImGui.Text("Effects")
    ImGui.Separator()

    editUI.selectedEffect = ImGui.Combo("", editUI.selectedEffect, {editUI.effectNames[0].dName, editUI.effectNames[1].dName, editUI.effectNames[2].dName, editUI.effectNames[3].dName, editUI.effectNames[4].dName, editUI.effectNames[5].dName, editUI.effectNames[6].dName, editUI.effectNames[7].dName, editUI.effectNames[8].dName, editUI.effectNames[9].dName, editUI.effectNames[10].dName, editUI.effectNames[11].dName}, 12)
    ImGui.SameLine()
    if ImGui.Button("Add") then 
        editUI.record:addEffect(editUI.effectNames[editUI.selectedEffect].key) 
    end
    ImGui.SameLine()
    if ImGui.Button("Sort effects") then
        editUI.record:sortEffects()
    end
    ImGui.EndChild()

    for _, effect in pairs(editUI.record.effects) do
        --ImGui.SetNextItemOpen(true, ImGuiCond.Appearing)
        ImGui.SetNextItemOpen(effect.data.uiOpen)
        state = ImGui.CollapsingHeader(tostring(effect.data.fancyName .. " | Frame " .. effect.data.frame))
        if state then
            ImGui.PushID(tostring(effect.childId))
            effect:draw()
            ImGui.PopID()
        end
        effect.data.uiOpen = state
    end

end

function editUI.calcEffectsBoxY()
    local y = editUI.saveBoxSize.efs.y
    for _, e in pairs(editUI.record.effects) do
        if e.collapsed then
            y = y + e.saveBoxSize.y + 25
        else
            y = y + 20
        end
    end
    editUI.saveBoxSize.efs.yCalc = y
end

function editUI.draw(recorder)
    recorder.CPS.colorBegin("Separator", editUI.colors.frame)
    recorder.CPS.colorBegin("Border", editUI.colors.frame)

    if editUI.record == nil then
        ImGui.Text("Nothing here ... Load a record from the \"Load and play\" tab first!")
    else
        editUI.calcEffectsBoxY()
        editUI.drawInfo()
        editUI.drawSubject()
        editUI.drawPlaybackSettings()
        editUI.drawEditSettings()
        editUI.drawEffects()
    end

    recorder.CPS.colorEnd(2)
end

return editUI