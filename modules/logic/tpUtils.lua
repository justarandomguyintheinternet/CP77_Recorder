tpUtils = {}

function tpUtils.tpTo(subject, position, rotationQ)
    teleportFacility = GetSingleton('gameTeleportationFacility')
    local angles = GetSingleton('Quaternion'):ToEulerAngles(rotationQ)
    local eulerAngles = EulerAngles.new(angles.pitch, angles.yaw, angles.roll)
    teleportFacility:Teleport(subject, position, eulerAngles)
end

return tpUtils