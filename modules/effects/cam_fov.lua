fov = {}

function fov:new(frame, record)
	local o = {} 

    o.saveBoxSize = {x = 515, y = 170}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.data = {
        frame = frame,
        active = true,
        amount = Game.GetPlayer():GetFPPCameraComponent():GetFOV(),
        key = "cam_fov",
        fancyName = "Camera | FOV",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

	self.__index = self
   	return setmetatable(o, self)
end

function fov:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function fov:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = true
	else
		self.compatible = false
	end
end

function fov:draw()
    self:updateCompatible()

	ImGui.BeginChild("cam_fov_" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Camera | FOV")

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

    self.data.amount, changed = ImGui.InputFloat("FOV", self.data.amount, 1, 140, "%.1f")
    self.data.amount = math.min(math.max(self.data.amount, 1), 140)

    if ImGui.Button("Use current FOV") then
        self.data.amount = Game.GetPlayer():GetFPPCameraComponent():GetFOV()
    end

    ImGui.EndChild()
end

function fov:execute()
    self:updateCompatible()

    if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        Game.GetPlayer():GetFPPCameraComponent():SetFOV(self.data.amount)
    end
end

return fov