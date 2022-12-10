light = {}

function light:new(frame, record)
	local o = {} 

    o.saveBoxSize = {x = 515, y = 270 * 1.25}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true
    o.offset = nil

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()
    o.CPS = require("CPStyling")
    o.data = {frame = frame,
            active = true,
            on_off = true,
            front = true,
            brake = true,
            blinker = true,
            inTime = 0.25,
            brightness = 1,
            key = "veh_light",
            fancyName = "Vehicle | Lights",
            offset = record.playbackSettings.offset,
            uiOpen = true
        }

	self.__index = self
   	return setmetatable(o, self)
end

function light:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function light:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = self.record.target:IsVehicle()
	else
		self.compatible = false
	end
end

function light:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_veh_light" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Vehicle | Lights")

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
    ImGui.PushID(self.data.frame)
	self.data.on_off = self.CPS.CPToggle("Toggle lights on / off", "Off", "On", self.data.on_off, 75 , 25)
    ImGui.PopID()
    self.data.brightness = ImGui.InputFloat("Brightness", self.data.brightness, 0.01, 15, "%.2f")
    self.data.inTime = ImGui.InputFloat("Fade in / out time", self.data.inTime, 1, 100, "%.2f")
    self.data.front = ImGui.Checkbox("Front Lights", self.data.front)
    self.data.brake = ImGui.Checkbox("Brake Lights", self.data.brake)
    self.data.blinker = ImGui.Checkbox("Blinker Lights", self.data.blinker)

    ImGui.EndChild()
end

function light:execute()
    self:updateCompatible()

	if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        local vController = self.record.target:GetController() 

        if self.data.on_off == true then
            if self.data.front then
                vController:SetLightStrength(1, self.data.brightness, self.data.inTime)
            end
            if self.data.brake then
                vController:SetLightStrength(2, self.data.brightness, self.data.inTime)
            end
            if self.data.blinker then
                vController:SetLightStrength(4, self.data.brightness, self.data.inTime)
            end
        else
            if self.data.front then
                vController:SetLightStrength(1, 0, self.data.inTime)
            end
            if self.data.brake then
                vController:SetLightStrength(2, 0, self.data.inTime)
            end
            if self.data.blinker then
                vController:SetLightStrength(4, 0, self.data.inTime)
            end
        end
	end
end

return light