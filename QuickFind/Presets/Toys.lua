local _, QF = ...

QF.createPreset({
    type = 'TOY',
    name = 'Toys',
    description = 'Adds quick access to all your usable toys',
    all = true,
    getData = function () return {} end,
})
