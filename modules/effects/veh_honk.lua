honk = {}

function honk:new(frame, record)
	local o = {} 

    o.saveBoxSize = {x = 515, y = 170}
    o.collapsed = false

    o.record = record
    o.compatible = false
    o.executeWhenSkipped = false

    o.miscUtils = require("modules/logic/miscUtils")
    o.childId = Game.GetTimeSystem():GetGameTimeStamp() * math.random()

    o.data = {frame = frame,
              honk = true,
              arrivalSfx = false,
              active = true,
              key = "veh_honk",
              fancyName = "Vehicle | Honk and Flash",
              offset = record.playbackSettings.offset,
              uiOpen = true
            }

	self.__index = self
   	return setmetatable(o, self)
end

function honk:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function honk:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = self.record.target:IsVehicle()
	else
		self.compatible = false
	end
end

function honk:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_honk" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Vehicle | Honk and Flash")

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
	self.data.honk = ImGui.Checkbox("Honk and Flash", self.data.honk)
	self.data.arrivalSfx = ImGui.Checkbox("Play summon arrival SFX", self.data.arrivalSfx)

    ImGui.EndChild()
end

function honk:execute()
    self:updateCompatible()

	if self.compatible and self.data.active and self.record.playbackSettings.enabled then
		local vComp = self.record.target:GetVehicleComponent()
		if self.data.honk then
			vComp:HonkAndFlash()
		end
		if self.data.arrivalSfx then
			vComp:PlaySummonArrivalSFX()
		end  	
	end
end

return honk