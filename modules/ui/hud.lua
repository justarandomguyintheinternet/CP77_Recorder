hud = {
    mode = "Record",
    state = "Standby",
    subject = "Not set",
    lastEffect = "None",
    paused = false,
    recording = false,
    playback = false,
    frame = 1,
    scrollTodo = 0,

    extraWidth = 0
}

function hud.draw(recorder)
    recorder.CPS:setThemeBegin()
    recorder.CPS.styleBegin("WindowBorderSize", 0)
    recorder.CPS.colorBegin("WindowBg", {0,0,0,0})

    if (ImGui.Begin("hud", bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoTitleBar))) then
        ImGui.BeginChild("hud_frame", 22 + hud.extraWidth, 80 * 1.25, true)
        ImGui.Text("Mode: " .. hud.mode)
        if hud.mode == "Record" then
            hud.drawRecord(recorder)
        elseif hud.mode == "Playback" then
            hud.drawPlayback(recorder)
        elseif hud.mode == "Edit" then
            hud.drawEdit(recorder)
        end
        ImGui.EndChild()
    end
    ImGui.End()

    recorder.CPS.colorEnd(1)
    recorder.CPS.styleEnd(1)
    recorder.CPS:setThemeEnd()
end

function hud.drawRecord(recorder)
    ImGui.Text(tostring("State: " .. hud.state))
    ImGui.Text(tostring("Subject: " .. hud.subject))
    hud.extraWidth = ImGui.CalcTextSize(tostring("Subject: " .. hud.subject))
    ImGui.Text(tostring("Frame: " .. hud.frame))
end

function hud.drawPlayback(recorder)
    local state = "Standby"
    if recorder.playback.isPlaying then
        state = "Running..."
    elseif recorder.playback.isPaused then
        state = "Paused"
    end

    ImGui.Text(tostring("State: " .. state))
    ImGui.Text(tostring("Frame: " .. recorder.playback.currentFrame))
    ImGui.Text(tostring("Running Records: " .. #recorder.baseUI.arrangeUI.getRunningRecords() .. "/" .. #recorder.baseUI.arrangeUI.getActiveRecords()))
    local a = ImGui.CalcTextSize(tostring("Running Records: " .. #recorder.baseUI.arrangeUI.getRunningRecords() .. "/" .. #recorder.baseUI.arrangeUI.getActiveRecords()))
    local b = ImGui.CalcTextSize(tostring("Action: " .. state))
    hud.extraWidth = math.max(a, b)
end

function hud.drawEdit(recorder)
    ImGui.Text(tostring("Frame: " .. recorder.playback.currentFrame .. "/" .. recorder.playback:getLongestRecord()))
    ImGui.Text(tostring("Running Records: " .. #recorder.baseUI.arrangeUI.getRunningRecords() .. "/" .. #recorder.baseUI.arrangeUI.getActiveRecords()))
    ImGui.Text(tostring("Last Effect: " .. hud.lastEffect))
    local a = ImGui.CalcTextSize(tostring("Last Effect: " .. hud.lastEffect))
    local b = ImGui.CalcTextSize(tostring("Running Records: " .. #recorder.baseUI.arrangeUI.getRunningRecords() .. "/" .. #recorder.baseUI.arrangeUI.getActiveRecords()))
    hud.extraWidth = math.max(a, b)
end

function hud.startAction(recorder)
    if hud.mode == "Record" then
        recorder.recordLogic.startRecord(recorder)
    else
        if #recorder.baseUI.arrangeUI.loadedRecords ~= 0 then
            recorder.playback:startPlayback()
        else
            hud.state = "No Record loaded!"
        end
    end
end

function hud.stopAction(recorder)
    if hud.mode == "Record" then
        recorder.recordLogic.togglePause()
    else
        recorder.playback:pausePlayback()
    end
end

function hud.resetAction(recorder)
    if hud.mode == "Record" then
        recorder.recordLogic.stopRecord(recorder)
    else
        recorder.playback:resetPlayback()
    end
end

function hud.setSubject(recorder)
    if hud.mode == "Record" then
        recorder.recordLogic.autoSetSubject(recorder)
    elseif hud.mode == "Edit" then
        if recorder.baseUI.editUI.record ~= nil then
            recorder.baseUI.editUI.record:autoSetSubject()
        end
    end
end

function hud.switchMode(recorder)
    if hud.mode == "Record" then
		hud.mode = "Playback"
        recorder.settings.lastHudTab = "Playback"
	elseif hud.mode == "Playback" then
        hud.tryNoWeapon(recorder, true)
		hud.mode = "Edit"
        recorder.settings.lastHudTab = "Edit"
	elseif hud.mode == "Edit" then
        hud.tryNoWeapon(recorder, false)
		hud.mode = "Record"
        recorder.settings.lastHudTab = "Record"
	end
end

function hud.tryNoWeapon(recorder, state)
    if recorder.settings.noWeapon and state then
        Game.ApplyEffectOnPlayer("GameplayRestriction.NoCombat")
    else
        local rmStatus = Game['StatusEffectHelper::RemoveStatusEffect;GameObjectTweakDBID']
        rmStatus(Game.GetPlayer(), "GameplayRestriction.NoCombat")
    end
end

function hud.editScroll(recorder, dir)
    if hud.mode == "Edit" then
        if dir == "up" then
            hud.scrollTodo = hud.scrollTodo + recorder.settings.frameStep
        else
            hud.scrollTodo = hud.scrollTodo - recorder.settings.frameStep
        end
    end
end

function hud.updateScroll(recorder) -- Only update once per frame, observer would call it more than once per frame, producing lag
    if hud.mode == "Edit" and (recorder.playback.currentFrame + hud.scrollTodo ~=  recorder.playback.currentFrame) then
        recorder.playback:jumpToFrame(recorder.playback.currentFrame + hud.scrollTodo)
    end
    hud.scrollTodo = 0
end

function hud.trySwitchHud(recorder, tab)
    if recorder.settings.autoSwitchHud then
        if tab == 1 then
            hud.mode = "Record"
            hud.tryNoWeapon(recorder, false)
        elseif tab == 2 then
            hud.mode = "Playback"
            hud.tryNoWeapon(recorder, false)
        elseif tab == 3 then
            hud.mode = "Edit"
            hud.tryNoWeapon(recorder, true)
        else
            hud.tryNoWeapon(recorder, false)
        end
    end
end

return hud