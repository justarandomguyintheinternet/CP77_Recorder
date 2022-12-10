gameTime = {}

function gameTime:new(frame, record)
	local o = {} 

    o.saveBoxSize = {x = 515, y = 170 * 1.25}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.data = {
        frame = frame,
        active = true,
        h = 6,
        m = 0,
        s = 0,
        key = "game_time",
        fancyName = "Game | Time",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

	self.__index = self
   	return setmetatable(o, self)
end

function gameTime:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function gameTime:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = true
	else
		self.compatible = false
	end
end

function gameTime:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_time_" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Game | Time")

    ImGui.Separator()

    ImGui.Text(tostring("Compatible subject: " .. tostring(self.compatible):upper()))
    self.data.active = ImGui.Checkbox("Active", self.data.active)
    self.data.frame, changed = ImGui.InputInt("Activation Frame", self.data.frame, 1, self.record.info.frames)
    if changed then
        if self.data.frame > self.record.info.frames then self.data.frame = self.record.info.frames end
    end
    
    if ImGui.Button("Jump to frame") then
        self.record:setFrameEdit(self.data.frame)
    end
    ImGui.SameLine()
    if ImGui.Button("Use current frame") then
        self.data.frame = self.record.currentFrame
    end
    ImGui.SameLine()
    if ImGui.Button("Test Effect") then
        self:execute()
    end
    ImGui.SameLine()
    if ImGui.Button("Remove") then
        self.miscUtils.removeItem(self.record.effects, self)
    end

    ImGui.Separator()

    ImGui.PushItemWidth(60)
    self.data.h = ImGui.DragInt("##h", self.data.h, 1, 0, 23, "%d H")
    ImGui.SameLine()
    self.data.m = ImGui.DragInt("##m", self.data.m, 1, 0, 59, "%d M")
    ImGui.SameLine()
    self.data.s = ImGui.DragInt("##s", self.data.s, 1, 0, 59, "%d S")
    ImGui.SameLine()
    ImGui.Text("Time")
    ImGui.PopItemWidth()

    if ImGui.Button("Use current Time") then
        local t = Game.GetTimeSystem():GetGameTime()
        self.data.h = Game.GetTimeSystem():GetGameTime():Hours(t)
        self.data.m = Game.GetTimeSystem():GetGameTime():Minutes(t)
        self.data.s = Game.GetTimeSystem():GetGameTime():Seconds(t)
    end

    ImGui.EndChild()
end

function gameTime:execute()
    self:updateCompatible()

    if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        Game.GetTimeSystem():SetGameTimeByHMS(self.data.h, self.data.m, self.data.s)
    end
end

return gameTime