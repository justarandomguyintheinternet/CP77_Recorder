baseUI = {
    recordUI = require("modules/ui/tabs/recordUI"),
    arrangeUI = require("modules/ui/tabs/arrangeUI"),
    editUI = require("modules/ui/tabs/editUI"),
    fileUI = require("modules/ui/tabs/fileUI"),
    settingsUI = require("modules/ui/tabs/settingsUI"),
    switchToEdit = false,
    switchToArrange = false,
    currentTab = 0
}

function baseUI.getSwitchFlag(tab)
    if tab == "edit" and baseUI.switchToEdit then
        baseUI.switchToEdit = false
        return ImGuiTabItemFlags.SetSelected 
    elseif tab == "arrange" and baseUI.switchToArrange then 
        baseUI.switchToArrange = false
        return ImGuiTabItemFlags.SetSelected 
    else
        return ImGuiTabItemFlags.None
    end
end

function baseUI.draw(recorder)
    if recorder.runtimeData.CETOpen then

        wWidth, wHeight = GetDisplayResolution()

        recorder.CPS:setThemeBegin()
        ImGui.Begin("Recorder v.0.1a", ImGuiWindowFlags.AlwaysAutoResize)
        ImGui.SetWindowPos(wWidth/2-250, wHeight/2-400, ImGuiCond.FirstUseEver)
        ImGui.SetWindowSize(550, 300)

        if ImGui.BeginTabBar("Tabbar", ImGuiTabBarFlags.NoTooltip) then
            recorder.CPS.styleBegin("TabRounding", 0)

            if ImGui.BeginTabItem("Record") then
                if baseUI.currentTab ~= 1 then recorder.hud.trySwitchHud(recorder, 1) end
                baseUI.currentTab = 1
                baseUI.recordUI.draw(recorder)
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem("Load and play", baseUI.getSwitchFlag("arrange")) then
                if baseUI.currentTab ~= 2 then recorder.hud.trySwitchHud(recorder, 2) end
                baseUI.currentTab = 2
                baseUI.arrangeUI.draw(recorder)
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem("Edit", baseUI.getSwitchFlag("edit")) then
                if baseUI.currentTab ~= 3 then recorder.hud.trySwitchHud(recorder, 3) end
                baseUI.currentTab = 3
                baseUI.editUI.draw(recorder)
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem("Files") then
                if baseUI.currentTab ~= 4 then recorder.hud.trySwitchHud(recorder, 4) end
                baseUI.currentTab = 4
                baseUI.fileUI.draw(recorder)
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem("Settings") then
                if baseUI.currentTab ~= 5 then recorder.hud.trySwitchHud(recorder, 5) end
                baseUI.currentTab = 5
                baseUI.settingsUI.draw(recorder)
                ImGui.EndTabItem()
            end

            recorder.CPS.styleEnd(1)
            ImGui.EndTabBar()
        end

        ImGui.End()
        recorder.CPS:setThemeEnd()
    end
end

return baseUI