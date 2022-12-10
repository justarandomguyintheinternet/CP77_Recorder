timeSpeed = {}

function timeSpeed:new(frame, record)
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
        amount = 1,
        ignorePlayer = false,
        key = "game_timeSpeed",
        fancyName = "Game | Time Speed",
        offset = record.playbackSettings.offset,
        uiOpen = true
    }

	self.__index = self
   	return setmetatable(o, self)
end

function timeSpeed:updateOffset(ofs)
    self.data.frame = self.data.frame - self.data.offset
    self.data.offset = ofs
    self.data.frame = self.data.frame + self.data.offset
    self.data.frame = math.max(1, self.data.frame)
end

function timeSpeed:updateCompatible()
    if self.record.target ~= nil then
		self.compatible = true
	else
		self.compatible = false
	end
end

function timeSpeed:draw()
    self:updateCompatible()

	ImGui.BeginChild("effect_timeSpeed_" .. self.childId, self.saveBoxSize.x, self.saveBoxSize.y, true)

    ImGui.Text("Game | Time speed")

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
    self.data.amount = ImGui.InputFloat("Amount", self.data.amount, 0, 50, "%.2f")
	self.data.ignorePlayer = ImGui.Checkbox("Ignore Player", self.data.ignorePlayer)

    ImGui.EndChild()
end

function timeSpeed:execute()
    self:updateCompatible()

    if self.compatible and self.data.active and self.record.playbackSettings.enabled then
        if self.data.ignorePlayer then
            Game.GetTimeSystem():SetIgnoreTimeDilationOnLocalPlayerZero(true)  
        else
            Game.GetTimeSystem():SetIgnoreTimeDilationOnLocalPlayerZero(false)  
        end

        local t = self.data.amount
        if t == 0 then
            t = 0.00001
        end

        if t == 1 then
            t = 0
        end

        Game.SetTimeDilation(t)
    end
end

return timeSpeed