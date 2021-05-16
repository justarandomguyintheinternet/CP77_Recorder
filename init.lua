local recorder = {

	runtimeData = {
		CETOpen = false,
		inGame = false,
		inMenu = false
	},

	defaultSettings = {
		defaultName = "TMPRecording",
		hudVisible = true,
		noWeapon = true,
		frameStep = 1,
		autoSwitchHud = true,
		lastHudTab = "Record",
		deleteConfirm = true,
		tooltips = 2
	},

	settings = {},

	baseUI = require("modules/ui/baseUI"),
	hud = require("modules/ui/hud"),
	recordLogic = require("modules/logic/recordLogic"),
	tpUtils = require("modules/logic/tpUtils"),
	input = require("modules/logic/input"),
	GameUI = require("modules/external/GameUI"),
	config = require("modules/logic/config"),
	offsetManager = require("modules/logic/offsetManager"),
	CPS = require("CPStyling")
}

function recorder:new()

registerForEvent("onInit", function()
	local pM = require("modules/logic/playback")
	recorder.playback = pM:new(recorder)
	recorder.input.startInputObserver(recorder)

	Observe('RadialWheelController', 'OnIsInMenuChanged', function(isInMenu )
        recorder.runtimeData.inMenu = isInMenu
    end)

    recorder.GameUI.OnSessionStart(function()
        recorder.runtimeData.inGame = true
    end)

    recorder.GameUI.OnSessionEnd(function()
        recorder.runtimeData.inGame = false
		recorder.hud.tryNoWeapon(recorder, false) -- Always remove noWeapon restriction
		recorder.baseUI.arrangeUI.clearAllTargets() -- Clear all targets to avoid issues
    end)

    recorder.runtimeData.inGame = not recorder.GameUI.IsDetached() -- Required to check if ingame after reloading all mods

	recorder.config.tryCreateConfig("config/config.json", recorder.defaultSettings)
	recorder.settings = recorder.config.loadFile("config/config.json")
	recorder.recordLogic.recordingName = recorder.settings.defaultName -- Setup Default name
	recorder.hud.mode = recorder.settings.lastHudTab -- Setup last HUD Tab
end)

registerForEvent("onUpdate", function()

	Game.GetPlayer():GetFPPCameraComponent():SetLocalOrientation(GetSingleton('EulerAngles'):ToQuat(EulerAngles.new(0, 0, 0))) -- Make sure that cam roll is always 0, if not overriden from wtihing run

	if recorder.runtimeData.inGame and not recorder.runtimeData.inMenu then
		recorder.recordLogic.run(recorder)
		recorder.playback:run()
		recorder.hud.updateScroll(recorder)
	end
end)

registerForEvent("onDraw", function()
	recorder.baseUI.draw(recorder)
	if recorder.settings.hudVisible and recorder.runtimeData.inGame and not recorder.runtimeData.inMenu then
		recorder.hud.draw(recorder)
	end
end)

registerForEvent("onOverlayOpen", function()
    recorder.runtimeData.CETOpen = true
end)

registerForEvent("onOverlayClose", function()
    recorder.runtimeData.CETOpen = false
end)

registerHotkey("recorderToggleHUD", "Toggle HUD", function()
	recorder.settings.hudVisible = not recorder.settings.hudVisible
	recorder.config.saveFile("config/config.json", recorder.settings)
end)

registerHotkey("recorderSwitchMode", "Switch Recorder Mode", function()
	recorder.hud.switchMode(recorder)
end)

registerHotkey("recorderSetSubject", "Set subject", function()
	recorder.recordLogic.autoSetSubject(recorder)
end)

registerHotkey("recorderTimeSpeed", "Toggle time speed", function()
	if recorder.recordLogic.recording then
		recorder.recordLogic.triggerTimeChange = true
	end
end)

registerHotkey("recorderStart", "Start action", function()
	recorder.hud.startAction(recorder)
end)

registerHotkey("recorderPause", "Pause action", function()
	recorder.hud.stopAction(recorder)
end)

registerHotkey("recorderReset", "Reset", function()
	recorder.hud.resetAction(recorder)
end)

end

return recorder:new()