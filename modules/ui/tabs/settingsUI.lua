settings = {}

function settings.draw(recorder)
    recorder.settings.defaultName, changed =  ImGui.InputTextWithHint("Default Record Name", "Name...", recorder.settings.defaultName, 100)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.deleteConfirm, changed =  ImGui.Checkbox("Show confirm to delete record popup", recorder.settings.deleteConfirm)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.hudVisible, changed =  ImGui.Checkbox("Show HUD", recorder.settings.hudVisible)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.autoSwitchHud, changed =  ImGui.Checkbox("Auto Switch HUD to active Tab", recorder.settings.autoSwitchHud)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    recorder.settings.noWeapon, changed =  ImGui.Checkbox("No Weapon during Edit Mode", recorder.settings.noWeapon)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end

    if ImGui.Button("Force Remove No Weapon Restriciton") then
        recorder.hud.tryNoWeapon(recorder, false)
    end

    recorder.settings.frameStep, changed = ImGui.SliderInt("Edit Mode Scroll Step Size", recorder.settings.frameStep, 1, 25)
    if changed then recorder.config.saveFile("config/config.json", recorder.settings) end
end

return settings