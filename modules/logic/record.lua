record = {}

function record:new(recorder)
	local o = {}

	o.recorder = recorder
	o.info = nil
	o.currentFrame = 1
	o.executedFrame = 0
	o.playbackSettings = nil
	o.target = nil
	o.recorderObjectID = nil
	o.recordData = {}
	o.effects = {}

	o.pastEffects = {}

	o.posOffset = {x = 0, y = 0, z = 0}
	o.c = 1

	o.miscUtils = require("modules/logic/miscUtils")

	self.__index = self
   	return setmetatable(o, self)
end

function record:load(data)
	self.info = data.info
	self.recordData = data.data
	self.playbackSettings = data.playbackSettings
	self:loadEffects(data.effects)
	if self.info.objectID.hash ~= 69420 then
		self.recorderObjectID = TweakDBID.new(self.info.objectID.hash, self.info.objectID.length)
	end
end

function record:loadEffects(data)
	for _, e in pairs(data) do
		local new = {}
		new = self:addEffect(e.key)
		new.data = e
	end
end

function record:save()
	local saveData = {}

	saveData.effects = {}
	saveData.info = self.info
	saveData.data = self.recordData
	saveData.playbackSettings = self.playbackSettings
	for _, e in pairs(self.effects) do
		table.insert(saveData.effects, e.data)
	end

	self.recorder.config.saveFile(tostring("saves/" .. self.info.name .. ".json"), saveData)

end

function record:setSubject(key)
	if key == "player" then
        self.target = Game.GetPlayer()
        self.info.playbackOnText = "Player"
		self.currentFrame = self.recorder.playback.currentFrame
		self.recorder.playback:jumpToFrame(self.currentFrame)
    elseif key == "lookAt" then
        if Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false) ~= nil then
            self.target = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false)
            self.info.playbackOnText = tostring(self.target:GetDisplayName())
			self.currentFrame = self.recorder.playback.currentFrame	
			self.recorder.playback:jumpToFrame(self.currentFrame)
        end
    elseif key == "mountedVehicle" then
        if Game['GetMountedVehicle;GameObject'](Game.GetPlayer()) ~= nil then
            self.target = Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
            self.info.playbackOnText = tostring(self.target:GetDisplayName())
			self.currentFrame = self.recorder.playback.currentFrame
			self.recorder.playback:jumpToFrame(self.currentFrame)
        end
    elseif key == "clear" then
		self.target = nil
		self.info.playbackOnText = "Not set"
	end

	for _, e in pairs(self.effects) do
		e:updateCompatible()
	end

end

function record:sortEffects()
	table.sort(self.effects, function (a, b) return a.data.frame < b.data.frame end)
end

function record:addEffect(key)
	local e = nil
	self.executedFrame = 0
	if key == "destroy" then
		local module = require("modules/effects/subject_destroy")
		e = module:new(self.currentFrame, self)
	elseif key == "veh_honk" then
		local module = require("modules/effects/veh_honk")
		e = module:new(self.currentFrame, self)
	elseif key == "veh_light" then
		local module = require("modules/effects/veh_light")
		e = module:new(self.currentFrame, self)
	elseif key == "veh_explode" then
		local module = require("modules/effects/veh_explode")
		e = module:new(self.currentFrame, self)
	elseif key == "game_timeSpeed" then
		local module = require("modules/effects/game_timeSpeed")
		e = module:new(self.currentFrame, self)
	elseif key == "game_time" then
		local module = require("modules/effects/game_time")
		e = module:new(self.currentFrame, self)
	elseif key == "subject_clear" then
		local module = require("modules/effects/subject_clear")
		e = module:new(self.currentFrame, self)
	elseif key == "device_power" then
		local module = require("modules/effects/device_power")
		e = module:new(self.currentFrame, self)
	elseif key == "veh_door" then
		local module = require("modules/effects/veh_door")
		e = module:new(self.currentFrame, self)
	elseif key == "veh_window" then
		local module = require("modules/effects/veh_window")
		e = module:new(self.currentFrame, self)
	elseif key == "cam_fov" then
		local module = require("modules/effects/cam_fov")
		e = module:new(self.currentFrame, self)
	elseif key == "subject_offset" then
		local module = require("modules/effects/subject_offset")
		e = module:new(self.currentFrame, self, self.recorder)
	end

	if e ~= nil then
		table.insert(self.effects, e)
		e:execute()
		self.recorder.hud.lastEffect = e.data.fancyName
	end

	return e

end

function record:handleGodMode()
	if self.playbackSettings.invincible then
		if self.target:IsVehicle() then
			local vComp = self.target:GetVehicleComponent()
			self.target:DestructionResetGrid()
			self.target:DestructionResetGlass()
			vComp:RepairVehicle() 
		end
		Game.GetGodModeSystem():AddGodMode(self.target:GetEntityID(), 0, "")
	else
		Game.GetGodModeSystem():RemoveGodMode(self.target:GetEntityID(), 0, "")
	end
end

function record:spawnTarget()
	if self.recorderObjectID ~= nil then
		Game.GetPlayer():SetWarningMessage("Try looking away and back, to make npcs spawn!")
		Game.GetPreventionSpawnSystem():RequestSpawn(self.recorderObjectID, -69, Game.GetPlayer():GetWorldTransform())
	end
end

function record:updateOffset(ofs)
	self.info.frames = self.info.frames - self.playbackSettings.offset
	self.playbackSettings.offset = ofs
	self.info.frames = self.info.frames + self.playbackSettings.offset
	for _, e in pairs(self.effects) do
		e:updateOffset(self.playbackSettings.offset)
	end
end

function record:updateTrimEnd(i)
	self.info.frames = self.info.frames + self.playbackSettings.endTrim
	self.playbackSettings.endTrim = i
	self.info.frames = self.info.frames - self.playbackSettings.endTrim

	if self.info.frames < 5 then -- Make sure there are never less than 5 frames
		self:updateTrimEnd(self.info.frames + i - 5) -- Sets the trim length to the total amount of frames - 5
	end
end

function record:updateTrimStart(i)
	self.info.frames = self.info.frames + self.playbackSettings.startTrim
	self.playbackSettings.startTrim = i
	self.info.frames = self.info.frames - self.playbackSettings.startTrim

	if self.info.frames < 5 then
		self:updateTrimStart(self.info.frames + i - 5)
	end
end

function record:calcPlayFrame(frame)
	local i = frame

	if frame > self.info.frames then
		i = self.info.frames
	end

	if self.playbackSettings.offset ~= 0 and self.playbackSettings.startTrim == 0 then -- Lord fogive me for this ugly piece of crap, this makes sure that offset and startTrim work fine together
		i = math.max(i - self.playbackSettings.offset, 1)
	elseif self.playbackSettings.offset == 0 and self.playbackSettings.startTrim ~= 0 then
		i = i + self.playbackSettings.startTrim
	elseif self.playbackSettings.offset ~= 0 and self.playbackSettings.startTrim ~= 0 then
		if i < self.playbackSettings.offset then
			i = self.playbackSettings.startTrim
		else
			i = i - (self.playbackSettings.offset - self.playbackSettings.startTrim)
		end
	end

	if self.playbackSettings.reverse then
		i = self.info.frames - i + 1 -- +1 Needed, cuz otherwise it will be one frame short
	end

	return i
end

function record:playFrame(frame)
	local i = self:calcPlayFrame(frame)

	if self.playbackSettings.enabled then
		if self.target ~= nil then
			if Game.FindEntityByID(self.target:GetEntityID()) == nil then
				self:setSubject("clear")
			end
		end

		if self.target ~= nil then

			self:handleGodMode()

			local framePos = self.recordData[i]
			local frameRot = self.recordData[i]

			local pos = nil
			local rot = nil

			if self.playbackSettings.ignoreRot then
				rot =  GetSingleton('Quaternion'):ToEulerAngles(self.target:GetWorldPosition())
			else
				rot = GetSingleton('Quaternion'):ToEulerAngles(Quaternion.new(frameRot.rot.i, frameRot.rot.j, frameRot.rot.k, frameRot.rot.r))
			end

			if self.playbackSettings.ignorePos then
				pos = self.target:GetWorldPosition()
			else
				pos = Vector4.new(framePos.pos.x, framePos.pos.y, framePos.pos.z, framePos.pos.w)
			end

			if self.executedFrame ~= self.currentFrame then
				self.executedFrame = self.currentFrame
				for _, e in pairs(self.effects) do
					if e.data.frame == self.currentFrame then
						if e.data.active then
							e:execute()
							self.recorder.hud.lastEffect = e.data.fancyName
						end
					end
				end
			end

			pos.x = pos.x + self.posOffset.x
			pos.y = pos.y + self.posOffset.y
			pos.z = pos.z + self.posOffset.z

			if not (self.playbackSettings.ignoreRot and self.playbackSettings.ignorePos) then
				Game.GetTeleportationFacility():Teleport(self.target, pos , rot)
			end

		end
	end
end

function record:setFrameEdit(frame)
	if self.target ~= nil then
		self.currentFrame = frame
		self.recorder.playback:jumpToFrame(frame)
	end
end

function record:setCurrentFrame(f)
	if f > self.info.frames then
		self.currentFrame = self.info.frames
	else
		self.currentFrame = f
	end
end

return record