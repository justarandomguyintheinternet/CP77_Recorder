settings = {
    tooltips = require("modules/ui/tooltips")
}

function settings.draw(recorder)
    recorder.settings.defaultName, changed =  ImGui.InputTextWithHint("Default Record Name", "Name...", recorder.settings.defaultName, 100)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.deleteConfirm, changed =  ImGui.Checkbox("Show confirm to delete record popup", recorder.settings.deleteConfirm)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    ImGui.Text("Show Tooltips: ")
    ImGui.SameLine()
    if ImGui.RadioButton("Button", recorder.settings.tooltips == 1) then
        recorder.settings.tooltips = 1
        recorder.config.saveFile("config/config.json", recorder.settings)
    end
    ImGui.SameLine()

    if ImGui.RadioButton("Hover", recorder.settings.tooltips == 2) then
        recorder.settings.tooltips = 2
        recorder.config.saveFile("config/config.json", recorder.settings)
    end
    settings.tooltips.drawHover(recorder, "tt_tooltipHover")

    ImGui.SameLine()
    if ImGui.RadioButton("Off", recorder.settings.tooltips == 3) then
        recorder.settings.tooltips = 3
        recorder.config.saveFile("config/config.json", recorder.settings)
    end
    settings.tooltips.drawButton(recorder, "tt_tooltipButton")

    recorder.settings.hudVisible, changed =  ImGui.Checkbox("Show HUD", recorder.settings.hudVisible)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end
    settings.tooltips.drawCombo(recorder, "tt_toggleHUDButton")

    recorder.settings.autoSwitchHud, changed =  ImGui.Checkbox("Auto Switch HUD to active Tab", recorder.settings.autoSwitchHud)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.noWeapon, changed =  ImGui.Checkbox("No Weapon during Edit Mode", recorder.settings.noWeapon)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end
    settings.tooltips.drawCombo(recorder, "tt_noWeapon")

    if ImGui.Button("Force Remove No Weapon Restriciton") then
        recorder.hud.tryNoWeapon(recorder, false)
    end
    settings.tooltips.drawCombo(recorder, "tt_removeNoWeapon")

    recorder.settings.frameStep, changed = ImGui.SliderInt("Edit Mode Scroll Step Size", recorder.settings.frameStep, 1, 25)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    ImGui.Separator()

    local y = 200
    if recorder.settings.tooltips == 2 then y = y - 50 end

    ImGui.BeginChild("hotkeys", 400, y * 1.3, true)
    ImGui.Text("Hotkeys info:")
    settings.tooltips.drawCombo(recorder, "tt_hotkeys")
    ImGui.Text(tostring("Toggle HUD: " .. GetBind("recorderToggleHUD")))
    settings.tooltips.drawCombo(recorder, "tt_HKtoggleHud")
    ImGui.Text(tostring("Switch HUD Mode: " .. GetBind("recorderSwitchMode")))
    settings.tooltips.drawCombo(recorder, "tt_HKswitchHud")
    ImGui.Text(tostring("Set Subject: " .. GetBind("recorderSetSubject")))
    settings.tooltips.drawCombo(recorder, "tt_HKsetSubject")
    ImGui.Text(tostring("Start Action: " .. GetBind("recorderStart")))
    settings.tooltips.drawCombo(recorder, "tt_HKstart")
    ImGui.Text(tostring("Pause Action: " .. GetBind("recorderPause")))
    settings.tooltips.drawCombo(recorder, "tt_HKpause")
    ImGui.Text(tostring("Reset Action: " .. GetBind("recorderReset")))
    settings.tooltips.drawCombo(recorder, "tt_HKreset")
    ImGui.Text(tostring("Toggle Time Speed: " .. GetBind("recorderTimeSpeed")))
    settings.tooltips.drawCombo(recorder, "tt_HKtimeSpeed")
    ImGui.EndChild()
end

return settings