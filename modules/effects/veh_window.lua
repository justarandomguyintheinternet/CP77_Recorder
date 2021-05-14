window = {}

function window:new(frame, record)
	local o = {}

    o.saveBoxSize = {x = 515, y = 155}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true
    o.offset = nil

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.CPS = GetMod("CPStyling"):New()

    o.data = {frame = frame,
            active = true,
            state = true,
            key = "veh_window",
            fancyName = "Vehicle | Windows",
            offset = record.playbackSettings.offset,
            uiOpen = true
        }

	self.__index = self
   	return setmetatable(o, self)
end

function window:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function window:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = self.record.target:IsVehicle()
	else
		self.compatible = false
	end
end

function window:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_veh_window" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Vehicle | Windows")

    ImGui.Separator()

	ImGui.Text(tostring("Compatible subject: " .. tostring(self.compatible):upper()))

    self.data.active = ImGui.Checkbox("Active", self.data.active)
    self.data.frame = ImGui.InputInt("Activation Frame", self.data.frame, 1, self.record.info.frames)
    self.data.frame = math.min(self.data.frame, self.record.info.frames)

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

	self.data.state = self.CPS:CPToggle("Action", "Close", "Open", self.data.state, 85 , 25)

    ImGui.EndChild()
end

function window:execute()
    self:updateCompatible()

	if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        local vPS = self.record.target:GetVehiclePS()

        if self.data.state == true then
            vPS:OpenAllVehWindows()
        else
            vPS:CloseAllVehWindows()
        end

	end
end

return window