playback = {}

function playback:new(recorder)
	local o = {}

    o.recorder = recorder
    o.currentFrame = 1
    o.isPlaying = false
    o.isPaused = false

    o.pastEffects = {}

    o.miscUtils = require("modules/logic/miscUtils")

	self.__index = self
   	return setmetatable(o, self)
end

function playback:run()
    for _, v in pairs(self.recorder.baseUI.arrangeUI.loadedRecords) do
        v:setCurrentFrame(self.currentFrame)
        self:play(v)
    end
    if self.isPlaying and not self.isPaused then
        self:jumpToFrame(self.currentFrame)
        self.currentFrame = self.currentFrame + 1
    end
    if self.currentFrame >= self:getLongestRecord() then
        self.isPlaying = false
        self.isPaused = false
    end
end

function playback:getLongestRecord()
    local biggest = 0
    for _, r in pairs(self.recorder.baseUI.arrangeUI.loadedRecords) do
        if r.info.frames > biggest then biggest = r.info.frames end
    end
    return biggest
end

function playback:play(record)
    record:playFrame(self.currentFrame)
end

function playback:startPlayback()
    self.isPlaying = true
    self.isPaused = false
end

function playback:pausePlayback()
    self.isPlaying = not self.isPlaying
    self.isPaused = not self.isPaused
end

function playback:resetPlayback()
    self.isPlaying = false
    self.isPaused = false
    self:jumpToFrame(1)
end

function playback:jumpToFrame(frame)
    frame = math.max(math.min(frame, self:getLongestRecord()), 1)

    local originFrame = self.currentFrame
    if frame < self.currentFrame then
        self.currentFrame = frame
        for _, v in pairs(self.recorder.baseUI.arrangeUI.loadedRecords) do
            self:getLastRecordEffects(v, originFrame)
        end
    elseif frame > self.currentFrame then
            self.currentFrame = frame
            for _, v in pairs(self.recorder.baseUI.arrangeUI.loadedRecords) do
                self:getLastRecordEffects(v, originFrame)
            end
    else
        self.currentFrame = frame
    end
end

function playback:getLastRecordEffects(record, originFrame) -- this piece of shit sucks my ass
    local sortedEffects = {}
    local effectTypes = {}

    sortedEffects = self.miscUtils.deepestCopy(record.effects)
    if #sortedEffects > 1 then
        table.sort(sortedEffects, function (a, b) return a.data.frame > b.data.frame end)
    end

    for _, v in pairs(sortedEffects) do
        if not (v.data.frame > self.currentFrame) then
            if not self.miscUtils.has_value(effectTypes, v.data.key) then
                table.insert(effectTypes, v.data.key)
                --print("Now playing effect: ", v.data.key, " At frame: ", v.data.frame, "Coming from frame: ", originFrame, "New frame is: ", self.currentFrame)

                if originFrame < self.currentFrame then
                    if v.data.frame == self.currentFrame then
                        record.pastEffects[v.data.key] = v.data.frame
                    end
                    if v.data.frame < self.currentFrame and v.data.frame > originFrame then
                        if v.executeWhenSkipped then
                            v:execute()
                            self.recorder.hud.lastEffect = v.data.fancyName
                            record.pastEffects[v.data.key] = v.data.frame
                            --print("New last effect for key: ", v.data.key, " at: ", self.pastEffects[v.data.key])
                        end
                    end
                end

                if originFrame > self.currentFrame then
                    --print("jump backward", v.data.frame, self.pastEffects[v.data.key])
                    if record.pastEffects[v.data.key] ~= v.data.frame then
                        record.pastEffects[v.data.key] = v.data.frame
                        --print("backward playback, frame: ", self.pastEffects[v.data.key])
                        if v.executeWhenSkipped then
                            v:execute()
                            self.recorder.hud.lastEffect = v.data.fancyName
                        end
                    end
                end

            end
        end
    end
end

return playback