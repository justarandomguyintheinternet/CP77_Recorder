oM = {
    offsets = {}
}

function oM.exec(recorder, record, amount)
    local id = recorder.baseUI.arrangeUI.miscUtils.indexValue(recorder.baseUI.arrangeUI.loadedRecords, record)
    oM.offsets[id] = amount
end

function oM.getOffset(recorder, record)
    local id = recorder.baseUI.arrangeUI.miscUtils.indexValue(recorder.baseUI.arrangeUI.loadedRecords, record)
    return oM.offsets[id]
end

function oM.resetRecord(recorder, record)
    local id = recorder.baseUI.arrangeUI.miscUtils.indexValue(recorder.baseUI.arrangeUI.loadedRecords, record)
    print(id, "id")
    oM.offsets[id] = {x = 0, y = 0, z = 0}
end

return oM

-- Ugly and temporary solution until i find out why calling the effect from inside the record can change a value on the record,
-- but calling the effect from inside playback cant change a value on the record