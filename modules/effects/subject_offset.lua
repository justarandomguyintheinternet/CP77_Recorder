offset = {}

function offset:new(frame, record, recorder)
	local o = {}

    o.saveBoxSize = {x = 515, y = 170}
    o.collapsed = false

    o.record = record
    o.recorder = recorder
    o.compatible = false
    o.executeWhenSkipped = true

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.data = {
        frame = frame,
        active = true,
        amount = {x = 0, y = 0, z = 0},
        key = "subject_offset",
        fancyName = "Subject | Position Offset",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

	self.__index = self
   	return setmetatable(o, self)
end

function offset:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function offset:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = true
	else
		self.compatible = false
	end
end

function offset:draw()
    self:updateCompatible()

	ImGui.BeginChild("subject_offset_" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Subject | Position Offset")

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
    self.data.amount.x, changed = ImGui.DragFloat("##x", self.data.amount.x, 0.05, -9999, 9999, "%.2f X")
    if changed then
        self.record:setFrameEdit(self.data.frame)
        self:execute()
    end
    ImGui.SameLine()
    self.data.amount.y, changed = ImGui.DragFloat("##y", self.data.amount.y, 0.05, -9999, 9999, "%.2f Y")
    if changed then
        self.record:setFrameEdit(self.data.frame)
        self:execute()
    end
    ImGui.SameLine()
    self.data.amount.z, changed = ImGui.DragFloat("##z", self.data.amount.z, 0.05, -9999, 9999, "%.2f Z")
    if changed then
        self.record:setFrameEdit(self.data.frame)
        self:execute()
    end
    ImGui.SameLine()
    ImGui.Text(tostring(self.recorder.test))

    if ImGui.Button("Move to player position") then
        local targetPos = self.record.recordData[self.record:calcPlayFrame(self.record.currentFrame)].pos
        self.data.amount.x = Game.GetPlayer():GetWorldPosition().x - targetPos.x
        self.data.amount.y = Game.GetPlayer():GetWorldPosition().y - targetPos.y
        self.data.amount.z = Game.GetPlayer():GetWorldPosition().z - targetPos.z
    end

    ImGui.PopItemWidth()

    ImGui.EndChild()
end

function offset:execute()
    self:updateCompatible()

    if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        self.record.posOffset.x = self.miscUtils.deepcopy(self.data.amount.x)
        self.record.posOffset.y = self.miscUtils.deepcopy(self.data.amount.y)
        self.record.posOffset.z = self.miscUtils.deepcopy(self.data.amount.z)
        print("exec", self.data.amount.z)
        self.recorder.test = self.recorder.test + 1
    end
end

return offset