device = {}

function device:new(frame, record)
	local o = {}

    o.saveBoxSize = {x = 515, y = 155 * 1.25}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.CPS = require("CPStyling")

    o.data = {
        frame = frame,
        active = true,
        state = true,
        key = "device_power",
        fancyName = "Device | Power",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

    o.types = {
        "GenericDevice",
        "SurveillanceCamera",
        "SecurityTurret",
        "Reflector",
        "ElectricLight",
        "ExitLight",
        "LcdScreen",
        "Computer",
        "Radio",
        "Jukebox",
        "Speaker",
        "TV",
        "ArcadeMachine",
        "PachinkoMachine",
        "CrossingLight",
        "TrafficLight",
        "DropPoint",
        "HoloTable",
        "VendingMachine",
        "BillboardDevice"
    }

	self.__index = self
   	return setmetatable(o, self)
end

function device:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function device:updateCompatible()
    if  self.record.target ~= nil then
		self.compatible = self.miscUtils.has_value(self.types, self.record.target:ToString())
	else
		self.compatible = false
	end
end

function device:draw()
    self:updateCompatible()

	ImGui.BeginChild("device_power_" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Device | Power")

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

    self.data.state = self.CPS.CPToggle("Turn on / off", "Off", "On", self.data.state, 75 , 25)

    ImGui.EndChild()
end

function device:execute()
    self:updateCompatible()

    if self.compatible and self.data.active and self.record.playbackSettings.enabled then

        local PS = self.record.target:GetDevicePS()

        if self.data.state then
            self.record.target:TurnOnDevice()
            self.record.target:ActivateDevice()
            if PS then
                PS:PowerDevice()
            end
        else
            self.record.target:TurnOffDevice()
            self.record.target:DeactivateDevice()
            if PS then
                PS:UnpowerDevice()
            end
        end
    end
end

return device