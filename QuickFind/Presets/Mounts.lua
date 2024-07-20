local _, QF = ...

QF.createPreset({
    type = 'MOUNT',
    name = 'Mounts',
    -- False indicates to show all
    all = true,
    getData = function () return {} end,
})
