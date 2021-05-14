explode = {}

function explode:new(frame, record)
	local o = {} 

    o.saveBoxSize = {x = 515, y = 120}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = true

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.data = {
        frame = frame,
        active = false,
        key = "veh_explode",
        fancyName = "Vehicle | Explode",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

	self.__index = self
   	return setmetatable(o, self)
end

function explode:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function explode:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = self.record.target:IsVehicle()
	else
		self.compatible = false
	end
end

function explode:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_veh_explode" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Vehicle | Explode")

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

    ImGui.EndChild()
end

function explode:execute()
    self:updateCompatible()

	if self.compatible and self.data.active and self.record.playbackSettings.enabled then
		local vPS = self.record.target:GetVehiclePS()
        local vComp = self.record.target:GetVehicleComponent()

        vComp:DestroyVehicle()
        vComp:LoadExplodedState()
        vComp:ExplodeVehicle(Game.GetPlayer())
        vPS:ForcePersistentStateChanged()	
	end
end

return explode