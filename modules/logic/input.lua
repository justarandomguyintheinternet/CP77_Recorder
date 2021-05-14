input = {}

function input.startInputObserver(recorder)
    Observe('PlayerPuppet', 'OnAction', function(action)
        local actionName = Game.NameToString(action:GetName(action))
        local actionType = action:GetType(action).value
        if actionName == 'ChoiceScrollUp'then
            if actionType == 'BUTTON_PRESSED'then
                recorder.hud.editScroll(recorder, "up")
            end
        elseif actionName == 'ChoiceScrollDown'then
            if actionType == 'BUTTON_PRESSED'then
                recorder.hud.editScroll(recorder, "down")
            end
        end
    end)
end

return input