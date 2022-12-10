recordLogic = {
    currentSubjectText = "Not set",
    recordingName = "TMPRecording",

    subject = nil,
    recording = false,
    paused = false,
    canPause = false,
    frame = 1,

    recordDataPosition = {},
    recordDataRotation = {},
    timeEvents = {},
    data = {},

    timeSpeed = 1,
    timeChanged = false,
    triggerTimeChange = false,
    startPlayback = false,
    homePoint = nil,

    record = require("modules/logic/record"),
    utils = require("modules/logic/miscUtils")
}

function recordLogic.handleTimeSpeed(speed)
    local transformedSpeed = 0

    if recordLogic.triggerTimeChange then
        recordLogic.triggerTimeChange = false
        recordLogic.timeChanged = not recordLogic.timeChanged
        if recordLogic.timeChanged then
            if speed == 0 then
                transformedSpeed = 0.000001
            elseif speed == 1 then
                transformedSpeed = 0
            else
                transformedSpeed = speed
            end
            recordLogic.timeEvents[recordLogic.frame] = transformedSpeed
            Game.SetTimeDilation(transformedSpeed)
        else
            Game.SetTimeDilation(0)
            recordLogic.timeEvents[recordLogic.frame] = 1
        end
    end
end

function recordLogic.setSubject(recorder, key)
    if key == "player" then
        recordLogic.subject = Game.GetPlayer()
        recordLogic.currentSubjectText = "Player"
    elseif key == "lookAt" then
        if Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false) ~= nil then
            recordLogic.subject = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false)
            recordLogic.currentSubjectText = tostring(recordLogic.subject:GetDisplayName())
        end  
    elseif key == "mountedVehicle" then
        if Game['GetMountedVehicle;GameObject'](Game.GetPlayer()) ~= nil then
            recordLogic.subject = Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
            recordLogic.currentSubjectText = tostring(recordLogic.subject:GetDisplayName())
        end  
    end

    recordLogic.updateOverlay(recorder)
end

function recordLogic.autoSetSubject(recorder)
    if Game['GetMountedVehicle;GameObject'](Game.GetPlayer()) ~= nil then
        recordLogic.subject = Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
        recordLogic.currentSubjectText = tostring(recordLogic.subject:GetDisplayName())
    elseif Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false) ~= nil then
        recordLogic.subject = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false)
        recordLogic.currentSubjectText = tostring(recordLogic.subject:GetDisplayName())
    else
        recordLogic.subject = Game.GetPlayer()
        recordLogic.currentSubjectText = "Player"
    end

    recordLogic.updateOverlay(recorder)
end

function recordLogic.run(recorder)
    if recordLogic.recording then
        recordLogic.handleTimeSpeed(recordLogic.timeSpeed)
        recordLogic.record()
    end
    recordLogic.updateOverlay(recorder)
end

function recordLogic.record()
    recordLogic.recordDataPosition[recordLogic.frame] = recordLogic.subject:GetWorldPosition()
    if recordLogic.subject:IsPlayer() then
        local v = Vector4.new(-Game.GetCameraSystem():GetActiveCameraForward().x, -Game.GetCameraSystem():GetActiveCameraForward().y, -Game.GetCameraSystem():GetActiveCameraForward().z, -Game.GetCameraSystem():GetActiveCameraForward().w)
        local euler = GetSingleton('Vector4'):ToRotation(v)
        local tEuler = EulerAngles.new(euler.roll, euler.pitch, euler.yaw + 180)
        recordLogic.recordDataRotation[recordLogic.frame] = GetSingleton('EulerAngles'):ToQuat(tEuler)
    else
	    recordLogic.recordDataRotation[recordLogic.frame] = recordLogic.subject:GetWorldOrientation()
    end
	print("Frame " .. recordLogic.frame .. " : " .. tostring(recordLogic.recordDataPosition[recordLogic.frame]))
    recordLogic.frame = recordLogic.frame + 1
end

function recordLogic.startRecord(recorder)
    if recordLogic.subject ~= nil and not recordLogic.paused and not recordLogic.recording then
        recorder.hud.mode = "Record"

        recordLogic.frame = 1
        recordLogic.recording = true
        recordLogic.paused = false
        recordLogic.canPause = true
        recordLogic.recordDataPosition = {}
        recordLogic.recordDataRotation = {}
        recordLogic.timeEvents = {}
        if recordLogic.startPlayback then
            recorder.playback:resetPlayback()
            recorder.playback:startPlayback()
        end
    elseif recordLogic.subject == nil then
        recordLogic.currentSubjectText = "Set a subject first!"
    elseif recordLogic.paused then
        recordLogic.togglePause()
    end
end

function recordLogic.togglePause()
    if recordLogic.canPause then
        recordLogic.recording = not recordLogic.recording
        recordLogic.paused = not recordLogic.paused
    end
end

function recordLogic.stopRecord(recorder)
    if recordLogic.recording or recordLogic.paused then
        local newRecord = require("modules/logic/record"):new(recorder)

        recordLogic.frame = recordLogic.frame - 1
        recordLogic.recording = false
        recordLogic.paused = false
        recordLogic.canPause = false

        local hash = 69420
        local length = 69
        pcall(function () -- GetRecordID is not always available, default values make it igonre the hash inside record.lua
            hash = recordLogic.subject:GetRecordID().hash
            length = recordLogic.subject:GetRecordID().length
        end)

        newRecord.info = {location = recordLogic.getDistrict(), playbackOnText = "Not set", frames = recordLogic.frame, recordedOn = recordLogic.currentSubjectText, name = recordLogic.recordingName, objectID = {hash = hash, length = length}, isVehicle = recordLogic.subject:IsVehicle()}
        newRecord.playbackSettings = {startTrim = 0, endTrim = 0, offset = 0, ignoreRot = false, ignorePos = false, ignoreTime = false, invincible = false, enabled = true, reverse = false, camPitch = true, camRoll = true}

        for i = 1, recordLogic.frame do
            local pos = recordLogic.recordDataPosition[i]
            local rot = recordLogic.recordDataRotation[i]

            table.insert(newRecord.recordData, {frame = i, pos = {x = pos.x, y = pos.y, z = pos.z, w = pos.w}, rot = {i = rot.i, j = rot.j, k = rot.k, r = rot.r}})
        end

        if recordLogic.utils.getLength(recordLogic.timeEvents) > 0 then -- Always add a timeSpeed 0 effect if there are any timeSpeed changes
            local e = newRecord:addEffect("game_timeSpeed")
            e.data.frame = 1
            e.data.amount = 1
        end

        for k, v in pairs(recordLogic.timeEvents) do
            local e = newRecord:addEffect("game_timeSpeed")
            e.data.frame = k
            e.data.amount = v
        end

        newRecord:save()
        recorder.baseUI.arrangeUI.loadRecord(newRecord)
        recorder.baseUI.fileUI.filesData[newRecord.info.name] = nil
        recordLogic.updateOverlay(recorder)
        recorder.hud.state = "Done"
    end
end

function recordLogic.updateOverlay(recorder)
    recorder.hud.subject = recordLogic.currentSubjectText
    recorder.hud.frame = recordLogic.frame
    if recordLogic.recording then
        recorder.hud.state = "Recording..."
    elseif recordLogic.paused then
        recorder.hud.state = "Paused"
    end
end

function recordLogic.setHomePoint()
    if recordLogic.subject ~= nil then
        recordLogic.homePoint = {}
        recordLogic.homePoint.pos = recordLogic.subject:GetWorldPosition()
        recordLogic.homePoint.rot = recordLogic.subject:GetWorldOrientation()
    else
        recordLogic.currentSubjectText = "Set a subject first!"
    end
end

function recordLogic.tpToHome(recorder)
    if recordLogic.homePoint ~= nil then
        Game.GetTeleportationFacility():Teleport(recordLogic.subject, recordLogic.homePoint.pos , GetSingleton('Quaternion'):ToEulerAngles(recordLogic.homePoint.rot))
    else
        recordLogic.currentSubjectText = "Set a homepoint first!"
    end
end

function recordLogic.getDistrict() -- Credits to psiberx for this code: https://github.com/psiberx/cp2077-cet-kit/blob/main/mods/GameUI-WhereAmI/init.lua
    local preventionSystem = Game.GetScriptableSystemsContainer():Get('PreventionSystem')
	local districtManager = preventionSystem.districtManager
    local districtLabel = "No District"

	if districtManager and districtManager:GetCurrentDistrict() then
		local districtId = districtManager:GetCurrentDistrict():GetDistrictID()
		local tweakDb = GetSingleton('gamedataTweakDBInterface')
		local districtRecord = tweakDb:GetDistrictRecord(districtId)
		districtLabel = Game.GetLocalizedText(districtRecord:LocalizedName())
    end

    return districtLabel
end

return recordLogic