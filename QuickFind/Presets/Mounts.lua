local _, QF = ...

QF.createPreset({
    type = 'MOUNT',
    name = 'Mounts',
    description = 'Adds quick access for all your learned mounts',
    all = true,
    getData = function () return {} end,
})
